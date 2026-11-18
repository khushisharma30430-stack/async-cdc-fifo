`timescale 1ns/1ps

module wptr_full #(
    parameter ADDR_WIDTH = 4
)(
    input  logic                  wclk,
    input  logic                  wrst_n,
    input  logic                  winc,
    input  logic [ADDR_WIDTH:0]   wq2_rptr,
    output logic                  wfull,
    output logic [ADDR_WIDTH-1:0] waddr,
    output logic [ADDR_WIDTH:0]   wptr
);
    logic [ADDR_WIDTH:0] wbin;
    logic [ADDR_WIDTH:0] wgraynext, wbinnext;
    logic                wfull_val;

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)
            {wbin, wptr} <= '0;
        else
            {wbin, wptr} <= {wbinnext, wgraynext};
    end

    assign waddr     = wbin[ADDR_WIDTH-1:0];
    assign wbinnext  = wbin + (winc & ~wfull);
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;

    // Full condition: MSBs inverted, lower bits identical
    assign wfull_val = (wgraynext == {~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n)
            wfull <= 1'b0;
        else
            wfull <= wfull_val;
    end
endmodule
