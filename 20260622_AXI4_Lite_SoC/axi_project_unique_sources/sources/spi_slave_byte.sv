`timescale 1ns / 1ps

// Synchronous 8-bit SPI slave byte engine.
// Asynchronous SPI pins are synchronized into clk before edge detection.
module spi_slave_byte (
    input  logic       clk,
    input  logic       rst,

    input  logic       cpol,
    input  logic       cpha,

    input  logic [7:0] tx_data,
    input  logic       tx_load,

    output logic [7:0] rx_data,
    output logic       rx_data_valid,
    output logic       byte_done,
    output logic       busy,

    input  logic       spi_sclk,
    input  logic       spi_mosi,
    input  logic       spi_ss_n,

    output logic       miso_o,
    output logic       miso_oe
);

    // Last bit index in one 8-bit transfer.
    localparam logic [2:0] BIT_LAST = 3'd7;

    // S_SELECTED remains active while chip select is low.
    typedef enum logic {
        S_IDLE,
        S_SELECTED
    } state_e;

    state_e c_state, n_state;

    // Two-stage synchronizers for SPI inputs and delayed SCLK for edges.
    logic       sclk_meta_reg,  sclk_meta_next;
    logic       sclk_sync_reg,  sclk_sync_next;
    logic       sclk_prev_reg,  sclk_prev_next;
    logic       mosi_meta_reg,  mosi_meta_next;
    logic       mosi_sync_reg,  mosi_sync_next;
    logic       ss_meta_reg,    ss_meta_next;
    logic       ss_sync_reg,    ss_sync_next;

    // Transfer context and shift registers.
    logic       cpol_reg,       cpol_next;
    logic       cpha_reg,       cpha_next;
    logic [2:0] bit_idx_reg,    bit_idx_next;
    logic [7:0] tx_buffer_reg,  tx_buffer_next;
    logic [7:0] tx_shift_reg,   tx_shift_next;
    logic [7:0] rx_shift_reg,   rx_shift_next;
    logic [7:0] rx_data_reg,    rx_data_next;
    logic       rx_valid_reg,   rx_valid_next;
    logic       byte_done_reg,  byte_done_next;
    logic       busy_reg,       busy_next;
    logic       miso_o_reg,     miso_o_next;
    logic       miso_oe_reg,    miso_oe_next;

    // Derived SPI edge strobes in the local clk domain.
    logic       sclk_rise;
    logic       sclk_fall;
    logic       leading_edge;
    logic       trailing_edge;
    logic       sample_edge;
    logic       update_edge;

    assign sclk_rise    =  sclk_sync_reg & ~sclk_prev_reg;
    assign sclk_fall    = ~sclk_sync_reg &  sclk_prev_reg;
    // Leading/trailing are defined relative to CPOL, then CPHA selects which
    // edge samples MOSI and which edge updates MISO.
    assign leading_edge = cpol_reg ? sclk_fall : sclk_rise;
    assign trailing_edge = cpol_reg ? sclk_rise : sclk_fall;
    assign sample_edge  = cpha_reg ? trailing_edge : leading_edge;
    assign update_edge  = cpha_reg ? leading_edge : trailing_edge;

    assign rx_data       = rx_data_reg;
    assign rx_data_valid = rx_valid_reg;
    assign byte_done     = byte_done_reg;
    assign busy          = busy_reg;
    assign miso_o        = miso_o_reg;

    // MISO output-enable is synchronously controlled, then immediately gated
    // by raw SS_n so the output driver is disabled when the external master
    // drives chip select high.
    assign miso_oe = miso_oe_reg & ~spi_ss_n;

    // State, synchronizer, and datapath registers.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state       <= S_IDLE;
            sclk_meta_reg <= 1'b0;
            sclk_sync_reg <= 1'b0;
            sclk_prev_reg <= 1'b0;
            mosi_meta_reg <= 1'b0;
            mosi_sync_reg <= 1'b0;
            ss_meta_reg   <= 1'b1;
            ss_sync_reg   <= 1'b1;
            cpol_reg      <= 1'b0;
            cpha_reg      <= 1'b0;
            bit_idx_reg   <= 3'd0;
            tx_buffer_reg <= 8'h00;
            tx_shift_reg  <= 8'h00;
            rx_shift_reg  <= 8'h00;
            rx_data_reg   <= 8'h00;
            rx_valid_reg  <= 1'b0;
            byte_done_reg <= 1'b0;
            busy_reg      <= 1'b0;
            miso_o_reg    <= 1'b0;
            miso_oe_reg   <= 1'b0;
        end
        else begin
            c_state       <= n_state;
            sclk_meta_reg <= sclk_meta_next;
            sclk_sync_reg <= sclk_sync_next;
            sclk_prev_reg <= sclk_prev_next;
            mosi_meta_reg <= mosi_meta_next;
            mosi_sync_reg <= mosi_sync_next;
            ss_meta_reg   <= ss_meta_next;
            ss_sync_reg   <= ss_sync_next;
            cpol_reg      <= cpol_next;
            cpha_reg      <= cpha_next;
            bit_idx_reg   <= bit_idx_next;
            tx_buffer_reg <= tx_buffer_next;
            tx_shift_reg  <= tx_shift_next;
            rx_shift_reg  <= rx_shift_next;
            rx_data_reg   <= rx_data_next;
            rx_valid_reg  <= rx_valid_next;
            byte_done_reg <= byte_done_next;
            busy_reg      <= busy_next;
            miso_o_reg    <= miso_o_next;
            miso_oe_reg   <= miso_oe_next;
        end
    end

    // Byte receive/transmit control. rx_data_valid and byte_done pulse for
    // one clk when the eighth bit has been sampled.
    always_comb begin
        n_state       = c_state;

        // 2FF synchronizers on asynchronous SPI inputs, plus one delayed
        // SCLK sample used by synchronous edge detection.
        sclk_meta_next = spi_sclk;
        sclk_sync_next = sclk_meta_reg;
        sclk_prev_next = sclk_sync_reg;
        mosi_meta_next = spi_mosi;
        mosi_sync_next = mosi_meta_reg;
        ss_meta_next   = spi_ss_n;
        ss_sync_next   = ss_meta_reg;

        cpol_next      = cpol_reg;
        cpha_next      = cpha_reg;
        bit_idx_next   = bit_idx_reg;
        tx_buffer_next = tx_buffer_reg;
        tx_shift_next  = tx_shift_reg;
        rx_shift_next  = rx_shift_reg;
        rx_data_next   = rx_data_reg;
        rx_valid_next  = 1'b0;
        byte_done_next = 1'b0;
        busy_next      = busy_reg;
        miso_o_next    = miso_o_reg;
        miso_oe_next   = miso_oe_reg;

        if (tx_load) begin
            tx_buffer_next = tx_data;
        end

        case (c_state)
            S_IDLE: begin
                // Arm MISO and latch mode when SS_n goes active low.
                busy_next     = 1'b0;
                miso_oe_next  = 1'b0;
                bit_idx_next  = 3'd0;
                rx_shift_next = 8'h00;

                if (!ss_sync_reg) begin
                    n_state      = S_SELECTED;
                    cpol_next    = cpol;
                    cpha_next    = cpha;
                    busy_next    = 1'b1;
                    miso_oe_next = 1'b1;
                    bit_idx_next = 3'd0;

                    // CPHA=0: MISO bit 7 must be valid before the first
                    // leading/sample edge. CPHA=1 launches bit 7 on the
                    // first leading/update edge.
                    if (!cpha) begin
                        miso_o_next   = tx_buffer_next[7];
                        tx_shift_next = {tx_buffer_next[6:0], 1'b0};
                    end
                    else begin
                        miso_o_next   = 1'b0;
                        tx_shift_next = tx_buffer_next;
                    end
                end
            end

            S_SELECTED: begin
                // Shift MOSI on sample edges and update MISO on update edges.
                busy_next    = 1'b1;
                miso_oe_next = 1'b1;

                if (sample_edge) begin
                    rx_shift_next = {rx_shift_reg[6:0], mosi_sync_reg};

                    if (bit_idx_reg == BIT_LAST) begin
                        rx_data_next   = {rx_shift_reg[6:0], mosi_sync_reg};
                        rx_valid_next  = 1'b1;
                        byte_done_next = 1'b1;
                        bit_idx_next   = 3'd0;
                        tx_shift_next  = tx_buffer_next;
                    end
                    else begin
                        bit_idx_next = bit_idx_reg + 1'b1;
                    end
                end

                if (update_edge) begin
                    // CPHA=0 reaches this branch on trailing edges after
                    // each sample. CPHA=1 reaches it on leading edges before
                    // each sample.
                    if (tx_load && !cpha_reg) begin
                        miso_o_next   = tx_data[7];
                        tx_shift_next = {tx_data[6:0], 1'b0};
                    end
                    else begin
                        miso_o_next   = tx_shift_reg[7];
                        tx_shift_next = {tx_shift_reg[6:0], 1'b0};
                    end
                end

                if (tx_load && !sample_edge && !update_edge) begin
                    if (!cpha_reg) begin
                        miso_o_next   = tx_data[7];
                        tx_shift_next = tx_data;
                    end
                    else begin
                        tx_shift_next = tx_data;
                    end
                end

                // End the byte session as soon as SS_n is released.
                if (ss_sync_reg) begin
                    n_state      = S_IDLE;
                    busy_next    = 1'b0;
                    miso_oe_next = 1'b0;
                    bit_idx_next = 3'd0;
                    rx_shift_next = 8'h00;
                    tx_shift_next = tx_buffer_next;
                end
            end

            default: begin
                n_state      = S_IDLE;
                busy_next    = 1'b0;
                miso_oe_next = 1'b0;
                bit_idx_next = 3'd0;
            end
        endcase
    end

endmodule
