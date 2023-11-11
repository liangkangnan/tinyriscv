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
// 每次除法运算至少需要33个时钟周期才能完成
module divider(

    input wire clk,
    input wire rst_n,

    input wire[31:0] dividend_i,        // 被除数
    input wire[31:0] divisor_i,         // 除数
    input wire start_i,                 // 开始信号，运算期间这个信号需要一直保持有效
    input wire[3:0] op_i,               // 具体是哪一条指令

    output reg[31:0] result_o,          // 除法结果，高32位是余数，低32位是商
    output reg ready_o                  // 运算结束信号

    );

    // 状态定义
    localparam STATE_IDLE  = 4'b0001;
    localparam STATE_START = 4'b0010;
    localparam STATE_CALC  = 4'b0100;
    localparam STATE_END   = 4'b1000;

    reg[31:0] dividend_r;
    reg[31:0] divisor_r;
    reg[3:0] op_r;
    reg[3:0] state;
    reg[31:0] count;
    reg[31:0] div_result;
    reg[31:0] div_remain;
    reg[31:0] minuend;
    reg invert_result;

    wire op_div = op_r[3];
    wire op_divu = op_r[2];
    wire op_rem = op_r[1];
    wire op_remu = op_r[0];

    wire[31:0] dividend_invert = (-dividend_r);
    wire[31:0] divisor_invert = (-divisor_r);
    wire minuend_ge_divisor = minuend >= divisor_r;
    wire[31:0] minuend_sub_res = minuend - divisor_r;
    wire[31:0] div_result_tmp = minuend_ge_divisor? ({div_result[30:0], 1'b1}): ({div_result[30:0], 1'b0});
    wire[31:0] minuend_tmp = minuend_ge_divisor? minuend_sub_res[30:0]: minuend[30:0];

    // 状态机实现
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            ready_o <= 1'b0;
            result_o <= 32'h0;
            div_result <= 32'h0;
            div_remain <= 32'h0;
            op_r <= 3'h0;
            dividend_r <= 32'h0;
            divisor_r <= 32'h0;
            minuend <= 32'h0;
            invert_result <= 1'b0;
            count <= 32'h0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (start_i) begin
                        op_r <= op_i;
                        dividend_r <= dividend_i;
                        divisor_r <= divisor_i;
                        state <= STATE_START;
                    end else begin
                        op_r <= 3'h0;
                        dividend_r <= 32'h0;
                        divisor_r <= 32'h0;
                        ready_o <= 1'b0;
                        result_o <= 32'h0;
                    end
                end

                STATE_START: begin
                    if (start_i) begin
                        // 除数为0
                        if (divisor_r == 32'h0) begin
                            if (op_div | op_divu) begin
                                result_o <= 32'hffffffff;
                            end else begin
                                result_o <= dividend_r;
                            end
                            ready_o <= 1'b1;
                            state <= STATE_IDLE;
                        // 除数不为0
                        end else begin
                            count <= 32'h40000000;
                            state <= STATE_CALC;
                            div_result <= 32'h0;
                            div_remain <= 32'h0;

                            // DIV和REM这两条指令是有符号数运算指令
                            if (op_div | op_rem) begin
                                // 被除数求补码
                                if (dividend_r[31] == 1'b1) begin
                                    dividend_r <= dividend_invert;
                                    minuend <= dividend_invert[31];
                                end else begin
                                    minuend <= dividend_r[31];
                                end
                                // 除数求补码
                                if (divisor_r[31] == 1'b1) begin
                                    divisor_r <= divisor_invert;
                                end
                            end else begin
                                minuend <= dividend_r[31];
                            end

                            // 运算结束后是否要对结果取补码
                            if ((op_div && (dividend_r[31] ^ divisor_r[31] == 1'b1))
                                || (op_rem && (dividend_r[31] == 1'b1))) begin
                                invert_result <= 1'b1;
                            end else begin
                                invert_result <= 1'b0;
                            end
                        end
                    end else begin
                        state <= STATE_IDLE;
                        result_o <= 32'h0;
                        ready_o <= 1'b0;
                    end
                end

                STATE_CALC: begin
                    if (start_i) begin
                        dividend_r <= {dividend_r[30:0], 1'b0};
                        div_result <= div_result_tmp;
                        count <= {1'b0, count[31:1]};
                        if (|count) begin
                            minuend <= {minuend_tmp[30:0], dividend_r[30]};
                        end else begin
                            state <= STATE_END;
                            if (minuend_ge_divisor) begin
                                div_remain <= minuend_sub_res;
                            end else begin
                                div_remain <= minuend;
                            end
                        end
                    end else begin
                        state <= STATE_IDLE;
                        result_o <= 32'h0;
                        ready_o <= 1'b0;
                    end
                end

                STATE_END: begin
                    if (start_i) begin
                        ready_o <= 1'b1;
                        state <= STATE_IDLE;
                        if (op_div | op_divu) begin
                            if (invert_result) begin
                                result_o <= (-div_result);
                            end else begin
                                result_o <= div_result;
                            end
                        end else begin
                            if (invert_result) begin
                                result_o <= (-div_remain);
                            end else begin
                                result_o <= div_remain;
                            end
                        end
                    end else begin
                        state <= STATE_IDLE;
                        result_o <= 32'h0;
                        ready_o <= 1'b0;
                    end
                end

            endcase
        end
    end

endmodule
