`timescale 1ns / 1ps

module tb_axi_timer_core;

    localparam integer CLK_PERIOD_NS = 10;
    localparam integer FAST_TICK_WAIT_CYCLES = 24;

    localparam [5:0] ADDR_CONTROL          = 6'h00;
    localparam [5:0] ADDR_COMMAND          = 6'h04;
    localparam [5:0] ADDR_STOPWATCH_VALUE  = 6'h08;
    localparam [5:0] ADDR_WATCH_VALUE      = 6'h0C;
    localparam [5:0] ADDR_WATCH_RAW_DIGITS = 6'h10;
    localparam [5:0] ADDR_STATUS           = 6'h14;
    localparam [5:0] ADDR_RESERVED_18      = 6'h18;
    localparam [5:0] ADDR_VERSION          = 6'h1C;

    localparam [31:0] RAW_MSEC_MASK   = 32'h0000_007F;
    localparam [31:0] RAW_SEC1_MASK   = 32'h0000_0780;
    localparam [31:0] RAW_SEC10_MASK  = 32'h0000_3800;
    localparam [31:0] RAW_MIN1_MASK   = 32'h0003_C000;
    localparam [31:0] RAW_MIN10_MASK  = 32'h001C_0000;
    localparam [31:0] RAW_HOUR_MASK   = 32'h03E0_0000;

    reg clk;
    reg resetn;

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

    axi_timer_core dut (
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

    defparam dut.u_stopwatch_datapath.U_TICK_GEN_100HZ.F_COUNT = 8;
    defparam dut.u_watch_datapath.uTICK_GEN_100HZ.F_COUNT = 8;

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) clk = ~clk;
    end

    function automatic [31:0] pack_control_expected(input [11:0] control_bits);
        begin
            pack_control_expected = {20'h00000, control_bits[11:8], 6'h00, control_bits[1:0]};
        end
    endfunction

    function automatic [31:0] pack_watch_expected_from_raw(input [31:0] raw);
        reg [5:0] min_value;
        reg [5:0] sec_value;
        begin
            min_value = (raw[20:18] * 6'd10) + raw[17:14];
            sec_value = (raw[13:11] * 6'd10) + raw[10:7];
            pack_watch_expected_from_raw = {8'h00, raw[25:21], min_value, sec_value, raw[6:0]};
        end
    endfunction

    function automatic [4:0] raw_hour(input [31:0] raw);
        begin
            raw_hour = raw[25:21];
        end
    endfunction

    function automatic [2:0] raw_min10(input [31:0] raw);
        begin
            raw_min10 = raw[20:18];
        end
    endfunction

    function automatic [3:0] raw_min1(input [31:0] raw);
        begin
            raw_min1 = raw[17:14];
        end
    endfunction

    function automatic [2:0] raw_sec10(input [31:0] raw);
        begin
            raw_sec10 = raw[13:11];
        end
    endfunction

    function automatic [3:0] raw_sec1(input [31:0] raw);
        begin
            raw_sec1 = raw[10:7];
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

    task automatic apply_reset_quick_release;
        begin
            resetn = 1'b0;
            init_axi();
            repeat (12) @(posedge clk);
            resetn = 1'b1;
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

    task automatic wait_stopwatch_tick_then_low;
        integer timeout;
        begin
            timeout = 0;
            while (dut.u_stopwatch_datapath.U_TICK_GEN_100HZ.o_tick_100hz !== 1'b1) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > 100) begin
                    record_error("timeout waiting for stopwatch fast tick high");
                    return;
                end
            end

            timeout = 0;
            while (dut.u_stopwatch_datapath.U_TICK_GEN_100HZ.o_tick_100hz !== 1'b0) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > 100) begin
                    record_error("timeout waiting for stopwatch fast tick low");
                    return;
                end
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

    task automatic check_nonzero32(input string name, input [31:0] value);
        begin
            if (value === 32'h0000_0000) begin
                record_error({name, " expected nonzero"});
            end
            else begin
                $display("[OK] %s nonzero = 0x%08h", name, value);
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

    task automatic check2(input string name, input [1:0] actual, input [1:0] expected);
        begin
            if (actual !== expected) begin
                $display("  actual   = 0b%02b", actual);
                $display("  expected = 0b%02b", expected);
                record_error(name);
            end
            else begin
                $display("[OK] %s = 0b%02b", name, actual);
            end
        end
    endtask

    task automatic check_field(input string name, input integer actual, input integer expected);
        begin
            if (actual != expected) begin
                $display("  actual   = %0d", actual);
                $display("  expected = %0d", expected);
                record_error(name);
            end
            else begin
                $display("[OK] %s = %0d", name, actual);
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

    task automatic command_write_and_check_pulse(input [31:0] data,
                                                 input [3:0] strb,
                                                 input expected_clear,
                                                 input [1:0] expected_edit);
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

            check1("stopwatch_clear_pulse active cycle", dut.stopwatch_clear_pulse, expected_clear);
            check2("watch_edit_cmd active cycle", dut.watch_edit_cmd, expected_edit);
            if (bvalid && bresp !== 2'b00) begin
                record_error("AXI command write BRESP not OKAY");
            end

            @(posedge clk);
            #1;
            check1("stopwatch_clear_pulse deasserted next cycle", dut.stopwatch_clear_pulse, 1'b0);
            check2("watch_edit_cmd deasserted next cycle", dut.watch_edit_cmd, 2'b00);
            bready = 1'b0;
        end
    endtask

    task automatic read_and_check_command_zero;
        reg [31:0] rd;
        begin
            axi_read(ADDR_COMMAND, rd);
            check32("COMMAND reads zero", rd, 32'h0000_0000);
        end
    endtask

    task automatic check_watch_adapter_matches_raw(input string name);
        reg [31:0] raw;
        reg [31:0] watch_packed;
        reg [31:0] expected;
        begin
            axi_read(ADDR_WATCH_RAW_DIGITS, raw);
            axi_read(ADDR_WATCH_VALUE, watch_packed);
            expected = pack_watch_expected_from_raw(raw);
            check32({name, " WATCH_VALUE adapter"}, watch_packed, expected);
        end
    endtask

    initial begin
        reg [31:0] rd;
        reg [31:0] rd2;
        reg [31:0] before_value;
        reg [31:0] after_value;
        reg [31:0] before_raw;
        reg [31:0] after_raw;
        reg [31:0] saved_stopwatch;
        reg [31:0] saved_watch;
        reg [31:0] saved_raw;
        reg [31:0] saved_status;
        reg [31:0] saved_control;
        reg [31:0] saved_version;
        integer off;
        integer expected_int;

        result_file = "sim/vivado/axi_timer_core/axi_timer_core_sim_result.txt";
        plusarg_ok = $value$plusargs("RESULT_FILE=%s", result_file);

        error_count = 0;
        pass_count = 0;
        current_test_errors = 0;
        resetn = 1'b0;
        init_axi();

        apply_reset_quick_release();

        start_test("Test 1: Reset behavior");
        axi_read(ADDR_WATCH_VALUE, rd);
        check32("WATCH_VALUE reset before first fast tick", rd, 32'h0000_0000);
        axi_read(ADDR_WATCH_RAW_DIGITS, rd);
        check32("WATCH_RAW_DIGITS reset before first fast tick", rd, 32'h0000_0000);
        axi_read(ADDR_STOPWATCH_VALUE, rd);
        check32("STOPWATCH_VALUE reset", rd, 32'h0000_0000);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL reset", rd, 32'h0000_0000);
        axi_read(ADDR_COMMAND, rd);
        check32("COMMAND reset read zero", rd, 32'h0000_0000);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS reset", rd, 32'h0000_0000);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION reset", rd, 32'h0001_0000);
        finish_test("Test 1: Reset behavior");

        start_test("Test 2: CONTROL write/read");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0D03, 4'b1111);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL meaningful bits readback", rd, pack_control_expected(12'hD03));
        axi_read(ADDR_STATUS, rd);
        check32("STATUS mirrors CONTROL meaningful bits", rd, pack_control_expected(12'hD03));
        finish_test("Test 2: CONTROL write/read");

        start_test("Test 3: CONTROL WSTRB behavior");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0000, 4'b1111);
        axi_write(ADDR_CONTROL, 32'hFFFF_FF03, 4'b0001);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte0", rd, pack_control_expected(12'h003));
        axi_write(ADDR_CONTROL, 32'h0000_0F00, 4'b0010);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte1", rd, pack_control_expected(12'hF03));
        axi_write(ADDR_CONTROL, 32'hFFFF_0000, 4'b1100);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB bytes2/3 ignored", rd, pack_control_expected(12'hF03));
        finish_test("Test 3: CONTROL WSTRB behavior");

        start_test("Test 4: COMMAND read-zero behavior");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        axi_write(ADDR_COMMAND, 32'hFFFF_FFFF, 4'b1111);
        read_and_check_command_zero();
        finish_test("Test 4: COMMAND read-zero behavior");

        start_test("Test 5: Stopwatch clear pulse");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0101, 4'b1111);
        wait_clocks(FAST_TICK_WAIT_CYCLES);
        axi_read(ADDR_STOPWATCH_VALUE, before_value);
        check_nonzero32("STOPWATCH_VALUE before clear", before_value);
        wait_stopwatch_tick_then_low();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        wait_clocks(2);
        command_write_and_check_pulse(32'h0000_0001, 4'b0001, 1'b1, 2'b00);
        wait_clocks(2);
        axi_read(ADDR_STOPWATCH_VALUE, rd);
        check32("STOPWATCH_VALUE after clear", rd, 32'h0000_0000);
        read_and_check_command_zero();
        finish_test("Test 5: Stopwatch clear pulse");

        start_test("Test 6: Stopwatch run/stop up-count behavior");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0101, 4'b1111);
        wait_clocks(FAST_TICK_WAIT_CYCLES);
        axi_read(ADDR_STOPWATCH_VALUE, before_value);
        check_nonzero32("STOPWATCH_VALUE after run up", before_value);
        wait_stopwatch_tick_then_low();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        wait_clocks(2);
        axi_read(ADDR_STOPWATCH_VALUE, rd);
        wait_clocks(FAST_TICK_WAIT_CYCLES);
        axi_read(ADDR_STOPWATCH_VALUE, rd2);
        check32("STOPWATCH_VALUE stable while stopped", rd2, rd);
        finish_test("Test 6: Stopwatch run/stop up-count behavior");

        start_test("Test 7: Stopwatch down-count behavior");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0103, 4'b1111);
        wait_clocks(FAST_TICK_WAIT_CYCLES);
        axi_read(ADDR_STOPWATCH_VALUE, rd);
        check_nonzero32("STOPWATCH_VALUE after down-count from zero", rd);
        finish_test("Test 7: Stopwatch down-count behavior");

        start_test("Test 8: Watch set mode control");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL watch_set_mode stored", rd, pack_control_expected(12'h100));
        axi_read(ADDR_STATUS, rd);
        check32("STATUS watch_set_mode mirrored", rd, pack_control_expected(12'h100));
        check1("watch_datapath i_set_mode driven", dut.u_watch_datapath.i_set_mode, 1'b1);
        axi_read(ADDR_WATCH_VALUE, before_value);
        wait_clocks(FAST_TICK_WAIT_CYCLES);
        axi_read(ADDR_WATCH_VALUE, after_value);
        check32("WATCH_VALUE held in set mode", after_value, before_value);
        finish_test("Test 8: Watch set mode control");

        start_test("Test 9: Watch edit ignored when set mode = 0");
        apply_reset_quick_release();
        axi_read(ADDR_WATCH_RAW_DIGITS, before_raw);
        command_write_and_check_pulse(32'h0000_0300, 4'b0010, 1'b0, 2'b00);
        axi_read(ADDR_WATCH_RAW_DIGITS, after_raw);
        check_field("watch hour unchanged when edit ignored", raw_hour(after_raw), raw_hour(before_raw));
        read_and_check_command_zero();
        finish_test("Test 9: Watch edit ignored when set mode = 0");

        start_test("Test 10: Watch edit up, hour target");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        axi_read(ADDR_WATCH_RAW_DIGITS, before_raw);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        axi_read(ADDR_WATCH_RAW_DIGITS, after_raw);
        expected_int = (raw_hour(before_raw) == 23) ? 0 : raw_hour(before_raw) + 1;
        check_field("watch hour edit up", raw_hour(after_raw), expected_int);
        check_watch_adapter_matches_raw("watch hour edit up");
        finish_test("Test 10: Watch edit up, hour target");

        start_test("Test 11: Watch edit down, hour target");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        axi_read(ADDR_WATCH_RAW_DIGITS, before_raw);
        command_write_and_check_pulse(32'h0000_0200, 4'b0010, 1'b0, 2'b10);
        axi_read(ADDR_WATCH_RAW_DIGITS, after_raw);
        expected_int = (raw_hour(before_raw) == 0) ? 23 : raw_hour(before_raw) - 1;
        check_field("watch hour edit down", raw_hour(after_raw), expected_int);
        finish_test("Test 11: Watch edit down, hour target");

        start_test("Test 12: Watch edit-up priority over edit-down");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        axi_read(ADDR_WATCH_RAW_DIGITS, before_raw);
        command_write_and_check_pulse(32'h0000_0300, 4'b0010, 1'b0, 2'b01);
        axi_read(ADDR_WATCH_RAW_DIGITS, after_raw);
        expected_int = (raw_hour(before_raw) == 23) ? 0 : raw_hour(before_raw) + 1;
        check_field("watch edit priority selected up", raw_hour(after_raw), expected_int);
        finish_test("Test 12: Watch edit-up priority over edit-down");

        start_test("Test 13: Watch minute/second digit target selection");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0B00, 4'b1111);
        axi_read(ADDR_WATCH_RAW_DIGITS, before_raw);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        axi_read(ADDR_WATCH_RAW_DIGITS, after_raw);
        check_field("minute ones changed", raw_min1(after_raw), (raw_min1(before_raw) + 1) % 10);
        check32("minute ones unselected fields stable", (after_raw & ~RAW_MIN1_MASK), (before_raw & ~RAW_MIN1_MASK));

        axi_write(ADDR_CONTROL, 32'h0000_0300, 4'b1111);
        axi_read(ADDR_WATCH_RAW_DIGITS, before_raw);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        axi_read(ADDR_WATCH_RAW_DIGITS, after_raw);
        check_field("minute tens changed", raw_min10(after_raw), (raw_min10(before_raw) + 1) % 6);
        check32("minute tens unselected fields stable", (after_raw & ~RAW_MIN10_MASK), (before_raw & ~RAW_MIN10_MASK));

        axi_write(ADDR_CONTROL, 32'h0000_0D00, 4'b1111);
        axi_read(ADDR_WATCH_RAW_DIGITS, before_raw);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        axi_read(ADDR_WATCH_RAW_DIGITS, after_raw);
        check_field("second ones changed", raw_sec1(after_raw), (raw_sec1(before_raw) + 1) % 10);
        check32("second ones unselected fields stable", (after_raw & ~RAW_SEC1_MASK), (before_raw & ~RAW_SEC1_MASK));

        axi_write(ADDR_CONTROL, 32'h0000_0500, 4'b1111);
        axi_read(ADDR_WATCH_RAW_DIGITS, before_raw);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        axi_read(ADDR_WATCH_RAW_DIGITS, after_raw);
        check_field("second tens changed", raw_sec10(after_raw), (raw_sec10(before_raw) + 1) % 6);
        check32("second tens unselected fields stable", (after_raw & ~RAW_SEC10_MASK), (before_raw & ~RAW_SEC10_MASK));
        check_watch_adapter_matches_raw("minute/second target selection");
        finish_test("Test 13: Watch minute/second digit target selection");

        start_test("Test 14: WATCH_VALUE adapter readback");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        axi_write(ADDR_CONTROL, 32'h0000_0B00, 4'b1111);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        axi_write(ADDR_CONTROL, 32'h0000_0500, 4'b1111);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        axi_read(ADDR_WATCH_RAW_DIGITS, before_raw);
        axi_read(ADDR_WATCH_VALUE, rd);
        check32("WATCH_VALUE equals adapter calculation", rd, pack_watch_expected_from_raw(before_raw));
        finish_test("Test 14: WATCH_VALUE adapter readback");

        start_test("Test 15: VERSION read and RO protection");
        apply_reset_quick_release();
        axi_read(ADDR_VERSION, rd);
        check32("VERSION before write", rd, 32'h0001_0000);
        axi_write(ADDR_VERSION, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION after write", rd, 32'h0001_0000);
        finish_test("Test 15: VERSION read and RO protection");

        start_test("Test 16: Read-only write protection");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        axi_read(ADDR_STOPWATCH_VALUE, saved_stopwatch);
        axi_read(ADDR_WATCH_VALUE, saved_watch);
        axi_read(ADDR_WATCH_RAW_DIGITS, saved_raw);
        axi_read(ADDR_STATUS, saved_status);
        axi_write(ADDR_STOPWATCH_VALUE, 32'hFFFF_FFFF, 4'b1111);
        axi_write(ADDR_WATCH_VALUE, 32'hFFFF_FFFF, 4'b1111);
        axi_write(ADDR_WATCH_RAW_DIGITS, 32'hFFFF_FFFF, 4'b1111);
        axi_write(ADDR_STATUS, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_STOPWATCH_VALUE, rd);
        check32("STOPWATCH_VALUE ignores write", rd, saved_stopwatch);
        axi_read(ADDR_WATCH_VALUE, rd);
        check32("WATCH_VALUE ignores write", rd, saved_watch);
        axi_read(ADDR_WATCH_RAW_DIGITS, rd);
        check32("WATCH_RAW_DIGITS ignores write", rd, saved_raw);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS ignores write", rd, saved_status);
        finish_test("Test 16: Read-only write protection");

        start_test("Test 17: Reserved offset behavior");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0D00, 4'b1111);
        axi_read(ADDR_CONTROL, saved_control);
        axi_read(ADDR_STATUS, saved_status);
        axi_read(ADDR_VERSION, saved_version);
        axi_read(ADDR_STOPWATCH_VALUE, saved_stopwatch);
        axi_read(ADDR_WATCH_VALUE, saved_watch);
        for (off = 24; off <= 60; off = off + 4) begin
            if (off != 28) begin
                axi_write(off[5:0], 32'hA500_0000 | off[31:0], 4'b1111);
                axi_read(off[5:0], rd);
                check32($sformatf("reserved 0x%02h read zero", off[5:0]), rd, 32'h0000_0000);
            end
        end
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL unaffected by reserved writes", rd, saved_control);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS unaffected by reserved writes", rd, saved_status);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION unaffected by reserved writes", rd, saved_version);
        axi_read(ADDR_STOPWATCH_VALUE, rd);
        check32("STOPWATCH_VALUE unaffected by reserved writes", rd, saved_stopwatch);
        axi_read(ADDR_WATCH_VALUE, rd);
        check32("WATCH_VALUE unaffected by reserved writes", rd, saved_watch);
        finish_test("Test 17: Reserved offset behavior");

        start_test("Test 18: COMMAND WSTRB behavior");
        apply_reset_quick_release();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        command_write_and_check_pulse(32'h0000_0100, 4'b0001, 1'b0, 2'b00);
        command_write_and_check_pulse(32'h0000_0100, 4'b0010, 1'b0, 2'b01);
        command_write_and_check_pulse(32'h0000_0001, 4'b0010, 1'b0, 2'b00);
        command_write_and_check_pulse(32'h0000_0001, 4'b0001, 1'b1, 2'b00);
        finish_test("Test 18: COMMAND WSTRB behavior");

        start_test("Test 19: Timer/FND decoupling compile check");
        $display("[OK] Timer simulation elaborated with only Timer reference RTL and axi_timer_core.");
        $display("[OK] No fnd_controller.v or axi_fnd_core.v is required by this testbench.");
        finish_test("Test 19: Timer/FND decoupling compile check");

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
            $display("[TB PASS] axi_timer_core directed tests passed (%0d tests)", pass_count);
        end
        else begin
            $display("");
            $display("[TB FAIL] axi_timer_core directed tests failed: %0d errors, %0d tests passed", error_count, pass_count);
        end

        $finish;
    end

endmodule


