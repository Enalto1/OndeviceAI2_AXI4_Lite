`timescale 1ns / 1ps

// AXI4-Lite GPIO peripheral for the MicroBlaze Basys3 system.
// Register map:
// 0x00 GPIO_OUT     RW  [15:0] LED output
// 0x04 GPIO_IN      RO  [15:0] sw_sync, [20:16] btn_level, [25:21] btn_raw_sync
// 0x08 GPIO_SET     WO  write-one-to-set LED bits, reads as 0
// 0x0C GPIO_CLR     WO  write-one-to-clear LED bits, reads as 0
// 0x10 GPIO_TOGGLE  WO  write-one-to-toggle LED bits, reads as 0
// 0x14 BTN_EDGE     RO  [4:0] latched debounced button rising-edge flags
// 0x18 BTN_EDGE_CLR WO  write-one-to-clear edge flags, reads as 0
// 0x1C VERSION      RO  fixed 32'h0001_0000
// 0x20-0x3C reserved, reads 0 and ignores writes
module axi_gpio_core #(
    parameter integer C_S00_AXI_DATA_WIDTH = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH = 6
)(
    input  wire [15:0] sw_i,
    input  wire [4:0]  btn_i,
    output wire [15:0] led_o,

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

    localparam [3:0] REG_GPIO_OUT     = 4'h0;
    localparam [3:0] REG_GPIO_IN      = 4'h1;
    localparam [3:0] REG_GPIO_SET     = 4'h2;
    localparam [3:0] REG_GPIO_CLR     = 4'h3;
    localparam [3:0] REG_GPIO_TOGGLE  = 4'h4;
    localparam [3:0] REG_BTN_EDGE     = 4'h5;
    localparam [3:0] REG_BTN_EDGE_CLR = 4'h6;
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

    reg [15:0] gpio_out_reg;
    reg [4:0] btn_edge_reg;

    reg [15:0] sw_sync_0;
    reg [15:0] sw_sync_1;
    reg [4:0] btn_sync_0;
    reg [4:0] btn_sync_1;

    wire [15:0] sw_sync;
    wire [4:0] btn_raw_sync;
    wire [4:0] btn_level;
    wire [4:0] btn_pulse;

    wire slv_reg_wren;
    wire slv_reg_rden;
    wire [3:0] write_addr_index;
    wire [3:0] read_addr_index;
    wire [15:0] wstrb_mask16;
    wire [15:0] cmd_mask16;
    wire [4:0] btn_edge_clr_mask;

    reg [C_S00_AXI_DATA_WIDTH-1:0] reg_data_out;

    assign led_o = gpio_out_reg;
    assign sw_sync = sw_sync_1;
    assign btn_raw_sync = btn_sync_1;

    assign slv_reg_wren = axi_wready && s00_axi_wvalid && axi_awready && s00_axi_awvalid;
    assign slv_reg_rden = axi_arready && s00_axi_arvalid && (~axi_rvalid);

    assign write_addr_index = s00_axi_awaddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];
    assign read_addr_index  = s00_axi_arvalid ?
                              s00_axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB] :
                              axi_araddr[ADDR_LSB + OPT_MEM_ADDR_BITS:ADDR_LSB];

    assign wstrb_mask16 = {{8{s00_axi_wstrb[1]}}, {8{s00_axi_wstrb[0]}}};
    assign cmd_mask16 = s00_axi_wdata[15:0] & wstrb_mask16;
    assign btn_edge_clr_mask = (slv_reg_wren && (write_addr_index == REG_BTN_EDGE_CLR)) ?
                               (s00_axi_wdata[4:0] & {5{s00_axi_wstrb[0]}}) :
                               5'b0;

    // External buttons are first synchronized to the AXI clock. The synchronized
    // values feed both GPIO_IN raw readback and the debounce-level helpers.
    always @(posedge s00_axi_aclk) begin
        if (rst) begin
            sw_sync_0  <= 16'h0000;
            sw_sync_1  <= 16'h0000;
            btn_sync_0 <= 5'b00000;
            btn_sync_1 <= 5'b00000;
        end
        else begin
            sw_sync_0  <= sw_i;
            sw_sync_1  <= sw_sync_0;
            btn_sync_0 <= btn_i;
            btn_sync_1 <= btn_sync_0;
        end
    end

    button_debounce_level u_btn_db0 (
        .clk         (s00_axi_aclk),
        .rst         (rst),
        .i_btn       (btn_raw_sync[0]),
        .o_btn_level (btn_level[0]),
        .o_btn_pulse (btn_pulse[0])
    );

    button_debounce_level u_btn_db1 (
        .clk         (s00_axi_aclk),
        .rst         (rst),
        .i_btn       (btn_raw_sync[1]),
        .o_btn_level (btn_level[1]),
        .o_btn_pulse (btn_pulse[1])
    );

    button_debounce_level u_btn_db2 (
        .clk         (s00_axi_aclk),
        .rst         (rst),
        .i_btn       (btn_raw_sync[2]),
        .o_btn_level (btn_level[2]),
        .o_btn_pulse (btn_pulse[2])
    );

    button_debounce_level u_btn_db3 (
        .clk         (s00_axi_aclk),
        .rst         (rst),
        .i_btn       (btn_raw_sync[3]),
        .o_btn_level (btn_level[3]),
        .o_btn_pulse (btn_pulse[3])
    );

    button_debounce_level u_btn_db4 (
        .clk         (s00_axi_aclk),
        .rst         (rst),
        .i_btn       (btn_raw_sync[4]),
        .o_btn_level (btn_level[4]),
        .o_btn_pulse (btn_pulse[4])
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
            gpio_out_reg <= 16'h0000;
            btn_edge_reg <= 5'b00000;
        end
        else begin
            btn_edge_reg <= (btn_edge_reg & (~btn_edge_clr_mask)) | btn_pulse;

            if (slv_reg_wren) begin
                case (write_addr_index)
                    REG_GPIO_OUT: begin
                        if (s00_axi_wstrb[0]) begin
                            gpio_out_reg[7:0] <= s00_axi_wdata[7:0];
                        end
                        if (s00_axi_wstrb[1]) begin
                            gpio_out_reg[15:8] <= s00_axi_wdata[15:8];
                        end
                    end

                    REG_GPIO_SET: begin
                        gpio_out_reg <= gpio_out_reg | cmd_mask16;
                    end

                    REG_GPIO_CLR: begin
                        gpio_out_reg <= gpio_out_reg & (~cmd_mask16);
                    end

                    REG_GPIO_TOGGLE: begin
                        gpio_out_reg <= gpio_out_reg ^ cmd_mask16;
                    end

                    default: begin
                        gpio_out_reg <= gpio_out_reg;
                    end
                endcase
            end
        end
    end

    always @(*) begin
        case (read_addr_index)
            REG_GPIO_OUT: begin
                reg_data_out = {16'h0000, gpio_out_reg};
            end

            REG_GPIO_IN: begin
                reg_data_out = {6'b000000, btn_raw_sync, btn_level, sw_sync};
            end

            REG_GPIO_SET: begin
                reg_data_out = 32'h0000_0000;
            end

            REG_GPIO_CLR: begin
                reg_data_out = 32'h0000_0000;
            end

            REG_GPIO_TOGGLE: begin
                reg_data_out = 32'h0000_0000;
            end

            REG_BTN_EDGE: begin
                reg_data_out = {27'b0, btn_edge_reg};
            end

            REG_BTN_EDGE_CLR: begin
                reg_data_out = 32'h0000_0000;
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
