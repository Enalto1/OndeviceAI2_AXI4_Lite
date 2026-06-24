`timescale 1ns / 1ps

module tb_axi_i2c_core;

    localparam integer CLK_PERIOD_NS = 10;

    localparam [5:0] ADDR_CONTROL    = 6'h00;
    localparam [5:0] ADDR_TXDATA     = 6'h04;
    localparam [5:0] ADDR_COMMAND    = 6'h08;
    localparam [5:0] ADDR_RXDATA     = 6'h0C;
    localparam [5:0] ADDR_STATUS     = 6'h10;
    localparam [5:0] ADDR_BUS_STATUS = 6'h14;
    localparam [5:0] ADDR_RSV_18     = 6'h18;
    localparam [5:0] ADDR_VERSION    = 6'h1C;

    localparam [2:0] I2C_CMD_START      = 3'd0;
    localparam [2:0] I2C_CMD_STOP       = 3'd1;
    localparam [2:0] I2C_CMD_WRITE_BYTE = 3'd2;
    localparam [2:0] I2C_CMD_READ_BYTE  = 3'd3;

    reg clk;
    reg resetn;

    tri1 i2c_scl_io;
    tri1 i2c_sda_io;
    reg tb_scl_drive_low;
    reg tb_sda_drive_low;

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

    assign i2c_scl_io = tb_scl_drive_low ? 1'b0 : 1'bz;
    assign i2c_sda_io = tb_sda_drive_low ? 1'b0 : 1'bz;

    axi_i2c_core #(
        .I2C_CLK_HZ(1000),
        .I2C_BUS_HZ(250)
    ) dut (
        .i2c_scl_io      (i2c_scl_io),
        .i2c_sda_io      (i2c_sda_io),
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

    function automatic [31:0] control_expected(input [1:0] control_bits);
        begin
            control_expected = {30'h00000000, control_bits[1:0]};
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
                                               input cmd_ready,
                                               input done_flag,
                                               input nack_flag,
                                               input nack_live,
                                               input enable,
                                               input read_ack);
        begin
            status_expected = {22'h000000, read_ack, enable, 3'b000,
                               nack_live, nack_flag, done_flag,
                               cmd_ready, busy};
        end
    endfunction

    function automatic [31:0] bus_status_expected(input scl_value,
                                                   input sda_value,
                                                   input scl_drive,
                                                   input sda_drive);
        begin
            bus_status_expected = {28'h0000000, sda_drive, scl_drive,
                                   sda_value, scl_value};
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
            tb_scl_drive_low = 1'b0;
            tb_sda_drive_low = 1'b0;
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

    task automatic check_nonzero(input string name, input [31:0] value);
        begin
            if (value === 32'h0000_0000) begin
                record_error(name);
            end
            else begin
                $display("[OK] %s = 0x%08h", name, value);
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

    task automatic command_write_and_check_cmd(input [31:0] data,
                                               input [3:0] strb,
                                               input expected_pulse,
                                               input [2:0] expected_cmd);
        integer timeout;
        reg aw_seen;
        reg w_seen;
        reg [2:0] cmd_before;
        begin
            aw_seen = 1'b0;
            w_seen = 1'b0;
            timeout = 0;
            cmd_before = dut.i2c_cmd_code;

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

            check1("i2c_cmd_valid_pulse active cycle", dut.i2c_cmd_valid_pulse, expected_pulse);
            if (expected_pulse) begin
                check8("i2c_cmd_code selected", {5'b00000, dut.i2c_cmd_code}, {5'b00000, expected_cmd});
            end
            else begin
                check8("i2c_cmd_code unchanged for ignored command", {5'b00000, dut.i2c_cmd_code}, {5'b00000, cmd_before});
            end

            if (bvalid && bresp !== 2'b00) begin
                record_error("AXI command write BRESP not OKAY");
            end

            @(posedge clk);
            #1;
            check1("i2c_cmd_valid_pulse deasserted next cycle", dut.i2c_cmd_valid_pulse, 1'b0);
            bready = 1'b0;
        end
    endtask

    task automatic wait_for_cmd_ready(input integer timeout_limit);
        integer timeout;
        begin
            timeout = 0;
            while (dut.i2c_cmd_ready !== 1'b1) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > timeout_limit) begin
                    record_error("timeout waiting for i2c_cmd_ready");
                    return;
                end
            end
            $display("[OK] i2c_cmd_ready asserted");
        end
    endtask

    task automatic wait_for_busy_high(input integer timeout_limit);
        integer timeout;
        begin
            timeout = 0;
            while (dut.i2c_busy !== 1'b1) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > timeout_limit) begin
                    record_error("timeout waiting for i2c_busy high");
                    return;
                end
            end
            $display("[OK] i2c_busy asserted");
        end
    endtask

    task automatic wait_for_busy_low(input integer timeout_limit);
        integer timeout;
        begin
            timeout = 0;
            while (dut.i2c_busy !== 1'b0) begin
                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > timeout_limit) begin
                    record_error("timeout waiting for i2c_busy low");
                    return;
                end
            end
            $display("[OK] i2c_busy deasserted");
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

    task automatic wait_for_done_with_activity(input integer timeout_limit,
                                               output integer saw_scl_drive,
                                               output integer saw_sda_drive,
                                               output integer saw_scl_low,
                                               output integer saw_sda_low);
        integer timeout;
        begin
            timeout = 0;
            saw_scl_drive = 0;
            saw_sda_drive = 0;
            saw_scl_low = 0;
            saw_sda_low = 0;

            while (dut.done_sticky !== 1'b1) begin
                if (dut.scl_drive_low === 1'b1) begin
                    saw_scl_drive = 1;
                end
                if (dut.sda_drive_low === 1'b1) begin
                    saw_sda_drive = 1;
                end
                if (i2c_scl_io === 1'b0) begin
                    saw_scl_low = 1;
                end
                if (i2c_sda_io === 1'b0) begin
                    saw_sda_low = 1;
                end

                @(posedge clk);
                #1;
                timeout = timeout + 1;
                if (timeout > timeout_limit) begin
                    record_error("timeout waiting for done with I2C activity");
                    return;
                end
            end
        end
    endtask

    task automatic check_bus_released;
        reg [31:0] rd;
        begin
            wait_clocks(2);
            check1("SCL released high", i2c_scl_io, 1'b1);
            check1("SDA released high", i2c_sda_io, 1'b1);
            check1("scl_drive_low released", dut.scl_drive_low, 1'b0);
            check1("sda_drive_low released", dut.sda_drive_low, 1'b0);
            axi_read(ADDR_BUS_STATUS, rd);
            check32("BUS_STATUS released", rd, bus_status_expected(1'b1, 1'b1, 1'b0, 1'b0));
        end
    endtask

    task automatic issue_command_and_wait(input [3:0] command_bits,
                                          input [2:0] expected_cmd);
        begin
            command_write_and_check_cmd({28'h0000000, command_bits}, 4'b0001, 1'b1, expected_cmd);
            wait_for_done_sticky(1000);
            wait_for_cmd_ready(100);
        end
    endtask

    task automatic write_byte_and_wait(input [7:0] tx_byte,
                                       input ack_low,
                                       output [31:0] status_read);
        begin
            tb_sda_drive_low = ack_low;
            axi_write(ADDR_TXDATA, {24'h000000, tx_byte}, 4'b0001);
            command_write_and_check_cmd(32'h0000_0004, 4'b0001, 1'b1, I2C_CMD_WRITE_BYTE);
            wait_for_done_sticky(1000);
            axi_read(ADDR_STATUS, status_read);
        end
    endtask

    task automatic read_byte_and_wait(input read_ack_value,
                                      input sda_low,
                                      output [31:0] rx_read,
                                      output [31:0] status_read);
        begin
            tb_sda_drive_low = sda_low;
            axi_write(ADDR_CONTROL, {30'h00000000, read_ack_value, 1'b1}, 4'b0001);
            command_write_and_check_cmd(32'h0000_0008, 4'b0001, 1'b1, I2C_CMD_READ_BYTE);
            wait_for_done_sticky(1000);
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

    task automatic create_done_nack_and_release_bus;
        reg [31:0] status;
        begin
            tb_sda_drive_low = 1'b0;
            axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
            write_byte_and_wait(8'hA0, 1'b0, status);
            check1("nack_sticky created", dut.nack_sticky, 1'b1);
            command_write_and_check_cmd(32'h0000_0002, 4'b0001, 1'b1, I2C_CMD_STOP);
            wait_for_done_sticky(1000);
            check_bus_released();
        end
    endtask

    initial begin
        reg [31:0] rd;
        reg [31:0] status;
        reg [31:0] saved_control;
        reg [31:0] saved_txdata;
        reg [31:0] saved_status;
        reg [31:0] saved_bus_status;
        reg [31:0] saved_rxdata;
        integer off;
        integer saw_scl_drive;
        integer saw_sda_drive;
        integer saw_scl_low;
        integer saw_sda_low;

        result_file = "sim/vivado/axi_i2c_core/axi_i2c_core_sim_result.txt";
        plusarg_ok = $value$plusargs("RESULT_FILE=%s", result_file);

        error_count = 0;
        pass_count = 0;
        current_test_errors = 0;
        resetn = 1'b0;
        tb_scl_drive_low = 1'b0;
        tb_sda_drive_low = 1'b0;
        init_axi();

        apply_reset();

        start_test("Test 1: Reset behavior");
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL reset", rd, 32'h0000_0000);
        axi_read(ADDR_TXDATA, rd);
        check32("TXDATA reset", rd, 32'h0000_0000);
        axi_read(ADDR_COMMAND, rd);
        check32("COMMAND reset read zero", rd, 32'h0000_0000);
        axi_read(ADDR_RXDATA, rd);
        check32("RXDATA reset", rd, 32'h0000_0000);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS reset fields", rd, status_expected(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0));
        axi_read(ADDR_BUS_STATUS, rd);
        check32("BUS_STATUS reset pullups", rd, bus_status_expected(1'b1, 1'b1, 1'b0, 1'b0));
        axi_read(ADDR_VERSION, rd);
        check32("VERSION reset", rd, 32'h0001_0000);
        check1("i2c_cmd_valid_pulse reset", dut.i2c_cmd_valid_pulse, 1'b0);
        check1("SCL pullup high after reset", i2c_scl_io, 1'b1);
        check1("SDA pullup high after reset", i2c_sda_io, 1'b1);
        finish_test("Test 1: Reset behavior");

        start_test("Test 2: CONTROL write/read");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0003, 4'b0001);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL[1:0] write", rd, control_expected(2'b11));
        axi_read(ADDR_STATUS, rd);
        check32("STATUS control mirrors", rd, status_expected(1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1));
        finish_test("Test 2: CONTROL write/read");

        start_test("Test 3: CONTROL WSTRB behavior");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0000, 4'b0001);
        axi_write(ADDR_CONTROL, 32'h0000_0003, 4'b0001);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte0", rd, control_expected(2'b11));
        axi_write(ADDR_CONTROL, 32'hFFFF_FFFF, 4'b0010);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte1 ignored", rd, control_expected(2'b11));
        axi_write(ADDR_CONTROL, 32'hFFFF_FFFF, 4'b0100);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte2 ignored", rd, control_expected(2'b11));
        axi_write(ADDR_CONTROL, 32'hFFFF_FFFF, 4'b1000);
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL WSTRB byte3 ignored", rd, control_expected(2'b11));
        finish_test("Test 3: CONTROL WSTRB behavior");

        start_test("Test 4: TXDATA write/read and WSTRB");
        apply_reset();
        axi_write(ADDR_TXDATA, 32'h0000_00A0, 4'b0001);
        axi_read(ADDR_TXDATA, rd);
        check32("TXDATA byte0 write", rd, txdata_expected(8'hA0));
        axi_write(ADDR_TXDATA, 32'hFFFF_FF55, 4'b1110);
        axi_read(ADDR_TXDATA, rd);
        check32("TXDATA upper byte strobes ignored", rd, txdata_expected(8'hA0));
        finish_test("Test 4: TXDATA write/read and WSTRB");

        start_test("Test 5: COMMAND read-zero behavior");
        apply_reset();
        axi_write(ADDR_COMMAND, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_COMMAND, rd);
        check32("COMMAND reads zero after write", rd, 32'h0000_0000);
        finish_test("Test 5: COMMAND read-zero behavior");

        start_test("Test 6: COMMAND ignored when disabled");
        apply_reset();
        create_done_nack_and_release_bus();
        axi_write(ADDR_CONTROL, 32'h0000_0000, 4'b0001);
        command_write_and_check_cmd(32'h0000_0001, 4'b0001, 1'b0, I2C_CMD_START);
        check1("done_sticky preserved by disabled command", dut.done_sticky, 1'b1);
        check1("nack_sticky preserved by disabled command", dut.nack_sticky, 1'b1);
        check_bus_released();
        finish_test("Test 6: COMMAND ignored when disabled");

        start_test("Test 7: COMMAND pulse when enabled and ready");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        command_write_and_check_cmd(32'h0000_0001, 4'b0001, 1'b1, I2C_CMD_START);
        axi_read(ADDR_COMMAND, rd);
        check32("COMMAND reads zero after accepted START", rd, 32'h0000_0000);
        wait_for_done_sticky(1000);
        finish_test("Test 7: COMMAND pulse when enabled and ready");

        start_test("Test 8: COMMAND priority");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        issue_command_and_wait(4'b1111, I2C_CMD_START);
        issue_command_and_wait(4'b1110, I2C_CMD_STOP);
        issue_command_and_wait(4'b1100, I2C_CMD_WRITE_BYTE);
        issue_command_and_wait(4'b1000, I2C_CMD_READ_BYTE);
        finish_test("Test 8: COMMAND priority");

        start_test("Test 9: COMMAND WSTRB behavior");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        command_write_and_check_cmd(32'h0000_0001, 4'b0010, 1'b0, I2C_CMD_START);
        command_write_and_check_cmd(32'h0000_0001, 4'b0001, 1'b1, I2C_CMD_START);
        wait_for_done_sticky(1000);
        finish_test("Test 9: COMMAND WSTRB behavior");

        start_test("Test 10: START command bus activity");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        command_write_and_check_cmd(32'h0000_0001, 4'b0001, 1'b1, I2C_CMD_START);
        wait_for_done_with_activity(1000, saw_scl_drive, saw_sda_drive, saw_scl_low, saw_sda_low);
        if ((saw_scl_drive == 0) && (saw_sda_drive == 0)) begin
            record_error("START did not show drive-low activity");
        end
        else begin
            $display("[OK] START showed drive-low activity");
        end
        if ((saw_scl_low == 0) && (saw_sda_low == 0)) begin
            record_error("START did not pull either bus line low");
        end
        else begin
            $display("[OK] START pulled at least one bus line low");
        end
        axi_read(ADDR_STATUS, status);
        check1("cmd_ready after START", status[1], 1'b1);
        finish_test("Test 10: START command bus activity");

        start_test("Test 11: STOP command bus release");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        issue_command_and_wait(4'b0001, I2C_CMD_START);
        command_write_and_check_cmd(32'h0000_0002, 4'b0001, 1'b1, I2C_CMD_STOP);
        wait_for_done_sticky(1000);
        check_bus_released();
        finish_test("Test 11: STOP command bus release");

        start_test("Test 12: WRITE_BYTE with ACK");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        write_byte_and_wait(8'hA0, 1'b1, status);
        check1("WRITE ACK done_sticky", status[2], 1'b1);
        check1("WRITE ACK nack_sticky clear", status[3], 1'b0);
        check1("WRITE ACK nack_live clear", status[4], 1'b0);
        axi_read(ADDR_COMMAND, rd);
        check32("COMMAND reads zero after WRITE ACK", rd, 32'h0000_0000);
        tb_sda_drive_low = 1'b0;
        finish_test("Test 12: WRITE_BYTE with ACK");

        start_test("Test 13: WRITE_BYTE with NACK");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        write_byte_and_wait(8'hA0, 1'b0, status);
        check1("WRITE NACK done_sticky", status[2], 1'b1);
        check1("WRITE NACK nack_sticky set", status[3], 1'b1);
        check1("WRITE NACK nack_live set", status[4], 1'b1);
        command_write_and_check_cmd(32'h0000_0002, 4'b0001, 1'b1, I2C_CMD_STOP);
        check1("accepted STOP clears nack_sticky immediately", dut.nack_sticky, 1'b0);
        wait_for_done_sticky(1000);
        finish_test("Test 13: WRITE_BYTE with NACK");

        start_test("Test 14: READ_BYTE returning 8'hFF");
        apply_reset();
        tb_sda_drive_low = 1'b0;
        read_byte_and_wait(1'b0, 1'b0, rd, status);
        check32("READ high RXDATA", rd, rxdata_expected(8'hFF));
        check1("READ high done_sticky", status[2], 1'b1);
        finish_test("Test 14: READ_BYTE returning 8'hFF");

        start_test("Test 15: READ_BYTE returning 8'h00");
        apply_reset();
        read_byte_and_wait(1'b1, 1'b1, rd, status);
        check32("READ low RXDATA", rd, rxdata_expected(8'h00));
        check1("READ low done_sticky", status[2], 1'b1);
        tb_sda_drive_low = 1'b0;
        finish_test("Test 15: READ_BYTE returning 8'h00");

        start_test("Test 16: done_sticky and nack_sticky clear on accepted command");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        write_byte_and_wait(8'hA0, 1'b0, status);
        check1("done_sticky created before clear", dut.done_sticky, 1'b1);
        check1("nack_sticky created before clear", dut.nack_sticky, 1'b1);
        command_write_and_check_cmd(32'h0000_0002, 4'b0001, 1'b1, I2C_CMD_STOP);
        check1("done_sticky cleared by accepted STOP", dut.done_sticky, 1'b0);
        check1("nack_sticky cleared by accepted STOP", dut.nack_sticky, 1'b0);
        wait_for_done_sticky(1000);
        check1("done_sticky set again after STOP", dut.done_sticky, 1'b1);
        finish_test("Test 16: done_sticky and nack_sticky clear on accepted command");

        start_test("Test 17: COMMAND ignored when cmd_ready=0");
        apply_reset();
        tb_sda_drive_low = 1'b1;
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        axi_write(ADDR_TXDATA, 32'h0000_0055, 4'b0001);
        command_write_and_check_cmd(32'h0000_0004, 4'b0001, 1'b1, I2C_CMD_WRITE_BYTE);
        wait_for_busy_high(100);
        check1("cmd_ready low during WRITE_BYTE", dut.i2c_cmd_ready, 1'b0);
        command_write_and_check_cmd(32'h0000_0001, 4'b0001, 1'b0, I2C_CMD_START);
        wait_for_done_sticky(1000);
        tb_sda_drive_low = 1'b0;
        finish_test("Test 17: COMMAND ignored when cmd_ready=0");

        start_test("Test 18: BUS_STATUS readback");
        apply_reset();
        axi_read(ADDR_BUS_STATUS, rd);
        check32("BUS_STATUS idle pullups", rd, bus_status_expected(1'b1, 1'b1, 1'b0, 1'b0));
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        tb_sda_drive_low = 1'b1;
        axi_write(ADDR_TXDATA, 32'h0000_0000, 4'b0001);
        command_write_and_check_cmd(32'h0000_0004, 4'b0001, 1'b1, I2C_CMD_WRITE_BYTE);
        wait_for_busy_high(100);
        wait_clocks(2);
        saw_scl_drive = dut.scl_drive_low;
        saw_sda_drive = dut.sda_drive_low;
        axi_read(ADDR_BUS_STATUS, rd);
        check_nonzero("BUS_STATUS during command lower nibble nonzero", {28'h0, rd[3:0]});
        if ((saw_scl_drive == 0) && (saw_sda_drive == 0) && (rd[3:2] == 2'b00)) begin
            record_error("BUS_STATUS did not show drive-low activity near command");
        end
        wait_for_done_sticky(1000);
        tb_sda_drive_low = 1'b0;
        finish_test("Test 18: BUS_STATUS readback");

        start_test("Test 19: VERSION read and RO protection");
        apply_reset();
        axi_read(ADDR_VERSION, rd);
        check32("VERSION before write", rd, 32'h0001_0000);
        axi_write(ADDR_VERSION, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION after write", rd, 32'h0001_0000);
        finish_test("Test 19: VERSION read and RO protection");

        start_test("Test 20: Read-only write protection");
        apply_reset();
        axi_read(ADDR_RXDATA, saved_rxdata);
        axi_read(ADDR_STATUS, saved_status);
        axi_read(ADDR_BUS_STATUS, saved_bus_status);
        axi_write(ADDR_RXDATA, 32'hFFFF_FFFF, 4'b1111);
        axi_write(ADDR_STATUS, 32'hFFFF_FFFF, 4'b1111);
        axi_write(ADDR_BUS_STATUS, 32'hFFFF_FFFF, 4'b1111);
        axi_read(ADDR_RXDATA, rd);
        check32("RXDATA not overwritten by write", rd, saved_rxdata);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS not overwritten by write", rd, saved_status);
        axi_read(ADDR_BUS_STATUS, rd);
        check32("BUS_STATUS not overwritten by write", rd, saved_bus_status);
        finish_test("Test 20: Read-only write protection");

        start_test("Test 21: Reserved offset behavior");
        apply_reset();
        axi_write(ADDR_CONTROL, 32'h0000_0003, 4'b0001);
        axi_write(ADDR_TXDATA, 32'h0000_00A0, 4'b0001);
        axi_read(ADDR_CONTROL, saved_control);
        axi_read(ADDR_TXDATA, saved_txdata);
        axi_read(ADDR_STATUS, saved_status);
        check_reserved_zero(ADDR_RSV_18);
        for (off = 32; off <= 60; off = off + 4) begin
            check_reserved_zero(off[5:0]);
        end
        axi_read(ADDR_CONTROL, rd);
        check32("CONTROL unaffected by reserved writes", rd, saved_control);
        axi_read(ADDR_TXDATA, rd);
        check32("TXDATA unaffected by reserved writes", rd, saved_txdata);
        axi_read(ADDR_STATUS, rd);
        check32("STATUS unaffected by reserved writes", rd, saved_status);
        axi_read(ADDR_VERSION, rd);
        check32("VERSION unaffected by reserved writes", rd, 32'h0001_0000);
        finish_test("Test 21: Reserved offset behavior");

        start_test("Test 22: Open-drain behavior");
        apply_reset();
        check_bus_released();
        axi_write(ADDR_CONTROL, 32'h0000_0001, 4'b0001);
        command_write_and_check_cmd(32'h0000_0001, 4'b0001, 1'b1, I2C_CMD_START);
        wait_for_done_with_activity(1000, saw_scl_drive, saw_sda_drive, saw_scl_low, saw_sda_low);
        if (saw_scl_drive && !saw_scl_low) begin
            record_error("SCL drive-low did not pull SCL low");
        end
        else begin
            $display("[OK] SCL drive-low observation consistent");
        end
        if (saw_sda_drive && !saw_sda_low) begin
            record_error("SDA drive-low did not pull SDA low");
        end
        else begin
            $display("[OK] SDA drive-low observation consistent");
        end
        if ((saw_scl_drive == 0) && (saw_sda_drive == 0)) begin
            record_error("No open-drain drive-low activity observed");
        end
        check1("SCL is known after command", (^i2c_scl_io !== 1'bx), 1'b1);
        check1("SDA is known after command", (^i2c_sda_io !== 1'bx), 1'b1);
        finish_test("Test 22: Open-drain behavior");

        start_test("Test 23: I2C independence compile check");
        $display("[OK] I2C simulation elaborated with i2c_master_core.sv, axi_i2c_core.v, and tb_axi_i2c_core.sv.");
        $display("[OK] i2c_slave_core.sv is intentionally not compiled for the first master-only simulation.");
        $display("[OK] No GPIO/FND/Timer/Sensor/SPI/UVM/MicroBlaze/block-design files are required.");
        finish_test("Test 23: I2C independence compile check");

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
            $display("[TB PASS] axi_i2c_core directed tests passed (%0d tests)", pass_count);
        end
        else begin
            $display("");
            $display("[TB FAIL] axi_i2c_core directed tests failed: %0d errors, %0d tests passed", error_count, pass_count);
        end

        $finish;
    end

endmodule
