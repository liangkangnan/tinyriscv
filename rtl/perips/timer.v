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

`include "defines.v"


// 32 bits count up timer module
module timer(

    input wire clk,
    input wire rst,

    input wire[31:0] data_i,
    input wire[31:0] addr_i,
    input wire we_i,
    input wire req_i,

    output reg[31:0] data_o,
    output reg int_sig_o,
    output reg ack_o

    );

    localparam REG_CTRL = 4'h0;
    localparam REG_COUNT = 4'h4;
    localparam REG_VALUE = 4'h8;

    // [0]: timer enable
    // [1]: timer int enable
    // [2]: timer int pending, write 1 to clear it
    // addr offset: 0x00
    reg[31:0] timer_ctrl;

    // timer current count, read only
    // addr offset: 0x04
    reg[31:0] timer_count;

    // timer expired value
    // addr offset: 0x08
    reg[31:0] timer_value;


    // counter
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            timer_count <= `ZeroWord;
        end else begin
            if (timer_ctrl[0] == 1'b1 && timer_value > 32'h0) begin
                timer_count <= timer_count + 1'b1;
            end else begin
                timer_count <= `ZeroWord;
            end
        end
    end

    // int signal
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            int_sig_o <= `INT_DEASSERT;
        end else begin
            if (timer_count >= timer_value && timer_value > 32'h0) begin
                int_sig_o <= `INT_ASSERT;
            end else if (we_i == `WriteEnable && addr_i[3:0] == REG_CTRL && timer_ctrl[2] == 1'b1) begin
                int_sig_o <= `INT_DEASSERT;
            end
        end
    end

    // write regs
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            timer_ctrl <= `ZeroWord;
            timer_value <= `ZeroWord;
        end else begin
            if (we_i == `WriteEnable) begin
                case (addr_i[3:0])
                    REG_CTRL: begin
                        timer_ctrl <= data_i;
                    end
                    REG_VALUE: begin
                        timer_value <= data_i;
                    end
                endcase
            end else begin
                if (timer_count >= timer_value && timer_value > 32'h0) begin
                    timer_ctrl[0] <= 1'b0;
                end
            end
        end
    end

    // read regs
    always @ (*) begin
        if (rst == `RstEnable) begin
            data_o <= `ZeroWord;
        end else begin
            case (addr_i[3:0])
                REG_VALUE: begin
                    data_o <= timer_value;
                end
                REG_CTRL: begin
                    data_o <= timer_ctrl;
                end
                REG_COUNT: begin
                    data_o <= timer_count;
                end
                default: begin
                    data_o <= `ZeroWord;
                end
            endcase
        end
    end

endmodule
