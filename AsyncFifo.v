module AsyncFifo_1 #(parameter DSIZE = 8,
parameter ASIZE = 4)
	(input [DSIZE-1:0] wdata,
	 input winc, wclk, wrst_n,
	 input rinc, rclk, rrst_n,
	 output [DSIZE-1:0] rdata,
	 output wfull,
	 output rempty);
	
	wire [ASIZE-1:0] waddr, raddr;
	wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;
	
	fifomemory #(DSIZE, ASIZE) fifomemory
		(.wdata(wdata), .waddr(waddr), .raddr(raddr),
		 .wclken(winc), .wfull(wfull), .wclk(wclk),
		 .rdata(rdata));
	
	synchronizer synchronizer_r2w (.ptr(rptr), .clk(wclk), .rst_n(wrst_n),
											 .q2_ptr(wq2_rptr));
											 
	synchronizer synchronizer_w2r (.ptr(wptr), .clk(rclk), .rst_n(rrst_n),
											 .q2_ptr(rq2_wptr));	
		 
	read_pointer_empty #(ASIZE) read_pointer_empty
		(.rq2_wptr(rq2_wptr), .rinc(rinc), .rclk(rclk),
		 .rrst_n(rrst_n), .rempty(rempty), .raddr(raddr),
		 .rptr(rptr));
		 
	write_pointer_full #(ASIZE) write_pointer_full
		(.wptr(wptr), .wq2_rptr(wq2_rptr),
		 .winc(winc), .wclk(wclk), .wrst_n(wrst_n),
		 .wfull(wfull), .waddr(waddr));
endmodule