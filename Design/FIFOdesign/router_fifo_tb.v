`timescale 1ns/1ns
module router_fifo_tb;
reg clock,rstn,write_enb,soft_rst,read_enb,lfd_state;
reg [7:0] data_in;
wire full,empty;
wire [7:0] data_out;
integer i,j;
router_fifo dut(clock,rstn,write_enb,soft_rst,read_enb,lfd_state,data_in,empty,full,data_out);
always begin
 #10 clock=~clock;
end

task reset();
begin
 @(negedge clock);
 rstn=1'b0;
 @(negedge clock);
 rstn=1'b1;
end
endtask

task wdata(input [7:0] in,input state);
 begin
   write_enb=1'b1;
   data_in=in; 
   lfd_state=state;
  @(negedge clock);
  end
endtask

task rdata;
  begin
    read_enb=1'b1;
    @(negedge clock);
   end
endtask

task softreset;
 begin
   soft_rst=1'b0;
   @(negedge clock);
   soft_rst=1'b1;
   @(negedge clock);
 end
endtask

initial begin
    clock=1'b0;
    reset;
    for(i=0;i<16;i=i+1) begin 
        if(i==0)
           wdata(8'b00111001,1);
        else
           wdata(i+4,0);
    end  
    write_enb=1'b0;
    for(j=0;j<17;j=j+1) begin 
        rdata;
        if(j==16) 
         softreset;
     end
    #10; 
    $finish;
end

endmodule   

 
 
