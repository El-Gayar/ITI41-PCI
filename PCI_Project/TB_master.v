////////////////
///// TB_MAASTER 
//////////////////////



module MASTER_TB (); 
	
		
		wire T_RDY;
		wire DEVSEL;
		reg CLK, RST;
		wire  [31:0] ADDR_DATA;
		wire  [3:0] C_BE ;  
		reg FRAME = 1'b1;
		reg IRDY = 1'b1;
		reg ADRESS_oe; 
		reg [31:0] ADDR , DATA;
		
		 assign ADDR_DATA = ADRESS_oe ? ADDR_1: DATA_1;
		
		
		
 
     /***************INSTANTIATE *****************************/
	    
		
		
		
		
	 /*****************************CLOCK ***************************/



		
      always 
			begin
				#10 CLK = ~CLK;
			end





	 /************************STIMULUS******************************/
		initial
        begin
            CLK = 1;
            #5   
                FRAME <=0;
                ADRESS_oe <= 1 ; 
                ADDR <= 32'b0;
                C_BE <= 4'b0111;
           #15

                IRDY <= 0;
                C_BE <= 4'b0111;


            #25
			  ADRESS_oe <= 1 ;  
                DATA <= 32'h0000000E;
                FRAME <=1;
            #35
                IRDY <= 1;

        end


     /*****************************************************************/


endmodule 








