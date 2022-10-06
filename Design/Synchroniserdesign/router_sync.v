module router_sync(input detect_add,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,
                    input [1:0]data_in,output reg soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
                    output reg[2:0] write_enb,output vld_out_0,vld_out_1,vld_out_2);
	reg [1:0] tempaddr; 
        reg [4:0] counter0,counter1,counter2 ;
	
	always@(posedge clock) begin
 		if(~resetn)
			tempaddr<=0;
		else if	(detect_add)
			tempaddr<=data_in; 		
	end

	always@(*)
		begin
			if(write_enb_reg)begin
				case(tempaddr)
					2'b00:write_enb=3'b001;
					2'b01:write_enb=3'b010; 
					2'b10:write_enb=3'b100;
					default:write_enb=3'b000;
				endcase
			end
		end

	always@(*)
		begin
			case(tempaddr)
				2'b00: fifo_full=full_0;
				2'b01: fifo_full=full_1;
				2'b10: fifo_full=full_2;
			endcase
		end

		
		assign  vld_out_0=~empty_0;  //can't do in always block as will have to be non blocking but we want to use latest updated value in the next always for soft reset
		assign	vld_out_1=~empty_1;
		assign	vld_out_2=~empty_2;
	

	always@(posedge clock) begin
		if(~resetn) begin
			counter0<=0;
			soft_reset_0<=0;
		end
		else begin
			if(vld_out_0) begin
				if(read_enb_0)
					begin
						soft_reset_0<=0;
						counter0<=0;
					end
				else begin
					if(counter0 == 5'd29) begin  //including this and initial cycle at which vld_out just became hight, at 30th cycle we reset
						counter0<=0;
						soft_reset_0<=1'b1;
					end
					else begin
						counter0<=counter0+1'b1;
						soft_reset_0<=1'b0; 
					end
				end
			end
			else begin
				soft_reset_0<=0;
				counter0<=0;
			end
		end
	end

	always@(posedge clock) begin
		if(~resetn) begin
			counter1<=0;
			soft_reset_1<=0;
		end
		else begin
			if(vld_out_1) begin
				if(read_enb_1) begin
					soft_reset_1<=0;
					counter1<=0;
				end
				else begin
					if(counter1 == 5'd29) begin  //including this and initial cycle at which vld_out just became hight, at 30th cycle we reset
						counter1<=0;
						soft_reset_1<=1'b1;
					end
					else begin
						counter1<=counter1+1'b1;
						soft_reset_1<=1'b0; 
					end
				end
			end
			else begin
				soft_reset_1<=0;
				counter1<=0;
			end
		end
	end

	always@(posedge clock) begin
		if(~resetn) begin
			counter2<=0;
			soft_reset_2<=0;
		end
		else begin
			if(vld_out_2) begin
				if(read_enb_2) begin
					soft_reset_2<=0;
					counter2<=0;
				end
				else begin
					if(counter2 == 5'd29) begin  //including this and initial cycle at which vld_out just became hight, at 30th cycle we reset
						counter2<=0;
						soft_reset_2<=1'b1;
					end
					else begin
						counter2<=counter2+1'b1;
						soft_reset_2<=1'b0; 
					end
				end
			end
			else begin
				soft_reset_2<=0;
				counter2<=0;
			end
		end
	end

			
endmodule
