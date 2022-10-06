module router_top_tb;
reg clock,resetn,pkt_valid,read_enb_0,read_enb_1,read_enb_2;
reg [7:0] data_in;
wire valid_out_0,valid_out_1,valid_out_2,error,busy;
wire [7:0] data_out_0,data_out_1,data_out_2;
integer i;

router_top dut_top(clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,
		valid_out_1,valid_out_2,error,busy);

always 
	#5 clock=~clock;

task initialise;
	begin
		clock=1'b0;
		resetn=1'b0;
		read_enb_0=1'b0;
		read_enb_1=1'b0;
		read_enb_2=1'b0;
		data_in=0;
		pkt_valid=1'b0;
	end
endtask

task reset;
	begin
		@(negedge clock);
		resetn=1'b1;
		@(negedge clock);
	end
endtask

task dataflow;
begin
	pkt_valid=1'b1;
	data_in=8'b0011_11010;
	@(negedge clock);
	for(i=0;i<30;i=i+1)
		begin
			while(busy == 1'b1)	begin
				@(negedge clock);
				read_enb_2=1'b1;
			end
			data_in=i+4;
			@(negedge clock);
			if(i == 30)    //last payload data sent and now parity to be sent
				pkt_valid=1'b0;
		end
	data_in=8'b1010_1010;
	@(negedge clock);
	data_in=0;
end
endtask

initial 
	begin
		initialise;
		reset;
		dataflow;
		repeat(100) @(negedge clock);
		$finish;
	end

endmodule
