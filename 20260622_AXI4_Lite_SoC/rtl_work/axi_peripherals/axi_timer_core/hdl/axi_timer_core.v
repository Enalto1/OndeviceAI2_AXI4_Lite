`timescale 1ns / 1ps

// AXI4-Lite stopwatch/watch Timer peripheral for the MicroBlaze Basys3 system.
// Register map:
// 0x00 CONTROL          RW  [1:0] stopwatch run/down, [11:8] watch control
// 0x04 COMMAND          WO  write-one clear/edit pulses, reads as 0
// 0x08 STOPWATCH_VALUE  RO  packed stopwatch msec/sec/min/hour
// 0x0C WATCH_VALUE      RO  packed watch msec/sec/min/hour from adapter
// 0x10 WATCH_RAW_DIGITS RO  raw watch split digit fields
// 0x14 STATUS           RO  mirrors meaningful CONTROL bits
// 0x1C VERSION          RO  fixed 32'h0001_0000
// 0x18,0x20-0x3C reserved, reads 0 and ignores writes
module axi_timer_core #(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 6
)(
    input  wire                                  s00_axi_aclk,
    input  wire                                  s00_axi_aresetn,
    input  wire [C_S00_AXI_ADDR_WIDTH-1:0]       s00_axi_awaddr,
    input  wire [2:0]                            s00_axi_awprot,
    input  wire                                  s00_axi_awvalid,
    output wire                                  s00_axi_awready,
    input  wire [C_S00_AXI_DATA_WIDTH-1:0]       s00_axi_wdata,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1:0]   s00_axi_wstrb,
    input  wire                                  s00_axi_wvalid,
    output wire                                  s00_axi_wready,
    output wire [1:0]                            s00_axi_bresp,
    output wire                                  s00_axi_bvalid,
    input  wire                                  s00_axi_bready,
    input  wire [C_S00_AXI_ADDR_WIDTH-1:0]       s00_axi_araddr,
    input  wire [2:0]                            s00_axi_arprot,
    input  wire                                  s00_axi_arvalid,
    output wire                                  s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1:0]       s00_axi_rdata,
    output wire [1:0]                            s00_axi_rresp,
    output wire                                  s00_axi_rvalid,
    input  wire                                  s00_axi_rready
);

    localparam integer ADDR_LSB = 2;
    localparam integer OPT_MEM_ADDR_BITS = 3;

    localparam [3:0] REG_CONTROL          = 4'h0;
    localparam [3:0] REG_COMMAND          = 4'h1;
    localparam [3:0] REG_STOPWATCH_VALUE  = 4'h2;
    localparam [3:0] REG_WATCH_VALUE      = 4'h3;
    localparam [3:0] REG_WATCH_RAW_DIGITS = 4'h4;
    localparam [3:0] REG_STATUS           = 4'h5;
    localparam [3:0] REG_VERSION          = 4'h7;

    wire rst;
    assign rst = ~s00_axi_aresetn;

    reg [C_S00_AXI_ADDR_WIDTH-1:0] axi_awaddr;
    reg axi_awready;
    reg axi_wready;
    reg [1:0] axi_bresp;
    reg axi_bvalid;
    reg [C_S00_AXI_ADDR_WIDTH-1:0] axi_araddr;
    reg axi_arready;
    reg [C_S00_AXI_DATA_WIDTH-1:0] axi_rdata;
    reg [1:0] axi_rresp;
    reg axi_rvalid;
    reg aw_en;

    assign s00_axi_awready = axi_awready;
    assign s00_axi_wready  = axi_wready;
    assign s00_axi_bresp   = axi_bresp;
    assign s00_axi_bvalid  = axi_bvalid;
    assign s00_axi_arready = axi_arready;
    assign s00_axi_rdata   = axi_rdata;
    assign s00_axi_rresp   = axi_rresp;
    assign s00_axi_rvalid  = axi_rvalid;

    reg [11:0] control_reg;
    reg stopwatch_clear_pulse;
    reg [1:0] watch_edit_cmd;
    reg [C_S00_AXI_DATA_WIDTH-1:0] reg_data_out;

    wire slv_reg_wren;
    wire slv_reg_rden;
    wire [3:0] write_addr_index;
    wire [3:0] read_addr_index;

    wire [6:0] stopwatch_msec;
    wire [5:0] stopwatch_sec;
    wire [5:0] stopwatch_min;
    wire [4:0] stopwatch_hour;

    wire [6:0] watch_msec_raw;
    wire [3:0] watch_sec_d1;
    wire [2:0] watch_sec_d10;
    wire [3:0] watch_min_d1;
    wire [2:0] watch_min_d10;
    wire [4:0] watch_hour_raw;

    wire [6:0] watch_msec;
    wire [5:0] watch_sec;
    wire [5:0] watch_min;
    wire [4:0] watch_hour;

    assign slv_reg_wren = axi_wready && s00_axi_wvalid && axi_awready && s00_axi_awvalid;
    assign slv_reg_rden = axi_arready && s00_axi_arvalid && (~axi_rvalid);

    assign write_addr_index = s00_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    assign read_addr_index  = s00_axi_arvalid ?
                              s00_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB] :
                              axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];

    stopwatch_datapath u_stopwatch_datapath (
        .clk       (s00_axi_aclk),
        .rst       (rst),
        .i_runstop (control_reg[0]),
        .i_clear   (stopwatch_clear_pulse),
        .i_mode    (control_reg[1]),
        .msec      (stopwatch_msec),
        .sec       (stopwatch_sec),
        .min       (stopwatch_min),
        .hour      (stopwatch_hour)
    );

    watch_datapath u_watch_datapath (
        .clk         (s00_axi_aclk),
        .rst         (rst),
        .i_set_mode  (control_reg[8]),
        .i_digit_sel (control_reg[11]),
        .i_time_sel  (control_reg[10:9]),
        .i_edit_cmd  (watch_edit_cmd),
        .msec        (watch_msec_raw),
        .sec_d1      (watch_sec_d1),
        .sec_d10     (watch_sec_d10),
        .min_d1      (watch_min_d1),
        .min_d10     (watch_min_d10),
        .hour        (watch_hour_raw)
    );

    watch_fnd_adapter u_watch_fnd_adapter (
        .i_hour    (watch_hour_raw),
        .i_min_d10 (watch_min_d10),
        .i_min_d1  (watch_min_d1),
        .i_sec_d10 (watch_sec_d10),
        .i_sec_d1  (watch_sec_d1),
        .i_msec    (watch_msec_raw),
        .hour      (watch_hour),
        .min       (watch_min),
        .sec       (watch_sec),
        .msec      (watch_msec)
    );

    always @(posedge s00_axi_aclk) begin
        if (rst) begin
            axi_awready <= 1'b0;
            aw_en       <= 1'b1;
        end
        else begin
            if ((~axi_awready) && s00_axi_awvalid && s00_axi_wvalid && aw_en) begin
                axi_awready <= 1'b1;
                aw_en       <= 1'b0;
            end
            else if (s00_axi_bready && axi_bvalid) begin
                aw_en       <= 1'b1;
                axi_awready <= 1'b0;
            end
            else begin
                axi_awready <= 1'b0;
            end
        end
    end

    always @(posedge s00_axi_aclk) begin
        if (rst) begin
            axi_awaddr <= 0;
        end
        else begin
            if ((~axi_awready) && s00_axi_awvalid && s00_axi_wvalid && aw_en) begin
                axi_awaddr <= s00_axi_awaddr;
            end
        end
    end

    always @(posedge s00_axi_aclk) begin
        if (rst) begin
            axi_wready <= 1'b0;
        end
        else begin
            if ((~axi_wready) && s00_axi_wvalid && s00_axi_awvalid && aw_en) begin
                axi_wready <= 1'b1;
            end
            else begin
                axi_wready <= 1'b0;
            end
        end
    end

    always @(posedge s00_axi_aclk) begin
        if (rst) begin
            axi_bvalid <= 1'b0;
            axi_bresp  <= 2'b00;
        end
        else begin
            if (axi_awready && s00_axi_awvalid && (~axi_bvalid) &&
                axi_wready && s00_axi_wvalid) begin
                axi_bvalid <= 1'b1;
                axi_bresp  <= 2'b00;
            end
            else begin
                if (s00_axi_bready && axi_bvalid) begin
                    axi_bvalid <= 1'b0;
                end
            end
        end
    end

    always @(posedge s00_axi_aclk) begin
        if (rst) begin
            axi_arready <= 1'b0;
            axi_araddr  <= 0;
        end
        else begin
            if ((~axi_arready) && s00_axi_arvalid) begin
                axi_arready <= 1'b1;
                axi_araddr  <= s00_axi_araddr;
            end
            else begin
                axi_arready <= 1'b0;
            end
        end
    end

    always @(posedge s00_axi_aclk) begin
        if (rst) begin
            axi_rvalid <= 1'b0;
            axi_rresp  <= 2'b00;
        end
        else begin
            if (axi_arready && s00_axi_arvalid && (~axi_rvalid)) begin
                axi_rvalid <= 1'b1;
                axi_rresp  <= 2'b00;
            end
            else if (axi_rvalid && s00_axi_rready) begin
                axi_rvalid <= 1'b0;
            end
        end
    end

    always @(posedge s00_axi_aclk) begin
        if (rst) begin
            control_reg             <= 12'h000;
            stopwatch_clear_pulse   <= 1'b0;
            watch_edit_cmd          <= 2'b00;
        end
        else begin
            stopwatch_clear_pulse <= 1'b0;
            watch_edit_cmd        <= 2'b00;

            if (slv_reg_wren) begin
                case (write_addr_index)
                    REG_CONTROL: begin
                        if (s00_axi_wstrb[0]) begin
                            control_reg[1:0] <= s00_axi_wdata[1:0];
                        end
                        if (s00_axi_wstrb[1]) begin
                            control_reg[11:8] <= s00_axi_wdata[11:8];
                        end
                    end

                    REG_COMMAND: begin
                        if (s00_axi_wstrb[0] && s00_axi_wdata[0]) begin
                            stopwatch_clear_pulse <= 1'b1;
                        end
                        if (control_reg[8] && s00_axi_wstrb[1]) begin
                            if (s00_axi_wdata[8]) begin
                                watch_edit_cmd <= 2'b01;
                            end
                            else if (s00_axi_wdata[9]) begin
                                watch_edit_cmd <= 2'b10;
                            end
                        end
                    end

                    default: begin
                        control_reg <= control_reg;
                    end
                endcase
            end
        end
    end

    always @(*) begin
        case (read_addr_index)
            REG_CONTROL: begin
                reg_data_out = {20'h00000, control_reg[11:8], 6'h00, control_reg[1:0]};
            end

            REG_COMMAND: begin
                reg_data_out = 32'h0000_0000;
            end

            REG_STOPWATCH_VALUE: begin
                reg_data_out = {8'h00, stopwatch_hour[4:0], stopwatch_min[5:0],
                                stopwatch_sec[5:0], stopwatch_msec[6:0]};
            end

            REG_WATCH_VALUE: begin
                reg_data_out = {8'h00, watch_hour[4:0], watch_min[5:0],
                                watch_sec[5:0], watch_msec[6:0]};
            end

            REG_WATCH_RAW_DIGITS: begin
                reg_data_out = {6'h00, watch_hour_raw[4:0], watch_min_d10[2:0],
                                watch_min_d1[3:0], watch_sec_d10[2:0],
                                watch_sec_d1[3:0], watch_msec_raw[6:0]};
            end

            REG_STATUS: begin
                reg_data_out = {20'h00000, control_reg[11:8], 6'h00, control_reg[1:0]};
            end

            REG_VERSION: begin
                reg_data_out = 32'h0001_0000;
            end

            default: begin
                reg_data_out = 32'h0000_0000;
            end
        endcase
    end

    always @(posedge s00_axi_aclk) begin
        if (rst) begin
            axi_rdata <= 0;
        end
        else begin
            if (slv_reg_rden) begin
                axi_rdata <= reg_data_out;
            end
        end
    end

endmodule