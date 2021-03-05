`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:04:47 02/19/2021 
// Design Name: 
// Module Name:    pci_rw 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pci_rw(rst,clk,
				  frame,ad,c_be,
				  irdy,trdy,devsel,stop,
				  par,perr,
    );
///////////////////////////////Inputs,outputs and inouts//////////////////////////
inout [31:0] ad;
inout [3:0]  c_be;


input        par_d,par_addr,devsel_ram;
input        clk,rst;
input        frame,irdy;

output  reg  par;
output  reg  trdy,devsel;
output  reg  stop,perr;
output  reg  [31:0] addr_out;
//////////////////////////////////////////////////////////////////////////////////

///////////////////////////////Internal regs and wires////////////////////////////
reg [31:0] ad_r;
reg [3:0]  c_be_r;
reg        frame_r,irdy_r,par_r;
reg [19:0] dev_buff [0:29];
reg [29:0] add_start,add_end;
reg [31:0] address_new,address_base,data_new;
reg        dir_rw;
reg [31:0] be_rep;
reg        ad_oe = 0;
reg        c_be_oe = 0;

wire 		  add_valid = frame_r == 0 && ad_r>=add_start[19] && add_end>=ad_r;
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////Local params and states/command/////////////////////////////
reg [4:0]         state      = idle;
reg [4:0]         next_state = idle;
localparam [4:0]  idle = 5'b11000 ,address = 5'b11001 ,wr_data = 5'b11010 ,terminate = 5'b11011 ,turn_around = 5'b11100 ,r_data = 5'b11101 ;
localparam [3:0]  int_ack = 4'b0000 ,mem_r = 4'b0110 ,mem_w = 4'b0111 ,mem_r_mult = 4'b1100 ,mem_r_line = 4'b1110 ,dual = 4'b1101;
//////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////Tri state assignments//////////////////
assign   ad   = ad_oe ?   ad_r   : 32'bz ;
assign   c_be = c_be_oe ? c_be_r : 4'bz  ;
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////negedge state/reg evaluation////////////////////////
always@(negedge clk)
	begin
	if(!rst)
		begin
		state    = idle;
		end
	else
		begin
		state    = next_state;
		end
	end
////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////states////////////////////////////////////////
always@(negedge clk)
	begin
		case(state)
			idle : 
				begin
				
				ad_r     <= 32'bz ;
				c_be     <= 4'bz  ;
				ad_oe    <= 1'b1  ;
				c_be_oe  <= 1'b1  ;
				
				
				trdy     <= 1'b1  ;
				devsel   <= 1'b1  ;
				if (frame == 1'b0 )
					begin
					frame_r    <= 1'b0;
					next_state <= address;
					end
				else
					begin
					frame_r    <= 1'b1;
					next_state <= idle;
					end
				end
			
			
			address :
				begin
				ad_r   = ad;
				c_be_r = c_be;
				irdy_r = 1'b1;
				trdy_r = 1'b1;
				devsel = 1'b1;
				
				address_base <= ad ;
				address_out  <= ad ;

				if (frame == 1'b0)
					begin
					case(c_be_r)
							mem_w      :   next_state <= we_data     ;
							mem_r      :   next_state <= turn_around ;
							mem_r_mult :   next_state <= turn_around ;
							mem_r_line :   next_state <= turn_around ;
							default    :   next_state <= idle        ;
					endcase;	
					end
				else
					begin
					next_state <= idle;
					end
				end

				
			
			wr_data :
				begin
					ad_r = ad;
					be_rep ={{8{C_BE[3]}}, {8{C_BE[2]}}, {8{C_BE[1]}}, {8{C_BE[0]}}};
					Memory [index] = ad_r & mask;
					ad_r = ad_r+1;
					
				end
				
			turn_around :
				begin
				
				
				if(devsel_ram == 1'b0 && frame == 1'b0 && irdy == 1'b0)
					begin
					devsel     <= 1'b0;
					trdy       <= 1'b0;
					next_state <= r_data; 
					end
				else
					begin
					next_state <=
					end
				end
				
			r_data :
				begin
				
				end                    
				
			terminate :
				begin
				
				end
			endcase;
		
end
////////////////////////////////////////////////////////////////////////////////////////
endmodule
