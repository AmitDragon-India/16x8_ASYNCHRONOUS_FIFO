module AsyncFifoTb;

  parameter DATASIZE = 8;
  parameter ADDRSIZE = 4;

  wire [DATASIZE-1:0] rdata;
  wire wfull;
  wire rempty;
  reg [DATASIZE-1:0] wdata;
  reg winc, wclk, wrst_n;
  reg rinc, rclk, rrst_n;
  
  integer i = 0;
  integer j = 0;
  // Instantiate the FIFO
  AsyncFifo #(DATASIZE, ADDRSIZE) dut (
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
 initial begin
    wclk = 1'b0;
    rclk = 1'b0;

    forever #20 wclk = ~wclk;
  end

  initial begin
    forever #30 rclk = ~rclk;
  end


  initial begin
    winc = 1'b0;
    wdata = 1'b0;
    wrst_n = 1'b0;
    repeat(5) @(posedge wclk);
    wrst_n = 1'b1;

      for (i = 0; i < 16; i = i + 1) begin
        @(posedge wclk);
        if (!wfull) begin
          winc = (i % 2 == 0) ? 1'b1 : 1'b0;
          if (winc) begin
            wdata = $urandom;
          end
        end
      end
      
  end

  initial begin
    rinc = 1'b0;
    rrst_n = 1'b0;
    repeat(8) @(posedge rclk);
    rrst_n = 1'b1;

      for (j = 0; j < 64; j = j + 1) begin
        @(posedge rclk);
        if (!rempty) begin
          rinc = (j % 2 == 0) ? 1'b1 : 1'b0;
			end
      end
  end

endmodule