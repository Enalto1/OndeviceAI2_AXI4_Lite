`timescale 1ns / 1ps

module tb_axi_fnd_core;

    localparam integer CLK_PERIOD_NS = 10;
    localparam integer SCAN_OBSERVE_CYCLES = 300;

    localparam [5:0] ADDR_CONTROL      = 6'h00;
    localparam [5:0] ADDR_TIMER_VALUE  = 6'h04;
    localparam [5:0] ADDR_SENSOR_VALUE = 6'h08;
    localparam [5:0] ADDR_FND_OUTPUT   = 6'h0C;
    localparam [5:0] ADDR_VERSION      = 6'h1C;

    reg clk;
    reg resetn;

    wire [3:0] fnd_com_o;
    wire [7:0] fnd_data_o;

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

    axi_fnd_core #(
        .FND_DIV_COUNT     (8),
        .FND_DOT_THRESHOLD (2)
    ) dut (
        .fnd_com_o        (fnd_com_o),
        .fnd_data_o       (fnd_data_o),
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
            init_axi();
            repeat (20) @(posedge clk);
            resetn = 1'b1;
            repeat (20) @(posedge clk);
            #1;
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

    task automatic check4(input string name, input [3:0] actual, input [3:0] expected);
        begin
            if (actual !== expected) begin
                $display("  actual   = 0b%04b", actual);
                $display("  expected = 0b%04b", expected);
                record_error(name);
            end
            else begin
                $display("[OK] %s = 0b%04b", name, actual);
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

    task automatic check_blank_outputs(input string name);
        begin
            check4({name, " fnd_com_o blank"}, fnd_com_o, 4'b1111);
            check8({name, " fnd_data_o blank"}, fnd_data_o, 8'hFF);
        end
    endtask

    task automatic observe_scan(input integer cycles,
                                output integer seen_1110,
                                output integer seen_1101,
                                output integer seen_1011,
                                output integer seen_0111,
                                output integer nonblank_seen);
        integer i;
        begin
            seen_1110 = 0;
            seen_1101 = 0;
            seen_1011 = 0;
            seen_0111 = 0;
            nonblank_seen = 0;
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge clk);
                #1;
                case (fnd_com_o)
                    4'b1110: seen_1110 = 1;
                    4'b1101: seen_1101 = 1;
                    4'b1011: seen_1011 = 1;
                    4'b0111: seen_0111 = 1;
                    default: begin
                    end
                endcase
                if (fnd_data_o !== 8'hFF) begin
                    nonblank_seen = 1;
                end
            end
        end
    endtask

    task automatic wait_for_scan_activity(input string name);
        integer seen_1110;
        integer seen_1101;
        integer seen_1011;
        integer seen_0111;
        integer nonblank_seen;
        integer active_count;
        begin
            observe_scan(SCAN_OBSERVE_CYCLES, seen_1110, seen_1101, seen_1011, seen_0111, nonblank_seen);
            active_count = seen_1110 + seen_1101 + seen_1011 + seen_0111;
            if (active_count < 2) begin
                $display("  seen 1110=%0d 1101=%0d 1011=%0d 0111=%0d", seen_1110, seen_1101, seen_1011, seen_0111);
                record_error({name, " scan activity"});
            end
            else begin
                $display("[OK] %s scan activity saw %0d active digit enables", name, active_count);
            end
        end
    endtask

    task automatic check_output_not_permanently_blank(input string name);
        integer seen_1110;
        integer seen_1101;
        integer seen_1011;
        integer seen_0111;
        integer nonblank_seen;
        begin
            observe_scan(SCAN_OBSERVE_CYCLES, seen_1110, seen_1101, seen_1011, seen_0111, nonblank_seen);
            if (nonblank_seen == 0) begin
                record_error({name, " fnd_data_o permanently blank"});
            end
            else begin
                $display("[OK] %s fnd_data_o was not permanently blank", name);
            end
        end
    endtask

    task automatic read_and_check_fnd_output_matches(input string name);
        reg [31:0] rd;
        integer attempt;
        integer matched;
        begin
            matched = 0;
            for (attempt = 0; attempt < 8; attempt = attempt + 1) begin
                axi_read(ADDR_FND_OUTPUT, rd);
                if ((rd[31:16] === 16'h0000) &&
                    (rd[7:4] === 4'h0) &&
                    (rd[3:0] === fnd_com_o) &&
                    (rd[15:8] === fnd_data_o)) begin
                    matched = 1;
                end
                repeat (4) @(posedge clk);
                #1;
            end
            if (matched == 0) begin
                $display("  last rd       = 0x%08h", rd);
                $display("  current com   = 0b%04b", fnd_com_o);
                $display("  current data  = 0x%02h", fnd_data_o);
                record_error({name, " FND_OUTPUT readback did not match current gated outputs"});
            end
            else begin
                $display("[OK] %s FND_OUTPUT matched final gated outputs", name);
            end
        end
    endtask

    initial begin
        reg [31:0] rd;
        reg [31:0] expected_timer;
        reg [31:0] expected_sensor;
        reg [31:0] saved_control;
        reg [31:0] saved_timer;
        reg [31:0] saved_sensor;
        integer off;

        result_file = "sim/vivado/axi_fnd_core/axi_fnd_core_sim_result.txt";
        plusarg_ok = $value$plusargs("RESULT_FILE=%s", result_file);

        error_count = 0;
        pass_count = 0;
        current_test_errors = 0;
        resetn = 1'b0;
        init_axi();

        apply_reset();

        start_test("Test 1: Reset behavior");
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL reset", rd, 32'h0000_0000);
        axi_read(ADDR_TIMER_VALUE, rd);
        check32("TIMER_VALUE reset", rd, 32'h0000_0000);
        axi_read(ADDR_SENSOR_VALUE, rd);
        check32("SENSOR_VALUE reset", rd, 32'h0000_0000);
        axi_read(ADDR_FND_OUTPUT, rd);
        check32("FND_OUTPUT reset blank readback", rd, 32'h0000_FF0F);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION reset", rd, 32'h0001_0000);
        check_blank_outputs("reset");
        finish_test("Test 1: Reset behavior");

        start_test("Test 2: CONTROL enable/disable");
        axi_write(ADDR_CONTROL, 32'h0000_0000, 4'b1111);
        check_blank_outputs("CONTROL display_enable=0");
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b1111);
        wait_for_scan_activity("CONTROL display_enable=1");
        check_output_not_permanently_blank("CONTROL display_enable=1");
        finish_test("Test 2: CONTROL enable/disable");

        start_test("Test 3: TIMER_VALUE write/read");
        expected_timer = ((32'd1 << 19) | (32'd5 << 13) | (32'd34 << 7) | 32'd12);
        axi_write(ADDR_TIMER_VALUE, expected_timer, 4'b1111);
        axi_read(ADDR_TIMER_VALUE, rd);
        check32("TIMER_VALUE representative readback", rd, expected_timer);
        check32("TIMER_VALUE upper reserved zero", {24'h0, rd[31:24]}, 32'h0000_0000);
        finish_test("Test 3: TIMER_VALUE write/read");

        start_test("Test 4: SENSOR_VALUE write/read");
        expected_sensor = ((32'd27 << 17) | (32'd45 << 9) | 32'd123);
        axi_write(ADDR_SENSOR_VALUE, expected_sensor, 4'b1111);
        axi_read(ADDR_SENSOR_VALUE, rd);
        check32("SENSOR_VALUE representative readback", rd, expected_sensor);
        check32("SENSOR_VALUE upper reserved zero", {25'h0, rd[31:25]}, 32'h0000_0000);
        finish_test("Test 4: SENSOR_VALUE write/read");

        start_test("Test 5: Timer low display mode");
        expected_timer = ((32'd1 << 19) | (32'd5 << 13) | (32'd34 << 7) | 32'd12);
        axi_write(ADDR_TIMER_VALUE, expected_timer, 4'b1111);
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b1111);
        wait_for_scan_activity("timer low mode");
        check_output_not_permanently_blank("timer low mode");
        read_and_check_fnd_output_matches("timer low mode");
        finish_test("Test 5: Timer low display mode");

        start_test("Test 6: Timer high display mode");
        expected_timer = ((32'd23 << 19) | (32'd58 << 13) | (32'd45 << 7) | 32'd99);
        axi_write(ADDR_TIMER_VALUE, expected_timer, 4'b1111);
        axi_write(ADDR_CONTROL, 32'h0000_0009, 4'b1111);
        wait_for_scan_activity("timer high mode");
        check_output_not_permanently_blank("timer high mode");
        finish_test("Test 6: Timer high display mode");

        start_test("Test 7: Distance display mode");
        expected_sensor = ((32'd27 << 17) | (32'd45 << 9) | 32'd123);
        axi_write(ADDR_SENSOR_VALUE, expected_sensor, 4'b1111);
        axi_write(ADDR_CONTROL, 32'h0000_0005, 4'b1111);
        wait_for_scan_activity("distance mode");
        check_output_not_permanently_blank("distance mode");
        finish_test("Test 7: Distance display mode");

        start_test("Test 8: DHT humidity display mode");
        expected_sensor = ((32'd27 << 17) | (32'd45 << 9) | 32'd123);
        axi_write(ADDR_SENSOR_VALUE, expected_sensor, 4'b1111);
        axi_write(ADDR_CONTROL, 32'h0000_0007, 4'b1111);
        wait_for_scan_activity("DHT humidity mode");
        check_output_not_permanently_blank("DHT humidity mode");
        finish_test("Test 8: DHT humidity display mode");

        start_test("Test 9: DHT temperature display mode");
        axi_write(ADDR_CONTROL, 32'h0000_000F, 4'b1111);
        wait_for_scan_activity("DHT temperature mode");
        check_output_not_permanently_blank("DHT temperature mode");
        finish_test("Test 9: DHT temperature display mode");

        start_test("Test 10: FND_OUTPUT readback");
        axi_write(ADDR_CONTROL, 32'h0000_0000, 4'b1111);
        axi_read(ADDR_FND_OUTPUT, rd);
        check32("FND_OUTPUT disabled blank", rd, 32'h0000_FF0F);
        check_blank_outputs("FND_OUTPUT disabled");
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b1111);
        wait_for_scan_activity("FND_OUTPUT enabled");
        read_and_check_fnd_output_matches("FND_OUTPUT enabled");
        finish_test("Test 10: FND_OUTPUT readback");

        start_test("Test 11: WSTRB behavior on CONTROL");
        axi_write(ADDR_CONTROL, 32'h0000_0000, 4'b1111);
        axi_write(ADDR_CONTROL, 32'hFFFF_FFFE, 4'b1111);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL full strobe reserved ignored", rd, 32'h0000_000E);
        check_blank_outputs("CONTROL bit0 remains 0 after full strobe");
        axi_write(ADDR_CONTROL, 32'h0000_0101, 4'b0010);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL byte1 strobe no visible effect", rd, 32'h0000_000E);
        finish_test("Test 11: WSTRB behavior on CONTROL");

        start_test("Test 12: WSTRB behavior on TIMER_VALUE");
        axi_write(ADDR_TIMER_VALUE, 32'h00A1_B2C3, 4'b1111);
        axi_read(ADDR_TIMER_VALUE, rd);
        check32("TIMER_VALUE full write", rd, 32'h00A1_B2C3);
        axi_write(ADDR_TIMER_VALUE, 32'h0000_005A, 4'b0001);
        axi_read(ADDR_TIMER_VALUE, rd);
        check32("TIMER_VALUE byte0 partial", rd, 32'h00A1_B25A);
        axi_write(ADDR_TIMER_VALUE, 32'h0000_6600, 4'b0010);
        axi_read(ADDR_TIMER_VALUE, rd);
        check32("TIMER_VALUE byte1 partial", rd, 32'h00A1_665A);
        axi_write(ADDR_TIMER_VALUE, 32'h0077_0000, 4'b0100);
        axi_read(ADDR_TIMER_VALUE, rd);
        check32("TIMER_VALUE byte2 partial", rd, 32'h0077_665A);
        axi_write(ADDR_TIMER_VALUE, 32'hFF00_0000, 4'b1000);
        axi_read(ADDR_TIMER_VALUE, rd);
        check32("TIMER_VALUE byte3 ignored", rd, 32'h0077_665A);
        finish_test("Test 12: WSTRB behavior on TIMER_VALUE");

        start_test("Test 13: WSTRB behavior on SENSOR_VALUE");
        axi_write(ADDR_SENSOR_VALUE, 32'h0155_AA33, 4'b1111);
        axi_read(ADDR_SENSOR_VALUE, rd);
        check32("SENSOR_VALUE full write", rd, 32'h0155_AA33);
        axi_write(ADDR_SENSOR_VALUE, 32'h0000_007E, 4'b0001);
        axi_read(ADDR_SENSOR_VALUE, rd);
        check32("SENSOR_VALUE byte0 partial", rd, 32'h0155_AA7E);
        axi_write(ADDR_SENSOR_VALUE, 32'h0000_4400, 4'b0010);
        axi_read(ADDR_SENSOR_VALUE, rd);
        check32("SENSOR_VALUE byte1 partial", rd, 32'h0155_447E);
        axi_write(ADDR_SENSOR_VALUE, 32'h0023_0000, 4'b0100);
        axi_read(ADDR_SENSOR_VALUE, rd);
        check32("SENSOR_VALUE byte2 partial", rd, 32'h0123_447E);
        axi_write(ADDR_SENSOR_VALUE, 32'h0000_0000, 4'b1000);
        axi_read(ADDR_SENSOR_VALUE, rd);
        check32("SENSOR_VALUE byte3 bit24 clear", rd, 32'h0023_447E);
        axi_write(ADDR_SENSOR_VALUE, 32'h0100_0000, 4'b1000);
        axi_read(ADDR_SENSOR_VALUE, rd);
        check32("SENSOR_VALUE byte3 bit24 set", rd, 32'h0123_447E);
        finish_test("Test 13: WSTRB behavior on SENSOR_VALUE");

        start_test("Test 14: VERSION read and RO protection");
        axi_read(ADDR_VERSION, rd);
        check32("VERSION before write", rd, 32'h0001_0000);
        axi_write(ADDR_VERSION, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION after write", rd, 32'h0001_0000);
        finish_test("Test 14: VERSION read and RO protection");

        start_test("Test 15: FND_OUTPUT RO protection");
        axi_write(ADDR_CONTROL, 32'h0000_0000, 4'b1111);
        axi_read(ADDR_FND_OUTPUT, rd);
        check32("FND_OUTPUT before write", rd, 32'h0000_FF0F);
        axi_write(ADDR_FND_OUTPUT, 32'h0000_0000, 4'b1111);
        axi_read(ADDR_FND_OUTPUT, rd);
        check32("FND_OUTPUT after write remains gated", rd, 32'h0000_FF0F);
        finish_test("Test 15: FND_OUTPUT RO protection");

        start_test("Test 16: Reserved offsets");
        axi_write(ADDR_CONTROL, 32'h0000_0000, 4'b1111);
        axi_write(ADDR_TIMER_VALUE, 32'h0012_3456, 4'b1111);
        axi_write(ADDR_SENSOR_VALUE, 32'h01AB_CDEF, 4'b1111);
        axi_read(ADDR_CONTROL, saved_control);
        axi_read(ADDR_TIMER_VALUE, saved_timer);
        axi_read(ADDR_SENSOR_VALUE, saved_sensor);
        for (off = 16; off <= 60; off = off + 4) begin
            if (off != 28) begin
                axi_write(off[5:0], 32'hDEAD_0000 | off[31:0], 4'b1111);
                axi_read(off[5:0], rd);
                check32($sformatf("reserved 0x%02h read", off[5:0]), rd, 32'h0000_0000);
            end
        end
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL unaffected by reserved writes", rd, saved_control);
        axi_read(ADDR_TIMER_VALUE, rd);
        check32("TIMER_VALUE unaffected by reserved writes", rd, saved_timer);
        axi_read(ADDR_SENSOR_VALUE, rd);
        check32("SENSOR_VALUE unaffected by reserved writes", rd, saved_sensor);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION unaffected by reserved writes", rd, 32'h0001_0000);
        check_blank_outputs("reserved writes do not unblank display");
        finish_test("Test 16: Reserved offsets");

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
            $display("[TB PASS] axi_fnd_core directed tests passed (%0d tests)", pass_count);
        end
        else begin
            $display("");
            $display("[TB FAIL] axi_fnd_core directed tests failed: %0d errors, %0d tests passed", error_count, pass_count);
        end

        $finish;
    end

endmodule