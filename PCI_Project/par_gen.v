`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:11:30 02/20/2021 
// Design Name: 
// Module Name:    par_gen 
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
module par_gen(
    input [31:0] data,
    input [31:0] addr,
    output reg data_p,
    output reg addr_p
    );

always@(data,addr)
	begin
	data_p = ^data; 
	addr_p = ^addr;
	end

endmodule
