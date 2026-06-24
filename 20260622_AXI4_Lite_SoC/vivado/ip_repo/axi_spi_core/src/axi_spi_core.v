`timescale 1ns / 1ps

// AXI4-Lite SPI master peripheral for the MicroBlaze Basys3 system.
// Register map:
// 0x00 CONTROL  RW  [0] enable, [1] cpol, [2] cpha
// 0x04 CLKDIV   RW  [15:0] stored divider, zero clamped only at master input
// 0x08 TXDATA   RW  [7:0] transmit byte
// 0x0C COMMAND  WO  write-one start pulse, reads as 0
// 0x10 RXDATA   RO  [7:0] last received byte
// 0x14 STATUS   RO  busy, done_sticky, control mirrors
// 0x1C VERSION  RO  fixed 32'h0001_0000
// 0x18,0x20-0x3C reserved, reads 0 and ignores writes
module axi_spi_core #(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 6
)(
    output wire                                  spi_sclk_o,
    output wire                                  spi_mosi_o,
    input  wire                                  spi_miso_i,
    output wire                                  spi_ss_n_o,

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

    localparam [3:0] REG_CONTROL = 4'h0;
    localparam [3:0] REG_CLKDIV  = 4'h1;
    localparam [3:0] REG_TXDATA  = 4'h2;
    localparam [3:0] REG_COMMAND = 4'h3;
    localparam [3:0] REG_RXDATA  = 4'h4;
    localparam [3:0] REG_STATUS  = 4'h5;
    localparam [3:0] REG_VERSION = 4'h7;

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

    reg [2:0] control_reg;
    reg [15:0] clkdiv_reg;
    reg [7:0] txdata_reg;
    reg spi_start_pulse;
    reg done_sticky;
    reg [C_S00_AXI_DATA_WIDTH-1:0] reg_data_out;

    wire slv_reg_wren;
    wire slv_reg_rden;
    wire [3:0] write_addr_index;
    wire [3:0] read_addr_index;

    wire [7:0] spi_rx_data;
    wire spi_busy;
    wire spi_done;
    wire [15:0] clk_div_to_master;

    assign slv_reg_wren = axi_wready && s00_axi_wvalid && axi_awready && s00_axi_awvalid;
    assign slv_reg_rden = axi_arready && s00_axi_arvalid && (~axi_rvalid);

    assign write_addr_index = s00_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    assign read_addr_index  = s00_axi_arvalid ?
                              s00_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB] :
                              axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];

    assign clk_div_to_master = (clkdiv_reg == 16'h0000) ? 16'h0001 : clkdiv_reg;

    spi_master_byte #(
        .CLK_DIV_WIDTH(16)
    ) u_spi_master_byte (
        .clk     (s00_axi_aclk),
        .rst     (rst),
        .start   (spi_start_pulse),
        .clk_div (clk_div_to_master),
        .cpol    (control_reg[1]),
        .cpha    (control_reg[2]),
        .tx_data (txdata_reg[7:0]),
        .miso    (spi_miso_i),
        .rx_data (spi_rx_data),
        .busy    (spi_busy),
        .done    (spi_done),
        .sclk    (spi_sclk_o),
        .mosi    (spi_mosi_o),
        .ss_n    (spi_ss_n_o)
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
            control_reg     <= 3'b000;
            clkdiv_reg      <= 16'h0001;
            txdata_reg      <= 8'h00;
            spi_start_pulse <= 1'b0;
            done_sticky     <= 1'b0;
        end
        else begin
            spi_start_pulse <= 1'b0;

            if (spi_done) begin
                done_sticky <= 1'b1;
            end

            if (slv_reg_wren) begin
                case (write_addr_index)
                    REG_CONTROL: begin
                        if (s00_axi_wstrb[0]) begin
                            control_reg[2:0] <= s00_axi_wdata[2:0];
                        end
                    end

                    REG_CLKDIV: begin
                        if (s00_axi_wstrb[0]) begin
                            clkdiv_reg[7:0] <= s00_axi_wdata[7:0];
                        end
                        if (s00_axi_wstrb[1]) begin
                            clkdiv_reg[15:8] <= s00_axi_wdata[15:8];
                        end
                    end

                    REG_TXDATA: begin
                        if (s00_axi_wstrb[0]) begin
                            txdata_reg[7:0] <= s00_axi_wdata[7:0];
                        end
                    end

                    REG_COMMAND: begin
                        if (s00_axi_wstrb[0] && s00_axi_wdata[0] &&
                            control_reg[0] && (~spi_busy)) begin
                            spi_start_pulse <= 1'b1;
                            done_sticky     <= 1'b0;
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
                reg_data_out = {29'd0, control_reg[2:0]};
            end

            REG_CLKDIV: begin
                reg_data_out = {16'h0000, clkdiv_reg[15:0]};
            end

            REG_TXDATA: begin
                reg_data_out = {24'h000000, txdata_reg[7:0]};
            end

            REG_COMMAND: begin
                reg_data_out = 32'h0000_0000;
            end

            REG_RXDATA: begin
                reg_data_out = {24'h000000, spi_rx_data[7:0]};
            end

            REG_STATUS: begin
                reg_data_out = {21'h000000, control_reg[2], control_reg[1],
                                control_reg[0], 5'h00, 1'b0,
                                done_sticky, spi_busy};
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