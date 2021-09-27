module fifo_16x8_tb();

    parameter D_width = 8,
                D_depth=16;
    parameter D_addr=4, MAX_COUNT=4'b1111;

    reg clk,reset,read,write;
    reg [D_width-1:0]d_in;

    reg [D_width-1:0]rd_pntr,wr_pntr;

    wire [D_width-1:0]d_out;
	wire full,empty;

    fifo_16x8 DUT(clk,reset,d_in,read,write,d_out,empty,full);

    integer i,j;
    always 
        begin
            clk=1'b0;
            forever #5 clk=~clk;
        end

    task initialize;
        begin
          d_in<=8'h00;
          {read,write}=4'b00;
          {wr_pntr,rd_pntr}=8'h00;
        end
    endtask

    task resetip;
        begin
          @(negedge clk)
          reset=1'b1;
          @(negedge clk)
          reset=1'b0;
        end
    endtask

    task write_d(input [7:0]wd,input [3:0]wa);
        begin
          @(negedge clk)
          write=1'b1;
          read=1'b0;
          d_in<=wd;
          wr_pntr<=wa;
        end
    endtask

    task read_d(input [3:0]ra);
        begin
          @(negedge clk)
          read=1'b1;
          write=1'b0;
          rd_pntr<=ra;
         
        end
    endtask

    initial begin
        
        resetip;
		
            begin
              for (i =0 ;i<16 ;i=i+1 ) 
                begin
                write_d(10*i,i);
                #10;
                end
            end
	        begin
              for (j =0 ;j<16 ;j=j+1 ) 
                begin
                read_d(j);  
                #10;
                end
            end
		
		write_d(8'd222,4'd04);
        #10;
		read_d(4'd04);
	
            read=1'b1;
            #10;
            write=1'b1;
            #10;

            initialize;
	
       
    end

    initial begin
        $monitor("reset=%b,read=%b,write=%b,full=%b,empty=%b,wr_pntr=%d,rd_pntr=%d,Count=%d,d_in=%d,d_out=%d",reset,read,write,full,empty,DUT.wr_pntr,DUT.rd_pntr,DUT.count,d_in,d_out);
    end

    initial begin
        #500 $finish;
    end
endmodule