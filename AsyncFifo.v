module AsyncFifo #(parameter DATASIZE = 16,
parameter ADDRSIZE = 4)
	(input [DATASIZE-1:0] wdata,
	 input winc, wclk, wrst_n,
	 input rinc, rclk, rrst_n,
	 output [DATASIZE-1:0] rdata,
	 output wfull,
	 output rempty);
	
	wire [ADDRSIZE-1:0] waddr, raddr;
	wire [ADDRSIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;
	
	fifomemory #(DATASIZE, ADDRSIZE) fifomemory
		(.wdata(wdata), .waddr(waddr), .raddr(raddr),
		 .wclken(winc), .wfull(wfull), .wclk(wclk),
		 .rdata(rdata));
	
	synchronizer synchronizer_r2w (.ptr(rptr), .clk(wclk), .rst_n(wrst_n),
											 .q2_ptr(wq2_rptr));
											 
	synchronizer synchronizer_w2r (.ptr(wptr), .clk(rclk), .rst_n(rrst_n),
											 .q2_ptr(rq2_wptr));	
		 
	read_pointer_empty #(ADDRSIZE) read_pointer_empty
		(.rq2_wptr(rq2_wptr), .rinc(rinc), .rclk(rclk),
		 .rrst_n(rrst_n), .rempty(rempty), .raddr(raddr),
		 .rptr(rptr));
		 
	write_pointer_full #(ADDRSIZE) write_pointer_full
		(.wptr(wptr), .wq2_rptr(wq2_rptr),
		 .winc(winc), .wclk(wclk), .wrst_n(wrst_n),
		 .wfull(wfull), .waddr(waddr));
endmodule