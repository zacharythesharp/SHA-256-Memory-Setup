//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
// DUT


`define MSG_LENGTH 5

/*
 *	@author Zachary Sharp
 *	Last edit: 11/9/2018
 *	ECE 464 Project
 *	Project is a simplified version of the SHA256 hash algorithm
 */
 // DATA PARAMETERS
 
module MyDesign #(parameter OUTPUT_LENGTH       = 8,
                  parameter MAX_MESSAGE_LENGTH  = 55,
                  parameter NUMBER_OF_Ks        = 64,
                  parameter NUMBER_OF_Hs        = 8 ,
                  parameter SYMBOL_WIDTH        = 8  )
            (

            //---------------------------------------------------------------------------
            // Control
            //
            output reg                                   dut__xxx__finish     ,
            input  wire                                  xxx__dut__go         ,  
            input  wire  [ $clog2(MAX_MESSAGE_LENGTH):0] xxx__dut__msg_length ,

            //---------------------------------------------------------------------------
            // Message memory interface - For reading memory
            //
            output reg  [ $clog2(MAX_MESSAGE_LENGTH)-1:0]   dut__msg__address  ,  // address of letter
            output reg                                      dut__msg__enable   ,  // 
            output reg                                      dut__msg__write    ,  // 
            input  wire [7:0]                               msg__dut__data     ,  // read each letter
            
            //---------------------------------------------------------------------------
            // K memory interface
            //
            output reg  [ $clog2(NUMBER_OF_Ks)-1:0]     dut__kmem__address  ,  // UNUSED
            output reg                                  dut__kmem__enable   ,  // UNUSED
            output reg                                  dut__kmem__write    ,  // UNUSED
            input  wire [31:0]                          kmem__dut__data     ,  // UNUSED // read data

            //---------------------------------------------------------------------------
            // H memory interface
            //
            output reg  [ $clog2(NUMBER_OF_Hs)-1:0]     dut__hmem__address  ,  // UNUSED
            output reg                                  dut__hmem__enable   ,  // UNUSED
            output reg                                  dut__hmem__write    ,  // UNUSED
            input  wire [31:0]                          hmem__dut__data     ,  // UNUSED // read data


            //---------------------------------------------------------------------------
            // Output data memory - For writing memory
            //
            output reg  [ $clog2(OUTPUT_LENGTH)-1:0]    dut__dom__address  ,
            output reg  [31:0]                          dut__dom__data     ,  // write data
            output reg                                  dut__dom__enable   ,
            output reg                                  dut__dom__write    ,


            //-------------------------------
            // General
            //
            input  wire                 clk             ,
            input  wire                 reset  
            );

  	//---------------------------------------------------------------------------
	localparam reset_wait_state = 4'b0001;
	localparam read_state = 4'b0010;
	localparam param_state = 4'b0100;
	localparam write_state = 4'b1000;
	
	// STATE MACHINE LOCALS
	reg [3:0] current_state;
	
	// LATCHED DATA FROM INPUTS
	reg go;
	reg [7:0] data;
	reg [5:0] length;
	reg my_reset;
	reg [31:0] kmem;
	reg [31:0] hmem;
	
	// LOCALS
	reg [511:0] M1;
	reg [5:0] count;
	reg [4:0] index;
	
	//---------------------------------------------------------------------------	
	// controller
	always @ (posedge clk) begin
		my_reset <= reset;
		go <= xxx__dut__go;
		data <= msg__dut__data;
		length <= xxx__dut__msg_length;
		kmem <= kmem__dut__data; 
		hmem <= hmem__dut__data; 
		
		if (my_reset) begin
			current_state <= reset_wait_state;
		end
		
		case (current_state) 
			//---------------------------------------------------------------------------	
			reset_wait_state: begin
				// RESET OUTPUT REGISTERS
				dut__xxx__finish <= 1'b0; 	// final output signifying completion
				dut__msg__address <= 0;		// address used to access sram - useless unless enable is high
				dut__msg__enable <= 1'b0;	// whenever sram needs to be accessed, this needs to be set high
				dut__msg__write <= 1'b0;	// low when reading from sram, high when writing to sram
				
				dut__kmem__address <= 0;  	// UNUSED
                                dut__kmem__enable <= 1'b0;   	// UNUSED
                                dut__kmem__write  <= 1'b0;    	// UNUSED
                                dut__hmem__address <= 0;  	// UNUSED
                                dut__hmem__enable <= 1'b0;   	// UNUSED
                                dut__hmem__write  <= 1'b0;    	// UNUSED
                                
                                dut__dom__address <= 0;		// address for writing memory to other sram M1[x] array vectors
                                dut__dom__data    <= 0;		// 32 bits of data you wish to write to the sram
                                dut__dom__enable  <= 1'b0;	// must be high when accessing second sram
                                dut__dom__write   <= 1'b0;	// must be high when writing to second sram
                                
                                // RESET LOCAL REGISTERS
                                M1 <= 0;
                 		count <= 0;
                 		index <= 0;
                                
                                if (go) begin
                                	dut__msg__address <= count;	// address used to access sram - useless unless enable is high
					dut__msg__enable <= 1'b1;	// whenever sram needs to be accessed, this needs to be set high
					dut__msg__write <= 1'b0;	// low when reading from sram, high when writing to sram
					count <= count + 1;
                                	current_state <= read_state;
                                end
			end // end reset_wait_state
			//---------------------------------------------------------------------------	
			read_state: begin
				if (count <= length + 1) begin
					M1[511-((count-1)*8) -: 8] <= data;
					count <= count + 1;
					
					if (count <= length - 1) begin
						dut__msg__address <= count;	// address used to access sram - useless unless enable is high
						dut__msg__enable <= 1'b1;	// whenever sram needs to be accessed, this needs to be set high
						dut__msg__write <= 1'b0;	// low when reading from sram, high when writing to sram
					end 
				end
				else begin
					dut__msg__enable <= 1'b0;	// whenever sram needs to be accessed, this needs to be set high
					dut__msg__write <= 1'b0;	// low when reading from sram, high when writing to sram
					M1 <= M1 << 8;
					current_state <= param_state;
				end
				
			end // end read_state
			//---------------------------------------------------------------------------	
			param_state: begin
				M1[511-(8*length)] <= 1'b1;
				M1[31 -: 32] <= length * 8;
				current_state <= write_state;
			end // end read_state
			//---------------------------------------------------------------------------	
			write_state: begin
			
				if (index <= 15) begin
					dut__dom__address <= index;				// address for writing memory to other sram M1[x] array vectors
                             		dut__dom__data    <= M1[511-(index*32) -: 32];		// 32 bits of data you wish to write to the sram
                              		dut__dom__enable  <= 1'b1;				// must be high when accessing second sram
                                	dut__dom__write   <= 1'b1;				// must be high when writing to second sram
                                	
                                	M1 <= M1;
                                	index <= index + 1;
                                	current_state <= write_state;
                                end else begin
                                	dut__dom__enable  <= 1'b0;				// must be high when accessing second sram
                                	dut__dom__write   <= 1'b0;				// must be high when writing to second sram
                                	dut__xxx__finish <= 1;
                                	current_state <= reset_wait_state;
                                end
			end // end write_state
			//---------------------------------------------------------------------------	
		endcase // end case
		
	end // end always posedge clk

endmodule // end module

