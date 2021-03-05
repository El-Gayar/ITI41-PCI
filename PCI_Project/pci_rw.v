`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// PCI_READ_WRITE MODULE 
//////////////////////////////////////////////////////////////////////////////////
module pci_rw(rst,clk,                   //Global inputs
				  ad,c_be,                   //Top    inouts
				  frame,irdy,
				  par_d,par_addr,devsel_ram_32, last_add, trdy,devsel,data_ram,  stop,
				  par,perr,we, be_out ,  addr_out,data_out,data_ram_64,devsel_ram_64
				  ,req_64,ack_64,req_64_ram
              );
///////////////////////////////Inputs,outputs and inouts//////////////////////////

/*************************************Inouts********************************************/
inout [63:0] ad;                                 //Data or address from top                             --Top_1
inout [7:0]  c_be;                               //Command or Byte enable from top                      --Top_2



/**************************************inputs******************************************/
input        frame,irdy;                         //Signals related to tthe mmaster fromm top module     --Parity                  
input        par_d,par_addr;                     //Calculated data & address parity                     --Top
input        devsel_ram_32, last_add;            //Signals from RAM (Slave)                             --RAM_1
input [31:0] data_ram ;                          //Data from RAM                                        --RAM_2                         
input        clk,rst;                            //Global signals for timming and reset                 --Global

/**************************************64-bit extension******************************************/
input        devsel_ram_64;                      //Signals from RAM (Slave)                             --RAM_1
input [31:0] data_ram_64  ;                      //Data from RAM                                        --RAM_2
input        req_64       ;




/*************************************Outputs*****************************************/
output  reg [7:0]  be_out ;                         //To RAM for byte enable                               --RAM_1
output  reg        we,par;                          //Write enable signal to ram                           --RAM_2
output  reg [31:0] addr_out;               //Data or address to be sent to the RAM/Parity gen     --RAM_3/Par
output  reg [63:0] data_out  ;
output  reg        trdy,devsel,perr,stop;           //To top module                                        --Top
/**************************************64-bit extension******************************************/
//output  reg [3:0]  be_out_64  ;                         //To RAM for byte enable                               --RAM_1
//output  reg [31:0] data_out_64;                         //Data or address to be sent to the RAM/Parity gen     --RAM_3/Par
output  reg        ack_64,req_64_ram     ;                        

//output  reg  par;                                 

//////////////////////////////////////////////////////////////////////////////////

///////////////////////////////Internal regs and wires////////////////////////////
reg [31:0] address_next,address_base;        //Regs to save addresses and data required for operations
reg [63:0] data_next;
reg [3:0]  c_be_r, command;                          //Regs to save the command in adddress phase or BE in data phase

reg        ad_oe = 0;                                //To control tri-state AD as in or out
reg        c_be_oe = 0;                              //To control tri-state C_BE as in or out

reg        reserved = 0;
reg        flag = 0;
reg        last_write_flag = 0;
reg        last_read_flag  = 0;

reg [2:0]  counter_read = 2'b00;                     //Starts with 2 words as read maxes at 2 words
            
//reg [31:0] be_rep;
//reg [29:0] add_start,add_end;
//reg [31:0] ad_r;
//reg        frame_r,irdy_r,par_r;
//wire 		  add_valid = frame_r == 0 && ad_r>=add_start[19] && add_end>=ad_r;
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////Local params and states/command/////////////////////////////
reg [4:0]         state      = idle;

reg [4:0]         next_state = idle;

localparam [4:0]  idle = 5'b11000 ,address = 5'b11001 ,wr_data = 5'b11010 ,terminate = 5'b11011 , turn_around = 5'b11100    //States
                  ,r_data = 5'b11101 , last_write = 5'b11110 , last_read = 5'b11111 , interrupt_state = 5'b00000 , stop_state = 5'b00001 ;
						  
localparam [3:0]  int_ack = 4'b0000 ,mem_r = 4'b0110 ,mem_w = 4'b0111 ,mem_r_mult = 4'b1100 ,mem_r_line = 4'b1110 ,dual = 4'b1101, interrupt = 4'b 0000; //Commands
//////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////Tri state assignments//////////////////
assign   ad   = ad_oe   ? data_next   : 64'bz ;
assign   c_be = c_be_oe ? c_be_r     : 8'bz  ;
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////negedge state/reg evaluation////////////////////////

////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////states////////////////////////////////////////
always@(negedge clk)
	begin
	if(!rst)
		begin
		next_state    <= idle;
		end
	else
		begin
		case(next_state)
			idle : 
				begin
 				/*********************Next state(s) selection***********************/
				if(frame == 1'b0 )
					begin
					next_state <= address;         //Moves to address phase when frame asserted
					end
				else
					begin
					next_state <= idle;            //Stay idle if frame not asserted (No master yet)
					flag       <=~ flag;
					end
				end
			/*****************************End of IDLE******************************/
			
			address :
				begin
 				/*********************Next state(s) selection***********************/
				if(frame == 1'b1 )
					begin
					next_state <= idle; 
					end
				else if (command == mem_w)
					begin
					next_state <= wr_data;           
					end
				else if (command == mem_r  || command == mem_r_line || command == mem_r_mult )
					begin
					next_state <= turn_around;
					end
				else if (command == interrupt )
					begin
					next_state <= interrupt_state;
					end
				else
					begin
					next_state <= idle;            //May be handled differently
					end
					
				end
			/*****************************End of ADDRESS******************************/

				
			interrupt_state : ;
			
			wr_data :
				begin
					
 				/*********************Next state(s) selection***********************/
				if (stop== 1'b0)
					begin
					next_state <= stop_state;           
					end
				if(frame == 1'b1)
					begin
					next_state <= last_write;         
					end
				else
					begin
					next_state <= wr_data; 
					flag <=~ flag ;
					end
					
				end
			/*****************************End of WRITE******************************/
				
			last_write : 
				begin	
 				/*********************Next state(s) selection***********************/
				if(last_write_flag == 1'b1 || stop==1'b0)
					begin
					next_state <= terminate;         
					end
				else
					begin
					next_state <= last_write; 
					flag       <=~ flag;
					end
					
				end
			/*****************************End of LAST_WRITE******************************/
			
			
				
			turn_around :
				begin
 				/*********************Next state(s) selection***********************/
				if(frame == 1'b1 )
					begin
					next_state <= idle;                         //Fram deasserted so operation terminated (Fault by master)
					end
				else if (irdy == 1'b1)
					begin
					next_state <=  turn_around ;                 //If not rdy wait until master is ready  
               flag       <=~ flag        ;					
					end
				else if ((devsel_ram_32 == 1'b0 || devsel_ram_64 == 1'b0) && irdy == 1'b0 )
					begin
					next_state <= r_data;                      //If rdy start the read data phases
					end
				else
					begin
					next_state <= idle;                       //Means that address wasn't found in the address space
					end
					
				end
			/*****************************End of TURN AROUND******************************/

				
			r_data :
				begin
					
 				/*********************Next state(s) selection***********************/
				if (stop== 1'b0)
					begin
					next_state <= stop_state;           
					end
				if(frame == 1'b1)
					begin
					next_state <= last_read;         
					end
				else
					begin
					next_state <= r_data; 
					flag <=~ flag ;
					end
					
				end
			/*****************************End of WRITE******************************/
			
				
			last_read :  
				begin	
 				/*********************Next state(s) selection***********************/
				if(last_read_flag == 1'b1 || stop == 1'b0)
					begin
					next_state <= terminate;         
					end
				else
					begin
					next_state <= last_read; 
					flag       <=~ flag;
					end
					
				end
			/*****************************End of LAST_WRITE******************************/

			
			stop_state  :
				begin
 				/*********************Next state(s) selection***********************/
				if(frame == 1'b1 && command==mem_w )
					begin
					next_state <= last_write;                         //Fram deasserted so operation terminated (Fault by master)
					end
				else if (frame == 1'b1 && (command==mem_r || command==mem_r_line || command==mem_r_mult))
					begin
					next_state <= last_read;                 //If not rdy wait until master is ready      
					end
				else
					begin
					next_state <= stop_state;                      //If rdy start the read data phases
					flag <=~ flag;
					end
					
				end
			/*****************************End of TURN AROUND******************************/	
			
			terminate :
				begin
 				/*********************Next state(s) selection***********************/
	         next_state <= idle;
					
				end
			/*****************************End of LAST_WRITE******************************/
			endcase;
		end
end


always @(next_state,flag)
begin
case(next_state)
			idle : 
				begin
					/********************Outputs/Signals to change*********************/
					perr         <= 1'b1 ;          //Not yet of use
					devsel       <= 1'b1 ;          //No target yet attached so Pulled up
					trdy         <= 1'b1 ;          //Same as devsel
					
					ack_64       <= 1'b1 ;
					
					reserved     <= 1'b0  ;
					
					ad_oe        <= 1'b0 ;          //Won't write on the inout port so it's set to O.C. (Input mode)
					c_be_oe      <= 1'b0 ;          //Same as ad_oe
					
					addr_out     <= 32'bz;          //No address to send yet to ram
					data_out     <= 64'bz;          //Same as addr_out

					
					address_base <= 32'bz;          //Will be set in address phase
					address_next <= 32'bz;          //same as base addr.
					data_next    <= 64'bz;          //Same as 2 prev.
					command      <= 4'bz ;          //will be set in address phase
					
					stop         <= 1'b1;
					
					last_write_flag <= 0;
					last_read_flag  <= 0;
					
					we           <= 1'b0 ;          //Not writting on RAM so defaulted to read
					be_out       <= 8'b0 ;          //Not writing so it is don't care value
					
					counter_read <= 2'b00;          //Reset to 2 max words for read cmd
				end
			/*****************************End of IDLE******************************/
			
			address :
				begin
													/********************Outputs/Signals to change*********************/
					perr         <= 1'b1 ;          //Not yet of use
					devsel       <= 1'b1 ;          //Waitting RAM to verify the address on next +ve edge
					trdy         <= 1'b1 ;          //Will be asserted when the adress is confirmed valid
					
					ack_64          <= 1'b1 ;
					
					ad_oe        <= 1'b0 ;          //Won't write on the inout port so it's set to O.C. (Input mode)
					c_be_oe      <= 1'b0 ;          //Same as ad_oe
					
					addr_out     <= ad;             //capture address from the AD port
					data_out     <= 64'bz;          //Not yet data phase so no change

					
					address_base <= ad;             //The base address to start the operations from
					address_next <= ad;             //Initial value in as base
					data_next    <= 64'bz;          //Same as data_out
					command      <= c_be[3:0] ;          //Capture the command for operation from c_be port
					
					req_64_ram   <= req_64;
					
					we           <= 1'b0 ;          //Not writting on RAM so defaulted to read	
 				end
			/*****************************End of ADDRESS******************************/

				
			interrupt_state : ;
			
			wr_data :
				begin
				/********************Outputs/Signals to change*********************/
					perr         <= 1'b1 ;          //Not yet of use
					if (devsel_ram_32 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not (32-bit)
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b1 ;
						end
					else if (devsel_ram_64 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not (64-bit)
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b0 ;
						end
					else
						begin
						devsel       <= 1'b1 ;          //Address isn't in tthe address space
						trdy         <= 1'b1 ;          //No slave so target not ready
						ack_64       <= 1'b1 ;
						stop         <= 1'b0 ;
						end
					
					ad_oe        <= 1'b0 ;          //Won't write on the inout port so it's set to O.C. (Input mode)
					c_be_oe      <= 1'b0 ;          //Same as ad_oe

					if (irdy == 1'b0 && (devsel_ram_32 ==1'b0 || devsel_ram_64 == 1'b0))
						begin

						be_out   <= (devsel_ram_64 == 1'b0) ?  c_be : ({4'b0,c_be[3:0]}) ;         //To selectt which bytes to write to the RAM
						data_out <= (devsel_ram_64 == 1'b0) ?  ad   : ({32'b0,ad[31:0]});
						case (address_base[1:0])    //Those 2 bits deccide how data 
							00 :     begin           //Linear inc.
										 if ( last_add == 1'b0 ) 
											begin
										   addr_out  <= address_next ;
											address_next <= address_next +4;
											we         <= 1'b1 ;          //Not writting on RAM so defaulted to read
											end
										 else
											begin
										   addr_out  <= addr_out ;
											stop      <=  1'b0    ;
											we         <= 1'b0 ;          //Not writting on RAM so defaulted to read
											end
										end
								  
						   10 :      begin        //Wrap
										 if ( last_add == 1'b0 ) 
											begin
										   addr_out  <= address_next ;
											address_next <= address_next +4;
											we         <= 1'b1 ;          //Not writting on RAM so defaulted to read
											end
										 else
											begin
										   addr_out  <= addr_out ;
											stop      <=  1'b0    ;
											we         <= 1'b0 ;          //Not writting on RAM so defaulted to read
											end
								       end
						
							default : begin        //Reserved
										 we         <= 1'b0 ;          //Not writting on RAM so defaulted to read
										 stop       <= 1'b0 ;
										 end
							endcase
						end
//					else if (devsel_ram_32 == 1'b1)
//							begin
//							we       <= 1'b0;
//							be_out   <= 4'b0;
//							//stop     <= 1'b0;
//							end
					else
							begin
							we           <=1'b0     ;
							addr_out     <= addr_out;
							be_out       <= be_out  ;
							end
					
				end
			/*****************************End of WRITE******************************/
				
			last_write : 
				begin
				/********************Outputs/Signals to change*********************/
					perr         <= 1'b1 ;          //Not yet of use
					if (devsel_ram_32 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not (32-bit)
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b1 ;
						end
					else if (devsel_ram_64 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not (64-bit)
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b0 ;
						end
					else
						begin
						devsel       <= 1'b1 ;          //Address isn't in tthe address space
						trdy         <= 1'b1 ;          //No slave so target not ready
						ack_64       <= 1'b1 ;
						stop         <= 1'b0 ;
						end
					
					ad_oe        <= 1'b0 ;          //Won't write on the inout port so it's set to O.C. (Input mode)
					c_be_oe      <= 1'b0 ;          //Same as ad_oe
					
					
					if(irdy == 1'b0 && (devsel_ram_32 ==1'b0 || devsel_ram_64 ==1'b0 ))
						begin
						be_out   <= (devsel_ram_64 == 1'b0) ?  c_be : ({4'b0,c_be[3:0]}) ;         //To selectt which bytes to write to the RAM
						data_out <= (devsel_ram_64 == 1'b0) ?  ad   : ({32'b0,ad[31:0]});
						we<= 1'b1 ;
						addr_out <=address_next;
						last_write_flag <= 1'b1;
						end
					else
						begin
						we <=1'b0;
						end
						

				end
			/*****************************End of LAST_WRITE******************************/
			
			
				
			turn_around :
				begin
								/********************Outputs/Signals to change*********************/
					perr         <= 1'b1 ;          //Should be calculated                                         --To be changed

					
					ad_oe        <= 1'b0 ;          //O.C. preparing for ooutput mode in the read sttatte
					c_be_oe      <= 1'b0 ;          //O.C.
					
					addr_out     <= address_base;   //Just to assure we got the correct base address for op.
					data_out     <= 64'bz;          //Not yet data phase so no change

					
					address_next <= address_base;   //To make sure it hasn't changed
					data_next    <= 64'bz;          //Same as data_out
					
					we           <= 1'b0 ;          //Not writting on RAM so defaulted to read	
					
					if (devsel_ram_32 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not (32-bit)
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b1 ;
						end
					else if (devsel_ram_64 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not (64-bit)
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b0 ;
						end
					else
						begin
						devsel       <= 1'b1 ;          //Address isn't in tthe address space
						trdy         <= 1'b1 ;          //No slave so target not ready
						ack_64       <= 1'b1 ;
						stop         <= 1'b0 ;
						end
					
					case (command)
						mem_r       : counter_read <= 2'b01;    //2 wordsmax
						mem_r_line  : counter_read <= 2'b11;    //4 words
						default     : counter_read <= 2'b00;    //Read mult depends on frame
						endcase
				end
				
			/*****************************End of TURN AROUND******************************/

				
			r_data :
				begin
				/********************Outputs/Signals to change*********************/
					perr         <= 1'b1 ;          //Not yet of use
					
					if (devsel_ram_32 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b1 ;
						end
					else if (devsel_ram_64 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b0 ;
						end
					else
						begin
						devsel       <= 1'b1 ;          //Address isn't in tthe address space
						trdy         <= 1'b1 ;          //No slave so target not ready
						ack_64       <= 1'b1 ;
						stop         <= 1'b0 ;
						end
					
					ad_oe        <= 1'b1 ;          //Outt mode
					c_be_oe      <= 1'b0 ;          //Same as ad_oe
					data_next    <= (devsel_ram_64 == 1'b0) ? ({data_ram_64,data_ram}) : ({32'bz,data_ram});
					
					we <= 1'b0;

					if (irdy == 1'b0 && (devsel_ram_32 ==1'b0 || devsel_ram_64 == 1'b0))
						begin
						case (command)
							mem_r: begin
								case (address_base[1:0])    //Those 2 bits deccide how data 
									2'b00 :     begin           //Linear inc.
												 if ( last_add == 1'b0 ) 
													begin
													addr_out     <= (counter_read == 2'b00 ) ? addr_out     : addr_out + 4 ;
													counter_read <= (counter_read == 2'b00 ) ? counter_read : counter_read-1;
													end
												 else
													begin
													addr_out  <= addr_out ;
													stop      <= (counter_read == 2'b00 )    ? 1'b1         : 1'b0         ;
													end
												end
										  
									2'b10 :      begin        //Wrap
												 if ( last_add == 1'b0 ) 
													begin
													addr_out     <= (counter_read == 2'b00 ) ? address_base : addr_out + 4 ;
													counter_read <= (counter_read == 2'b00 ) ? 2'b01        : counter_read - 1;
													end
												 else
													begin
													addr_out     <= (counter_read == 2'b00 ) ? address_base     : addr_out    ;
													stop         <= (counter_read == 2'b00 )    ? 1'b1         : 1'b0         ;
													end
												 end
								
									default : begin        //Reserved
												 addr_out   <= addr_out ;
												 stop       <= 1'b0     ;
												 end
									
									endcase
									end


							mem_r_line : begin
								case (address_base[1:0])    //Those 2 bits deccide how data 
									2'b00 :     begin           //Linear inc.
												 if ( last_add == 1'b0 ) 
													begin
													addr_out     <= (counter_read == 2'b00 ) ? addr_out     : addr_out + 4 ;
													counter_read <= (counter_read == 2'b00 ) ? counter_read : counter_read-1  ;
													end
												 else
													begin
													addr_out  <= addr_out ;
													stop      <= (counter_read == 2'b00 )    ? 1'b1         : 1'b0         ;
													end
												end
										  
									2'b10 :      begin        //Wrap
												 if ( last_add == 1'b0 ) 
													begin
													addr_out     <= (counter_read == 2'b00 ) ? address_base : addr_out  + 4   ;
													counter_read <= (counter_read == 2'b00 ) ? 2'b11        : counter_read - 1;
													end
												 else
													begin
													addr_out     <= (counter_read == 2'b00 ) ? address_base     : addr_out+4    ;
													stop         <= (counter_read == 2'b00 )    ? 1'b1         : 1'b0         ;
													end
												 end
								
									default : begin        //Reserved
												 addr_out   <= addr_out ;
												 stop       <= 1'b0     ;
												 end
									
									endcase
									end
									
									
							default: begin
								case (address_base[1:0])    //Those 2 bits deccide how data 
									2'b00 :     begin           //Linear inc.
													addr_out     <= (last_add == 1'b0 ) ? addr_out + 4    : addr_out ;
													stop         <= (last_add == 1'b0 ) ? 1'b1            : 1'b0        ;
													end
										  
									2'b10 :      begin        //Wrap
													addr_out     <= (last_add == 1'b0 ) ? addr_out + 4    : addr_out ;
													stop         <= (last_add == 1'b0 ) ? 1'b1            : 1'b0        ;
													end
								
									default : begin        //Reserved
												 addr_out   <= addr_out ;
												 stop       <= 1'b0     ;
												 end
									
									endcase
									end
						endcase
		
						end
					else
							begin
							addr_out  <= addr_out;
							end
					
				end
			/*****************************End of READ******************************/
			
				
			last_read :
				begin
				/********************Outputs/Signals to change*********************/
					perr         <= 1'b1 ;          //Not yet of use
					if (devsel_ram_32 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b1 ;
						end
					else if (devsel_ram_64 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b0 ;
						end
					else
						begin
						devsel       <= 1'b1 ;          //Address isn't in tthe address space
						trdy         <= 1'b1 ;          //No slave so target not ready
						ack_64       <= 1'b1 ;
						stop         <= 1'b0 ;
						end
					
					ad_oe        <= 1'b1 ;          //Won't write on the inout port so it's set to O.C. (Input mode)
					c_be_oe      <= 1'b0 ;          //Same as ad_oe
					
					we <=1'b0;
					
					if(irdy == 1'b0 && (devsel_ram_32 ==1'b0 || devsel_ram_64 == 1'b0))
					
						begin
						addr_out <= addr_out + 4;
					   data_next    <= (ack_64 == 1'b0) ? ({data_ram_64,data_ram}) : ({32'bz,data_ram});
						last_read_flag <= 1'b1  ;
						end
					else
						begin
						last_read_flag <= 1'b0;
						we <=1'b0;
						end
						

				end
			/*****************************End of LAST_WRITE******************************/

				
			stop_state  :
				begin
								/********************Outputs/Signals to change*********************/
					perr         <= 1'b1 ;          //No transaction                                         --To be changed

					case (command)
						mem_w : begin
									ad_oe        <= 1'b0 ;          //O.C. preparing for ooutput mode in the read sttatte
									c_be_oe      <= 1'b0 ;          //O.C.
							      data_out     <= data_out;          //Not yet data phase so no change
									addr_out     <= address_next;   //Just to assure we got the correct base address for op.
									end
					   
						mem_r : begin
									ad_oe        <= 1'b1 ;          //O.C. preparing for ooutput mode in the read sttatte
									c_be_oe      <= 1'b0 ;          //O.C.
								   addr_out     <= address_next;   //Just to assure we got the correct base address for op.
					            data_next    <= (ack_64 == 1'b0) ? ({data_ram_64,data_ram}) : ({32'bz,data_ram});          //Same as data_out
								   end
						 
					   mem_r_line : begin
									ad_oe        <= 1'b1 ;          //O.C. preparing for ooutput mode in the read sttatte
									c_be_oe      <= 1'b0 ;          //O.C.
								   addr_out     <= address_next;   //Just to assure we got the correct base address for op.
					            data_next    <= (ack_64 == 1'b0) ? ({data_ram_64,data_ram}) : ({32'bz,data_ram});          //Same as data_out
								   end
						
						mem_r_mult : begin
									ad_oe        <= 1'b1 ;          //O.C. preparing for ooutput mode in the read sttatte
									c_be_oe      <= 1'b0 ;          //O.C.
								   addr_out     <= address_next;   //Just to assure we got the correct base address for op.
					            data_next    <= (ack_64 == 1'b0) ? ({data_ram_64,data_ram}) : ({32'bz,data_ram});          //Same as data_out
								   end
						default :begin
									ad_oe        <= 1'b0 ;          //O.C. preparing for ooutput mode in the read sttatte
									c_be_oe      <= 1'b0 ;          //O.C.
								   end
						endcase
					
					we           <= 1'b0 ;          //Not writting on RAM so defaulted to read	
					
					if (devsel_ram_32 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b1 ;
						end
					else if (devsel_ram_64 == 1'b0)            //Confirms with RAM weither the sent address is within the address space or not
						begin
						devsel       <= 1'b0 ;          //Address is within the address space of the slave
						trdy         <= 1'b0 ;          //Target is ready
						ack_64       <= 1'b0 ;
						end
					else
						begin
						devsel       <= 1'b1 ;          //Address isn't in tthe address space
						trdy         <= 1'b1 ;          //No slave so target not ready
						ack_64       <= 1'b1 ;
						stop         <= 1'b0 ;
						end
				end
			/*****************************End of TURN AROUND******************************/	
			
			terminate :
				begin
				/********************Outputs/Signals to change*********************/
					perr         <= 1'b1 ;          //Not yet of use
               devsel       <= 1'b1;
					ack_64       <= 1'b1;
					req_64_ram   <= 1'b1;
					trdy         <= 1'b1;
					stop         <= 1'b1;
					ad_oe        <=1'b0;
					c_be_oe      <=1'b0;
					
					address_base <= 32'bz;
					address_next <= 32'bz;
					addr_out <= 32'bz;
					
					data_out   <=64'bz;
					data_next   <=64'bz;
					
					command   <=4'bz;
					
					we        <=1'b0;
					be_out    <=8'b0;

				end
			/*****************************End of LAST_WRITE******************************/
			endcase;
end
////////////////////////////////////////////////////////////////////////////////////////
endmodule
