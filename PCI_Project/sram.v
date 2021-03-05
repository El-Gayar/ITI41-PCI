`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:09:13 02/20/2021 
// Design Name: 
// Module Name:    sram 
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
module sram_32(
    input [31:0] data_in,
    input [31:0] add_in,
	 input [29:0] add_start,add_end,
    input [3:0] be,
    input we,clk,req_64,
	 
    output reg [31:0] data_out,
    output reg devsel_32,
    output reg last_add
    );
	 
/////////////////////////////////regs and wires///////////////////////////////////
reg [31:0] mem [0:1024];
reg [29:0] add;
reg [31:0] data_d;
//////////////////////////////////////////////////////////////////////////////////

always @(posedge clk)
	begin
	add = add_in[31:2];
	if(add >= add_start && add_end>add ) //Checking if this device is the correct one
		begin
		devsel_32   = 1'b0;
		last_add = 1'b0;
		end
	else if (add == add_end)
		begin
		devsel_32   = 1'b0;
		last_add = 1'b1;
		end
	else
		begin
		devsel_32   = 1'b1;
		last_add = 1'b0;
		end
	
	if(devsel_32 == 1'b0 && we == 1'b1)    //Write command
		begin
		//////////////////////Keeps same value if be=0////////////
		/*
		if(be[0] == 1'b1) mem[add][7:0] = data_in[7:0];
		else              mem[add][7:0] = mem[add][7:0];
		
		if(be[1] == 1'b1) mem[add][15:8] = data_in[15:8];
		else              mem[add][15:8] = mem[add][15:8];

		if(be[2] == 1'b1) mem[add][23:16] = data_in[23:16];
		else              mem[add][23:16] = mem[add][23:16];

		if(be[3] == 1'b1) mem[add][31:24] = data_in[31:24];
		else              mem[add][31:24] = mem[add][31:24];
		data_d   = mem[add];
		*/
		///////////////////////////////////////////////////////////
		
		/////////////////////changes data to 0 if be=0/////////////
		
		mem[add] = data_in & {{8{be[3]}},{8{be[2]}},{8{be[1]}},{8{be[0]}}};
		data_d   = data_in & {{8{be[3]}},{8{be[2]}},{8{be[1]}},{8{be[0]}}};
		
		///////////////////////////////////////////////////////////
		end	
	else if(devsel_32 == 1'b0 && we == 1'b0) data_out = mem[add];
	else                                  data_out = 30'bz;
	
			
		
	
	end
endmodule
