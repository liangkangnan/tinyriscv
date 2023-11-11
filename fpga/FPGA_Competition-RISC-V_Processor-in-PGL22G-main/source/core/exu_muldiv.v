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


module exu_muldiv(

    input wire clk,
    input wire rst_n,

    input wire[31:0] muldiv_op1_i,
    input wire[31:0] muldiv_op2_i,
    input wire muldiv_op_mul_i,
    input wire muldiv_op_mulh_i,
    input wire muldiv_op_mulhsu_i,
    input wire muldiv_op_mulhu_i,
    input wire muldiv_op_div_i,
    input wire muldiv_op_divu_i,
    input wire muldiv_op_rem_i,
    input wire muldiv_op_remu_i,

    output wire[31:0] muldiv_reg_wdata_o,
    output wire muldiv_reg_we_o,
    output wire muldiv_stall_o

    );

    // 除法操作
    wire op_div = muldiv_op_div_i | muldiv_op_divu_i | muldiv_op_rem_i | muldiv_op_remu_i;
    wire div_start = op_div & (!div_ready);
    wire[3:0] div_op = {muldiv_op_div_i, muldiv_op_divu_i, muldiv_op_rem_i, muldiv_op_remu_i};
    wire[31:0] div_result;
    wire div_ready;

    divider u_divider(
        .clk(clk),
        .rst_n(rst_n),
        .dividend_i(muldiv_op1_i),
        .divisor_i(muldiv_op2_i),
        .start_i(div_start),
        .op_i(div_op),
        .result_o(div_result),
        .ready_o(div_ready)
    );

    // 乘法操作
    wire op_mul = muldiv_op_mul_i | muldiv_op_mulh_i | muldiv_op_mulhsu_i | muldiv_op_mulhu_i;
    wire[31:0] muldiv_op1_r;
    gen_en_dff #(32) mul_op1_ff(clk, rst_n, op_mul, muldiv_op1_i, muldiv_op1_r);
    wire[31:0] muldiv_op2_r;
    gen_en_dff #(32) mul_op2_ff(clk, rst_n, op_mul, muldiv_op2_i, muldiv_op2_r);

    wire mul_ready_r;
    wire mul_ready = (~mul_ready_r) & op_mul;
    gen_rst_0_dff #(1) mul_ready_ff(clk, rst_n, mul_ready, mul_ready_r);

    wire mul_start = (~mul_ready_r) & op_mul;

    wire op1_is_signed = muldiv_op1_r[31];
    wire op2_is_signed = muldiv_op2_r[31];
    wire[31:0] op1_complcode = op1_is_signed? (-muldiv_op1_r): muldiv_op1_r;
    wire[31:0] op2_complcode = op2_is_signed? (-muldiv_op2_r): muldiv_op2_r;

    wire[31:0] op1_mul = ({32{(muldiv_op_mul_i | muldiv_op_mulhu_i)}} & muldiv_op1_r) |
                         ({32{(muldiv_op_mulh_i | muldiv_op_mulhsu_i)}} & op1_complcode);
    wire[31:0] op2_mul = ({32{(muldiv_op_mul_i | muldiv_op_mulhu_i | muldiv_op_mulhsu_i)}} & muldiv_op2_r) |
                         ({32{(muldiv_op_mulh_i)}} & op2_complcode);
    wire[63:0] mul_res_tmp = op1_mul * op2_mul;
    wire[63:0] mul_res_tmp_complcode = -mul_res_tmp;
    wire[31:0] mul_res = mul_res_tmp[31:0];
    wire[31:0] mulhu_res = mul_res_tmp[63:32];
    wire[31:0] mulh_res = (op1_is_signed ^ op2_is_signed)? mul_res_tmp_complcode[63:32]: mul_res_tmp[63:32];
    wire[31:0] mulhsu_res = (op1_is_signed)? mul_res_tmp_complcode[63:32]: mul_res_tmp[63:32];

    reg[31:0] mul_op_res;

    always @ (*) begin
        mul_op_res = 32'h0;
        case (1'b1)
            muldiv_op_mul_i:    mul_op_res = mul_res;
            muldiv_op_mulhu_i:  mul_op_res = mulhu_res;
            muldiv_op_mulh_i:   mul_op_res = mulh_res;
            muldiv_op_mulhsu_i: mul_op_res = mulhsu_res;
        endcase
    end

    // 运算结果
    assign muldiv_reg_wdata_o = div_result | mul_op_res;
    assign muldiv_reg_we_o = div_ready | mul_ready_r;
    assign muldiv_stall_o = div_start | mul_start;

endmodule
