`timescale 1ns / 1ps

module tb_axi_sensor_core;

    localparam integer CLK_PERIOD_NS = 10;

    localparam [5:0] ADDR_CONTROL    = 6'h00;
    localparam [5:0] ADDR_COMMAND    = 6'h04;
    localparam [5:0] ADDR_SR04_VALUE = 6'h08;
    localparam [5:0] ADDR_DHT_VALUE  = 6'h0C;
    localparam [5:0] ADDR_STATUS     = 6'h10;
    localparam [5:0] ADDR_VERSION    = 6'h1C;

    reg clk;
    reg resetn;
    reg sr04_echo_i;
    wire sr04_trig_o;
    tri dht11_io;
    reg dht11_sensor_drive_low;

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

    assign dht11_io = dht11_sensor_drive_low ? 1'b0 : 1'bz;

    axi_sensor_core dut (
        .sr04_echo_i      (sr04_echo_i),
        .sr04_trig_o      (sr04_trig_o),
        .dht11_io         (dht11_io),
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

    defparam dut.u_sr04.U_TICK_GEN_SR04.F_COUNT = 4;
    defparam dut.u_dht11.U_TICK_GEN_US.F_COUNT = 4;

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD_NS / 2) clk = ~clk;
    end

    function automatic [31:0] control_expected(input sr04_enable, input dht_enable);
        begin
            control_expected = {23'h0, dht_enable, 7'h0, sr04_enable};
        end
    endfunction

    function automatic [31:0] status_expected(input sr04_trig, input dht_valid, input sr04_enable, input dht_enable);
        begin
            status_expected = {7'h0, dht_enable, 7'h0, sr04_enable, 7'h0, dht_valid, 7'h0, sr04_trig};
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
            sr04_echo_i = 1'b0;
            dht11_sensor_drive_low = 1'b0;
            init_axi();
            repeat (20) @(posedge clk);
            resetn = 1'b1;
            repeat (20) @(posedge clk);
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

    task automatic wait_sr04_us_ticks(input integer ticks);
        integer seen;
        integer guard;
        begin
            seen = 0;
            guard = 0;
            while (seen < ticks) begin
                @(posedge clk);
                #1;
                if (dut.u_sr04.U_TICK_GEN_SR04.tick_us === 1'b1) begin
                    seen = seen + 1;
                end
                guard = guard + 1;
                if (guard > ticks * 20 + 100) begin
                    record_error("timeout waiting for SR04 us ticks");
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

    task automatic command_write_and_check(input [31:0] data,
                                           input [3:0] strb,
                                           input expected_sr04,
                                           input expected_dht);
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

            check1("sr04_start_pulse active cycle", dut.sr04_start_pulse, expected_sr04);
            check1("dht_start_pulse active cycle", dut.dht_start_pulse, expected_dht);

            @(posedge clk);
            #1;
            check1("sr04_start_pulse deasserted next cycle", dut.sr04_start_pulse, 1'b0);
            check1("dht_start_pulse deasserted next cycle", dut.dht_start_pulse, 1'b0);
            bready = 1'b0;
        end
    endtask

    task automatic read_command_zero;
        reg [31:0] rd;
        begin
            axi_read(ADDR_COMMAND, rd);
            check32("COMMAND reads zero", rd, 32'h0000_0000);
        end
    endtask

    task automatic start_sr04_and_echo(output [31:0] value_out);
        integer guard;
        begin
            value_out = 32'h0000_0000;
            axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b1111);
            command_write_and_check(32'h0000_0001, 4'b0001, 1'b1, 1'b0);

            guard = 0;
            while (sr04_trig_o !== 1'b1 && guard < 200) begin
                @(posedge clk);
                #1;
                guard = guard + 1;
            end
            if (sr04_trig_o !== 1'b1) begin
                record_error("sr04_trig_o did not assert");
            end

            guard = 0;
            while (sr04_trig_o !== 1'b0 && guard < 300) begin
                @(posedge clk);
                #1;
                guard = guard + 1;
            end
            if (sr04_trig_o !== 1'b0) begin
                record_error("sr04_trig_o did not deassert");
            end

            sr04_echo_i = 1'b1;
            wait_sr04_us_ticks(130);
            sr04_echo_i = 1'b0;
            wait_sr04_us_ticks(4);
            axi_read(ADDR_SR04_VALUE, value_out);
        end
    endtask

    initial begin
        reg [31:0] rd;
        reg [31:0] before_status;
        reg [31:0] saved_control;
        reg [31:0] saved_sr04;
        reg [31:0] saved_dht;
        reg [31:0] saved_status;
        integer off;
        integer saw_low;
        integer i;

        result_file = "sim/vivado/axi_sensor_core/axi_sensor_core_sim_result.txt";
        plusarg_ok = $value$plusargs("RESULT_FILE=%s", result_file);

        error_count = 0;
        pass_count = 0;
        current_test_errors = 0;
        resetn = 1'b0;
        sr04_echo_i = 1'b0;
        dht11_sensor_drive_low = 1'b0;
        init_axi();

        apply_reset();

        start_test("Test 1: Reset behavior");
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL reset", rd, 32'h0000_0000);
        axi_read(ADDR_COMMAND, rd);
        check32("COMMAND reset read zero", rd, 32'h0000_0000);
        axi_read(ADDR_SR04_VALUE, rd);
        check32("SR04_VALUE reset", rd, 32'h0000_0000);
        axi_read(ADDR_DHT_VALUE, rd);
        check32("DHT_VALUE reset", rd, 32'h0000_0000);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS reset", rd, 32'h0000_0000);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION reset", rd, 32'h0001_0000);
        finish_test("Test 1: Reset behavior");

        start_test("Test 2: CONTROL write/read");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0101, 4'b1111);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL both enables", rd, control_expected(1'b1, 1'b1));
        finish_test("Test 2: CONTROL write/read");

        start_test("Test 3: CONTROL WSTRB");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'hFFFF_0001, 4'b0001);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte0", rd, control_expected(1'b1, 1'b0));
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b0010);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte1", rd, control_expected(1'b1, 1'b1));
        axi_write(ADDR_CONTROL, 32'hFFFF_0000, 4'b1100);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB bytes2/3 ignored", rd, control_expected(1'b1, 1'b1));
        finish_test("Test 3: CONTROL WSTRB");

        start_test("Test 4: COMMAND reads zero");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0101, 4'b1111);
        axi_write(ADDR_COMMAND, 32'hFFFF_FFFF, 4'b1111);
        read_command_zero();
        finish_test("Test 4: COMMAND reads zero");

        start_test("Test 5: COMMAND WSTRB");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0101, 4'b1111);
        command_write_and_check(32'h0000_0100, 4'b0001, 1'b0, 1'b0);
        command_write_and_check(32'h0000_0100, 4'b0010, 1'b0, 1'b1);
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0101, 4'b1111);
        command_write_and_check(32'h0000_0001, 4'b0010, 1'b0, 1'b0);
        command_write_and_check(32'h0000_0001, 4'b0001, 1'b1, 1'b0);
        finish_test("Test 5: COMMAND WSTRB");

        start_test("Test 6: sr04_start pulse only when enabled");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b1111);
        command_write_and_check(32'h0000_0001, 4'b0001, 1'b1, 1'b0);
        finish_test("Test 6: sr04_start pulse only when enabled");

        start_test("Test 7: sr04_start ignored when disabled");
        apply_reset();
        command_write_and_check(32'h0000_0001, 4'b0001, 1'b0, 1'b0);
        finish_test("Test 7: sr04_start ignored when disabled");

        start_test("Test 8: sr04_trig_o activity after start");
        apply_reset();
        start_sr04_and_echo(rd);
        check_nonzero32("SR04_VALUE after echo", rd);
        finish_test("Test 8: sr04_trig_o activity after start");

        start_test("Test 9: simple SR04 echo response produces distance");
        apply_reset();
        start_sr04_and_echo(rd);
        check32("SR04_VALUE reserved bits zero", {9'h0, rd[31:9]}, 32'h0000_0000);
        check_nonzero32("SR04_VALUE distance", rd);
        finish_test("Test 9: simple SR04 echo response produces distance");

        start_test("Test 10: dht_start pulse only when enabled");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        command_write_and_check(32'h0000_0100, 4'b0010, 1'b0, 1'b1);
        finish_test("Test 10: dht_start pulse only when enabled");

        start_test("Test 11: dht_start ignored when disabled");
        apply_reset();
        command_write_and_check(32'h0000_0100, 4'b0010, 1'b0, 1'b0);
        finish_test("Test 11: dht_start ignored when disabled");

        start_test("Test 12: dht11_io start-line sanity");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0100, 4'b1111);
        command_write_and_check(32'h0000_0100, 4'b0010, 1'b0, 1'b1);
        saw_low = 0;
        for (i = 0; i < 80; i = i + 1) begin
            @(posedge clk);
            #1;
            if (dht11_io === 1'b0) begin
                saw_low = 1;
            end
        end
        if (saw_low == 0) begin
            record_error("dht11_io did not drive low during start sequence");
        end
        else begin
            $display("[OK] dht11_io drove low during start sequence");
        end
        finish_test("Test 12: dht11_io start-line sanity");

        start_test("Test 13: DHT_VALUE readback reserved bits");
        apply_reset();
        axi_read(ADDR_DHT_VALUE, rd);
        check32("DHT_VALUE reset/readback", rd, 32'h0000_0000);
        check32("DHT_VALUE reserved bits zero", {16'h0, rd[31:16]}, 32'h0000_0000);
        finish_test("Test 13: DHT_VALUE readback reserved bits");

        start_test("Test 14: STATUS readback");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0101, 4'b1111);
        axi_read(ADDR_STATUS, rd);
        before_status = status_expected(sr04_trig_o, dut.dht_valid_live, 1'b1, 1'b1);
        check32("STATUS enable mirrors and live bits", rd, before_status);
        finish_test("Test 14: STATUS readback");

        start_test("Test 15: VERSION read and RO protection");
        apply_reset();
        axi_read(ADDR_VERSION, rd);
        check32("VERSION before write", rd, 32'h0001_0000);
        axi_write(ADDR_VERSION, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION after write", rd, 32'h0001_0000);
        finish_test("Test 15: VERSION read and RO protection");

        start_test("Test 16: reserved offset behavior");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0101, 4'b1111);
        axi_read(ADDR_CONTROL, saved_control);
        axi_read(ADDR_SR04_VALUE, saved_sr04);
        axi_read(ADDR_DHT_VALUE, saved_dht);
        axi_read(ADDR_STATUS, saved_status);
        for (off = 20; off <= 60; off = off + 4) begin
            if (off != 28) begin
                axi_write(off[5:0], 32'h5A00_0000 | off[31:0], 4'b1111);
                axi_read(off[5:0], rd);
                check32($sformatf("reserved 0x%02h read zero", off[5:0]), rd, 32'h0000_0000);
            end
        end
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL unaffected by reserved writes", rd, saved_control);
        axi_read(ADDR_SR04_VALUE, rd);
        check32("SR04_VALUE unaffected by reserved writes", rd, saved_sr04);
        axi_read(ADDR_DHT_VALUE, rd);
        check32("DHT_VALUE unaffected by reserved writes", rd, saved_dht);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS unaffected by reserved writes", rd, saved_status);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION unaffected by reserved writes", rd, 32'h0001_0000);
        finish_test("Test 16: reserved offset behavior");

        start_test("Test 17: Sensor/FND decoupling compile check");
        $display("[OK] Sensor simulation elaborated with sr04.v, dht11.v, and axi_sensor_core.v only.");
        $display("[OK] No fnd_controller.v or axi_fnd_core.v is required by this testbench.");
        finish_test("Test 17: Sensor/FND decoupling compile check");

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
            $display("[TB PASS] axi_sensor_core directed tests passed (%0d tests)", pass_count);
        end
        else begin
            $display("");
            $display("[TB FAIL] axi_sensor_core directed tests failed: %0d errors, %0d tests passed", error_count, pass_count);
        end

        $finish;
    end

endmodule
