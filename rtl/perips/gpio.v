 /*                                                                      
 Copyright 2020 Blue Liang, liangkangnan@163.com
                                                                         
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
                                                                         
     http://www.apache.org/licenses/LICENSE-2.0                          
                                                                         
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */



module gpio(

    input wire clk,
	input wire rst,

    input wire we_i,
    input wire req_i,
    input wire[31:0] addr_i,
    input wire[31:0] data_i,

    output reg[31:0] data_o,
    output reg ack_o,
	output wire io_pin

    );


    localparam GPIO_DATA = 4'h4;

    reg[31:0] gpio_data;


    assign io_pin = gpio_data[0];


    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            gpio_data <= 32'h0;
        end else begin
            if (we_i == 1'b1) begin
                case (addr_i[3:0])
                    GPIO_DATA: begin
                        gpio_data <= data_i;
                    end
                endcase
            end
        end
    end

    always @ (*) begin
        if (rst == 1'b0) begin
            data_o <= 32'h0;
        end else begin
            case (addr_i[3:0])
                GPIO_DATA: begin
                    data_o <= gpio_data;
                end
            endcase
        end
    end

endmodule
