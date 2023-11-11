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

`include "../core/defines.v"

// 32位向上计数定时器模块
module timer(

    input wire clk,
    input wire rst_n,
    input wire[31:0] addr_i,
    input wire[31:0] data_i,
    input wire[3:0] sel_i,
    input wire we_i,
	output wire[31:0] data_o,

    input wire req_valid_i,
    output wire req_ready_o,
    output wire rsp_valid_o,
    input wire rsp_ready_i,

    output wire int_sig_o

    );

    // 寄存器(偏移)地址
    localparam REG_CTRL  = 4'h0;
    localparam REG_COUNT = 4'h4;
    localparam REG_VALUE = 4'h8;

    // 定时器控制寄存器，可读可写
    // bit[0]: 定时器使能
    // bit[1]: 定时器中断使能
    // bit[2]: 定时器中断pending标志，写1清零
    reg[31:0] timer_ctrl;

    // 定时器当前计数值寄存器, 只读
    reg[31:0] timer_count;

    // 定时器溢出值寄存器，当定时器计数值达到该值时产生pending，可读可写
    reg[31:0] timer_value;

    wire wen = we_i & req_valid_i;
    wire ren = (~we_i) & req_valid_i;
    wire timer_en = (timer_ctrl[0] == 1'b1);
    wire timer_int_en = (timer_ctrl[1] == 1'b1);
    wire timer_expired = (timer_count >= timer_value);
    wire write_reg_ctrl_en = wen & (addr_i[3:0] == REG_CTRL);
    wire write_reg_value_en = wen & (addr_i[3:0] == REG_VALUE);

    // 计数
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_count <= 32'h0;
        end else begin
            if (timer_en) begin
                if (timer_expired) begin
                    timer_count <= 32'h0;
                end else begin
                    timer_count <= timer_count + 1'b1;
                end
            end else begin
                timer_count <= 32'h0;
            end
        end
    end

    reg int_sig_r;
    // 产生中断信号
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            int_sig_r <= 1'b0;
        end else begin
            if (write_reg_ctrl_en & (data_i[2] == 1'b1)) begin
                int_sig_r <= 1'b0;
            end else if (timer_int_en & timer_en & timer_expired) begin
                int_sig_r <= 1'b1;
            end
        end
    end

    assign int_sig_o = int_sig_r;

    // 写timer_ctrl
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_ctrl <= 32'h0;
        end else begin
            if (write_reg_ctrl_en) begin
                if (sel_i[0]) begin
                    timer_ctrl[7:0] <= {data_i[7:3], timer_ctrl[2] & (~data_i[2]), data_i[1:0]};
                end
            end else begin
                if (timer_expired) begin
                    timer_ctrl[0] <= 1'b0;
                end
            end
        end
    end

    // 写timer_value
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_value <= 32'h0;
        end else begin
            if (write_reg_value_en) begin
                if (sel_i[0]) begin
                    timer_value[7:0] <= data_i[7:0];
                end
                if (sel_i[1]) begin
                    timer_value[15:8] <= data_i[15:8];
                end
                if (sel_i[2]) begin
                    timer_value[23:16] <= data_i[23:16];
                end
                if (sel_i[3]) begin
                    timer_value[31:24] <= data_i[31:24];
                end
            end
        end
    end

    reg[31:0] data_r;
    // 读寄存器
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_r <= 32'h0;
        end else begin
            if (ren) begin
                case (addr_i[3:0])
                    REG_VALUE: data_r <= timer_value;
                    REG_CTRL:  data_r <= timer_ctrl;
                    REG_COUNT: data_r <= timer_count;
                    default:   data_r <= 32'h0;
                endcase
            end else begin
                data_r <= 32'h0;
            end
        end
    end

    assign data_o = data_r;

    vld_rdy #(
        .CUT_READY(0)
    ) u_vld_rdy(
        .clk(clk),
        .rst_n(rst_n),
        .vld_i(req_valid_i),
        .rdy_o(req_ready_o),
        .rdy_i(rsp_ready_i),
        .vld_o(rsp_valid_o)
    );

endmodule
