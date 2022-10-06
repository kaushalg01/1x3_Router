# Router_1x3
Verilog implementation of 1x3 Router


Router is a layer 3 networking device that forwards packets between computer networks. It drives an incoming packet to an output channel based on the address field contained in the header field of the packet.



<img width="500" alt="image" src="https://user-images.githubusercontent.com/75021962/194210462-d165eec6-eef6-491d-aafb-0b23167ea39a.png">


The router follows packet based protocol. It receives input packet as data_in from source network on a byte by byte basis on posedge of clock. resetn is synchronous active low reset.
The starting of a packet is indicated by asserting pkt_valid and end of the packet is indicated by deasserting pkt_valid. The design stores the packet inside a FIFO as per the address of the packet. There are 3 different FIFOs for 3 different networks.
During read operation, the destination monitors vld_out_x(x=0,1,2) and then asserts read_enb_x. The packet is then read by the destination using data_out_x.
The router may enter into busy state indicated by the busy signal. The busy signal is sent back to the source LAN so that source has to wait to send the next byte of  the packet.
To confirm the correctness of the received, a parity checking mechanism has been implemented. If there is a mismatch in the parity byte sent and the internal parity calculated by the router , an error signal is generated which is sent to the source and the source can then resend the packet.
The design can only  receive 1 packet at a time, but 3 packets can be read simultaneouly.

Router packet

<img width="300" alt="image" src="https://user-images.githubusercontent.com/75021962/194207763-df2df1a2-4154-4064-b570-df48989b2743.png">
 Packet format: The packet consists of 3 parts: header, payload data and parity such that each is of 8 bits. Payload can of 1 to 63 length.
 
1. Header: It contains Destination address(DA) and length. The least 2 significant bits give the destination and the remaining 6 give the length of payload data.
2. Payload: It contains the data information.
3. Parity: It contains the security check of the packet. It is calculated as bitwise parity over the header and payload bytes of the packet.



The router consists of the following blocks:
1. It contains 3 FIFOs to store packet based on the address.
2. It contains a Synchroniser block that resets the FIFO if read_enb_x is not received within 30 clock cycles of assertion of vld_out_x.
3. It contains a Register block that temporarily stores header byte, internal parity while calculating parity, packet parity and full state byte. It also generates error signal in case of mismatch in generated and received parity.
4. It contains an FSM controller that generates and sends the control signals.


The top module is as shown:
  <img width="826" alt="image" src="https://user-images.githubusercontent.com/75021962/194208665-6220ab55-758b-4db7-9eb8-03e2d4b6b3fa.png">
  
  The block diagram of following blocks are as shown:
  

1.FIFO:

<img width="201" alt="image" src="https://user-images.githubusercontent.com/75021962/194210000-c562ae89-0f4f-4287-adf0-0c495a77a919.png">

2. Synchroniser block:
<img width="201" alt="image" src="https://user-images.githubusercontent.com/75021962/194210049-40a9acce-e85d-4617-ab54-014ab0f68af8.png">

3. Register block:
<img width="201" alt="image" src="https://user-images.githubusercontent.com/75021962/194210111-cc5c4e30-503b-402e-ab73-f5d4173982f1.png">

4. FSM Controller block:
<img width="383" alt="image" src="https://user-images.githubusercontent.com/75021962/194210144-d827c83a-b798-4a54-ab8f-8e1bc94df93e.png">

The Design folder contains the design RTL code and testbench code. 
Synthesis folder contains RTL synthesised design ,which has been synthesised using Quartus prime , .qpf files can be viewed usin Quartus Prime to view the generated netlist.
Output waveform has been attached as below:

<img width="500" height = "500" alt="image" src="https://user-images.githubusercontent.com/75021962/194216375-f9ab414a-5b60-4c1c-b530-aad7870bbaba.png">






