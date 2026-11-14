`timescale 1ns / 1ps

module uart_receiver(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,            //transmitted data tx from transmitter
    input  wire       rdy_clr,
    input  wire       clk_en,       //rx_enable pin from braud rate generator  
    output reg        rdy,
    output reg [7:0]  data_out,
    output reg  parity_error
);

reg parity_check=1'b0;

    localparam start_state = 2'b00;
    localparam data_state  = 2'b01;
    localparam stop_state  = 2'b10;

    reg [1:0] state;
    reg [3:0] sample;
    reg [3:0] index;
    reg [7:0] temp_register;

    always @(posedge clk) begin
        if(rst) begin
            rdy           <= 1'b0;
            data_out      <= 8'b0;
            state         <= start_state;
            sample        <= 4'b0;
            index         <= 3'b0;
            temp_register <= 8'b0;
            end
        else begin
                if(rdy_clr) begin
                    rdy <= 1'b0;
                    end
                else begin
                    rdy<=rdy;  //It shoudl assign its old value
                    end
            
            
            if(clk_en) begin
                case(state)
                    start_state: begin
                        if(rx == 1'b0) begin
                                sample <= 4'b0;
                                state  <= data_state;
                                index  <= 3'b0;
                                    end   
                        else begin
                                state<=start_state;
                            end
                      end
                    
                    data_state: begin
                        if(sample == 4'hF) begin
                            sample<= 4'b0;
                            if(index == 4'h8) begin
                                if(parity_check==1'b1)
                                    begin
                                    state <= stop_state;
                                    parity_check<=1'b0;
                                   
                                    end   
                                else begin
                                    parity_error=(^temp_register) ^ rx ;
                                    // $display("temp : %b , parity : %b , Error : %b",^temp_register,rx,parity_error);
                                    parity_check<=1'b1;
                                    end
                              end
                            else begin
                                temp_register[index] <= rx;
                                $display(" BIT = %d ,rx : %b",index,rx);
                                index <= index + 1'b1;
                                end
                          end 
                        else begin
                            sample <= sample + 1'b1;
                        end
                    end

                    stop_state: begin
                        if(sample == 4'hF) begin
                              sample   <= 4'b0;
                              
                                    if(rx == 1'b1) begin 
                                        state    <= start_state;
                                        data_out <= temp_register;
                                        rdy<= 1'b1;
                                        $display("Transmission End");
                                        end
                                     else begin
                                        data_out <=data_out;
                                        rdy<= 1'b0;
                                        state<=stop_state;
                                         end
                              end
                        else begin
                            sample <= sample + 1'b1;
                            end
                     end

                   default: state <= start_state;
                endcase
            end
        end
    end
endmodule
