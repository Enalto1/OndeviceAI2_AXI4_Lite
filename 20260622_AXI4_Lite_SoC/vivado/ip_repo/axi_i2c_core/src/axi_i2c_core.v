`timescale 1ns / 1ps

// AXI4-Lite I2C master peripheral for the MicroBlaze Basys3 system.
// Register map:
// 0x00 CONTROL     RW  [0] enable, [1] read_ack
// 0x04 TXDATA      RW  [7:0] transmit byte
// 0x08 COMMAND     WO  write-one low-level command, reads as 0
// 0x0C RXDATA      RO  [7:0] last received byte
// 0x10 STATUS      RO  busy, cmd_ready, done/nack sticky, control mirrors
// 0x14 BUS_STATUS  RO  sampled SCL/SDA and drive-low state
// 0x1C VERSION     RO  fixed 32'h0001_0000
// 0x18,0x20-0x3C reserved, reads 0 and ignores writes
module axi_i2c_core #(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 6,
    parameter integer I2C_CLK_HZ = 100_000_000,
    parameter integer I2C_BUS_HZ = 100_000
)(
    inout  wire                                  i2c_scl_io,
    inout  wire                                  i2c_sda_io,

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
    localparam [3:0] REG_TXDATA     = 4'h1;
    localparam [3:0] REG_COMMAND    = 4'h2;
    localparam [3:0] REG_RXDATA     = 4'h3;
    localparam [3:0] REG_STATUS     = 4'h4;
    localparam [3:0] REG_BUS_STATUS = 4'h5;
    localparam [3:0] REG_VERSION    = 4'h7;

    localparam [2:0] I2C_CMD_START      = 3'd0;
    localparam [2:0] I2C_CMD_STOP       = 3'd1;
    localparam [2:0] I2C_CMD_WRITE_BYTE = 3'd2;
    localparam [2:0] I2C_CMD_READ_BYTE  = 3'd3;

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

    reg [1:0] control_reg;
    reg [7:0] txdata_reg;
    reg i2c_cmd_valid_pulse;
    reg [2:0] i2c_cmd_code;
    reg done_sticky;
    reg nack_sticky;
    reg [C_S00_AXI_DATA_WIDTH-1:0] reg_data_out;

    wire slv_reg_wren;
    wire slv_reg_rden;
    wire [3:0] write_addr_index;
    wire [3:0] read_addr_index;

    wire i2c_cmd_ready;
    wire i2c_done;
    wire i2c_busy;
    wire i2c_nack;
    wire [7:0] i2c_rx_byte;
    wire scl_drive_low;
    wire sda_drive_low;
    wire scl_in;
    wire sda_in;

    assign slv_reg_wren = axi_wready && s00_axi_wvalid && axi_awready && s00_axi_awvalid;
    assign slv_reg_rden = axi_arready && s00_axi_arvalid && (~axi_rvalid);

    assign write_addr_index = s00_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    assign read_addr_index  = s00_axi_arvalid ?
                              s00_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB] :
                              axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];

    assign i2c_scl_io = scl_drive_low ? 1'b0 : 1'bz;
    assign i2c_sda_io = sda_drive_low ? 1'b0 : 1'bz;
    assign scl_in = i2c_scl_io;
    assign sda_in = i2c_sda_io;

    i2c_master_core #(
        .CLK_HZ(I2C_CLK_HZ),
        .I2C_HZ(I2C_BUS_HZ)
    ) u_i2c_master_core (
        .clk           (s00_axi_aclk),
        .rst           (rst),
        .cmd_valid     (i2c_cmd_valid_pulse),
        .cmd           (i2c_cmd_code),
        .tx_byte       (txdata_reg[7:0]),
        .read_ack      (control_reg[1]),
        .cmd_ready     (i2c_cmd_ready),
        .done          (i2c_done),
        .busy          (i2c_busy),
        .nack          (i2c_nack),
        .rx_byte       (i2c_rx_byte),
        .scl_drive_low (scl_drive_low),
        .sda_drive_low (sda_drive_low),
        .scl_in        (scl_in),
        .sda_in        (sda_in)
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
            control_reg         <= 2'b00;
            txdata_reg          <= 8'h00;
            i2c_cmd_valid_pulse <= 1'b0;
            i2c_cmd_code        <= I2C_CMD_START;
            done_sticky         <= 1'b0;
            nack_sticky         <= 1'b0;
        end
        else begin
            i2c_cmd_valid_pulse <= 1'b0;

            if (i2c_done) begin
                done_sticky <= 1'b1;
                if (i2c_nack) begin
                    nack_sticky <= 1'b1;
                end
            end

            if (slv_reg_wren) begin
                case (write_addr_index)
                    REG_CONTROL: begin
                        if (s00_axi_wstrb[0]) begin
                            control_reg[1:0] <= s00_axi_wdata[1:0];
                        end
                    end

                    REG_TXDATA: begin
                        if (s00_axi_wstrb[0]) begin
                            txdata_reg[7:0] <= s00_axi_wdata[7:0];
                        end
                    end

                    REG_COMMAND: begin
                        if (s00_axi_wstrb[0] && control_reg[0] &&
                            i2c_cmd_ready && (|s00_axi_wdata[3:0])) begin
                            i2c_cmd_valid_pulse <= 1'b1;
                            done_sticky         <= 1'b0;
                            nack_sticky         <= 1'b0;

                            if (s00_axi_wdata[0]) begin
                                i2c_cmd_code <= I2C_CMD_START;
                            end
                            else if (s00_axi_wdata[1]) begin
                                i2c_cmd_code <= I2C_CMD_STOP;
                            end
                            else if (s00_axi_wdata[2]) begin
                                i2c_cmd_code <= I2C_CMD_WRITE_BYTE;
                            end
                            else begin
                                i2c_cmd_code <= I2C_CMD_READ_BYTE;
                            end
                        end
                    end

                    default: begin
                    end
                endcase
            end
        end
    end

    always @(*) begin
        case (read_addr_index)
            REG_CONTROL: begin
                reg_data_out = {30'h00000000, control_reg[1:0]};
            end

            REG_TXDATA: begin
                reg_data_out = {24'h000000, txdata_reg[7:0]};
            end

            REG_COMMAND: begin
                reg_data_out = 32'h0000_0000;
            end

            REG_RXDATA: begin
                reg_data_out = {24'h000000, i2c_rx_byte[7:0]};
            end

            REG_STATUS: begin
                reg_data_out = {22'h000000, control_reg[1], control_reg[0],
                                3'b000, i2c_nack, nack_sticky,
                                done_sticky, i2c_cmd_ready, i2c_busy};
            end

            REG_BUS_STATUS: begin
                reg_data_out = {28'h0000000, sda_drive_low, scl_drive_low,
                                sda_in, scl_in};
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
