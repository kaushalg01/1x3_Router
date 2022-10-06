module router_sync_tb;
reg  detect_add,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;
reg  [1:0]data_in;
wire vld_out_0,vld_out_1,vld_out_2,fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;
wire [2:0] write_enb;
router_sync dut(detect_add,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,
		full_2,data_in,soft_reset_0,soft_reset_1,soft_reset_2,write_enb,vld_out_0,vld_out_1,vld_out_2,fifo_full);

always 
	#10 clock=~clock;
		
task reset();
	begin
	 resetn=1'b0;
	 @(negedge clock);
	 resetn=1'b1;
	end
endtask

task writeinitial;   // writes header byte then makes empty as 0 on next edge,write_enb_reg is asserted on next edge, after empty is driven low
	begin
	  detect_add=1'b1;
          {empty_0,empty_1,empty_2}=3'b111;
          data_in=2'b10;
  	  @(negedge clock);
 	  detect_add=1'b0;
     	  @(negedge clock);
	  write_enb_reg=1'b1;
	  @(negedge clock);
	  empty_1=1'b1;
	  empty_0=1'b0;
	end
endtask

task read_enbset(input [4:0] ccreadenb,ccfifofull);  //no. of clocks for after which read_enb and full_0 become 1
	fork
	   begin 
		repeat(ccreadenb) @(negedge clock);
                read_enb_0=1'b1; 
	   end
      	   begin 	
		repeat(ccfifofull) @(negedge clock);
		full_0=1'b1;
           end
	join
endtask

initial begin
		clock=1'b0;
		reset;
		writeinitial;
		read_enbset(5'd30,5'd14);
		#300 $finish;
end
endmodule