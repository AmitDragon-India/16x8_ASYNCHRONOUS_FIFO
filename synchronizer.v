module synchronizer #(parameter ADDRSIZE = 4)
	(input [ADDRSIZE:0] ptr,
	 input clk, rst_n,
	 output reg [ADDRSIZE:0] q2_ptr);
	 // synchronizer module
	reg [ADDRSIZE:0] q1_ptr;
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) {q2_ptr,q1_ptr} <= 0;
		else {q2_ptr,q1_ptr} <= {q1_ptr,ptr};
	end
endmodule