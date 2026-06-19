`timescale 1ns / 1ps

module AXI4_master (
    input logic ACLK,
    input logic RESET_N,

    //AW channel
    output logic [31:0] AWADDR,
    output logic        AWVALID,
    input  logic        AWREADY,

    //W channel
    output logic [31:0] WDATA,
    output logic        WVALID,
    input  logic        WREADY,

    //B channel
    input  logic [1:0] BRESP,
    input  logic       BVALID,
    output logic       BREADY,

    //AR channel
    output logic [31:0] ARADDR,
    output logic        ARVALID,
    input  logic        ARREADY,

    //R channel
    input  logic [31:0] RDATA,
    input  logic        RVALID,
    output logic        RREADY,
    input  logic [ 1:0] RRESP,

    input  logic        transfer,
    output logic        ready,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic        write,
    output logic [31:0] rdata

);
    logic w_ready, r_ready;
    assign ready = w_ready | r_ready;

    //******************Write Transaction ***************/
    //AW channel
    typedef enum logic {
        AW_IDLE  = 0,
        AW_VALID
    } state_aw_e;

    state_aw_e aw_state, aw_state_next;

    always_ff @(posedge ACLK) begin
        if (!RESET_N) begin
            aw_state <= AW_IDLE;
        end else begin
            aw_state <= aw_state_next;
        end
    end

    always_comb begin
        aw_state_next = aw_state;
        AWADDR = addr;
        AWVALID = 1'b0;
        case (aw_state)
            AW_IDLE: begin
                AWVALID = 1'b0;
                if (transfer & write) begin
                    aw_state_next <= AW_VALID;
                end
            end
            AW_VALID: begin
                AWADDR  = addr;
                AWVALID = 1'b1;
                if (AWREADY) begin
                    aw_state_next = AW_IDLE;
                end
            end
            default: begin
                AWADDR = addr;
                AWVALID = 1'b0;
                aw_state_next = AW_IDLE;
            end
        endcase
    end

    //W channel
    typedef enum logic {
        W_IDLE  = 0,
        W_VALID
    } state_w_e;

    state_w_e w_state, w_state_next;

    always_ff @(posedge ACLK) begin
        if (!RESET_N) begin
            w_state <= W_IDLE;
        end else begin
            w_state <= w_state_next;
        end
    end

    always_comb begin
        w_state_next = w_state;
        WDATA = wdata;
        WVALID = 1'b0;
        case (w_state)
            W_IDLE: begin
                WVALID = 1'b0;
                if (transfer & write) begin
                    w_state_next <= W_VALID;
                end
            end
            W_VALID: begin
                WDATA  = wdata;
                WVALID = 1'b1;
                if (WREADY) begin
                    w_state_next = W_IDLE;
                end
            end
            default: begin
                WDATA = wdata;
                WVALID = 1'b0;
                w_state_next = W_IDLE;
            end
        endcase
    end

    //B channel
    typedef enum logic {
        B_IDLE  = 0,
        B_READY
    } state_b_e;

    state_b_e b_state, b_state_next;

    always_ff @(posedge ACLK) begin
        if (!RESET_N) begin
            b_state <= B_IDLE;
        end else begin
            b_state <= b_state_next;
        end
    end

    always_comb begin
        b_state_next = b_state;
        w_ready = 1'b0;
        case (b_state)
            B_IDLE: begin
                BREADY = 1'b0;
                if (WVALID) begin
                    b_state_next <= B_READY;
                end
            end
            B_READY: begin
                BREADY = 1'b1;
                if (BVALID) begin
                    b_state_next = B_IDLE;
                    w_ready = 1'b1;
                end
            end
            default: begin
                BREADY = 1'b0;
                b_state_next = B_IDLE;
            end
        endcase
    end

    //******************Read Transaction ***************/
    // AR channel
    typedef enum logic {
        AR_IDLE  = 0,
        AR_VALID
    } state_ar_e;

    state_ar_e ar_state, ar_state_next;

    always_ff @(posedge ACLK) begin
        if (!RESET_N) begin
            ar_state <= AR_IDLE;
        end else begin
            ar_state <= ar_state_next;
        end
    end

    always_comb begin
        ar_state_next = ar_state;
        ARADDR = addr;
        ARVALID = 1'b0;
        case (ar_state)
            AR_IDLE: begin
                ARVALID = 1'b0;
                if (transfer & !write) begin
                    ar_state_next <= AR_VALID;
                end
            end
            AR_VALID: begin
                ARADDR  = addr;
                ARVALID = 1'b1;
                if (ARREADY) begin
                    ar_state_next = AR_IDLE;
                end
            end
            default: begin
                ARADDR = addr;
                ARVALID = 1'b0;
                ar_state_next = AR_IDLE;
            end
        endcase
    end

    //R channel
    typedef enum logic {
        R_IDLE  = 0,
        R_READY
    } state_r_e;

    state_r_e r_state, r_state_next;

    always_ff @(posedge ACLK) begin
        if (!RESET_N) begin
            r_state <= R_IDLE;
        end else begin
            r_state <= r_state_next;
        end
    end

    always_comb begin
        r_state_next = r_state;
        r_ready = 1'b0;
        RREADY = 1'b0;
        case (r_state)
            R_IDLE: begin
                RREADY = 1'b0;
                if (ARVALID) begin
                    r_state_next <= R_READY;
                end
            end
            R_READY: begin
                RREADY = 1'b1;
                if (RVALID) begin
                    r_state_next = R_IDLE;
                    rdata = RDATA;
                    r_ready = 1'b1;
                end
            end
            default: begin
                RREADY = 1'b0;
                r_state_next = R_IDLE;
            end
        endcase
    end
endmodule
