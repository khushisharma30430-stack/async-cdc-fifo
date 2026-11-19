`timescale 1ns/1ps

module sync_w2r #(
    parameter ADDR_WIDTH = 4
)(
    input  logic                rclk,
    input  logic                rrst_n,
    input  logic [ADDR_WIDTH:0] wptr,
    output logic [ADDR_WIDTH:0] rq2_wptr
);
    (* ASYNC_REG = "TRUE" *) logic [ADDR_WIDTH:0] rq1_wptr;

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            {rq2_wptr, rq1_wptr} <= '0;
        else
            {rq2_wptr, rq1_wptr} <= {rq1_wptr, wptr};
    end
endmodule
