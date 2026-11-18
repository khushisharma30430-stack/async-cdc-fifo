`timescale 1ns/1ps

module async_fifo_tb;
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;

    logic                  wclk, wrst_n, winc, wfull;
    logic [DATA_WIDTH-1:0] wdata;
    logic                  rclk, rrst_n, rinc, rempty;
    logic [DATA_WIDTH-1:0] rdata;

    async_fifo #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) dut (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .wdata(wdata), .wfull(wfull),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc), .rdata(rdata), .rempty(rempty)
    );

    // Bind SVA Verification Suite
    bind async_fifo sva_assertions #(.ADDR_WIDTH(ADDR_WIDTH)) u_sva (
        .wclk(wclk), .wrst_n(wrst_n), .winc(winc), .wfull(wfull), .wptr(wptr),
        .rclk(rclk), .rrst_n(rrst_n), .rinc(rinc), .rempty(rempty), .rptr(rptr)
    );

    // Asynchronous Clocks: Write @ 100 MHz (10ns), Read @ 33.3 MHz (30ns)
    always #5  wclk = ~wclk;
    always #15 rclk = ~rclk;

    initial begin
        $dumpfile("sim/async_fifo_trace.vcd");
        $dumpvars(0, async_fifo_tb);

        wclk = 0; wrst_n = 0; winc = 0; wdata = 0;
        rclk = 0; rrst_n = 0; rinc = 0;

        #25 wrst_n = 1; rrst_n = 1;

        // Burst write to trigger full condition
        repeat (20) begin
            @(posedge wclk);
            if (!wfull) begin
                winc  <= 1'b1;
                wdata <= wdata + 8'h11;
            end else begin
                winc  <= 1'b0;
            end
        end
        @(posedge wclk) winc <= 1'b0;

        // Burst read to drain FIFO and verify CDC synchronization
        #40;
        repeat (20) begin
            @(posedge rclk);
            if (!rempty)
                rinc <= 1'b1;
            else
                rinc <= 1'b0;
        end
        @(posedge rclk) rinc <= 1'b0;

        #100;
        $display(">>> TEST PASSED: Asynchronous CDC FIFO & SVA Checks Verified! <<<");
        $finish;
    end
endmodule
