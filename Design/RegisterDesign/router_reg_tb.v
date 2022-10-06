module router_reg_tb;
reg  clock,resetn,pkt_valid,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state;
reg [7:0] data_in;
wire parity_done,low_pkt_valid,err;
wire [7:0] dout;
integer i;
router_reg dut(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,err,dout);

task initialreset;
	begin
		resetn=1'b0;
		@(negedge clock);
		resetn=1'b1;
	end
endtask

task flowcheck;
	begin
		detect_add=1'b1;
		pkt_valid=1'b1;
		fifo_full=1'b0;
		data_in=8'b0011_1100;
		@(negedge clock);
		detect_add=1'b0;
		lfd_state=1'b1;
		@(negedge clock);
		lfd_state=1'b0;
		ld_state=1'b1;
		for(i=0;i<16;i=i+1) 
			begin
				data_in=i+4;
			@(negedge clock);
			end
		fifo_full=1'b1;
		@(negedge clock);
		ld_state=1'b0;
		full_state=1'b1;
		@(negedge clock);
		laf_state=1'b1;
		ld_state=1'b0;
		fifo_full=1'b0;
		@(negedge clock);
		pkt_valid=1'b0;
		ld_state=1'b1;
		data_in=8'b00111100;
		@(negedge clock);
		rst_int_reg=1'b1;
	end
endtask

always
	#5 clock=~clock;

initial begin
		clock=1'b0;
		initialreset;
		flowcheck;
		@(negedge clock);
		@(negedge clock);
		$finish;
	end
endmodule	