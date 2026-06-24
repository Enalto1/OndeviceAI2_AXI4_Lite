`timescale 1ns / 1ps

// AXI4-Lite FND display peripheral for the MicroBlaze Basys3 system.
// Register map:
// 0x00 CONTROL      RW  [0] enable, [2:1] main_mode, [3] display_sel
// 0x04 TIMER_VALUE  RW  [6:0] msec, [12:7] sec, [18:13] min, [23:19] hour
// 0x08 SENSOR_VALUE RW  [8:0] distance, [16:9] humidity, [24:17] temperature
// 0x0C FND_OUTPUT   RO  [3:0] fnd_com_o, [15:8] fnd_data_o
// 0x1C VERSION      RO  fixed 32'h0001_0000
// 0x10,0x14,0x18,0x20-0x3C reserved, reads 0 and ignores writes
module axi_fnd_core #(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 6,
    parameter integer FND_DIV_COUNT        = 50_000,
    parameter integer FND_DOT_THRESHOLD    = 50
)(
    output wire [3:0] fnd_com_o,
    output wire [7:0] fnd_data_o,

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

    localparam [3:0] REG_CONTROL      = 4'h0;
    localparam [3:0] REG_TIMER_VALUE  = 4'h1;
    localparam [3:0] REG_SENSOR_VALUE = 4'h2;
    localparam [3:0] REG_FND_OUTPUT   = 4'h3;
    localparam [3:0] REG_VERSION      = 4'h7;

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

    reg [3:0] control_reg;
    reg [23:0] timer_value_reg;
    reg [24:0] sensor_value_reg;
    reg [C_S00_AXI_DATA_WIDTH-1:0] reg_data_out;

    wire slv_reg_wren;
    wire slv_reg_rden;
    wire [3:0] write_addr_index;
    wire [3:0] read_addr_index;

    wire display_enable;
    wire [3:0] fnd_com_raw;
    wire [7:0] fnd_data_raw;

    assign display_enable = control_reg[0];
    assign fnd_com_o = display_enable ? fnd_com_raw : 4'b1111;
    assign fnd_data_o = display_enable ? fnd_data_raw : 8'hFF;

    assign slv_reg_wren = axi_wready && s00_axi_wvalid && axi_awready && s00_axi_awvalid;
    assign slv_reg_rden = axi_arready && s00_axi_arvalid && (~axi_rvalid);

    assign write_addr_index = s00_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    assign read_addr_index  = s00_axi_arvalid ?
                              s00_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB] :
                              axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];

    fnd_controller #(
        .DIV_COUNT     (FND_DIV_COUNT),
        .DOT_THRESHOLD (FND_DOT_THRESHOLD)
    ) u_fnd_controller (
        .clk           (s00_axi_aclk),
        .rst           (rst),
        .i_main_mode   (control_reg[2:1]),
        .i_display_sel (control_reg[3]),
        .msec          (timer_value_reg[6:0]),
        .sec           (timer_value_reg[12:7]),
        .min           (timer_value_reg[18:13]),
        .hour          (timer_value_reg[23:19]),
        .distance      (sensor_value_reg[8:0]),
        .humidity      (sensor_value_reg[16:9]),
        .temperature   (sensor_value_reg[24:17]),
        .fnd_com       (fnd_com_raw),
        .fnd_data      (fnd_data_raw)
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
            control_reg      <= 4'h0;
            timer_value_reg  <= 24'h0;
            sensor_value_reg <= 25'h0;
        end
        else begin
            if (slv_reg_wren) begin
                case (write_addr_index)
                    REG_CONTROL: begin
                        if (s00_axi_wstrb[0]) begin
                            control_reg <= s00_axi_wdata[3:0];
                        end
                    end

                    REG_TIMER_VALUE: begin
                        if (s00_axi_wstrb[0]) begin
                            timer_value_reg[7:0] <= s00_axi_wdata[7:0];
                        end
                        if (s00_axi_wstrb[1]) begin
                            timer_value_reg[15:8] <= s00_axi_wdata[15:8];
                        end
                        if (s00_axi_wstrb[2]) begin
                            timer_value_reg[23:16] <= s00_axi_wdata[23:16];
                        end
                    end

                    REG_SENSOR_VALUE: begin
                        if (s00_axi_wstrb[0]) begin
                            sensor_value_reg[7:0] <= s00_axi_wdata[7:0];
                        end
                        if (s00_axi_wstrb[1]) begin
                            sensor_value_reg[15:8] <= s00_axi_wdata[15:8];
                        end
                        if (s00_axi_wstrb[2]) begin
                            sensor_value_reg[23:16] <= s00_axi_wdata[23:16];
                        end
                        if (s00_axi_wstrb[3]) begin
                            sensor_value_reg[24] <= s00_axi_wdata[24];
                        end
                    end

                    default: begin
                        control_reg      <= control_reg;
                        timer_value_reg  <= timer_value_reg;
                        sensor_value_reg <= sensor_value_reg;
                    end
                endcase
            end
        end
    end

    always @(*) begin
        case (read_addr_index)
            REG_CONTROL: begin
                reg_data_out = {28'h0000000, control_reg};
            end

            REG_TIMER_VALUE: begin
                reg_data_out = {8'h00, timer_value_reg};
            end

            REG_SENSOR_VALUE: begin
                reg_data_out = {7'h00, sensor_value_reg};
            end

            REG_FND_OUTPUT: begin
                reg_data_out = {16'h0000, fnd_data_o, 4'h0, fnd_com_o};
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