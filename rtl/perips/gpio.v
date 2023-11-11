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

// GPIO模块
module gpio(

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

    input wire[1:0] io_pin_i,
    output wire[31:0] reg_ctrl,
    output wire[31:0] reg_data

    );

    // GPIO寄存器(偏移)地址
    localparam GPIO_CTRL = 4'h0;
    localparam GPIO_DATA = 4'h4;

    // GPIO控制寄存器
    // 每2位控制1个IO的输入、输出模式，最多支持16个IO
    // 0: 高阻，1：输出，2：输入
    reg[31:0] gpio_ctrl;

    // GPIO输入输出数据寄存器
    reg[31:0] gpio_data;

    assign reg_ctrl = gpio_ctrl;
    assign reg_data = gpio_data;

    wire wen = we_i & req_valid_i;
    wire ren = (~we_i) & req_valid_i;
    wire write_reg_ctrl_en = wen & (addr_i[3:0] == GPIO_CTRL);
    wire write_reg_data_en = wen & (addr_i[3:0] == GPIO_DATA);

    // 写gpio_ctrl
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_ctrl <= 32'h0;
        end else begin
            if (write_reg_ctrl_en) begin
                if (sel_i[0]) begin
                    gpio_ctrl[7:0] <= data_i[7:0];
                end
                if (sel_i[1]) begin
                    gpio_ctrl[15:8] <= data_i[15:8];
                end
                if (sel_i[2]) begin
                    gpio_ctrl[23:16] <= data_i[23:16];
                end
                if (sel_i[3]) begin
                    gpio_ctrl[31:24] <= data_i[31:24];
                end
            end
        end
    end

    // 写gpio_data
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            gpio_data <= 32'h0;
        end else begin
            if (write_reg_data_en) begin
                if (sel_i[0]) begin
                    gpio_data[7:0] <= data_i[7:0];
                end
                if (sel_i[1]) begin
                    gpio_data[15:8] <= data_i[15:8];
                end
            end else begin
                if (gpio_ctrl[1:0] == 2'b10) begin
                    gpio_data[0] <= io_pin_i[0];
                end
                if (gpio_ctrl[3:2] == 2'b10) begin
                    gpio_data[1] <= io_pin_i[1];
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
                    GPIO_CTRL: data_r <= gpio_ctrl;
                    GPIO_DATA: data_r <= gpio_data;
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
