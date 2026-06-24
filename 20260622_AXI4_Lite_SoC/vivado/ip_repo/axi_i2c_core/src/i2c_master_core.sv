`timescale 1ns / 1ps

module i2c_master_core #(
    parameter int CLK_HZ = 100_000_000,
    parameter int I2C_HZ = 100_000
) (
    input  logic       clk,
    input  logic       rst,

    input  logic       cmd_valid,
    input  logic [2:0] cmd,
    input  logic [7:0] tx_byte,
    input  logic       read_ack,

    output logic       cmd_ready,
    output logic       done,
    output logic       busy,
    output logic       nack,
    output logic [7:0] rx_byte,

    output logic       scl_drive_low,
    output logic       sda_drive_low,
    input  logic       scl_in,
    input  logic       sda_in
);

    localparam logic [2:0] CMD_START      = 3'd0;
    localparam logic [2:0] CMD_STOP       = 3'd1;
    localparam logic [2:0] CMD_WRITE_BYTE = 3'd2;
    localparam logic [2:0] CMD_READ_BYTE  = 3'd3;

    localparam int RAW_QUARTER_PERIOD = CLK_HZ / (I2C_HZ * 4);
    localparam int QUARTER_PERIOD     = (RAW_QUARTER_PERIOD < 1) ? 1 : RAW_QUARTER_PERIOD;
    localparam int CNT_WIDTH          = (QUARTER_PERIOD <= 1) ? 1 : $clog2(QUARTER_PERIOD);

    typedef enum logic [2:0] {
        S_IDLE,
        S_START,
        S_STOP,
        S_WRITE_BIT,
        S_WRITE_ACK,
        S_READ_BIT,
        S_READ_ACK
    } state_e;

    state_e c_state, n_state;

    logic [CNT_WIDTH-1:0] cnt_reg, cnt_next;
    logic [1:0]           phase_reg, phase_next;
    logic [2:0]           bit_cnt_reg, bit_cnt_next;
    logic [7:0]           tx_shift_reg, tx_shift_next;
    logic [7:0]           rx_shift_reg, rx_shift_next;
    logic [7:0]           rx_byte_reg, rx_byte_next;
    logic                 read_ack_reg, read_ack_next;
    logic                 scl_drive_reg, scl_drive_next;
    logic                 sda_drive_reg, sda_drive_next;
    logic                 bus_active_reg, bus_active_next;
    logic                 repeated_start_reg, repeated_start_next;
    logic                 done_reg, done_next;
    logic                 nack_reg, nack_next;

    logic                 quarter_done;
    logic                 scl_sample_unused;

    assign quarter_done     = (cnt_reg == (QUARTER_PERIOD - 1));
    assign scl_sample_unused = scl_in;

    assign cmd_ready     = (c_state == S_IDLE);
    assign done          = done_reg;
    assign busy          = bus_active_reg || (c_state != S_IDLE);
    assign nack          = nack_reg;
    assign rx_byte       = rx_byte_reg;
    assign scl_drive_low = scl_drive_reg;
    assign sda_drive_low = sda_drive_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            c_state        <= S_IDLE;
            cnt_reg        <= '0;
            phase_reg      <= 2'd0;
            bit_cnt_reg    <= 3'd0;
            tx_shift_reg   <= 8'h00;
            rx_shift_reg   <= 8'h00;
            rx_byte_reg    <= 8'h00;
            read_ack_reg   <= 1'b0;
            scl_drive_reg  <= 1'b0;
            sda_drive_reg  <= 1'b0;
            bus_active_reg <= 1'b0;
            repeated_start_reg <= 1'b0;
            done_reg       <= 1'b0;
            nack_reg       <= 1'b0;
        end
        else begin
            c_state        <= n_state;
            cnt_reg        <= cnt_next;
            phase_reg      <= phase_next;
            bit_cnt_reg    <= bit_cnt_next;
            tx_shift_reg   <= tx_shift_next;
            rx_shift_reg   <= rx_shift_next;
            rx_byte_reg    <= rx_byte_next;
            read_ack_reg   <= read_ack_next;
            scl_drive_reg  <= scl_drive_next;
            sda_drive_reg  <= sda_drive_next;
            bus_active_reg <= bus_active_next;
            repeated_start_reg <= repeated_start_next;
            done_reg       <= done_next;
            nack_reg       <= nack_next;
        end
    end

    always_comb begin
        n_state         = c_state;
        cnt_next        = cnt_reg;
        phase_next      = phase_reg;
        bit_cnt_next    = bit_cnt_reg;
        tx_shift_next   = tx_shift_reg;
        rx_shift_next   = rx_shift_reg;
        rx_byte_next    = rx_byte_reg;
        read_ack_next   = read_ack_reg;
        scl_drive_next  = scl_drive_reg;
        sda_drive_next  = sda_drive_reg;
        bus_active_next = bus_active_reg;
        repeated_start_next = repeated_start_reg;
        done_next       = 1'b0;
        nack_next       = nack_reg;

        unique case (c_state)
            S_IDLE: begin
                cnt_next       = '0;
                phase_next     = 2'd0;
                bit_cnt_next   = 3'd0;
                scl_drive_next = bus_active_reg;
                sda_drive_next = bus_active_reg;

                if (cmd_valid) begin
                    unique case (cmd)
                        CMD_START: begin
                            n_state             = S_START;
                            repeated_start_next = bus_active_reg;
                            bus_active_next     = 1'b1;
                            scl_drive_next      = bus_active_reg;
                            sda_drive_next      = 1'b0;
                        end

                        CMD_STOP: begin
                            n_state         = S_STOP;
                            scl_drive_next  = 1'b1;
                            sda_drive_next  = 1'b1;
                        end

                        CMD_WRITE_BYTE: begin
                            n_state         = S_WRITE_BIT;
                            tx_shift_next   = tx_byte;
                            bit_cnt_next    = 3'd0;
                            phase_next      = 2'd0;
                            nack_next       = 1'b0;
                            scl_drive_next  = 1'b1;
                            sda_drive_next  = ~tx_byte[7];
                            bus_active_next = 1'b1;
                        end

                        CMD_READ_BYTE: begin
                            n_state         = S_READ_BIT;
                            rx_shift_next   = 8'h00;
                            bit_cnt_next    = 3'd0;
                            phase_next      = 2'd0;
                            read_ack_next   = read_ack;
                            scl_drive_next  = 1'b1;
                            sda_drive_next  = 1'b0;
                            bus_active_next = 1'b1;
                        end

                        default: begin
                            n_state = S_IDLE;
                        end
                    endcase
                end
            end

            S_START: begin
                if (quarter_done) begin
                    cnt_next = '0;

                    unique case (phase_reg)
                        2'd0: begin
                            phase_next     = 2'd1;
                            scl_drive_next = 1'b0;
                            sda_drive_next = repeated_start_reg ? 1'b0 : 1'b1;
                        end

                        2'd1: begin
                            phase_next     = 2'd2;
                            scl_drive_next = repeated_start_reg ? 1'b0 : 1'b1;
                            sda_drive_next = 1'b1;
                        end

                        2'd2: begin
                            phase_next     = 2'd3;
                            scl_drive_next = 1'b1;
                            sda_drive_next = 1'b1;
                        end

                        default: begin
                            phase_next          = 2'd0;
                            repeated_start_next = 1'b0;
                            n_state             = S_IDLE;
                            scl_drive_next      = 1'b1;
                            sda_drive_next      = 1'b1;
                            done_next           = 1'b1;
                        end
                    endcase
                end
                else begin
                    cnt_next = cnt_reg + {{(CNT_WIDTH-1){1'b0}}, 1'b1};
                end
            end

            S_STOP: begin
                if (quarter_done) begin
                    cnt_next = '0;

                    unique case (phase_reg)
                        2'd0: begin
                            phase_next     = 2'd1;
                            scl_drive_next = 1'b0;
                            sda_drive_next = 1'b1;
                        end

                        2'd1: begin
                            phase_next     = 2'd2;
                            scl_drive_next = 1'b0;
                            sda_drive_next = 1'b0;
                        end

                        2'd2: begin
                            phase_next     = 2'd3;
                            scl_drive_next = 1'b0;
                            sda_drive_next = 1'b0;
                        end

                        default: begin
                            phase_next      = 2'd0;
                            n_state         = S_IDLE;
                            scl_drive_next  = 1'b0;
                            sda_drive_next  = 1'b0;
                            bus_active_next = 1'b0;
                            done_next       = 1'b1;
                        end
                    endcase
                end
                else begin
                    cnt_next = cnt_reg + {{(CNT_WIDTH-1){1'b0}}, 1'b1};
                end
            end

            S_WRITE_BIT: begin
                if (quarter_done) begin
                    cnt_next = '0;

                    unique case (phase_reg)
                        2'd0: begin
                            phase_next     = 2'd1;
                            scl_drive_next = 1'b0;
                            sda_drive_next = ~tx_shift_reg[7];
                        end

                        2'd1: begin
                            phase_next     = 2'd2;
                            scl_drive_next = 1'b0;
                            sda_drive_next = ~tx_shift_reg[7];
                        end

                        2'd2: begin
                            phase_next     = 2'd3;
                            scl_drive_next = 1'b1;
                            sda_drive_next = ~tx_shift_reg[7];
                        end

                        default: begin
                            phase_next     = 2'd0;
                            scl_drive_next = 1'b1;

                            if (bit_cnt_reg == 3'd7) begin
                                bit_cnt_next  = 3'd0;
                                n_state       = S_WRITE_ACK;
                                sda_drive_next = 1'b0;
                            end
                            else begin
                                bit_cnt_next  = bit_cnt_reg + 3'd1;
                                tx_shift_next = {tx_shift_reg[6:0], 1'b0};
                                sda_drive_next = ~tx_shift_reg[6];
                            end
                        end
                    endcase
                end
                else begin
                    cnt_next = cnt_reg + {{(CNT_WIDTH-1){1'b0}}, 1'b1};
                end
            end

            S_WRITE_ACK: begin
                if (quarter_done) begin
                    cnt_next = '0;

                    unique case (phase_reg)
                        2'd0: begin
                            phase_next     = 2'd1;
                            scl_drive_next = 1'b0;
                            sda_drive_next = 1'b0;
                        end

                        2'd1: begin
                            phase_next     = 2'd2;
                            scl_drive_next = 1'b0;
                            sda_drive_next = 1'b0;
                            nack_next      = sda_in;
                        end

                        2'd2: begin
                            phase_next     = 2'd3;
                            scl_drive_next = 1'b1;
                            sda_drive_next = 1'b0;
                        end

                        default: begin
                            phase_next     = 2'd0;
                            n_state        = S_IDLE;
                            scl_drive_next = 1'b1;
                            sda_drive_next = 1'b0;
                            done_next      = 1'b1;
                        end
                    endcase
                end
                else begin
                    cnt_next = cnt_reg + {{(CNT_WIDTH-1){1'b0}}, 1'b1};
                end
            end

            S_READ_BIT: begin
                if (quarter_done) begin
                    cnt_next = '0;

                    unique case (phase_reg)
                        2'd0: begin
                            phase_next     = 2'd1;
                            scl_drive_next = 1'b0;
                            sda_drive_next = 1'b0;
                        end

                        2'd1: begin
                            phase_next     = 2'd2;
                            scl_drive_next = 1'b0;
                            sda_drive_next = 1'b0;
                            rx_shift_next  = {rx_shift_reg[6:0], sda_in};
                        end

                        2'd2: begin
                            phase_next     = 2'd3;
                            scl_drive_next = 1'b1;
                            sda_drive_next = 1'b0;
                        end

                        default: begin
                            phase_next     = 2'd0;
                            scl_drive_next = 1'b1;
                            sda_drive_next = 1'b0;

                            if (bit_cnt_reg == 3'd7) begin
                                bit_cnt_next = 3'd0;
                                rx_byte_next = rx_shift_reg;
                                n_state      = S_READ_ACK;
                            end
                            else begin
                                bit_cnt_next = bit_cnt_reg + 3'd1;
                            end
                        end
                    endcase
                end
                else begin
                    cnt_next = cnt_reg + {{(CNT_WIDTH-1){1'b0}}, 1'b1};
                end
            end

            S_READ_ACK: begin
                if (quarter_done) begin
                    cnt_next = '0;

                    unique case (phase_reg)
                        2'd0: begin
                            phase_next     = 2'd1;
                            scl_drive_next = 1'b1;
                            sda_drive_next = read_ack_reg;
                        end

                        2'd1: begin
                            phase_next     = 2'd2;
                            scl_drive_next = 1'b0;
                            sda_drive_next = read_ack_reg;
                        end

                        2'd2: begin
                            phase_next     = 2'd3;
                            scl_drive_next = 1'b0;
                            sda_drive_next = read_ack_reg;
                        end

                        default: begin
                            phase_next     = 2'd0;
                            n_state        = S_IDLE;
                            scl_drive_next = 1'b1;
                            sda_drive_next = 1'b0;
                            done_next      = 1'b1;
                        end
                    endcase
                end
                else begin
                    cnt_next = cnt_reg + {{(CNT_WIDTH-1){1'b0}}, 1'b1};
                end
            end

            default: begin
                n_state         = S_IDLE;
                cnt_next        = '0;
                phase_next      = 2'd0;
                bit_cnt_next    = 3'd0;
                tx_shift_next   = 8'h00;
                rx_shift_next   = 8'h00;
                rx_byte_next    = 8'h00;
                read_ack_next   = 1'b0;
                scl_drive_next  = 1'b0;
                sda_drive_next  = 1'b0;
                bus_active_next = 1'b0;
                repeated_start_next = 1'b0;
                done_next       = 1'b0;
                nack_next       = 1'b0;
            end
        endcase
    end

endmodule
