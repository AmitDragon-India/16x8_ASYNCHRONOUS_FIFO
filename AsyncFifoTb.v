`timescale 1ns/1ps

module AsyncFifoTb;

    // Parameters
    parameter DSIZE = 8;
    parameter ASIZE = 4;

    // Signals
    reg wclk, rclk, wrst_n, rrst_n;
    reg winc, rinc;
    reg [DSIZE-1:0] wdata;
    wire [DSIZE-1:0] rdata;
    wire wfull, rempty;

    // Instantiate the AsyncFifo_1 module
    AsyncFifo_1 #(
        .DSIZE(DSIZE),
        .ASIZE(ASIZE)
    ) uut (
        .wdata(wdata),
        .winc(winc),
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rinc(rinc),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rdata(rdata),
        .wfull(wfull),
        .rempty(rempty)
    );

    // Clock generation
    initial begin
        wclk = 0;
        //always #5 wclk = ~wclk; // 100MHz write clock
    end
	 always #5 wclk = ~wclk; // 100MHz write clock

    initial begin
        rclk = 0;
        //forever #7 rclk = ~rclk; // ~71MHz read clock
    end
	 always #7 rclk = ~rclk; // ~71MHz read clock

    // Reset generation
    initial begin
        wrst_n = 0;
        rrst_n = 0;
        #15 wrst_n = 1;
        #15 rrst_n = 1;
    end

    // Test sequence
    initial begin
        // Initialize signals
        winc = 0;
        rinc = 0;
        wdata = 0;

        // Wait for reset release
        @(posedge wrst_n);
        @(posedge rrst_n);

        // Test: Write data into FIFO
        repeat(16) begin
            @(posedge wclk);
            winc = 1;
            wdata = wdata + 1; // Writing random data
        end
        winc = 0;

        // Test: Read data from FIFO
        repeat(16) begin
            @(posedge rclk);
            rinc = 1;
        end
        rinc = 0;

        // Test: Edge case - Read from empty FIFO
        @(posedge rclk);
        rinc = 1;
        #10 rinc = 0;

        // Test: Edge case - Write to full FIFO
        repeat(16) begin
            @(posedge wclk);
            winc = 1;
            wdata = wdata + 1;
        end
        winc = 0;

        // End of simulation
        #100 $stop;
    end

endmodule
