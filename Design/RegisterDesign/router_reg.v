module router_reg(input clock,resetn,pkt_valid,input [7:0] data_in,input fifo_full,rst_int_reg,detect_add,ld_state,
		  laf_state,full_state,lfd_state,output reg parity_done,low_pkt_valid,err,output reg[7:0] dout);
reg  [7:0] header_byte,fullstate_byte,internal_parity,packet_parity;

always@(posedge clock)  // to set and change internal registers
	begin
		if(rst_int_reg) 
			begin
				header_byte<=0;
				fullstate_byte<=0;
				internal_parity<=0;
				packet_parity<=0;
			end	
		else if(!resetn) 
			begin
				dout<=0;
				header_byte<=0;
				fullstate_byte<=0;
				internal_parity<=0;
				packet_parity<=0;
			end
   		else begin
			if(detect_add) begin
				if(pkt_valid)
					header_byte<=data_in;
				internal_parity<=8'b0;
			end
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
			if(ld_state && !full_state && pkt_valid)
				internal_parity<=internal_parity^data_in;
			else if(lfd_state) 
				internal_parity<=internal_parity^header_byte;
			else if(!pkt_valid && ld_state)
				packet_parity<=data_in;
		end
	end

always@(posedge clock)    //to calculate output signals
	begin
		if(!resetn)
			begin
				parity_done<=0;
				low_pkt_valid<=0;
			end
		else begin
			if((ld_state && !fifo_full && !pkt_valid) || (laf_state && ~pkt_valid && !parity_done))
				parity_done<=1;
			else if(detect_add)
				parity_done<=0;
	  		if(rst_int_reg)
				low_pkt_valid=0;
			else if(ld_state && !pkt_valid)
				low_pkt_valid=1;
		end
	end
always@(posedge clock)   //logic for calculating error
	begin
		if(!resetn)
			err<=0;
		else
             	   begin
			if(parity_done)
				err<=(packet_parity == internal_parity)?0:1;
		   end
	end
	
endmodule