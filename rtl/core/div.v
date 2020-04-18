 /*                                                                      
 Copyright 2019 Blue Liang, liangkangnan@163.com
                                                                         
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

// 除法模块
// 试商法实现32位整数除法
// 每次除法运算至少需要32个时钟周期才能完成
module div(

    input wire clk,
    input wire rst,

    // from ex
    input wire[`RegBus] dividend_i,      // 被除数
    input wire[`RegBus] divisor_i,       // 除数
    input wire start_i,                  // 开始信号，运算期间这个信号需要一直保持有效
    input wire[2:0] op_i,                // 具体是哪一条指令
    input wire[`RegAddrBus] reg_waddr_i, // 运算结束后需要写的寄存器

    // to ex
    output reg[`DoubleRegBus] result_o,  // 除法结果，高32位是余数，低32位是商
    output reg ready_o,                  // 运算结束信号
    output wire busy_o,                  // 正在运算信号
    output reg[2:0] op_o,                // 具体是哪一条指令
    output reg[`RegAddrBus] reg_waddr_o  // 运算结束后需要写的寄存器

    );

    // 状态定义
    localparam STATE_IDLE = 0;
    localparam STATE_START = 1;
    localparam STATE_INVERT = 2;
    localparam STATE_END = 3;

    reg[`RegBus] dividend_temp;
    reg[`RegBus] divisor_temp;
    reg[1:0] state;
    reg[6:0] count;
    reg[`RegBus] div_result;
    reg[`RegBus] div_remain;
    reg[`RegBus] minuend;
    reg[`RegBus] divisor_zero_result;
    reg invert_result;


    assign busy_o = (state != STATE_IDLE)? `True : `False;


    // 状态机实现
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            state <= STATE_IDLE;
            ready_o <= `DivResultNotReady;
            result_o <= {`ZeroWord, `ZeroWord};
            div_result <= `ZeroWord;
            div_remain <= `ZeroWord;
            divisor_zero_result <= ~32'b00000001 + 1'b1;
            op_o <= 3'h0;
            reg_waddr_o <= `ZeroWord;
            dividend_temp <= `ZeroWord;
            divisor_temp <= `ZeroWord;
            invert_result <= 1'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (start_i == `DivStart) begin
                        op_o <= op_i;
                        reg_waddr_o <= reg_waddr_i;

                        // 除数为0
                        if (divisor_i == `ZeroWord) begin
                            ready_o <= `DivResultReady;
                            result_o <= {dividend_i, divisor_zero_result};
                        // 除数不为0
                        end else begin
                            count <= 7'd31;
                            state <= STATE_START;
                            div_result <= `ZeroWord;
                            div_remain <= `ZeroWord;

                            // DIV和REM这两条指令是有符号数运算
                            if ((op_i == `INST_DIV) || (op_i == `INST_REM)) begin
                                // 被除数求补码
                                if (dividend_i[31] == 1'b1) begin
                                    dividend_temp <= ~dividend_i + 1;
                                    minuend <= ((~dividend_i + 1) >> 7'd31) & 1'b1;
                                end else begin
                                    dividend_temp <= dividend_i;
                                    minuend <= (dividend_i >> 7'd31) & 1'b1;
                                end
                                // 除数求补码
                                if (divisor_i[31] == 1'b1) begin
                                    divisor_temp <= ~divisor_i + 1;
                                end else begin
                                    divisor_temp <= divisor_i;
                                end
                            end else begin
                                dividend_temp <= dividend_i;
                                minuend <= (dividend_i >> 7'd31) & 1'b1;
                                divisor_temp <= divisor_i;
                            end

                            // 运算结束后是否要对结果取补码
                            if (((op_i == `INST_DIV) && (dividend_i[31] ^ divisor_i[31] == 1'b1))
                                || ((op_i == `INST_REM) && (dividend_i[31] == 1'b1))) begin
                                invert_result <= 1'b1;
                            end else begin
                                invert_result <= 1'b0;
                            end
                        end
                    end else begin
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord, `ZeroWord};
                    end
                end

                STATE_START: begin
                    if (start_i == `DivStart) begin
                        if (count >= 7'd1) begin
                            if (minuend >= divisor_temp) begin
                                div_result <= (div_result << 1'b1) | 1'b1;
                                minuend <= ((minuend - divisor_temp) << 1'b1) | ((dividend_temp >> (count - 1'b1)) & 1'b1);
                            end else begin
                                div_result <= (div_result << 1'b1) | 1'b0;
                                minuend <= (minuend << 1'b1) | ((dividend_temp >> (count - 1'b1)) & 1'b1);
                            end
                            count <= count - 1'b1;
                        end else begin
                            state <= STATE_INVERT;
                            if (minuend >= divisor_temp) begin
                                div_result <= (div_result << 1'b1) | 1'b1;
                                div_remain <= minuend - divisor_temp;
                            end else begin
                                div_result <= (div_result << 1'b1) | 1'b0;
                                div_remain <= minuend;
                            end
                        end
                    end else begin
                        ready_o <= `DivResultReady;
                        result_o <= {`ZeroWord, `ZeroWord};
                        state <= STATE_IDLE;
                    end
                end

                STATE_INVERT: begin
                    if (start_i == `DivStart) begin
                        if (invert_result == 1'b1) begin
                            div_result <= ~div_result + 1'b1;
                            div_remain <= ~div_remain + 1'b1;
                        end
                        state <= STATE_END;
                    end else begin
                        ready_o <= `DivResultReady;
                        result_o <= {`ZeroWord, `ZeroWord};
                        state <= STATE_IDLE;
                    end
                end

                STATE_END: begin
                    if (start_i == `DivStart) begin
                        ready_o <= `DivResultReady;
                        result_o <= {div_remain, div_result};
                        state <= STATE_IDLE;
                    end else begin
                        state <= STATE_IDLE;
                        result_o <= {`ZeroWord, `ZeroWord};
                        ready_o <= `DivResultNotReady;
                    end
                end

            endcase
        end
    end

endmodule
