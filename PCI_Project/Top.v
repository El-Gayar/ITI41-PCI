`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:05:18 02/24/2021 
// Design Name: 
// Module Name:    Top 
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
module Top(clk,rst,
			  ad,c_be,
			  frame,irdy,trdy,stop,perr,devsel,par,
			  req_64,ack_64
    );
	 
	 input clk,rst;
	 input frame,irdy,req_64;
	 output trdy,stop,perr,par,devsel,ack_64;
	 inout [63:0] ad;
	 inout [7:0]  c_be;
/***********************************************Wires************************************************************/
	 /**************************32-bit main wires**************************/
	 wire [31:0] data_ram_wr,addr_wr_ram;
	 wire [63:0] data_wr_ram;
	 wire        last_word_1,last_word_2,par_data,par_add,ram_devsel_32_1,ram_devsel_32_2,we_wr_ram;
	 wire [7:0]  be_wr_ram;
	 reg         last_word_final,ram_devsel_32_final;
	/******************************************************************/	
	 /**************************64-bit extension wires**************************/
	 wire [31:0] data_wr_ram_64,data_ram_wr_64;
	 wire [3:0]  be_wr_ram_64;
	 wire        ram_devsel_64,ram_req_64;
	 reg         ram_devsel_64_final;
	/******************************************************************/	
	
/****************************************************************************************************************/	


	 /**************************The PCI target core**************************/
	 pci_rw   rw(.rst(rst),.clk(clk),                   
				  .ad(ad),.c_be(c_be),                 
				  .frame(frame),.irdy(irdy),
				  .par_d(par_data),.par_addr(par_add),.devsel_ram_32(ram_devsel_32_final),.devsel_ram_64(ram_devsel_64), .last_add(last_word_final), .trdy(trdy),.devsel(devsel),.data_ram(data_ram_wr),.data_ram_64(data_ram_wr_64),  .stop(stop),
				  .par(par),.perr(perr),.we(we_wr_ram), .be_out(be_wr_ram),  .addr_out(addr_wr_ram),.data_out(data_wr_ram),
				  .req_64(req_64),.ack_64(ack_64),.req_64_ram(ram_req_64));
	/******************************************************************/		  
				  
	 /**************************32-bit slave**************************/
	sram_32     slave_32(    .data_in(data_wr_ram[31:0]),
    .add_in(addr_wr_ram),
	 .add_start(30'h00000000),.add_end(30'h0000000f),
    .be(be_wr_ram[3:0]),
    .we(we_wr_ram),.clk(clk),.req_64(ram_req_64),
	 .data_out(data_ram_wr),
    .devsel_32(ram_devsel_32_1),
    .last_add(last_word_1));
	/******************************************************************/ 
	 
	 /**************************64-bit slave**************************/
	sram_64     slave_64(.data_in(data_wr_ram),
    .add_in(addr_wr_ram),
	 .add_start(30'h00000020),.add_end(30'h0000002f),
    .be(be_wr_ram),
    .we(we_wr_ram),.clk(clk),.req_64(ram_req_64),
	 
    .data_out({data_ram_wr_64,data_ram_wr}),
    .devsel_32(ram_devsel_32_2),
	 .devsel_64(ram_devsel_64),
    .last_add(last_word_2)
    );
	/******************************************************************/
	 

	 /**************************Parity gen**************************/
	 par_gen p_gen(
    .data(data_wr_ram[31:0]),
    .addr(addr_wr_ram),
    .data_p(par_data),
    .addr_p(par_add)
    );
	/******************************************************************/
/****************************************************************************************************************/	


always@(*)
	begin
	if(ram_devsel_32_1 == 1'b0 || ram_devsel_32_2 == 1'b0) 		ram_devsel_32_final = 1'b0;
	else   ram_devsel_32_final = 1'b1;

	if(last_word_1 == 1'b1 || last_word_2 == 1'b1) 		last_word_final = 1'b1;
	else   last_word_final = 1'b0;
	end
	
endmodule
