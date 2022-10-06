module router_reg(input clock,resetn,pkt_valid,input [7:0] data_in,input fifo_full,rst_int_reg,detect_add,ld_state,
		  laf_state,full_state,lfd_state,output reg parity_done,low_pkt_valid,err,output reg[7:0] dout);
reg  [7:0] header_byte,fullstate_byte,internal_parity,packet_parity;

always@(posedge clock) 
	begin
		if(!resetn) 
			begin
				dout<=0;
				parity_done<=0;
				low_pkt_valid<=0;
				err<=0;
				header_byte<=0;
				fullstate_byte<=0;
				internal_parity<=0;
				packet_parity<=0;
			end
   		else begin
			if(detect_add && pkt_valid)
				header_byte<=data_in;
			else if(lfd_state)
				dout<=header_byte;
			else if(ld_state) 
				begin	
					if(fifo_full)
						fullstate_byte<=data_in;
					else
					 	dout<=data_in;
				end
			else if(laf_state)
				dout<=fullstate_byte;
			if(!full_state && !low_pkt_valid)
				internal_parity<=internal_parity^data_in;
			else if(low_pkt_valid)
				packet_parity<=data_in;
		end
	end

always@(posedge clock)
	begin
		if(rst_int_reg) 
			begin
				low_pkt_valid<=0;
				header_byte<=0;
				fullstate_byte<=0;
				internal_parity<=0;
				packet_parity<=0;
				err<=(packet_parity == internal_parity)?0:1;
			end
	end

always@(*)
	begin
		if(
		
		
	