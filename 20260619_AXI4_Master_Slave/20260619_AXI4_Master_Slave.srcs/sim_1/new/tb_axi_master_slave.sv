`timescale 1ns / 1ps

module tb_axi_master_slave();

    localparam int AXI_DATA_WIDTH = 32;
    localparam int AXI_ADDR_WIDTH = 4;

    logic               ACLK    ;
    logic               ARESETn ;
    logic [31:0]        AWADDR  ;
    logic               AWVALID ;
    logic               AWREADY ;
    logic [31:0]        WDATA   ;
    logic [ 3:0]        WSTRB   ;
    logic               WVALID  ;
    logic               WREADY  ;
    logic [ 1:0]        BRESP   ;
    logic               BVALID  ;
    logic               BREADY  ;
    logic [31:0]        ARADDR  ;
    logic               ARVALID ;
    logic               ARREADY ;
    logic [31:0]        RDATA   ;
    logic               RVALID  ;
    logic               RREADY  ;
    logic [ 1:0]        RRESP   ;
    logic [ 2:0]        AWPROT  ;
    logic [ 2:0]        ARPROT  ;

    // internal control signals for the custom master
    logic               transfer;
    logic               ready   ;
    logic [31:0]        addr    ;
    logic [31:0]        wdata   ;
    logic [31:0]        rdata   ;
    logic               write   ;

    assign WSTRB  = 4'hF;
    assign AWPROT = 3'b000;
    assign ARPROT = 3'b000;

    AXI4_master dut_master (
        .ACLK    (ACLK),
        .RESET_N (ARESETn),
        .AWADDR  (AWADDR),
        .AWVALID (AWVALID),
        .AWREADY (AWREADY),
        .WDATA   (WDATA),
        .WVALID  (WVALID),
        .WREADY  (WREADY),
        .BRESP   (BRESP),
        .BVALID  (BVALID),
        .BREADY  (BREADY),
        .ARADDR  (ARADDR),
        .ARVALID (ARVALID),
        .ARREADY (ARREADY),
        .RDATA   (RDATA),
        .RVALID  (RVALID),
        .RREADY  (RREADY),
        .RRESP   (RRESP),
        .transfer(transfer),
        .ready   (ready),
        .addr    (addr),
        .wdata   (wdata),
        .write   (write),
        .rdata   (rdata)
    );

    myip_v1_0_S00_AXI #(
        .C_S_AXI_DATA_WIDTH(AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(AXI_ADDR_WIDTH)
    ) dut_slave (
        .S_AXI_ACLK   (ACLK),
        .S_AXI_ARESETN(ARESETn),
        .S_AXI_AWADDR (AWADDR[AXI_ADDR_WIDTH-1:0]),
        .S_AXI_AWPROT (AWPROT),
        .S_AXI_AWVALID(AWVALID),
        .S_AXI_AWREADY(AWREADY),
        .S_AXI_WDATA  (WDATA),
        .S_AXI_WSTRB  (WSTRB),
        .S_AXI_WVALID (WVALID),
        .S_AXI_WREADY (WREADY),
        .S_AXI_BRESP  (BRESP),
        .S_AXI_BVALID (BVALID),
        .S_AXI_BREADY (BREADY),
        .S_AXI_ARADDR (ARADDR[AXI_ADDR_WIDTH-1:0]),
        .S_AXI_ARPROT (ARPROT),
        .S_AXI_ARVALID(ARVALID),
        .S_AXI_ARREADY(ARREADY),
        .S_AXI_RDATA  (RDATA),
        .S_AXI_RRESP  (RRESP),
        .S_AXI_RVALID (RVALID),
        .S_AXI_RREADY (RREADY)
    );

    task automatic axi_write(
        input logic [31:0] Addr,
        input logic [31:0] data
    );
        @(posedge ACLK);
        addr     = Addr;
        wdata    = data;
        write    = 1'b1;
        transfer = 1'b1;
        @(posedge ACLK);
        transfer = 1'b0;
        wait (ready === 1'b1);
        #1;
        if (BRESP !== 2'b00) begin
            $fatal(1, "AXI WRITE BRESP error. Addr=0x%08h BRESP=%0b", Addr, BRESP);
        end
        $display("[%0t] AXI WRITE Addr=0x%08h WDATA=0x%08h", $time, Addr, data);
        @(posedge ACLK);
    endtask

    task automatic axi_read(
        input logic [31:0] Addr,
        input logic [31:0] expected
    );
        @(posedge ACLK);
        addr     = Addr;
        write    = 1'b0;
        transfer = 1'b1;
        @(posedge ACLK);
        transfer = 1'b0;
        wait (ready === 1'b1);
        #1;
        if (RRESP !== 2'b00) begin
            $fatal(1, "AXI READ RRESP error. Addr=0x%08h RRESP=%0b", Addr, RRESP);
        end
        if (rdata !== expected) begin
            $fatal(1, "AXI READ mismatch. Addr=0x%08h expected=0x%08h actual=0x%08h", Addr, expected, rdata);
        end
        $display("[%0t] AXI READ  Addr=0x%08h RDATA=0x%08h", $time, Addr, rdata);
        @(posedge ACLK);
    endtask

    always #5 ACLK = ~ACLK;

    initial begin
        #5000;
        $fatal(1, "Simulation timeout");
    end

    initial begin
        $timeformat(-9, 0, " ns", 8);

        ACLK     = 1'b0;
        ARESETn  = 1'b0;
        transfer = 1'b0;
        addr     = 32'h0000_0000;
        wdata    = 32'h0000_0000;
        write    = 1'b0;

        repeat (3) @(posedge ACLK);
        ARESETn = 1'b1;
        repeat (2) @(posedge ACLK);

        axi_write(32'h0000_0000, 32'h1111_1111);
        axi_write(32'h0000_0004, 32'h2222_2222);
        axi_write(32'h0000_0008, 32'h3333_3333);
        axi_write(32'h0000_000C, 32'h4444_4444);

        axi_read(32'h0000_0000, 32'h1111_1111);
        axi_read(32'h0000_0004, 32'h2222_2222);
        axi_read(32'h0000_0008, 32'h3333_3333);
        axi_read(32'h0000_000C, 32'h4444_4444);

        $display("PASS: custom AXI4_master + Xilinx AXI template slave simulation completed");
        #100;
        $finish;
    end

endmodule