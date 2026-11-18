`timescale 1ns/1ps

module sva_assertions #(
    parameter ADDR_WIDTH = 4
)(
    input logic                wclk,
    input logic                wrst_n,
    input logic                winc,
    input logic                wfull,
    input logic [ADDR_WIDTH:0] wptr,

    input logic                rclk,
    input logic                rrst_n,
    input logic                rinc,
    input logic                rempty,
    input logic [ADDR_WIDTH:0] rptr
);
    // 1. Overflow Prevention: Write pointer must remain stable when wfull is asserted
    property p_no_overflow;
        @(posedge wclk) disable iff (!wrst_n)
        (wfull && winc) |=> $stable(wptr);
    endproperty
    assert_no_overflow: assert property (p_no_overflow)
        else $error("SVA ERROR: FIFO Overflow occurred!");

    // 2. Underflow Prevention: Read pointer must remain stable when rempty is asserted
    property p_no_underflow;
        @(posedge rclk) disable iff (!rrst_n)
        (rempty && rinc) |=> $stable(rptr);
    endproperty
    assert_no_underflow: assert property (p_no_underflow)
        else $error("SVA ERROR: FIFO Underflow occurred!");

    // 3. Gray Code Single-Bit Transition Check (Hamming Distance <= 1)
    property p_gray_wptr_single_bit;
        @(posedge wclk) disable iff (!wrst_n)
        $onehot0(wptr ^ $past(wptr));
    endproperty
    assert_gray_wptr: assert property (p_gray_wptr_single_bit)
        else $error("SVA ERROR: Multi-bit Gray transition detected on wptr!");
endmodule
