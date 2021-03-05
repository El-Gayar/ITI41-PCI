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
module sram_64(
    input [63:0] data_in,
    input [31:0] add_in,
	 input [29:0] add_start,add_end,
    input [7:0] be,
    input we,clk,req_64,
	 
    output reg [63:0] data_out,
    output reg devsel_32,
	 output reg devsel_64,
    output reg last_add
    );
	 
/////////////////////////////////regs and wires///////////////////////////////////
reg [63:0] mem [0:255];
reg [29:0] add;
reg [63:0] data_d;
//////////////////////////////////////////////////////////////////////////////////

always @(posedge clk)
	begin
	add = add_in[31:2];
	if(add >= add_start && add_end>add && req_64 == 1'b0 ) //Checking if this device is the correct one
		begin
		devsel_32   = 1'b1;
		devsel_64   = 1'b0;
		last_add = 1'b0;
		end
	else if(add >= add_start && add_end>add && req_64 == 1'b1 ) //Checking if this device is the correct one
		begin
		devsel_32   = 1'b0;
		devsel_64   = 1'b1;
		last_add = 1'b0;
		end
	else if (add == add_end && req_64 == 1'b0)
		begin
		devsel_32   = 1'b1;
		devsel_64   = 1'b0;
		last_add = 1'b1;
		end
	else if (add == add_end && req_64 == 1'b1)
		begin
		devsel_32   = 1'b0;
		devsel_64   = 1'b1;
		last_add = 1'b1;
		end
	else
		begin
		devsel_64 = 1'b1;
		devsel_32 = 1'b1;
		last_add  = 1'b0;
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
		data_d[31:0]   = mem[add][31:0];
		*/
		///////////////////////////////////////////////////////////
		
		/////////////////////changes data to 0 if be=0/////////////
		
		mem[add][31:0]  = data_in[31:0] & {{8{be[3]}},{8{be[2]}},{8{be[1]}},{8{be[0]}}};
		data_d [31:0]   = data_in[31:0] & {{8{be[3]}},{8{be[2]}},{8{be[1]}},{8{be[0]}}};
		
		///////////////////////////////////////////////////////////
		end	
	else if(devsel_64 == 1'b0 && we == 1'b1)    //Write command
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
		
		if(be[4] == 1'b1) mem[add][39:32] = data_in[39:32];
		else              mem[add][39:32] = mem[add][39:32];
		
		if(be[5] == 1'b1) mem[add][47:40] = data_in[47:40];
		else              mem[add][47:40] = mem[add][47:40];

		if(be[6] == 1'b1) mem[add][55:48] = data_in[55:48];
		else              mem[add][55:48] = mem[add][55:48];

		if(be[7] == 1'b1) mem[add][63:56] = data_in[63:56];
		else              mem[add][63:56] = mem[add][63:56];
		data_d   = mem[add];
		*/
		///////////////////////////////////////////////////////////
		
		/////////////////////changes data to 0 if be=0/////////////
		
		mem[add] = data_in & {{8{be[7]}},{8{be[6]}},{8{be[5]}},{8{be[4]}},{8{be[3]}},{8{be[2]}},{8{be[1]}},{8{be[0]}}};
		data_d   = data_in & {{8{be[7]}},{8{be[6]}},{8{be[5]}},{8{be[4]}},{8{be[3]}},{8{be[2]}},{8{be[1]}},{8{be[0]}}};
		
		///////////////////////////////////////////////////////////
		end
	else if(devsel_32 == 1'b0 && we == 1'b0) data_out = {32'b0,mem[add][31:0]};
	else if(devsel_64 == 1'b0 && we == 1'b0) data_out = mem[add];
	else                                  data_out = 64'bz;
	
			
		
	
	end
endmodule
