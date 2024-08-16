`timescale 1ps/1ps

module AsyncFifoTb1;

  parameter DATADDRSIZE = 8;
  parameter ADDRSIZE = 4;

  // Signal declarations
  wire [DATADDRSIZE-1:0] rdata;
  wire wfull;
  wire rempty;
  reg [DATADDRSIZE-1:0] wdata;
  reg winc, wclk, wrst_n;
  reg rinc, rclk, rrst_n;

  // Model a queue for checking data
  reg [DATADDRSIZE-1:0] verif_data_q [0:31];
  integer wr_ptr = 0;
  integer rd_ptr = 0;

  // Instantiate the FIFO
  AsyncFifo #(DATADDRSIZE, ADDRSIZE) dut (
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
    wclk = 1'b0;
    rclk = 1'b0;
    forever #20 wclk = ~wclk;  // 50MHz write clock
  end

  initial begin
    forever #70 rclk = ~rclk;  // ~14.29MHz read clock
  end

  integer iter;
  integer i;
  // Write sequence
  initial begin
    winc = 1'b0;
    wdata = 1'b0;
    wrst_n = 1'b0;
    repeat(5) @(posedge wclk);
    wrst_n = 1'b1;

    for (iter = 0; iter < 2; iter = iter + 1) begin
      for (i = 0; i < 32; i = i + 1) begin
        @(posedge wclk);
        if (!wfull) begin
          winc = (i % 2 == 0) ? 1'b1 : 1'b0;
          if (winc) begin
            wdata = $random % 256;  // Generate random 8-bit data
            verif_data_q[wr_ptr] = wdata;
            wr_ptr = (wr_ptr + 1) % 32;
          end
        end
      end
      #1000;  // Wait for 1 microsecond
    end
  end

 
  // Read sequence
  initial begin
    rinc = 1'b0;
    rrst_n = 1'b0;
    repeat(8) @(posedge rclk);
    rrst_n = 1'b1;

    for (iter = 0; iter < 2; iter = iter + 1) begin
      for (i = 0; i < 32; i = i + 1) begin
        @(posedge rclk);
        if (!rempty) begin
          rinc = (i % 2 == 0) ? 1'b1 : 1'b0;
          if (rinc) begin
            $display("Checking rdata: expected wdata = %h, rdata = %h", verif_data_q[rd_ptr], rdata);
            if (rdata !== verif_data_q[rd_ptr]) begin
              $error("Checking failed: expected wdata = %h, rdata = %h", verif_data_q[rd_ptr], rdata);
            end
            rd_ptr = (rd_ptr + 1) % 32;
          end
        end
      end
      #1000;  // Wait for 1 microsecond
    end

    $finish;
  end

endmodule
