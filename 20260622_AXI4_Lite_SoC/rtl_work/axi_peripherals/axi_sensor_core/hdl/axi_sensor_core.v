`timescale 1ns / 1ps

// AXI4-Lite SR04/DHT11 Sensor peripheral for the MicroBlaze Basys3 system.
// Register map:
// 0x00 CONTROL     RW  [0] sr04_enable, [8] dht_enable
// 0x04 COMMAND     WO  write-one start pulses, reads as 0
// 0x08 SR04_VALUE  RO  [8:0] distance
// 0x0C DHT_VALUE   RO  [7:0] humidity, [15:8] temperature
// 0x10 STATUS      RO  live status and enable mirrors
// 0x1C VERSION     RO  fixed 32'h0001_0000
// 0x14,0x18,0x20-0x3C reserved, reads 0 and ignores writes
module axi_sensor_core #(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 6
)(
    input  wire                                  sr04_echo_i,
    output wire                                  sr04_trig_o,
    inout  wire                                  dht11_io,

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

    localparam [3:0] REG_CONTROL    = 4'h0;
    localparam [3:0] REG_COMMAND    = 4'h1;
    localparam [3:0] REG_SR04_VALUE = 4'h2;
    localparam [3:0] REG_DHT_VALUE  = 4'h3;
    localparam [3:0] REG_STATUS     = 4'h4;
    localparam [3:0] REG_VERSION    = 4'h7;

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

    reg [8:0] control_reg;
    reg sr04_start_pulse;
    reg dht_start_pulse;
    reg [C_S00_AXI_DATA_WIDTH-1:0] reg_data_out;

    wire slv_reg_wren;
    wire slv_reg_rden;
    wire [3:0] write_addr_index;
    wire [3:0] read_addr_index;

    wire [8:0] sr04_distance;
    wire sr04_trig_live;
    wire [7:0] dht_humidity;
    wire [7:0] dht_temperature;
    wire dht_valid_live;

    assign sr04_trig_o = sr04_trig_live;

    assign slv_reg_wren = axi_wready && s00_axi_wvalid && axi_awready && s00_axi_awvalid;
    assign slv_reg_rden = axi_arready && s00_axi_arvalid && (~axi_rvalid);

    assign write_addr_index = s00_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    assign read_addr_index  = s00_axi_arvalid ?
                              s00_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB] :
                              axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];

    sr04 u_sr04 (
        .clk       (s00_axi_aclk),
        .rst       (rst),
        .ultra_btn (sr04_start_pulse),
        .echo      (sr04_echo_i),
        .distance  (sr04_distance),
        .trig      (sr04_trig_live)
    );

    dht11 u_dht11 (
        .clk     (s00_axi_aclk),
        .rst     (rst),
        .dht_btn (dht_start_pulse),
        .led     (dht_valid_live),
        .hm      (dht_humidity),
        .tm      (dht_temperature),
        .dht11   (dht11_io)
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
            control_reg       <= 9'h000;
            sr04_start_pulse  <= 1'b0;
            dht_start_pulse   <= 1'b0;
        end
        else begin
            sr04_start_pulse <= 1'b0;
            dht_start_pulse  <= 1'b0;

            if (slv_reg_wren) begin
                case (write_addr_index)
                    REG_CONTROL: begin
                        if (s00_axi_wstrb[0]) begin
                            control_reg[0] <= s00_axi_wdata[0];
                        end
                        if (s00_axi_wstrb[1]) begin
                            control_reg[8] <= s00_axi_wdata[8];
                        end
                    end

                    REG_COMMAND: begin
                        if (control_reg[0] && s00_axi_wstrb[0] && s00_axi_wdata[0]) begin
                            sr04_start_pulse <= 1'b1;
                        end
                        if (control_reg[8] && s00_axi_wstrb[1] && s00_axi_wdata[8]) begin
                            dht_start_pulse <= 1'b1;
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
                reg_data_out = {23'h000000, control_reg[8], 7'h00, control_reg[0]};
            end

            REG_COMMAND: begin
                reg_data_out = 32'h0000_0000;
            end

            REG_SR04_VALUE: begin
                reg_data_out = {23'h000000, sr04_distance[8:0]};
            end

            REG_DHT_VALUE: begin
                reg_data_out = {16'h0000, dht_temperature[7:0], dht_humidity[7:0]};
            end

            REG_STATUS: begin
                reg_data_out = {7'h00, control_reg[8], 7'h00, control_reg[0],
                                7'h00, dht_valid_live, 7'h00, sr04_trig_live};
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
