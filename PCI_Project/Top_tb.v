`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:43:49 02/24/2021
// Design Name:   Top
// Module Name:   E:/ITI_references/Digital_IC_course/Verilog/Project/PCI/Top_tb.v
// Project Name:  PCI
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Top_tb;

	// Inputs
	reg clk;
	reg rst;
	reg frame;
	reg irdy;
	reg req_64;

	// Outputs
	wire trdy;
	wire stop;
	wire perr;
	wire devsel;
	wire par;
	wire ack_64;

	// Bidirs
	wire [63:0] ad;
	wire [7:0] c_be;


	// Instantiate the Unit Under Test (UUT)
	Top uut (
		.clk(clk), 
		.rst(rst), 
		.ad(ad), 
		.c_be(c_be), 
		.frame(frame), 
		.irdy(irdy), 
		.trdy(trdy), 
		.stop(stop), 
		.perr(perr), 
		.devsel(devsel), 
		.par(par),
		.req_64(req_64),
		.ack_64(ack_64)
	);
	
	//Internal Regs//
   reg [63:0] ad_reg;
	reg ad_oe,c_be_oe;
	reg [7:0]  c_be_reg;
	
	//Clocking block//
	initial clk = 0;
	always 
		begin
		#10 clk =~ clk;
		end
	/***************/
	
	//Assign stimuli for tri-state	
	assign ad   = ad_oe ? ad_reg : 64'bz; 
   assign c_be = c_be_oe ? c_be_reg : 8'bz;	
	/**************************************/
	
	initial begin
		//INITIAL TRI-STATE MODE
		c_be_oe = 1;
		ad_oe =1;
		/****32-bit scenario with req_64 asserted (not compatible) ****/
		//IDLE
		#10
		frame = 1;
		req_64   = 1'b1;
		rst = 0;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bz;
		
		
		//IDLE
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bz;
		#1
		
		#10
		
		//ADDRESS
		#9
		frame = 0;
		req_64   = 1'b0;
		rst = 1;
		irdy = 1;
		ad_reg = 64'b0;
		c_be_reg =8'b0111;
		#1
		
		#10
		
		//WRITE_1
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h1A2B3C4D;
		c_be_reg =8'b1001;
		#1

		#10
		
		//WRITE_2
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hEEEEEEEE;
		c_be_reg =8'b1111;
		#1
		
		#10
		
		//WRITE_3
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hAAAABBBB;
		c_be_reg =8'b0011;
		#1
		
		#10
		
		//WRITE_4_wait
		#9
		frame = 0;
		rst = 1;
		irdy = 1;
		ad_reg = 64'hFFFFFFFF;
		c_be_reg =8'b0001;
		#1
		
		#10
		//WRITE_4
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hFFFFFFFF;
		c_be_reg =8'b0001;
		#1
		
		#10
		
		//WRITE_5
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hABCDEF01;
		c_be_reg =8'b1110;
		#1
		
		#10
		//WRITE_6
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hEE33FF55;
		c_be_reg =8'b0000;
		#1
		
		#10
		//WRITE_7
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hD123456E;
		c_be_reg =8'b1111;
		#1
		
		#10
		
		//WRITE_8
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h98765432;
		c_be_reg =8'b1010;
		#1
		
		#10

		//WRITE_9
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h13061997;
		c_be_reg =8'b1111;
		#1
		
		#10
		
		//LAST_WRITE_1
		#9
		frame = 1;
		req_64   = 1'b1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'hFFFFFFFF;
		c_be_reg =8'b0001;
		#1
		
		#10
		//TERMINATE
		#9
		frame = 1;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hFFFFFFFF;
		c_be_reg =8'b0001;
		#1
		
		#10
		//IDLE
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'hzzzzzzzz;
		c_be_reg =8'bz;
		#1
		
		#10
		/********Read test**********/
		//IDLE
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bz;
		#1
		
		#10
		//ADDRESS
		#9
		frame = 0;
		rst = 1;
		irdy = 1;
		ad_reg = 64'h00000006;
		c_be_reg =8'b1110;
		#1
		
		#10
		//TURN AROUND
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'bz;
		c_be_reg =8'b1110;
		#1
		
		#10
		//DATA cycle 1
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'bz;
		c_be_reg =8'b0110;
		ad_oe = 1'b0;
		#1
		
		#10
		//DATA cycle 2
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 3
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 4
		#9
		frame = 0;
		rst = 1;
		irdy = 1;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 5
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 6
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 7
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 8
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 9
		#9
		frame = 1;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 9
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bzzzz;
		ad_oe = 1'b1;
		#1
		
		#10
		
		/****Read Scenario_2 (Normal _ read) ****/
		//IDLE
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bz;
		#1
		
		#10
		//ADDRESS
		#9
		frame = 0;
		rst = 1;
		irdy = 1;
		ad_reg = 64'h0000000c;   //address 3 witth mode 10--wrap
		c_be_reg =8'b0110;       
		#1
		
		#10
		//TURN AROUND
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'bz;
		c_be_reg =8'b1110;
		#1
		
		#10
		//DATA cycle 1
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'bz;
		c_be_reg =8'b0110;
		ad_oe = 1'b0;
		#1
		
		#10
		//DATA cycle 2
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 3
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 8
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 9
		#9
		frame = 1;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 9
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bzzzz;
		ad_oe = 1'b1;
		#1
		
		#10
		
		
		/****Error scenario_1 (Terminate with data) ****/
		//IDLE
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bz;
		#1
		
		#10
		//ADDRESS
		#9
		frame = 0;
		rst = 1;
		irdy = 1;
		ad_reg = 64'h000003fc;   //address 3 witth mode 10--wrap
		c_be_reg =8'b0110;       
		#1
		
		#10
		//TURN AROUND
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'bz;
		c_be_reg =8'b1110;
		#1
		
		#10
		//DATA cycle 1
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'bz;
		c_be_reg =8'b0110;
		ad_oe = 1'b0;
		#1
		
		#10
		//DATA cycle 2
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 8
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 9
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 9
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bzzzz;
		ad_oe = 1'b1;
		#1
		
		#10
		
		/****64-bit scenario (compatible) ****/

        
		// Add stimulus here
		//IDLE
		frame = 1;
		req_64   = 1'b1;
		rst = 0;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bz;
		
		
		//IDLE
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bz;
		#1
		
		#10
		
		//ADDRESS
		#9
		frame = 0;
		req_64   = 1'b0;
		rst = 1;
		irdy = 1;
		ad_reg = 64'h94;
		c_be_reg =8'b0000_0111;
		#1
		
		#10
		
		//WRITE_1     77009900 00AADD00
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h77669988BBAADDCC;
		c_be_reg =8'b10100110;
		#1

		#10
		
		//WRITE_2     12345678 00000021
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h12345678_87654321;   
		c_be_reg =8'b1111_0001;
		#1
		
		#10
		
		//WRITE_3
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hABBACDDC_12213443;
		c_be_reg =8'b1000_0001;
		#1
		
		#10
		
		//WRITE_4_wait
		#9
		frame = 0;
		rst = 1;
		irdy = 1;
		ad_reg = 64'hCCCCCCCC_DDDDDDDD;
		c_be_reg =8'b1100_1001;
		#1
		
		#10
		//WRITE_4
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hBBBBAAAA_EEFFEEFF;
		c_be_reg =8'b1111_0000;
		#1
		
		#10
		
		//WRITE_5
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h11111111_22222222;
		c_be_reg =8'b1111_1111;
		#1
		
		#10
		//WRITE_6
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h12344321_ABCDDCBA;
		c_be_reg =8'b0000_0001;
		#1
		
		#10
		//WRITE_7
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h10203040_50607080;
		c_be_reg =8'b1010_0101;
		#1
		
		#10
		
		//WRITE_8
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h11223344_55667788;
		c_be_reg =8'b1001_0110;
		#1
		
		#10

		//WRITE_9
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'h1A2B3C4D_5F607182;
		c_be_reg =8'b1101_1110;
		#1
		
		#10
		
		//LAST_WRITE_1
		#9
		frame = 1;
		req_64   = 1'b1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'hDDDDDDDD_CCCCCCCC;
		c_be_reg =8'b0011_1100;
		#1
		
		#10
		//TERMINATE
		#9
		frame = 1;
		rst = 1;
		irdy = 0;
		ad_reg = 64'hDDDDDDDD_CCCCCCCC;
		c_be_reg =8'b0011_1100;
		#1
		
		#10
		//IDLE
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'hzzzzzzzz;
		c_be_reg =8'bz;
		#1
		
		
		#10;
		
		/********Read test**********/
		//IDLE
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bz;
		#1
		
		#10
		//ADDRESS
		#9
		frame = 0;
		req_64 =0;
		rst = 1;
		irdy = 1;
		ad_reg = 64'h9c;
		c_be_reg =8'b1100;
		#1
		
		#10
		//TURN AROUND
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'bz;
		c_be_reg =8'b1110;
		#1
		
		#10
		//DATA cycle 1
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		ad_reg = 64'bz;
		c_be_reg =8'b0110;
		ad_oe = 1'b0;
		#1
		
		#10
		//DATA cycle 2
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 3
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 4
		#9
		frame = 0;
		rst = 1;
		irdy = 1;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 5
		#9
		frame = 0;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 8
		#9
		frame = 1;
		req_64 =1;
		rst = 1;
		irdy = 1;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 9
		#9
		frame = 1;
		rst = 1;
		irdy = 0;
		//ad_reg = 64'bz;
		c_be_reg =8'b0110;
		#1
		
		#10
		//DATA cycle 9
		#9
		frame = 1;
		rst = 1;
		irdy = 1;
		ad_reg = 64'bz;
		c_be_reg =8'bzzzz;
		ad_oe = 1'b1;
		#1
		
		#10;
	end
      
endmodule

