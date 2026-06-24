`timescale 1ns/1ps

import uvm_pkg::*;
import ram_pkg::*;

module tb_top;
    logic clk;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    ram_if r_if(clk);

    ram dut(
        .clk   (r_if.clk),
        .write (r_if.write),
        .addr  (r_if.addr),
        .wdata (r_if.wdata),
        .rdata (r_if.rdata)
    );

    initial begin
        uvm_config_db #(virtual ram_if)::set(null, "*", "r_if", r_if);
        run_test("ram_basic_test");
    end

`ifdef FSDB_DUMP
    initial begin
        $fsdbDumpfile("ram_tb.fsdb");
        $fsdbDumpvars(0);
        $fsdbDumpMDA(); // 메모리 배열(mem) 덤프
    end
`endif
endmodule
