`timescale 1ns / 1ps

// Byte-level I2C slave engine.
// The core owns START/STOP detection, address matching, byte receive,
// byte transmit, and ACK/NACK bit timing. Higher-level protocol logic decides
// whether matched addresses and received bytes should be ACKed.
module i2c_slave_core #(
    parameter logic [6:0] SLAVE_ADDR = 7'h42
) (
    input  logic       clk,
    input  logic       rst,

    input  logic       scl_in,
    input  logic       sda_in,
    output logic       sda_drive_low,

    input  logic       addr_ack,
    output logic       addr_seen_pulse,
    output logic       addr_match,
    output logic       addr_read,

    output logic [7:0] rx_byte,
    output logic       rx_byte_valid,
    input  logic       rx_ack,

    input  logic [7:0] tx_byte,
    output logic       tx_byte_done,
    output logic       tx_master_ack,

    output logic       start_pulse,
    output logic       stop_pulse,
    output logic       busy
);

    typedef enum logic [2:0] {
        S_IDLE,
        S_RX_ADDR,
        S_ACK_ADDR,
        S_RX_BYTE,
        S_ACK_RX,
        S_TX_BYTE,
        S_TX_ACK,
        S_IGNORE
    } state_e;

    state_e c_state, n_state;

    logic scl_meta_reg, scl_meta_next;
    logic scl_sync_reg, scl_sync_next;
    logic scl_prev_reg, scl_prev_next;
    logic sda_meta_reg, sda_meta_next;
    logic sda_sync_reg, sda_sync_next;
    logic sda_prev_reg, sda_prev_next;

    logic [7:0] rx_shift_reg, rx_shift_next;
    logic [7:0] rx_byte_reg, rx_byte_next;
    logic [2:0] bit_cnt_reg, bit_cnt_next;
    logic [1:0] ack_phase_reg, ack_phase_next;
    logic       addr_read_reg, addr_read_next;
    logic       addr_match_reg, addr_match_next;
    logic       sda_drive_reg, sda_drive_next;
    logic       addr_seen_reg, addr_seen_next;
    logic       rx_valid_reg, rx_valid_next;
    logic       tx_done_reg, tx_done_next;
    logic       tx_master_ack_reg, tx_master_ack_next;
    logic       start_reg, start_next;
    logic       stop_reg, stop_next;

    logic       scl_rise;
    logic       scl_fall;
    logic       start_detect;
    logic       stop_detect;
    logic [7:0] rx_byte_complete;

    assign scl_rise = !scl_prev_reg && scl_sync_reg;
    assign scl_fall = scl_prev_reg && !scl_sync_reg;

    assign start_detect = scl_sync_reg && sda_prev_reg && !sda_sync_reg && !sda_drive_reg;
    assign stop_detect  = scl_sync_reg && !sda_prev_reg && sda_sync_reg && !sda_drive_reg;

    assign rx_byte_complete = {
        rx_shift_reg[6],
        rx_shift_reg[5],
        rx_shift_reg[4],
        rx_shift_reg[3],
        rx_shift_reg[2],
        rx_shift_reg[1],
        rx_shift_reg[0],
        sda_sync_reg
    };

    assign sda_drive_low  = sda_drive_reg;
    assign addr_seen_pulse = addr_seen_reg;
    assign addr_match     = addr_match_reg;
    assign addr_read      = addr_read_reg;
    assign rx_byte        = rx_byte_reg;
    assign rx_byte_valid  = rx_valid_reg;
    assign tx_byte_done   = tx_done_reg;
    assign tx_master_ack  = tx_master_ack_reg;
    assign start_pulse    = start_reg;
    assign stop_pulse     = stop_reg;
    assign busy           = (c_state != S_IDLE);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state           <= S_IDLE;
            scl_meta_reg      <= 1'b1;
            scl_sync_reg      <= 1'b1;
            scl_prev_reg      <= 1'b1;
            sda_meta_reg      <= 1'b1;
            sda_sync_reg      <= 1'b1;
            sda_prev_reg      <= 1'b1;
            rx_shift_reg      <= 8'h00;
            rx_byte_reg       <= 8'h00;
            bit_cnt_reg       <= 3'd0;
            ack_phase_reg     <= 2'd0;
            addr_read_reg     <= 1'b0;
            addr_match_reg    <= 1'b0;
            sda_drive_reg     <= 1'b0;
            addr_seen_reg     <= 1'b0;
            rx_valid_reg      <= 1'b0;
            tx_done_reg       <= 1'b0;
            tx_master_ack_reg <= 1'b0;
            start_reg         <= 1'b0;
            stop_reg          <= 1'b0;
        end
        else begin
            c_state           <= n_state;
            scl_meta_reg      <= scl_meta_next;
            scl_sync_reg      <= scl_sync_next;
            scl_prev_reg      <= scl_prev_next;
            sda_meta_reg      <= sda_meta_next;
            sda_sync_reg      <= sda_sync_next;
            sda_prev_reg      <= sda_prev_next;
            rx_shift_reg      <= rx_shift_next;
            rx_byte_reg       <= rx_byte_next;
            bit_cnt_reg       <= bit_cnt_next;
            ack_phase_reg     <= ack_phase_next;
            addr_read_reg     <= addr_read_next;
            addr_match_reg    <= addr_match_next;
            sda_drive_reg     <= sda_drive_next;
            addr_seen_reg     <= addr_seen_next;
            rx_valid_reg      <= rx_valid_next;
            tx_done_reg       <= tx_done_next;
            tx_master_ack_reg <= tx_master_ack_next;
            start_reg         <= start_next;
            stop_reg          <= stop_next;
        end
    end

    always_comb begin
        n_state            = c_state;
        scl_meta_next      = scl_in;
        scl_sync_next      = scl_meta_reg;
        scl_prev_next      = scl_sync_reg;
        sda_meta_next      = sda_in;
        sda_sync_next      = sda_meta_reg;
        sda_prev_next      = sda_sync_reg;
        rx_shift_next      = rx_shift_reg;
        rx_byte_next       = rx_byte_reg;
        bit_cnt_next       = bit_cnt_reg;
        ack_phase_next     = ack_phase_reg;
        addr_read_next     = addr_read_reg;
        addr_match_next    = addr_match_reg;
        sda_drive_next     = sda_drive_reg;
        addr_seen_next     = 1'b0;
        rx_valid_next      = 1'b0;
        tx_done_next       = 1'b0;
        tx_master_ack_next = tx_master_ack_reg;
        start_next         = 1'b0;
        stop_next          = 1'b0;

        if (stop_detect) begin
            n_state         = S_IDLE;
            rx_shift_next   = 8'h00;
            bit_cnt_next    = 3'd0;
            ack_phase_next  = 2'd0;
            addr_read_next  = 1'b0;
            addr_match_next = 1'b0;
            sda_drive_next  = 1'b0;
            stop_next       = 1'b1;
        end
        else if (start_detect) begin
            n_state         = S_RX_ADDR;
            rx_shift_next   = 8'h00;
            bit_cnt_next    = 3'd0;
            ack_phase_next  = 2'd0;
            addr_read_next  = 1'b0;
            addr_match_next = 1'b0;
            sda_drive_next  = 1'b0;
            start_next      = 1'b1;
        end
        else begin
            case (c_state)
                S_IDLE: begin
                    sda_drive_next = 1'b0;
                    bit_cnt_next   = 3'd0;
                    ack_phase_next = 2'd0;
                end

                S_RX_ADDR: begin
                    sda_drive_next = 1'b0;

                    if (scl_rise) begin
                        rx_shift_next = rx_byte_complete;

                        if (bit_cnt_reg == 3'd7) begin
                            rx_byte_next    = rx_byte_complete;
                            addr_read_next  = rx_byte_complete[0];
                            addr_match_next = (rx_byte_complete[7:1] == SLAVE_ADDR);
                            addr_seen_next  = 1'b1;
                            bit_cnt_next    = 3'd0;
                            ack_phase_next  = 2'd0;

                            if (rx_byte_complete[7:1] == SLAVE_ADDR) begin
                                n_state = S_ACK_ADDR;
                            end
                            else begin
                                n_state = S_IGNORE;
                            end
                        end
                        else begin
                            bit_cnt_next = bit_cnt_reg + 3'd1;
                        end
                    end
                end

                S_ACK_ADDR: begin
                    if (ack_phase_reg == 2'd0) begin
                        if (scl_fall) begin
                            sda_drive_next = addr_ack ? 1'b1 : 1'b0;
                            ack_phase_next = 2'd1;
                        end
                    end
                    else if (ack_phase_reg == 2'd1) begin
                        if (scl_rise) begin
                            ack_phase_next = 2'd2;
                        end
                    end
                    else begin
                        if (scl_fall) begin
                            sda_drive_next = 1'b0;
                            ack_phase_next = 2'd0;
                            bit_cnt_next   = 3'd0;
                            rx_shift_next  = 8'h00;

                            if (!addr_ack) begin
                                n_state = S_IGNORE;
                            end
                            else if (addr_read_reg) begin
                                sda_drive_next = ~tx_byte[7];
                                n_state = S_TX_BYTE;
                            end
                            else begin
                                n_state = S_RX_BYTE;
                            end
                        end
                    end
                end

                S_RX_BYTE: begin
                    sda_drive_next = 1'b0;

                    if (scl_rise) begin
                        rx_shift_next = rx_byte_complete;

                        if (bit_cnt_reg == 3'd7) begin
                            rx_byte_next   = rx_byte_complete;
                            rx_valid_next  = 1'b1;
                            bit_cnt_next   = 3'd0;
                            ack_phase_next = 2'd0;
                            n_state        = S_ACK_RX;
                        end
                        else begin
                            bit_cnt_next = bit_cnt_reg + 3'd1;
                        end
                    end
                end

                S_ACK_RX: begin
                    if (ack_phase_reg == 2'd0) begin
                        if (scl_fall) begin
                            sda_drive_next = rx_ack ? 1'b1 : 1'b0;
                            ack_phase_next = 2'd1;
                        end
                    end
                    else if (ack_phase_reg == 2'd1) begin
                        if (scl_rise) begin
                            ack_phase_next = 2'd2;
                        end
                    end
                    else begin
                        if (scl_fall) begin
                            sda_drive_next = 1'b0;
                            ack_phase_next = 2'd0;
                            rx_shift_next  = 8'h00;
                            bit_cnt_next   = 3'd0;
                            n_state        = rx_ack ? S_RX_BYTE : S_IGNORE;
                        end
                    end
                end

                S_TX_BYTE: begin
                    if (scl_fall) begin
                        if (bit_cnt_reg == 3'd7) begin
                            sda_drive_next = 1'b0;
                            bit_cnt_next   = 3'd0;
                            n_state        = S_TX_ACK;
                        end
                        else begin
                            bit_cnt_next = bit_cnt_reg + 3'd1;

                            case (bit_cnt_reg)
                                3'd0: sda_drive_next = ~tx_byte[6];
                                3'd1: sda_drive_next = ~tx_byte[5];
                                3'd2: sda_drive_next = ~tx_byte[4];
                                3'd3: sda_drive_next = ~tx_byte[3];
                                3'd4: sda_drive_next = ~tx_byte[2];
                                3'd5: sda_drive_next = ~tx_byte[1];
                                3'd6: sda_drive_next = ~tx_byte[0];
                                default: sda_drive_next = 1'b0;
                            endcase
                        end
                    end
                end

                S_TX_ACK: begin
                    sda_drive_next = 1'b0;

                    if (scl_rise) begin
                        tx_master_ack_next = !sda_sync_reg;
                        tx_done_next       = 1'b1;
                    end

                    if (scl_fall) begin
                        bit_cnt_next = 3'd0;

                        if (tx_master_ack_reg) begin
                            sda_drive_next = ~tx_byte[7];
                            n_state        = S_TX_BYTE;
                        end
                        else begin
                            n_state = S_IGNORE;
                        end
                    end
                end

                S_IGNORE: begin
                    sda_drive_next = 1'b0;
                end

                default: begin
                    n_state         = S_IDLE;
                    rx_shift_next   = 8'h00;
                    bit_cnt_next    = 3'd0;
                    ack_phase_next  = 2'd0;
                    addr_read_next  = 1'b0;
                    addr_match_next = 1'b0;
                    sda_drive_next  = 1'b0;
                end
            endcase
        end
    end

endmodule
