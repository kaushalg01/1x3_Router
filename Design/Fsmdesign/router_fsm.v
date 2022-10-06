module router_fsm(input clock,resetn,pkt_valid,parity_done,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,
	          fifo_empty_1,fifo_empty_2,input [1:0]data_in,output reg busy,lfd_state,detect_add,ld_state,laf_state,full_state,write_enb_reg,
		   rst_int_reg);
parameter DECODE_ADDRESS=3'b000,LOAD_FIRST_DATA=3'b001,LOAD_DATA=3'b010,LOAD_PARITY=3'b011,FIFO_FULL_STATE=3'b100,LOAD_AFTER_FULL=3'b101,
	   CHECK_PARITY_ERROR=3'b110,WAIT_TILL_EMPTY=3'b111;
reg [2:0] state,nstate;

always@(state,pkt_valid,data_in,fifo_empty_0,fifo_empty_1,fifo_empty_2,parity_done,low_pkt_valid,fifo_full) 
	begin
		case(state)
			DECODE_ADDRESS:begin 
					if((pkt_valid && (data_in==0) && fifo_empty_0) || (pkt_valid &&  data_in == 1 && fifo_empty_1) || 
					   (pkt_valid && (data_in==2) && fifo_empty_2)) 
						nstate<=LOAD_FIRST_DATA;
					else if((pkt_valid && (data_in==0) && !fifo_empty_0) || (pkt_valid &&  data_in == 1 && !fifo_empty_1) || 
					   (pkt_valid && (data_in==2) && !fifo_empty_2))
						nstate<=WAIT_TILL_EMPTY;
					else nstate<=state;
					end
			LOAD_FIRST_DATA:nstate<=LOAD_DATA;
			LOAD_DATA:begin 
					if(fifo_full) nstate<=FIFO_FULL_STATE;
					else if(!fifo_full && !pkt_valid) nstate<=LOAD_PARITY;
					else nstate<=state;
				  end
			LOAD_PARITY:nstate<=CHECK_PARITY_ERROR;
			FIFO_FULL_STATE:begin 
					  if(!fifo_full) nstate<=LOAD_AFTER_FULL;
					  else nstate<=state;
					end
			LOAD_AFTER_FULL:begin
					  if(!parity_done && low_pkt_valid) nstate<=LOAD_PARITY;
					  else if(!parity_done && !low_pkt_valid) nstate<=LOAD_DATA;
					  else if(parity_done) nstate<=DECODE_ADDRESS;
					end
			CHECK_PARITY_ERROR:begin 
						if(!fifo_full) nstate<=DECODE_ADDRESS;
						else nstate<=FIFO_FULL_STATE;
					   end
			WAIT_TILL_EMPTY:begin
						if((fifo_empty_0 && data_in == 0) || (fifo_empty_1 && data_in == 1) || (fifo_empty_2 && data_in == 2))
							 nstate<=LOAD_FIRST_DATA;
						else nstate<=state;
					end
		endcase
	end

always@(posedge clock)
	begin
		if(!resetn || soft_reset_0 || soft_reset_1 || soft_reset_2) 
			state<=DECODE_ADDRESS;
		else 
			state<=nstate;
	end
always@(state) 
	begin
	case(state)	
		DECODE_ADDRESS:begin detect_add=1;
				     lfd_state=0;
				     busy=0;
				     ld_state=0;
				     write_enb_reg=0;
				     full_state=0;
				     laf_state=0;
				     rst_int_reg=0;
				end
		LOAD_FIRST_DATA: begin lfd_state=1;
				 detect_add=0;
				 busy=1; 
				end
		LOAD_DATA: begin 
				busy=0;
				ld_state=1;
				write_enb_reg=1;
				lfd_state=0;
			   end
		LOAD_PARITY:begin 	
				busy=1;	
				laf_state=0;
				ld_state=0;
			    end
		CHECK_PARITY_ERROR:begin
					write_enb_reg=0;
					rst_int_reg=1;
				   end
		FIFO_FULL_STATE:begin
					busy=1;
					ld_state=0;
					write_enb_reg=0;
					full_state=1;
				end
		LOAD_AFTER_FULL: begin
					write_enb_reg=1;
					full_state=0;
					laf_state=1;
				end
		WAIT_TILL_EMPTY:begin
					busy=1;
					detect_add=0;
				end
		endcase
	end				
//assign detect_add=(state == DECODE_ADDRESS)?1:0;
//assign lfd_state=(state == LOAD_FIRST_DATA)?1:0;
//assign busy=((state == LOAD_DATA) || (state == DECODE_ADDRESS))?0:1;
//assign ld_state=(state == LOAD_DATA)?1:0;
//assign write_enb_reg=((state == LOAD_DATA) || (state == LOAD_PARITY) || (state == LOAD_AFTER_FULL))?1:0;
//assign full_state=(state == FIFO_FULL_STATE)?1:0;
//assign laf_state=(state == LOAD_AFTER_FULL)?1:0;
//assign rst_int_reg=(state == CHECK_PARITY_ERROR)?1:0;

endmodule
