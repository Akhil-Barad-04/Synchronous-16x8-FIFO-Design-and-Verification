module fifo_16x8(clk,reset,d_in,read,write,d_out,empty,full); 
 
    parameter D_width = 8,
                D_depth=16;
    parameter D_addr=4, MAX_COUNT=4'b1111;
	input clk; 
	input reset; 
	input [D_width-1:0]d_in;	//8-bit data input 
	input read; 
	input write; 
 
	output [D_width-1:0]d_out; //8-bit data output 
	output empty; 	   //flag to indicate that the memory is empty 
	output full;	   //flag to indicate that the memory is full 
	 
		 
//D_addr is number of bits,  bits thus 2^4=16 memory locations and MAX_COUNT is the last memory location. 
	 
	reg [D_width-1:0]d_out; 
	reg empty;
	reg full; 
 
	//wr_pntr is write_pointer and rd_pntr is read_pointer/ 
 
	reg [(D_addr-1):0]rd_pntr;	 
// rd_pntr(4bits) defines memory pointer location for reading instructions(0000 or 0001....1111) 
	 
	reg [(D_addr-1):0]wr_pntr;	 
// wr_pntr(4bits) defines memory pointer location for writing instructions(0000 or 0001...1111) 
	 
	reg [(D_addr-1):0]count;	 
// 4 bits count register[0000(0),0001(1),0010(2),....,1111(15)] 
	 
	reg [D_width-1:0]fifo_mem[0:D_depth-1];  
// fifo memory is having 8 bits data and 16 memory locations 
	 
	reg sr_read_write_empty;			// 1 bit register flag 
 
///////// WHEN BOTH READING AND WRITING BUT FIFO IS EMPTY //////// 
 
	always @(posedge clk) 
		begin 
			if(reset==1) 
			//reset is pressed															 
				sr_read_write_empty <= 0; 
			else if(read==1 && empty==1 && write==1)	 
			//when fifo is empty and read & write both 1 
				sr_read_write_empty <= 1; 
			else 
				sr_read_write_empty <= 0; 
		end 
 
//////////////////////// COUNTER OPERATION /////////////////////// 
		 
	always @(posedge clk) 
		begin 
			if(reset==1) 
//when reset, the fifo is made empty thus count is set to zero 
				count <= 4'b0000;		 
			else 
				begin 
					case({read,write}) 
					//CASE-1:when not reading or writing	 
						2'b00:	count <= count;				 
								//count remains same 
					//CASE-2:when writing only 
						2'b01:	if(count!=MAX_COUNT)			 
									count <= count+1; 
									//count increases 
					//CASE-3:when reading only							 
						2'b10:	if(count!=4'b0000)				 
									count <= count-1;							 
									//count decreases 
					//CASE-4 
						2'b11:	if(sr_read_write_empty==1)	 
									count <= count+1; 
//(if) fifo is empty => only write, thus count increases			 
								else 
									count <= count; 
//(else) both read and write takes place, thus no change											 
					//DEFAULT CASE			 
						default: count <= count; 
					endcase 
				end 
		end 
 
////////////////////// EMPTY AND FULL ALERT ///////////////////// 
	 
	// Memory empty signal 
	always @(count) 
		begin 
			if(count==4'b0000) 
				empty <= 1; 
			else 
				empty <= 0; 
		end 
 
	// Memory full signal 
	always @(count) 
		begin 
			if(count==MAX_COUNT) 
				full <= 1; 
			else 
				full <= 0; 
		end 
 
///////////// READ AND WRITE POINTER MEMORY LOCATION ///////////// 
 
	// Write operation memory pointer 
	always @(posedge clk) 
		begin 
			if(reset==1) 
			//wr_pntr moved to zero location (fifo is made empty) 
				wr_pntr <= 4'b0000;	 
			else 
				begin 
					if(write==1 && full==0)	 
					//writing when memory is NOT FULL 
						wr_pntr <= wr_pntr+1; 
				end 
		end 
	 
	// Read operation memory pointer 
		always @(posedge clk) 
			begin 
				if(reset==1) 
				//rd_pntr moved to zero location (fifo is made empty) 
					rd_pntr <= 4'b0000;	 
				else 
					begin 
						if(read==1 && empty==0)	 
						//reading when memory is NOT ZERO 
							rd_pntr <= rd_pntr+1; 
					end 
			end 
 
//////////////////// READ AND WRITE OPERATION //////////////////// 
 
	// Write operation 
	always @(posedge clk) 
		//IT CAN WRITE WHEN RESET IS USED AS FULL==0	 
		begin 
			if(write==1 && full==0) 
			//writing when memory is NOT FULL 
				fifo_mem[wr_pntr] <= d_in; 
			else									 
			//when NOT WRITING 
				fifo_mem[wr_pntr] <= fifo_mem[wr_pntr]; 
		end 
 
	// Read operation 
	always @(posedge clk) 
		begin 
			if(reset==1)						 
			//reset implies output is zero 
				d_out <= 8'h00; 
			else if(read==1 && empty==0)	 
			//reading data when memory is NOT EMPTY 
				d_out <= fifo_mem[rd_pntr]; 
			else 
			//no change 
				d_out <= d_out;  
		end 
endmodule