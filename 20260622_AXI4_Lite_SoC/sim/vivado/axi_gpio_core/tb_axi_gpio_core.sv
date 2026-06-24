`timescale 1ns / 1ps

module tb_axi_gpio_core;

    localparam integer CLK_PERIOD_NS = 10;
    localparam integer DEBOUNCE_WAIT_CYCLES = 1000000;

    localparam [5:0] ADDR_GPIO_OUT     = 6'h00;
    localparam [5:0] ADDR_GPIO_IN      = 6'h04;
    localparam [5:0] ADDR_GPIO_SET     = 6'h08;
    localparam [5:0] ADDR_GPIO_CLR     = 6'h0C;
    localparam [5:0] ADDR_GPIO_TOGGLE  = 6'h10;
    localparam [5:0] ADDR_BTN_EDGE     = 6'h14;
    localparam [5:0] ADDR_BTN_EDGE_CLR = 6'h18;
    localparam [5:0] ADDR_VERSION      = 6'h1C;

    reg clk;
    reg resetn;

    reg [15:0] sw_i;
    reg [4:0] btn_i;
    wire [15:0] led_o;

    reg [5:0] awaddr;
    reg [2:0] awprot;
    reg awvalid;
    wire awready;
    reg [31:0] wdata;
    reg [3:0] wstrb;
    reg wvalid;
    wire wready;
    wire [1:0] bresp;
    wire bvalid;
    reg bready;
    reg [5:0] araddr;
    reg [2:0] arprot;
    reg arvalid;
    wire arready;
    wire [31:0] rdata;
    wire [1:0] rresp;
    wire rvalid;
    reg rready;

    integer error_count;
    integer pass_count;
    integer current_test_errors;
    integer result_fd;
    string result_file;

    axi_gpio_core dut (
        .sw_i             (sw_i),
        .btn_i            (btn_i),
        .led_o            (led_o),
        .s00_axi_aclk     (clk),
        .s00_axi_aresetn  (resetn),
        .s00_axi_awaddr   (awaddr),
        .s00_axi_awprot   (awprot),
        .s00_axi_awvalid  (awvalid),
        .s00_axi_awready  (awready),
        .s00_axi_wdata    (wdata),
        .s00_axi_wstrb    (wstrb),
        .s00_axi_wvalid   (wvalid),
        .s00_axi_wready   (wready),
        .s00_axi_bresp    (bresp),
        .s00_axi_bvalid   (bvalid),
        .s00_axi_bready   (bready),
        .s00_axi_araddr   (araddr),
        .s00_axi_arprot   (arprot),
        .s00_axi_arvalid  (arvalid),
        .s00_axi_arready  (arready),
        .s00_axi_rdata    (rdata),
        .s00_axi_rresp    (rresp),
        .s00_axi_rvalid   (rvalid),
        .s00_axi_rready   (rready)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) clk = ~clk;
    end

    task automatic init_axi;
        begin
            awaddr  = 6'h00;
            awprot  = 3'b000;
            awvalid = 1'b0;
            wdata   = 32'h0000_0000;
            wstrb   = 4'b0000;
            wvalid  = 1'b0;
            bready  = 1'b0;
            araddr  = 6'h00;
            arprot  = 3'b000;
            arvalid = 1'b0;
            rready  = 1'b0;
        end
    endtask

    task automatic apply_reset;
        begin
            resetn = 1'b0;
            sw_i   = 16'h0000;
            btn_i  = 5'b00000;
            init_axi();
            repeat (20) @(posedge clk);
            resetn = 1'b1;
            repeat (10) @(posedge clk);
        end
    endtask

    task automatic start_test(input string name);
        begin
            current_test_errors = 0;
            $display("");
            $display("=== %s ===", name);
        end
    endtask

    task automatic finish_test(input string name);
        begin
            if (current_test_errors == 0) begin
                pass_count = pass_count + 1;
                $display("[PASS] %s", name);
            end
            else begin
                $display("[FAIL] %s (%0d check errors)", name, current_test_errors);
            end
        end
    endtask

    task automatic record_error(input string msg);
        begin
            error_count = error_count + 1;
            current_test_errors = current_test_errors + 1;
            $display("[CHECK FAIL] %s", msg);
        end
    endtask

    task automatic check32(input string name, input [31:0] actual, input [31:0] expected);
        begin
            if (actual !== expected) begin
                $display("  actual   = 0x%08h", actual);
                $display("  expected = 0x%08h", expected);
                record_error(name);
            end
            else begin
                $display("[OK] %s = 0x%08h", name, actual);
            end
        end
    endtask

    task automatic check16(input string name, input [15:0] actual, input [15:0] expected);
        begin
            if (actual !== expected) begin
                $display("  actual   = 0x%04h", actual);
                $display("  expected = 0x%04h", expected);
                record_error(name);
            end
            else begin
                $display("[OK] %s = 0x%04h", name, actual);
            end
        end
    endtask

    task automatic check5(input string name, input [4:0] actual, input [4:0] expected);
        begin
            if (actual !== expected) begin
                $display("  actual   = 0b%05b", actual);
                $display("  expected = 0b%05b", expected);
                record_error(name);
            end
            else begin
                $display("[OK] %s = 0b%05b", name, actual);
            end
        end
    endtask

    task automatic axi_write(input [5:0] addr, input [31:0] data, input [3:0] strb);
        integer timeout;
        bit aw_seen;
        bit w_seen;
        begin
            aw_seen = 1'b0;
            w_seen = 1'b0;
            timeout = 0;

            @(posedge clk);
            #1;
            awaddr = addr;
            wdata = data;
            wstrb = strb;
            awvalid = 1'b1;
            wvalid = 1'b1;
            bready = 1'b1;

            while (!(aw_seen && w_seen)) begin
                @(posedge clk);
                #1;
                if (awvalid && awready) begin
                    aw_seen = 1'b1;
                end
                if (wvalid && wready) begin
                    w_seen = 1'b1;
                end
                timeout = timeout + 1;
                if (timeout > 100) begin
                    awvalid = 1'b0;
                    wvalid = 1'b0;
                    bready = 1'b0;
                    record_error($sformatf("AXI write handshake timeout at addr 0x%02h", addr));
                    return;
                end
            end

            @(posedge clk);
            #1;
            awvalid = 1'b0;
            wvalid = 1'b0;

            timeout = 0;
            while (!bvalid) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > 100) begin
                    bready = 1'b0;
                    record_error($sformatf("AXI write response timeout at addr 0x%02h", addr));
                    return;
                end
            end

            if (bresp !== 2'b00) begin
                record_error($sformatf("AXI write BRESP not OKAY at addr 0x%02h", addr));
            end

            @(posedge clk);
            #1;
            bready = 1'b0;
        end
    endtask

    task automatic axi_read(input [5:0] addr, output [31:0] data);
        integer timeout;
        begin
            timeout = 0;
            data = 32'h0000_0000;

            @(posedge clk);
            #1;
            araddr = addr;
            arvalid = 1'b1;
            rready = 1'b1;

            while (!arready) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > 100) begin
                    arvalid = 1'b0;
                    rready = 1'b0;
                    record_error($sformatf("AXI read address timeout at addr 0x%02h", addr));
                    return;
                end
            end

            @(posedge clk);
            #1;
            arvalid = 1'b0;

            timeout = 0;
            while (!rvalid) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > 100) begin
                    rready = 1'b0;
                    record_error($sformatf("AXI read data timeout at addr 0x%02h", addr));
                    return;
                end
            end

            data = rdata;
            if (rresp !== 2'b00) begin
                record_error($sformatf("AXI read RRESP not OKAY at addr 0x%02h", addr));
            end

            @(posedge clk);
            #1;
            rready = 1'b0;
        end
    endtask

    task automatic wait_sync;
        begin
            repeat (8) @(posedge clk);
            #1;
        end
    endtask

    task automatic wait_debounce;
        integer i;
        begin
            for (i = 0; i < DEBOUNCE_WAIT_CYCLES; i = i + 1) begin
                @(posedge clk);
            end
            #1;
        end
    endtask

    task automatic write_gpio_out(input [15:0] value);
        begin
            axi_write(ADDR_GPIO_OUT, {16'h0000, value}, 4'b1111);
        end
    endtask

    task automatic read_and_check_gpio_out(input string name, input [15:0] expected);
        reg [31:0] rd;
        begin
            axi_read(ADDR_GPIO_OUT, rd);
            check32({name, " readback"}, rd, {16'h0000, expected});
            check16({name, " led_o"}, led_o, expected);
        end
    endtask

    initial begin
        reg [31:0] rd;
        integer off;
        reg [15:0] saved_led;
        reg [4:0] saved_edge;

        result_file = "sim/vivado/axi_gpio_core/axi_gpio_core_sim_result.txt";
        void'($value$plusargs("RESULT_FILE=%s", result_file));

        error_count = 0;
        pass_count = 0;
        current_test_errors = 0;
        resetn = 1'b0;
        sw_i = 16'h0000;
        btn_i = 5'b00000;
        init_axi();

        apply_reset();

        start_test("Test 1: Reset behavior");
        axi_read(ADDR_GPIO_OUT, rd);
        check32("GPIO_OUT reset", rd, 32'h0000_0000);
        check16("led_o reset", led_o, 16'h0000);
        axi_read(ADDR_BTN_EDGE, rd);
        check32("BTN_EDGE reset", rd, 32'h0000_0000);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION reset", rd, 32'h0001_0000);
        axi_read(6'h20, rd);
        check32("reserved 0x20 reset read", rd, 32'h0000_0000);
        finish_test("Test 1: Reset behavior");

        start_test("Test 2: GPIO_OUT write/read");
        axi_write(ADDR_GPIO_OUT, 32'h0000_00F0, 4'b1111);
        read_and_check_gpio_out("GPIO_OUT 0x00F0", 16'h00F0);
        axi_write(ADDR_GPIO_OUT, 32'hFFFF_A5A5, 4'b1111);
        read_and_check_gpio_out("GPIO_OUT reserved upper ignored", 16'hA5A5);
        finish_test("Test 2: GPIO_OUT write/read");

        start_test("Test 3: WSTRB behavior on GPIO_OUT");
        axi_write(ADDR_GPIO_OUT, 32'h0000_003C, 4'b0001);
        read_and_check_gpio_out("GPIO_OUT low-byte strobe", 16'hA53C);
        axi_write(ADDR_GPIO_OUT, 32'h0000_1200, 4'b0010);
        read_and_check_gpio_out("GPIO_OUT high-byte strobe", 16'h123C);
        finish_test("Test 3: WSTRB behavior on GPIO_OUT");

        start_test("Test 4: GPIO_SET");
        write_gpio_out(16'h0000);
        axi_write(ADDR_GPIO_SET, 32'h0000_0003, 4'b1111);
        read_and_check_gpio_out("GPIO_SET mask", 16'h0003);
        axi_read(ADDR_GPIO_SET, rd);
        check32("GPIO_SET read as zero", rd, 32'h0000_0000);
        finish_test("Test 4: GPIO_SET");

        start_test("Test 5: GPIO_CLR");
        write_gpio_out(16'h00FF);
        axi_write(ADDR_GPIO_CLR, 32'h0000_000F, 4'b1111);
        read_and_check_gpio_out("GPIO_CLR mask", 16'h00F0);
        axi_read(ADDR_GPIO_CLR, rd);
        check32("GPIO_CLR read as zero", rd, 32'h0000_0000);
        finish_test("Test 5: GPIO_CLR");

        start_test("Test 6: GPIO_TOGGLE");
        write_gpio_out(16'h00F0);
        axi_write(ADDR_GPIO_TOGGLE, 32'h0000_0001, 4'b1111);
        read_and_check_gpio_out("GPIO_TOGGLE mask", 16'h00F1);
        axi_read(ADDR_GPIO_TOGGLE, rd);
        check32("GPIO_TOGGLE read as zero", rd, 32'h0000_0000);
        finish_test("Test 6: GPIO_TOGGLE");

        start_test("Test 7: GPIO_IN switch and raw button synchronization");
        sw_i = 16'h1234;
        btn_i = 5'b10101;
        wait_sync();
        axi_read(ADDR_GPIO_IN, rd);
        check16("GPIO_IN sw_sync", rd[15:0], 16'h1234);
        check5("GPIO_IN btn_raw_sync", rd[25:21], 5'b10101);
        check32("GPIO_IN reserved high bits", {26'h0, rd[31:26]}, 32'h0000_0000);
        finish_test("Test 7: GPIO_IN switch and raw button synchronization");

        start_test("Test 8: Button debounce level and edge flag");
        btn_i = 5'b00000;
        wait_debounce();
        btn_i = 5'b00001;
        wait_debounce();
        axi_read(ADDR_GPIO_IN, rd);
        check5("GPIO_IN btn_debounced bit0", rd[20:16], 5'b00001);
        axi_read(ADDR_BTN_EDGE, rd);
        check5("BTN_EDGE bit0 latched", rd[4:0], 5'b00001);
        repeat (20) @(posedge clk);
        axi_read(ADDR_BTN_EDGE, rd);
        check5("BTN_EDGE bit0 remains latched", rd[4:0], 5'b00001);
        finish_test("Test 8: Button debounce level and edge flag");

        start_test("Test 9: BTN_EDGE_CLR");
        btn_i = 5'b00011;
        wait_debounce();
        axi_read(ADDR_BTN_EDGE, rd);
        check5("BTN_EDGE bits 1:0 set before clear", rd[4:0], 5'b00011);
        axi_write(ADDR_BTN_EDGE_CLR, 32'h0000_0001, 4'b1111);
        axi_read(ADDR_BTN_EDGE, rd);
        check5("BTN_EDGE clear bit0 keeps bit1", rd[4:0], 5'b00010);
        axi_read(ADDR_BTN_EDGE_CLR, rd);
        check32("BTN_EDGE_CLR read as zero", rd, 32'h0000_0000);
        finish_test("Test 9: BTN_EDGE_CLR");

        start_test("Test 10: Reserved offsets");
        write_gpio_out(16'h5A5A);
        axi_read(ADDR_BTN_EDGE, rd);
        saved_edge = rd[4:0];
        saved_led = led_o;
        for (off = 32; off <= 60; off = off + 4) begin
            axi_write(off[5:0], 32'hDEAD_0000 | off[31:0], 4'b1111);
            axi_read(off[5:0], rd);
            check32($sformatf("reserved 0x%02h read", off[5:0]), rd, 32'h0000_0000);
        end
        axi_read(ADDR_GPIO_OUT, rd);
        check32("GPIO_OUT unaffected by reserved writes", rd, {16'h0000, saved_led});
        axi_read(ADDR_BTN_EDGE, rd);
        check5("BTN_EDGE unaffected by reserved writes", rd[4:0], saved_edge);
        finish_test("Test 10: Reserved offsets");

        start_test("Test 11: Read-only write protection");
        sw_i = 16'hBEEF;
        btn_i = 5'b00100;
        wait_sync();
        axi_read(ADDR_BTN_EDGE, rd);
        saved_edge = rd[4:0];
        axi_write(ADDR_GPIO_IN, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_GPIO_IN, rd);
        check16("GPIO_IN sw after RO write", rd[15:0], 16'hBEEF);
        check5("GPIO_IN raw button after RO write", rd[25:21], 5'b00100);
        axi_write(ADDR_BTN_EDGE, 32'h0000_001F, 4'b1111);
        axi_read(ADDR_BTN_EDGE, rd);
        check5("BTN_EDGE not overwritten by RO write", rd[4:0], saved_edge);
        axi_write(ADDR_VERSION, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION remains fixed after write", rd, 32'h0001_0000);
        finish_test("Test 11: Read-only write protection");

        start_test("Test 12: WSTRB on command registers");
        write_gpio_out(16'h0000);
        axi_write(ADDR_GPIO_SET, 32'h0000_00AA, 4'b0001);
        read_and_check_gpio_out("GPIO_SET low-byte strobe", 16'h00AA);
        axi_write(ADDR_GPIO_SET, 32'h0000_5500, 4'b0010);
        read_and_check_gpio_out("GPIO_SET high-byte strobe", 16'h55AA);

        write_gpio_out(16'hFFFF);
        axi_write(ADDR_GPIO_CLR, 32'h0000_000F, 4'b0001);
        read_and_check_gpio_out("GPIO_CLR low-byte strobe", 16'hFFF0);
        axi_write(ADDR_GPIO_CLR, 32'h0000_0F00, 4'b0010);
        read_and_check_gpio_out("GPIO_CLR high-byte strobe", 16'hF0F0);

        write_gpio_out(16'h0000);
        axi_write(ADDR_GPIO_TOGGLE, 32'h0000_000F, 4'b0001);
        read_and_check_gpio_out("GPIO_TOGGLE low-byte strobe", 16'h000F);
        axi_write(ADDR_GPIO_TOGGLE, 32'h0000_F000, 4'b0010);
        read_and_check_gpio_out("GPIO_TOGGLE high-byte strobe", 16'hF00F);

        axi_read(ADDR_BTN_EDGE, rd);
        check5("BTN_EDGE bit1 available for WSTRB clear test", rd[4:0], 5'b00010);
        axi_write(ADDR_BTN_EDGE_CLR, 32'h0000_0002, 4'b0010);
        axi_read(ADDR_BTN_EDGE, rd);
        check5("BTN_EDGE_CLR high byte strobe ignored", rd[4:0], 5'b00010);
        axi_write(ADDR_BTN_EDGE_CLR, 32'h0000_0002, 4'b0001);
        axi_read(ADDR_BTN_EDGE, rd);
        check5("BTN_EDGE_CLR low byte strobe clears", rd[4:0], 5'b00000);
        finish_test("Test 12: WSTRB on command registers");

        result_fd = $fopen(result_file, "w");
        if (result_fd == 0) begin
            $display("[WARN] Could not open result file: %s", result_file);
        end
        else begin
            if (error_count == 0) begin
                $fdisplay(result_fd, "PASS tests_passed=%0d errors=%0d", pass_count, error_count);
            end
            else begin
                $fdisplay(result_fd, "FAIL tests_passed=%0d errors=%0d", pass_count, error_count);
            end
            $fclose(result_fd);
        end

        if (error_count == 0) begin
            $display("");
            $display("[TB PASS] axi_gpio_core directed tests passed (%0d tests)", pass_count);
        end
        else begin
            $display("");
            $display("[TB FAIL] axi_gpio_core directed tests failed: %0d errors, %0d tests passed", error_count, pass_count);
        end

        $finish;
    end

endmodule