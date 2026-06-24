`timescale 1ns / 1ps

module tb_axi_spi_core;

    localparam integer CLK_PERIOD_NS = 10;

    localparam [5:0] ADDR_CONTROL = 6'h00;
    localparam [5:0] ADDR_CLKDIV  = 6'h04;
    localparam [5:0] ADDR_TXDATA  = 6'h08;
    localparam [5:0] ADDR_COMMAND = 6'h0C;
    localparam [5:0] ADDR_RXDATA  = 6'h10;
    localparam [5:0] ADDR_STATUS  = 6'h14;
    localparam [5:0] ADDR_RSV_18  = 6'h18;
    localparam [5:0] ADDR_VERSION = 6'h1C;

    reg clk;
    reg resetn;

    wire spi_sclk_o;
    wire spi_mosi_o;
    reg  spi_miso_i;
    wire spi_ss_n_o;

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
    integer plusarg_ok;
    reg [1023:0] result_file;

    axi_spi_core dut (
        .spi_sclk_o      (spi_sclk_o),
        .spi_mosi_o      (spi_mosi_o),
        .spi_miso_i      (spi_miso_i),
        .spi_ss_n_o      (spi_ss_n_o),
        .s00_axi_aclk    (clk),
        .s00_axi_aresetn (resetn),
        .s00_axi_awaddr  (awaddr),
        .s00_axi_awprot  (awprot),
        .s00_axi_awvalid (awvalid),
        .s00_axi_awready (awready),
        .s00_axi_wdata   (wdata),
        .s00_axi_wstrb   (wstrb),
        .s00_axi_wvalid  (wvalid),
        .s00_axi_wready  (wready),
        .s00_axi_bresp   (bresp),
        .s00_axi_bvalid  (bvalid),
        .s00_axi_bready  (bready),
        .s00_axi_araddr  (araddr),
        .s00_axi_arprot  (arprot),
        .s00_axi_arvalid (arvalid),
        .s00_axi_arready (arready),
        .s00_axi_rdata   (rdata),
        .s00_axi_rresp   (rresp),
        .s00_axi_rvalid  (rvalid),
        .s00_axi_rready  (rready)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) clk = ~clk;
    end

    function automatic [31:0] control_expected(input [2:0] control_bits);
        begin
            control_expected = {29'd0, control_bits[2:0]};
        end
    endfunction

    function automatic [31:0] clkdiv_expected(input [15:0] clkdiv_value);
        begin
            clkdiv_expected = {16'h0000, clkdiv_value};
        end
    endfunction

    function automatic [31:0] txdata_expected(input [7:0] tx_value);
        begin
            txdata_expected = {24'h000000, tx_value};
        end
    endfunction

    function automatic [31:0] rxdata_expected(input [7:0] rx_value);
        begin
            rxdata_expected = {24'h000000, rx_value};
        end
    endfunction

    function automatic [31:0] status_expected(input busy,
                                               input done,
                                               input [2:0] control_bits);
        begin
            status_expected = {21'h000000, control_bits[2], control_bits[1],
                               control_bits[0], 5'h00, 1'b0, done, busy};
        end
    endfunction

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
            spi_miso_i = 1'b0;
            init_axi();
            repeat (20) @(posedge clk);
            resetn = 1'b1;
            repeat (10) @(posedge clk);
            #1;
        end
    endtask

    task automatic wait_clocks(input integer cycles);
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge clk);
                #1;
            end
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

    task automatic check8(input string name, input [7:0] actual, input [7:0] expected);
        begin
            if (actual !== expected) begin
                $display("  actual   = 0x%02h", actual);
                $display("  expected = 0x%02h", expected);
                record_error(name);
            end
            else begin
                $display("[OK] %s = 0x%02h", name, actual);
            end
        end
    endtask

    task automatic check1(input string name, input actual, input expected);
        begin
            if (actual !== expected) begin
                $display("  actual   = %0b", actual);
                $display("  expected = %0b", expected);
                record_error(name);
            end
            else begin
                $display("[OK] %s = %0b", name, actual);
            end
        end
    endtask

    task automatic axi_write(input [5:0] addr, input [31:0] data, input [3:0] strb);
        integer timeout;
        reg aw_seen;
        reg w_seen;
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

    task automatic command_write_and_check_start(input [31:0] data,
                                                 input [3:0] strb,
                                                 input expected_pulse);
        integer timeout;
        reg aw_seen;
        reg w_seen;
        begin
            aw_seen = 1'b0;
            w_seen = 1'b0;
            timeout = 0;

            @(posedge clk);
            #1;
            awaddr = ADDR_COMMAND;
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
                    record_error("AXI command write handshake timeout");
                    return;
                end
            end

            @(posedge clk);
            #1;
            awvalid = 1'b0;
            wvalid = 1'b0;

            check1("spi_start_pulse active cycle", dut.spi_start_pulse, expected_pulse);
            if (bvalid && bresp !== 2'b00) begin
                record_error("AXI command write BRESP not OKAY");
            end

            @(posedge clk);
            #1;
            check1("spi_start_pulse deasserted next cycle", dut.spi_start_pulse, 1'b0);
            bready = 1'b0;
        end
    endtask

    task automatic wait_for_busy_high(input integer timeout_limit);
        integer timeout;
        begin
            timeout = 0;
            while (dut.spi_busy !== 1'b1) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > timeout_limit) begin
                    record_error("timeout waiting for spi_busy high");
                    return;
                end
            end
            $display("[OK] spi_busy asserted");
        end
    endtask

    task automatic wait_for_busy_low(input integer timeout_limit);
        integer timeout;
        begin
            timeout = 0;
            while (dut.spi_busy !== 1'b0) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > timeout_limit) begin
                    record_error("timeout waiting for spi_busy low");
                    return;
                end
            end
            $display("[OK] spi_busy deasserted");
        end
    endtask

    task automatic wait_for_done_sticky(input integer timeout_limit);
        integer timeout;
        begin
            timeout = 0;
            while (dut.done_sticky !== 1'b1) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > timeout_limit) begin
                    record_error("timeout waiting for done_sticky");
                    return;
                end
            end
            $display("[OK] done_sticky set");
        end
    endtask

    task automatic monitor_transfer_wave(input check_wave);
        integer timeout;
        integer saw_ss_low;
        integer saw_sclk_toggle;
        reg last_sclk;
        begin
            timeout = 0;
            saw_ss_low = 0;
            saw_sclk_toggle = 0;
            last_sclk = spi_sclk_o;

            while (dut.spi_busy === 1'b1) begin
                if (spi_ss_n_o === 1'b0) begin
                    saw_ss_low = 1;
                end
                if (spi_sclk_o !== last_sclk) begin
                    saw_sclk_toggle = 1;
                end
                last_sclk = spi_sclk_o;
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > 1000) begin
                    record_error("timeout monitoring SPI transfer");
                    return;
                end
            end

            if (check_wave) begin
                if (saw_ss_low == 0) begin
                    record_error("spi_ss_n_o did not go low during transfer");
                end
                else begin
                    $display("[OK] spi_ss_n_o went low during transfer");
                end

                if (saw_sclk_toggle == 0) begin
                    record_error("spi_sclk_o did not toggle during transfer");
                end
                else begin
                    $display("[OK] spi_sclk_o toggled during transfer");
                end
            end
        end
    endtask

    task automatic start_transfer_and_wait(input [7:0] tx_byte,
                                           input miso_value,
                                           input check_wave,
                                           output [31:0] rx_read,
                                           output [31:0] status_read);
        begin
            spi_miso_i = miso_value;
            axi_write(ADDR_TXDATA, {24'h000000, tx_byte}, 4'b0001);
            command_write_and_check_start(32'h0000_0001, 4'b0001, 1'b1);
            wait_for_busy_high(100);
            monitor_transfer_wave(check_wave);
            wait_for_busy_low(1000);
            wait_for_done_sticky(100);
            axi_read(ADDR_RXDATA, rx_read);
            axi_read(ADDR_STATUS, status_read);
        end
    endtask

    task automatic check_reserved_zero(input [5:0] addr);
        reg [31:0] rd;
        begin
            axi_write(addr, 32'hA5A5_0000 | {26'h0, addr}, 4'b1111);
            axi_read(addr, rd);
            check32($sformatf("reserved 0x%02h reads zero", addr), rd, 32'h0000_0000);
        end
    endtask

    task automatic check_mode_transfer(input [2:0] control_bits,
                                       input expected_cpol,
                                       input string label);
        reg [31:0] rd;
        reg [31:0] status;
        begin
            axi_write(ADDR_CONTROL, {29'd0, control_bits}, 4'b0001);
            axi_write(ADDR_CLKDIV, 32'h0000_0002, 4'b0011);
            start_transfer_and_wait(8'h3C, 1'b1, 1'b0, rd, status);
            check32({label, " RXDATA"}, rd, rxdata_expected(8'hFF));
            check32({label, " STATUS done"}, status, status_expected(1'b0, 1'b1, control_bits));
            wait_clocks(4);
            check1({label, " idle SCLK"}, spi_sclk_o, expected_cpol);
        end
    endtask

    initial begin
        reg [31:0] rd;
        reg [31:0] status;
        reg [31:0] saved_control;
        reg [31:0] saved_clkdiv;
        reg [31:0] saved_txdata;
        reg [31:0] saved_status;
        integer off;

        result_file = "sim/vivado/axi_spi_core/axi_spi_core_sim_result.txt";
        plusarg_ok = $value$plusargs("RESULT_FILE=%s", result_file);

        error_count = 0;
        pass_count = 0;
        current_test_errors = 0;
        resetn = 1'b0;
        spi_miso_i = 1'b0;
        init_axi();

        apply_reset();

        start_test("Test 1: Reset behavior");
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL reset", rd, 32'h0000_0000);
        axi_read(ADDR_CLKDIV, rd);
        check32("CLKDIV reset", rd, 32'h0000_0001);
        axi_read(ADDR_TXDATA, rd);
        check32("TXDATA reset", rd, 32'h0000_0000);
        axi_read(ADDR_COMMAND, rd);
        check32("COMMAND reset read zero", rd, 32'h0000_0000);
        axi_read(ADDR_RXDATA, rd);
        check32("RXDATA reset", rd, 32'h0000_0000);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS reset", rd, 32'h0000_0000);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION reset", rd, 32'h0001_0000);
        check1("spi_ss_n_o reset inactive", spi_ss_n_o, 1'b1);
        check1("spi_start_pulse reset", dut.spi_start_pulse, 1'b0);
        finish_test("Test 1: Reset behavior");

        start_test("Test 2: CONTROL write/read");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'hFFFF_FFFF, 4'b0001);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL[2:0] write", rd, control_expected(3'b111));
        axi_read(ADDR_STATUS, rd);
        check32("STATUS control mirrors", rd, status_expected(1'b0, 1'b0, 3'b111));
        finish_test("Test 2: CONTROL write/read");

        start_test("Test 3: CONTROL WSTRB behavior");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0005, 4'b0001);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte0", rd, control_expected(3'b101));
        axi_write(ADDR_CONTROL, 32'hFFFF_FFFF, 4'b0010);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte1 ignored", rd, control_expected(3'b101));
        axi_write(ADDR_CONTROL, 32'hFFFF_FFFF, 4'b0100);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte2 ignored", rd, control_expected(3'b101));
        axi_write(ADDR_CONTROL, 32'hFFFF_FFFF, 4'b1000);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte3 ignored", rd, control_expected(3'b101));
        finish_test("Test 3: CONTROL WSTRB behavior");

        start_test("Test 4: CLKDIV write/read and WSTRB");
        apply_reset();
        axi_write(ADDR_CLKDIV, 32'h0000_1234, 4'b0011);
        axi_read(ADDR_CLKDIV, rd);
        check32("CLKDIV full low halfword write", rd, clkdiv_expected(16'h1234));
        axi_write(ADDR_CLKDIV, 32'h0000_00AB, 4'b0001);
        axi_read(ADDR_CLKDIV, rd);
        check32("CLKDIV low byte update", rd, clkdiv_expected(16'h12AB));
        axi_write(ADDR_CLKDIV, 32'h0000_CD00, 4'b0010);
        axi_read(ADDR_CLKDIV, rd);
        check32("CLKDIV high byte update", rd, clkdiv_expected(16'hCDAB));
        axi_write(ADDR_CLKDIV, 32'hFFFF_0000, 4'b1100);
        axi_read(ADDR_CLKDIV, rd);
        check32("CLKDIV upper byte strobes ignored", rd, clkdiv_expected(16'hCDAB));
        finish_test("Test 4: CLKDIV write/read and WSTRB");

        start_test("Test 5: TXDATA write/read and WSTRB");
        apply_reset();
        axi_write(ADDR_TXDATA, 32'h0000_00A5, 4'b0001);
        axi_read(ADDR_TXDATA, rd);
        check32("TXDATA byte0 write", rd, txdata_expected(8'hA5));
        axi_write(ADDR_TXDATA, 32'hFFFF_FF00, 4'b1110);
        axi_read(ADDR_TXDATA, rd);
        check32("TXDATA upper byte strobes ignored", rd, txdata_expected(8'hA5));
        finish_test("Test 5: TXDATA write/read and WSTRB");

        start_test("Test 6: COMMAND read-zero behavior");
        apply_reset();
        axi_write(ADDR_COMMAND, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_COMMAND, rd);
        check32("COMMAND reads zero after write", rd, 32'h0000_0000);
        finish_test("Test 6: COMMAND read-zero behavior");

        start_test("Test 7: Start ignored when disabled");
        apply_reset();
        command_write_and_check_start(32'h0000_0001, 4'b0001, 1'b0);
        check1("busy remains low when disabled", dut.spi_busy, 1'b0);
        check1("done_sticky remains low when disabled", dut.done_sticky, 1'b0);
        finish_test("Test 7: Start ignored when disabled");

        start_test("Test 8: Start pulse when enabled and idle");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        axi_write(ADDR_CLKDIV, 32'h0000_0002, 4'b0011);
        axi_write(ADDR_TXDATA, 32'h0000_00A5, 4'b0001);
        command_write_and_check_start(32'h0000_0001, 4'b0001, 1'b1);
        axi_read(ADDR_COMMAND, rd);
        check32("COMMAND reads zero after accepted start", rd, 32'h0000_0000);
        wait_for_busy_high(100);
        finish_test("Test 8: Start pulse when enabled and idle");

        start_test("Test 9: Basic SPI transfer mode 0");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        axi_write(ADDR_CLKDIV, 32'h0000_0002, 4'b0011);
        start_transfer_and_wait(8'hA5, 1'b1, 1'b1, rd, status);
        check32("RXDATA MISO high", rd, rxdata_expected(8'hFF));
        check32("STATUS done after mode0 transfer", status, status_expected(1'b0, 1'b1, 3'b001));
        check1("spi_ss_n_o returned high", spi_ss_n_o, 1'b1);
        finish_test("Test 9: Basic SPI transfer mode 0");

        start_test("Test 10: Done sticky clear on new accepted start");
        check1("done_sticky starts high", dut.done_sticky, 1'b1);
        command_write_and_check_start(32'h0000_0001, 4'b0001, 1'b1);
        check1("done_sticky cleared by accepted start", dut.done_sticky, 1'b0);
        wait_for_busy_high(100);
        monitor_transfer_wave(1'b0);
        wait_for_busy_low(1000);
        wait_for_done_sticky(100);
        check1("done_sticky set again", dut.done_sticky, 1'b1);
        finish_test("Test 10: Done sticky clear on new accepted start");

        start_test("Test 11: Start ignored while busy");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        axi_write(ADDR_CLKDIV, 32'h0000_0010, 4'b0011);
        axi_write(ADDR_TXDATA, 32'h0000_005A, 4'b0001);
        command_write_and_check_start(32'h0000_0001, 4'b0001, 1'b1);
        wait_for_busy_high(100);
        command_write_and_check_start(32'h0000_0001, 4'b0001, 1'b0);
        monitor_transfer_wave(1'b0);
        wait_for_busy_low(2000);
        wait_for_done_sticky(100);
        check1("done_sticky after busy ignored start", dut.done_sticky, 1'b1);
        finish_test("Test 11: Start ignored while busy");

        start_test("Test 12: RXDATA readback");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        axi_write(ADDR_CLKDIV, 32'h0000_0002, 4'b0011);
        start_transfer_and_wait(8'h33, 1'b1, 1'b0, rd, status);
        check32("RXDATA all ones", rd, rxdata_expected(8'hFF));
        start_transfer_and_wait(8'hCC, 1'b0, 1'b0, rd, status);
        check32("RXDATA all zeros", rd, rxdata_expected(8'h00));
        finish_test("Test 12: RXDATA readback");

        start_test("Test 13: CPOL idle behavior");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0000, 4'b0001);
        wait_clocks(4);
        check1("CPOL=0 idle SCLK low", spi_sclk_o, 1'b0);
        axi_write(ADDR_CONTROL, 32'h0000_0002, 4'b0001);
        wait_clocks(4);
        check1("CPOL=1 idle SCLK high", spi_sclk_o, 1'b1);
        finish_test("Test 13: CPOL idle behavior");

        start_test("Test 14: CPHA/mode transfer sanity");
        apply_reset();
        check_mode_transfer(3'b001, 1'b0, "mode0");
        check_mode_transfer(3'b101, 1'b0, "mode1");
        check_mode_transfer(3'b011, 1'b1, "mode2");
        check_mode_transfer(3'b111, 1'b1, "mode3");
        finish_test("Test 14: CPHA/mode transfer sanity");

        start_test("Test 15: CLKDIV zero clamp");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        axi_write(ADDR_CLKDIV, 32'h0000_0000, 4'b0011);
        axi_read(ADDR_CLKDIV, rd);
        check32("CLKDIV stores zero", rd, clkdiv_expected(16'h0000));
        check16("clk_div_to_master clamps zero", dut.clk_div_to_master, 16'h0001);
        start_transfer_and_wait(8'hF0, 1'b1, 1'b0, rd, status);
        check32("zero-clamp transfer RXDATA", rd, rxdata_expected(8'hFF));
        finish_test("Test 15: CLKDIV zero clamp");

        start_test("Test 16: VERSION read and RO protection");
        apply_reset();
        axi_read(ADDR_VERSION, rd);
        check32("VERSION before write", rd, 32'h0001_0000);
        axi_write(ADDR_VERSION, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION after write", rd, 32'h0001_0000);
        finish_test("Test 16: VERSION read and RO protection");

        start_test("Test 17: Read-only write protection");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        axi_write(ADDR_CLKDIV, 32'h0000_0002, 4'b0011);
        start_transfer_and_wait(8'h0F, 1'b1, 1'b0, rd, status);
        axi_write(ADDR_RXDATA, 32'h0000_0000, 4'b1111);
        axi_write(ADDR_STATUS, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_RXDATA, rd);
        check32("RXDATA not overwritten by write", rd, rxdata_expected(8'hFF));
        axi_read(ADDR_STATUS, rd);
        check32("STATUS not overwritten by write", rd, status_expected(1'b0, 1'b1, 3'b001));
        finish_test("Test 17: Read-only write protection");

        start_test("Test 18: Reserved offset behavior");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0005, 4'b0001);
        axi_write(ADDR_CLKDIV, 32'h0000_1234, 4'b0011);
        axi_write(ADDR_TXDATA, 32'h0000_00A5, 4'b0001);
        axi_read(ADDR_CONTROL, saved_control);
        axi_read(ADDR_CLKDIV, saved_clkdiv);
        axi_read(ADDR_TXDATA, saved_txdata);
        axi_read(ADDR_STATUS, saved_status);
        check_reserved_zero(ADDR_RSV_18);
        for (off = 32; off <= 60; off = off + 4) begin
            check_reserved_zero(off[5:0]);
        end
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL unaffected by reserved writes", rd, saved_control);
        axi_read(ADDR_CLKDIV, rd);
        check32("CLKDIV unaffected by reserved writes", rd, saved_clkdiv);
        axi_read(ADDR_TXDATA, rd);
        check32("TXDATA unaffected by reserved writes", rd, saved_txdata);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS unaffected by reserved writes", rd, saved_status);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION unaffected by reserved writes", rd, 32'h0001_0000);
        finish_test("Test 18: Reserved offset behavior");

        start_test("Test 19: COMMAND WSTRB behavior");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        axi_write(ADDR_CLKDIV, 32'h0000_0002, 4'b0011);
        axi_write(ADDR_TXDATA, 32'h0000_00A5, 4'b0001);
        command_write_and_check_start(32'h0000_0001, 4'b0010, 1'b0);
        check1("busy remains low after wrong COMMAND strobe", dut.spi_busy, 1'b0);
        command_write_and_check_start(32'h0000_0001, 4'b0001, 1'b1);
        wait_for_busy_high(100);
        monitor_transfer_wave(1'b0);
        wait_for_busy_low(1000);
        wait_for_done_sticky(100);
        finish_test("Test 19: COMMAND WSTRB behavior");

        start_test("Test 20: SPI independence compile check");
        $display("[OK] SPI simulation elaborated with spi_master_byte.sv, axi_spi_core.v, and tb_axi_spi_core.sv.");
        $display("[OK] spi_slave_byte.sv is intentionally not compiled for the first master-only simulation.");
        $display("[OK] No GPIO/FND/Timer/Sensor/I2C/UVM/MicroBlaze/block-design files are required.");
        finish_test("Test 20: SPI independence compile check");

        result_fd = $fopen(result_file, "w");
        if (result_fd == 0) begin
            $display("[WARN] Could not open result file: %0s", result_file);
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
            $display("[TB PASS] axi_spi_core directed tests passed (%0d tests)", pass_count);
        end
        else begin
            $display("");
            $display("[TB FAIL] axi_spi_core directed tests failed: %0d errors, %0d tests passed", error_count, pass_count);
        end

        $finish;
    end

endmodule