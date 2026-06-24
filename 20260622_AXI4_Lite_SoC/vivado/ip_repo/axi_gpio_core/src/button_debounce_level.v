`timescale 1ns / 1ps

// Adapted copy of the legacy button_debounce module.
// The original reference module exposes only a rising pulse. This working copy
// preserves the same sampled debounce concept while also exposing the stable
// debounced level required by axi_gpio_core GPIO_IN readback.
module button_debounce_level(
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn_level,
    output o_btn_pulse
);

    parameter F_COUNT = 100_000_000 / 1000;

    reg [$clog2(F_COUNT) - 1:0] r_counter;
    reg sample_tick;

    reg [7:0] sync_reg;
    wire debounce;
    reg edge_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            r_counter   <= 0;
            sample_tick <= 1'b0;
        end
        else begin
            if (r_counter == F_COUNT - 1) begin
                r_counter   <= 0;
                sample_tick <= 1'b1;
            end
            else begin
                r_counter   <= r_counter + 1'b1;
                sample_tick <= 1'b0;
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_reg <= 8'b0;
        end
        else begin
            if (sample_tick) begin
                sync_reg <= {i_btn, sync_reg[7:1]};
            end
        end
    end

    assign debounce = &sync_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            edge_reg <= 1'b0;
        end
        else begin
            edge_reg <= debounce;
        end
    end

    assign o_btn_level = debounce;
    assign o_btn_pulse = debounce & (~edge_reg);

endmodule
