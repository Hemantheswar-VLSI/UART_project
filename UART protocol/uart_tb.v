`timescale 1ns / 1ps

module UART_top_tb;
    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg wr_en;
    reg rdy_clr;
    wire rdy;
    wire busy;
    wire [7:0] data_out;
    wire tx_clk_en,rx_clk_en,tx_line;
    reg [7:0] count;
    wire error;
    
    
    reg start_time , end_time;
    
    
    uart_top dut(
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .wr_en(wr_en),
        .rdy_clr(rdy_clr),
        .rdy(rdy),
        .busy(busy),
        .data_out(data_out),
        .tx_clk_en(tx_clk_en),
        .rx_clk_en(rx_clk_en),
        .tx_line(tx_line),
        .error(error)
    );
    initial begin
        clk     = 0;
        rst     = 0;
        wr_en   = 0;
        rdy_clr = 0;
        data_in = 8'd0;
    end
    always #5 clk = ~clk; 
    task send_byte(input [7:0] din);
    begin
        @(negedge clk);
        data_in = din;
        wr_en   = 1'b1;
        @(negedge clk);
        wr_en   = 1'b0;
    end
    endtask
    task clear_ready;
    begin
        @(negedge clk);
        rdy_clr = 1'b1;
        @(negedge clk);
        rdy_clr = 1'b0;
    end
    endtask
    initial begin
        rst = 1'b1;
        #200;
        rst = 1'b0;
        wr_en=1'b0;
        #200;
        
        for(integer i = 99; i <= 170; i = i + 1) begin
         //  $display("execution start : start_time =%0t ns",$time) ;
            send_byte(i[7:0]);
            count=i;
            wait(rdy);
            $display("sent = %0d   received = %0d   Error : %b \n\n", count, data_out,error);
            
            clear_ready;
            wait(!busy); 
             #3000; 
          //  $display("end_time = %0t ns " ,$time);
            
            
        end      
        #10000;
        $finish;
    end
endmodule
;
