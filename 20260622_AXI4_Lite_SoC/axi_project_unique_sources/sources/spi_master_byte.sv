`timescale 1ns / 1ps

// Parameterized 8-bit SPI master primitive.
// Supports CPOL/CPHA selection, but this project instantiates it as mode 0.
module spi_master_byte #(
    parameter int CLK_DIV_WIDTH = 16
)(
    input  logic                       clk,
    input  logic                       rst,

    input  logic                       start,
    input  logic [CLK_DIV_WIDTH-1:0]   clk_div,
    input  logic                       cpol,
    input  logic                       cpha,
    input  logic [7:0]                 tx_data,

    input  logic                       miso,
    output logic [7:0]                 rx_data,
    output logic                       busy,
    output logic                       done,

    output logic                       sclk,
    output logic                       mosi,
    output logic                       ss_n
);

    // One start pulse transfers exactly one byte and then raises done.
    typedef enum logic [1:0] {
        S_IDLE,
        S_ASSERT_SS,
        S_TRANSFER,
        S_DONE
    } state_e;

    state_e c_state, n_state;

    // Registered transfer context. CPOL/CPHA and clk_div are latched at start
    // so changes on the inputs cannot disturb an active byte transfer.
    logic [CLK_DIV_WIDTH-1:0] clk_cnt_reg,   clk_cnt_next;
    logic [CLK_DIV_WIDTH-1:0] clk_div_reg,   clk_div_next;
    logic [7:0]               tx_shift_reg,  tx_shift_next;
    logic [7:0]               rx_shift_reg,  rx_shift_next;
    logic [7:0]               rx_data_reg,   rx_data_next;
    logic [2:0]               bit_idx_reg,   bit_idx_next;
    logic                     edge_phase_reg, edge_phase_next;
    logic                     cpol_reg,      cpol_next;
    logic                     cpha_reg,      cpha_next;
    logic                     sclk_reg,      sclk_next;
    logic                     mosi_reg,      mosi_next;
    logic                     ss_n_reg,      ss_n_next;
    logic                     busy_reg,      busy_next;
    logic                     done_reg,      done_next;

    assign rx_data = rx_data_reg;
    assign busy    = busy_reg;
    assign done    = done_reg;
    assign sclk    = sclk_reg;
    assign mosi    = mosi_reg;
    assign ss_n    = ss_n_reg;

    // State and datapath registers.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state        <= S_IDLE;
            clk_cnt_reg    <= '0;
            clk_div_reg    <= '0;
            tx_shift_reg   <= 8'h00;
            rx_shift_reg   <= 8'h00;
            rx_data_reg    <= 8'h00;
            bit_idx_reg    <= 3'd0;
            edge_phase_reg <= 1'b0;
            cpol_reg       <= 1'b0;
            cpha_reg       <= 1'b0;
            sclk_reg       <= 1'b0;
            mosi_reg       <= 1'b1;
            ss_n_reg       <= 1'b1;
            busy_reg       <= 1'b0;
            done_reg       <= 1'b0;
        end
        else begin
            c_state        <= n_state;
            clk_cnt_reg    <= clk_cnt_next;
            clk_div_reg    <= clk_div_next;
            tx_shift_reg   <= tx_shift_next;
            rx_shift_reg   <= rx_shift_next;
            rx_data_reg    <= rx_data_next;
            bit_idx_reg    <= bit_idx_next;
            edge_phase_reg <= edge_phase_next;
            cpol_reg       <= cpol_next;
            cpha_reg       <= cpha_next;
            sclk_reg       <= sclk_next;
            mosi_reg       <= mosi_next;
            ss_n_reg       <= ss_n_next;
            busy_reg       <= busy_next;
            done_reg       <= done_next;
        end
    end

    // SPI edge scheduler and shift-register control.
    always_comb begin
        n_state         = c_state;
        clk_cnt_next    = clk_cnt_reg;
        clk_div_next    = clk_div_reg;
        tx_shift_next   = tx_shift_reg;
        rx_shift_next   = rx_shift_reg;
        rx_data_next    = rx_data_reg;
        bit_idx_next    = bit_idx_reg;
        edge_phase_next = edge_phase_reg;
        cpol_next       = cpol_reg;
        cpha_next       = cpha_reg;
        sclk_next       = sclk_reg;
        mosi_next       = mosi_reg;
        ss_n_next       = ss_n_reg;
        busy_next       = busy_reg;
        done_next       = 1'b0;

        case (c_state)
            S_IDLE: begin
                // Idle bus: SS high, SCLK parked at CPOL, MOSI high.
                clk_cnt_next    = '0;
                bit_idx_next    = 3'd0;
                edge_phase_next = 1'b0;
                busy_next       = 1'b0;
                ss_n_next       = 1'b1;
                sclk_next       = cpol;
                mosi_next       = 1'b1;

                if (start) begin
                    n_state         = S_ASSERT_SS;
                    clk_div_next    = clk_div;
                    cpol_next       = cpol;
                    cpha_next       = cpha;
                    rx_shift_next   = 8'h00;
                    rx_data_next    = 8'h00;
                    bit_idx_next    = 3'd0;
                    edge_phase_next = 1'b0;
                    busy_next       = 1'b1;
                    ss_n_next       = 1'b0;
                    sclk_next       = cpol;

                    // CPHA=0 requires the first MOSI bit to be valid before
                    // the first leading/sample edge. CPHA=1 launches it on
                    // the first leading edge instead.
                    if (!cpha) begin
                        mosi_next     = tx_data[7];
                        tx_shift_next = {tx_data[6:0], 1'b0};
                    end
                    else begin
                        mosi_next     = 1'b1;
                        tx_shift_next = tx_data;
                    end
                end
            end

            S_ASSERT_SS: begin
                // One-cycle guard after SS falls before the first SCLK edge.
                n_state         = S_TRANSFER;
                clk_cnt_next    = '0;
                edge_phase_next = 1'b0;
                busy_next       = 1'b1;
                ss_n_next       = 1'b0;
                sclk_next       = cpol_reg;
            end

            S_TRANSFER: begin
                // Toggle SCLK whenever the divider expires. edge_phase_reg
                // identifies leading vs trailing edge for CPHA behavior.
                busy_next = 1'b1;
                ss_n_next = 1'b0;

                if (clk_cnt_reg >= clk_div_reg) begin
                    clk_cnt_next    = '0;
                    sclk_next       = ~sclk_reg;
                    edge_phase_next = ~edge_phase_reg;

                    if (!edge_phase_reg) begin
                        // Leading edge:
                        // CPHA=0 samples MISO.
                        // CPHA=1 launches/updates MOSI.
                        if (!cpha_reg) begin
                            rx_shift_next = {rx_shift_reg[6:0], miso};
                        end
                        else begin
                            mosi_next     = tx_shift_reg[7];
                            tx_shift_next = {tx_shift_reg[6:0], 1'b0};
                        end
                    end
                    else begin
                        // Trailing edge:
                        // CPHA=0 launches/updates MOSI.
                        // CPHA=1 samples MISO.
                        if (!cpha_reg) begin
                            if (bit_idx_reg == 3'd7) begin
                                n_state      = S_DONE;
                                rx_data_next = rx_shift_reg;
                                busy_next    = 1'b0;
                                done_next    = 1'b1;
                                ss_n_next    = 1'b1;
                                sclk_next    = cpol_reg;
                            end
                            else begin
                                bit_idx_next  = bit_idx_reg + 1'b1;
                                mosi_next     = tx_shift_reg[7];
                                tx_shift_next = {tx_shift_reg[6:0], 1'b0};
                            end
                        end
                        else begin
                            rx_shift_next = {rx_shift_reg[6:0], miso};
                            if (bit_idx_reg == 3'd7) begin
                                n_state      = S_DONE;
                                rx_data_next = {rx_shift_reg[6:0], miso};
                                busy_next    = 1'b0;
                                done_next    = 1'b1;
                                ss_n_next    = 1'b1;
                                sclk_next    = cpol_reg;
                            end
                            else begin
                                bit_idx_next = bit_idx_reg + 1'b1;
                            end
                        end
                    end
                end
                else begin
                    clk_cnt_next = clk_cnt_reg + 1'b1;
                end
            end

            S_DONE: begin
                // Present done for one clk, then return to idle bus levels.
                n_state         = S_IDLE;
                clk_cnt_next    = '0;
                edge_phase_next = 1'b0;
                busy_next       = 1'b0;
                ss_n_next       = 1'b1;
                sclk_next       = cpol_reg;
                mosi_next       = 1'b1;
            end

            default: begin
                n_state = S_IDLE;
            end
        endcase
    end

endmodule
