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


// spi master模块
module spi #(
    parameter SPI_CTRL = 8'h20,
    parameter SPI_DATA = 8'h24,
    parameter SPI_STATUS = 8'h28)(


    input wire clk,
    input wire rst,

    input wire[31:0] data_i,
    input wire[31:0] addr_i,
    input wire[3:0] sel_i,
    input wire we_i,
    input wire req_valid_i,


    output reg[31:0] spi_ctrl,
    output reg[31:0] spi_data,
    output reg[31:0] spi_status,

    output reg spi_mosi,             // spi控制器输出、spi设备输入信号
    input wire spi_miso,             // spi控制器输入、spi设备输出信号
    output wire spi_ss,              // spi设备片选
    output reg spi_clk               // spi设备时钟，最大频率为输入clk的一半   
    );


    //localparam SPI_CTRL   = 8'h20;    // spi_ctrl寄存器地址偏移
    //localparam SPI_DATA   = 8'h24;    // spi_data寄存器地址偏移
    //localparam SPI_STATUS = 8'h28;    // spi_status寄存器地址偏移

    // spi控制寄存器
    // addr: 0x00
    // [0]: 1: enable, 0: disable
    // [1]: CPOL
    // [2]: CPHA
    // [3]: select slave, 1: select, 0: deselect
    // [15:8]: clk div
    //reg[31:0] spi_ctrl;
    // spi数据寄存器
    // addr: 0x04
    // [7:0] cmd or inout data
    //reg[31:0] spi_data;
    // spi状态寄存器
    // addr: 0x08
    // [0]: 1: busy, 0: idle
    //reg[31:0] spi_status;

    reg[8:0] clk_cnt;               // 分频计数
    reg en;                         // 使能，开始传输信号，传输期间一直有效
    reg[4:0] spi_clk_edge_cnt;      // spi clk时钟沿的个数
    reg spi_clk_edge_level;         // spi clk沿电平
    reg[7:0] rdata;                 // 从spi设备读回来的数据
    reg done;                       // 传输完成信号
    reg[3:0] bit_index;             // 数据bit索引
    wire[8:0] div_cnt;


    assign spi_ss = ~spi_ctrl[3];   // SPI设备片选信号

    assign div_cnt = spi_ctrl[15:8];// 0: 2分频，1：4分频，2：8分频，3：16分频，4：32分频，以此类推

    wire wen = we_i & req_valid_i;
    wire ren = (~we_i) & req_valid_i;
    wire write_spi_ctrl_en = wen & (addr_i[7:0] == SPI_CTRL);
    wire write_spi_data_en = wen & (addr_i[7:0] == SPI_DATA);


    // 产生使能信号
    // 传输期间一直有效
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            en <= 1'b0;
        end else begin
            if (spi_ctrl[0] == 1'b1) begin
                en <= 1'b1;
            end else if (done == 1'b1) begin
                en <= 1'b0;
            end else begin
                en <= en;
            end
        end
    end

    // 对输入时钟进行计数
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            clk_cnt <= 9'h0;
        end else if (en == 1'b1) begin
            if (clk_cnt == div_cnt) begin
                clk_cnt <= 9'h0;
            end else begin
                clk_cnt <= clk_cnt + 1'b1;
            end
        end else begin
            clk_cnt <= 9'h0;
        end
    end

    // 对spi clk沿进行计数
    // 每当计数到分频值时产生一个上升沿脉冲
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            spi_clk_edge_cnt <= 5'h0;
            spi_clk_edge_level <= 1'b0;
        end else if (en == 1'b1) begin
            // 计数达到分频值
            if (clk_cnt == div_cnt) begin
                if (spi_clk_edge_cnt == 5'd17) begin
                    spi_clk_edge_cnt <= 5'h0;
                    spi_clk_edge_level <= 1'b0;
                end else begin
                    spi_clk_edge_cnt <= spi_clk_edge_cnt + 1'b1;
                    spi_clk_edge_level <= 1'b1;
                end
            end else begin
                spi_clk_edge_level <= 1'b0;
            end
        end else begin
            spi_clk_edge_cnt <= 5'h0;
            spi_clk_edge_level <= 1'b0;
        end
    end

    // bit序列
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            spi_clk <= 1'b0;
            rdata <= 8'h0;
            spi_mosi <= 1'b0;
            bit_index <= 4'h0;
        end else begin
            if (en) begin
                if (spi_clk_edge_level == 1'b1) begin
                    case (spi_clk_edge_cnt)
                        // 第奇数个时钟沿
                        1, 3, 5, 7, 9, 11, 13, 15: begin
                            spi_clk <= ~spi_clk;
                            if (spi_ctrl[2] == 1'b1) begin
                                spi_mosi <= spi_data[bit_index];   // 送出1bit数据
                                bit_index <= bit_index - 1'b1;
                            end else begin
                                rdata <= {rdata[6:0], spi_miso};   // 读1bit数据
                            end
                        end
                        // 第偶数个时钟沿
                        2, 4, 6, 8, 10, 12, 14, 16: begin
                            spi_clk <= ~spi_clk;
                            if (spi_ctrl[2] == 1'b1) begin
                                rdata <= {rdata[6:0], spi_miso};   // 读1bit数据
                            end else begin
                                spi_mosi <= spi_data[bit_index];   // 送出1bit数据
                                bit_index <= bit_index - 1'b1;
                            end
                        end
                        17: begin
                            spi_clk <= spi_ctrl[1];
                        end
                    endcase
                end
            end else begin
                // 初始状态
                spi_clk <= spi_ctrl[1];
                if (spi_ctrl[2] == 1'b0) begin
                    spi_mosi <= spi_data[7];           // 送出最高位数据
                    bit_index <= 4'h6;
                end else begin
                    bit_index <= 4'h7;
                end
            end
        end
    end

    // 产生结束(完成)信号
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            done <= 1'b0;
        end else begin
            if (en && spi_clk_edge_cnt == 5'd17) begin
                done <= 1'b1;
            end else begin
                done <= 1'b0;
            end
        end
    end

    // write reg
    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            spi_ctrl <= 32'h0;
            spi_data <= 32'h0;
            spi_status <= 32'h0;
        end else begin
            spi_status[0] <= en;
            if (write_spi_ctrl_en) begin
                if (sel_i[0]) begin
                    spi_ctrl[7:0] <= data_i[7:0];
                end
                if (sel_i[1]) begin
                    spi_ctrl[15:8] <= data_i[15:8];
                end
                if (sel_i[2]) begin
                    spi_ctrl[23:16] <= data_i[23:16];
                end
                if (sel_i[3]) begin
                    spi_ctrl[31:24] <= data_i[31:24];
                end
            end

            if (write_spi_data_en) begin
                if (sel_i[0]) begin
                    spi_data[7:0] <= data_i[7:0];
                end
                if (sel_i[1]) begin
                    spi_data[15:8] <= data_i[15:8];
                end
                if (sel_i[2]) begin
                    spi_data[23:16] <= data_i[23:16];
                end
                if (sel_i[3]) begin
                    spi_data[31:24] <= data_i[31:24];
                end
            end
            if (~wen) begin
                spi_ctrl[0] <= 1'b0;
                // 发送完成后更新数据寄存器
                if (done == 1'b1) begin
                    spi_data <= {24'h0, rdata};
                end
            end
        end
    end
    
/*
    reg[31:0] data_r;

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_r <= 32'h0;
        end else begin
            if (ren) begin
                case (addr_i[7:0])
                    SPI_CTRL: data_r <= spi_ctrl;
                    SPI_DATA: data_r <= spi_data;
                    SPI_STATUS: data_r <= spi_status;
                    default:   data_r <= 32'h0;
                endcase
            end else begin
                data_r <= 32'h0;
            end
        end
    end
*/


endmodule
