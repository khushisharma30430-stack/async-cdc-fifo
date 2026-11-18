`timescale 1ns/1ps

module rptr_empty #(
    parameter ADDR_WIDTH = 4
)(
    input  logic                  rclk,
    input  logic                  rrst_n,
    input  logic                  rinc,
    input  logic [ADDR_WIDTH:0]   rq2_wptr,
    output logic                  rempty,
    output logic [ADDR_WIDTH-1:0] raddr,
    output logic [ADDR_WIDTH:0]   rptr
);
    logic [ADDR_WIDTH:0] rbin;
    logic [ADDR_WIDTH:0] rgraynext, rbinnext;
    logic                rempty_val;

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            {rbin, rptr} <= '0;
        else
            {rbin, rptr} <= {rbinnext, rgraynext};
    end

    assign raddr      = rbin[ADDR_WIDTH-1:0];
    assign rbinnext   = rbin + (rinc & ~rempty);
    assign rgraynext  = (rbinnext >> 1) ^ rbinnext;
    assign rempty_val = (rgraynext == rq2_wptr);

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            rempty <= 1'b1;
        else
            rempty <= rempty_val;
    end
endmodule
