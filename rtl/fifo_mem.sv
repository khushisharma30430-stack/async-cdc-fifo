`timescale 1ns/1ps

module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
)(
    input  logic                  wclk,
    input  logic                  wclken,
    input  logic                  wfull,
    input  logic [ADDR_WIDTH-1:0] waddr,
    input  logic [DATA_WIDTH-1:0] wdata,
    input  logic [ADDR_WIDTH-1:0] raddr,
    output logic [DATA_WIDTH-1:0] rdata
);
    localparam DEPTH = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Asynchronous read for zero-latency output visibility
    assign rdata = mem[raddr];

    // Synchronous write guarded against full condition
    always_ff @(posedge wclk) begin
        if (wclken && !wfull)
            mem[waddr] <= wdata;
    end
endmodule
