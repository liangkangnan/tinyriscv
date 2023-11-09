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

// 串口收发模块(默认: 115200, 8，N，1)
module uart(

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

	output wire tx_pin,
    input wire rx_pin,

    output reg spi_mosi,             // spi控制器输出、spi设备输入信号
    input wire spi_miso,             // spi控制器输入、spi设备输出信号
    output wire spi_ss,              // spi设备片选
    output reg spi_clk,               // spi设备时钟，最大频率为输入clk的一半   

    output reg spi2_mosi,             // spi控制器输出、spi设备输入信号
    input wire spi2_miso,             // spi控制器输入、spi设备输出信号
    output wire spi2_ss,              // spi设备片选
    output reg spi2_clk               // spi设备时钟，最大频率为输入clk的一半   
    );

    // 波特率115200bps
    localparam BAUD_115200 = `CPU_CLOCK_HZ / 115200;

    localparam S_IDLE       = 4'b0001;
    localparam S_START      = 4'b0010;
    localparam S_SEND_BYTE  = 4'b0100;
    localparam S_STOP       = 4'b1000;


    reg[3:0] state;
    reg[3:0] next_state;
    reg[15:0] cycle_cnt;
    reg tx_bit;
    reg[3:0] bit_cnt;

    reg rx_q0;
    reg rx_q1;
    wire rx_negedge;
    reg rx_start;                      // RX使能
    reg[3:0] rx_clk_edge_cnt;          // clk沿的个数
    reg rx_clk_edge_level;             // clk沿电平
    reg rx_done;
    reg[15:0] rx_clk_cnt;
    reg[15:0] rx_div_cnt;
    reg[7:0] rx_data;
    reg rx_over;

    // 寄存器(偏移)地址
    localparam UART_CTRL    = 8'h0;
    localparam UART_STATUS  = 8'h4;
    localparam UART_BAUD    = 8'h8;
    localparam UART_TXDATA  = 8'hc;
    localparam UART_RXDATA  = 8'h10;
    localparam SPI_CTRL   = 8'h20;    // spi_ctrl寄存器地址偏移
    localparam SPI_DATA   = 8'h24;    // spi_data寄存器地址偏移
    localparam SPI_STATUS = 8'h28;    // spi_status寄存器地址偏移
    localparam SPI2_CTRL   = 8'h30;    // spi_ctrl寄存器地址偏移
    localparam SPI2_DATA   = 8'h34;    // spi_data寄存器地址偏移
    localparam SPI2_STATUS = 8'h38;    // spi_status寄存器地址偏移

    // UART控制寄存器，可读可写
    // bit[0]: UART TX使能, 1: enable, 0: disable
    // bit[1]: UART RX使能, 1: enable, 0: disable
    reg[31:0] uart_ctrl;

    // UART状态寄存器
    // 只读，bit[0]: TX空闲状态标志, 1: busy, 0: idle
    // 可读可写，bit[1]: RX接收完成标志, 1: over, 0: receiving
    reg[31:0] uart_status;

    // UART波特率寄存器(分频系数)，可读可写
    reg[31:0] uart_baud;

    // UART发送数据寄存器，可读可写
    reg[31:0] uart_tx;

    // UART接收数据寄存器，只读
    reg[31:0] uart_rx;

    wire wen = we_i & req_valid_i;
    wire ren = (~we_i) & req_valid_i;
    wire write_reg_ctrl_en = wen & (addr_i[7:0] == UART_CTRL);
    wire write_reg_status_en = wen & (addr_i[7:0] == UART_STATUS);
    wire write_reg_baud_en = wen & (addr_i[7:0] == UART_BAUD);
    wire write_reg_txdata_en = wen & (addr_i[7:0] == UART_TXDATA);
    wire tx_start = write_reg_txdata_en & sel_i[0] & uart_ctrl[0] & (~uart_status[0]);
    wire rx_recv_over = uart_ctrl[1] & rx_over;

    assign tx_pin = tx_bit;


    // 写uart_rxdata
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_rx <= 32'h0;
        end else begin
            // 接收完成时，保存接收到的数据
            if (rx_recv_over) begin
                uart_rx[7:0] <= rx_data;
            end
        end
    end

    // 写uart_txdata
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_tx <= 32'h0;
        end else begin
            // 开始发送时，保存要发送的数据
            if (tx_start) begin
                uart_tx[7:0] <= data_i[7:0];
            end
        end
    end

    // 写uart_status
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_status <= 32'h0;
        end else begin
            if (write_reg_status_en & sel_i[0]) begin
                // 写RX完成标志
                uart_status[1] <= data_i[1];
            end else begin
                // 开始发送数据时，置位TX忙标志
                if (tx_start) begin
                    uart_status[0] <= 1'b1;
                // 发送完成时，清TX忙标志
                end else if ((state == S_STOP) & (cycle_cnt == uart_baud[15:0])) begin
                    uart_status[0] <= 1'b0;
                // 接收完成，置位接收完成标志
                end
                if (rx_recv_over) begin
                    uart_status[1] <= 1'b1;
                end
            end
        end
    end

    // 写uart_ctrl
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_ctrl <= 32'h0;
        end else begin
            if (write_reg_ctrl_en & sel_i[0]) begin
                uart_ctrl[7:0] <= data_i[7:0];
            end
        end
    end

    // 写uart_baud
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_baud <= BAUD_115200;
        end else begin
            if (write_reg_baud_en) begin
                if (sel_i[0]) begin
                    uart_baud[7:0] <= data_i[7:0];
                end
                if (sel_i[1]) begin
                    uart_baud[15:8] <= data_i[15:8];
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
                case (addr_i[7:0])
                    UART_CTRL:   data_r <= uart_ctrl;
                    UART_STATUS: data_r <= uart_status;
                    UART_BAUD:   data_r <= uart_baud;
                    UART_RXDATA: data_r <= uart_rx;
                    SPI_CTRL: data_r <= spi_ctrl;
                    SPI_DATA: data_r <= spi_data;
                    SPI_STATUS: data_r <= spi_status;
                    SPI2_CTRL: data_r <= spi2_ctrl;
                    SPI2_DATA: data_r <= spi2_data;
                    SPI2_STATUS: data_r <= spi2_status;
                    default:     data_r <= 32'h0;
                endcase
            end else begin
                data_r <= 32'h0;
            end
        end
    end

    assign data_o = data_r;

    // *************************** TX发送 ****************************

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @ (*) begin
        case (state)
            S_IDLE: begin
                if (tx_start) begin
                    next_state = S_START;
                end else begin
                    next_state = S_IDLE;
                end
            end
            S_START: begin
                if (cycle_cnt == uart_baud[15:0]) begin
                    next_state = S_SEND_BYTE;
                end else begin
                    next_state = S_START;
                end
            end
            S_SEND_BYTE: begin
                if ((cycle_cnt == uart_baud[15:0]) & (bit_cnt == 4'd7)) begin
                    next_state = S_STOP;
                end else begin
                    next_state = S_SEND_BYTE;
                end
            end
            S_STOP: begin
                if (cycle_cnt == uart_baud[15:0]) begin
                    next_state = S_IDLE;
                end else begin
                    next_state = S_STOP;
                end
            end
            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    // cycle_cnt
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_cnt <= 16'h0;
        end else begin
            if (state == S_IDLE) begin
                cycle_cnt <= 16'h0;
            end else begin
                if (cycle_cnt == uart_baud[15:0]) begin
                    cycle_cnt <= 16'h0;
                end else begin
                    cycle_cnt <= cycle_cnt + 16'h1;
                end
            end
        end
    end

    // bit_cnt
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_cnt <= 4'h0;
        end else begin
            case (state)
                S_IDLE: begin
                    bit_cnt <= 4'h0;
                end
                S_SEND_BYTE: begin
                    if (cycle_cnt == uart_baud[15:0]) begin
                        bit_cnt <= bit_cnt + 4'h1;
                    end
                end
            endcase
        end
    end

    // tx_bit
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_bit <= 1'b0;
        end else begin
            case (state)
                S_IDLE, S_STOP: begin
                    tx_bit <= 1'b1;
                end
                S_START: begin
                    tx_bit <= 1'b0;
                end
                S_SEND_BYTE: begin
                    tx_bit <= uart_tx[bit_cnt];
                end
            endcase
        end
    end

    // *************************** RX接收 ****************************

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_q0 <= 1'b0;
            rx_q1 <= 1'b0;	
        end else begin
            rx_q0 <= rx_pin;
            rx_q1 <= rx_q0;
        end
    end

    // 下降沿检测(检测起始信号)
    assign rx_negedge = rx_q1 & (~rx_q0);

    // 产生开始接收数据信号，接收期间一直有效
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_start <= 1'b0;
        end else begin
            if (uart_ctrl[1]) begin
                if (rx_negedge) begin
                    rx_start <= 1'b1;
                end else if (rx_clk_edge_cnt == 4'd9) begin
                    rx_start <= 1'b0;
                end
            end else begin
                rx_start <= 1'b0;
            end
        end
    end

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_div_cnt <= 16'h0;
        end else begin
            // 第一个时钟沿只需波特率分频系数的一半
            if (rx_start == 1'b1 && rx_clk_edge_cnt == 4'h0) begin
                rx_div_cnt <= {1'b0, uart_baud[15:1]};
            end else begin
                rx_div_cnt <= uart_baud[15:0];
            end
        end
    end

    // 对时钟进行计数
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_clk_cnt <= 16'h0;
        end else if (rx_start == 1'b1) begin
            // 计数达到分频值
            if (rx_clk_cnt == rx_div_cnt) begin
                rx_clk_cnt <= 16'h0;
            end else begin
                rx_clk_cnt <= rx_clk_cnt + 16'h1;
            end
        end else begin
            rx_clk_cnt <= 16'h0;
        end
    end

    // 每当时钟计数达到分频值时产生一个上升沿脉冲
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_clk_edge_cnt <= 4'h0;
            rx_clk_edge_level <= 1'b0;
        end else if (rx_start == 1'b1) begin
            // 计数达到分频值
            if (rx_clk_cnt == rx_div_cnt) begin
                // 时钟沿个数达到最大值
                if (rx_clk_edge_cnt == 4'd9) begin
                    rx_clk_edge_cnt <= 4'h0;
                    rx_clk_edge_level <= 1'b0;
                end else begin
                    // 时钟沿个数加1
                    rx_clk_edge_cnt <= rx_clk_edge_cnt + 4'h1;
                    // 产生上升沿脉冲
                    rx_clk_edge_level <= 1'b1;
                end
            end else begin
                rx_clk_edge_level <= 1'b0;
            end
        end else begin
            rx_clk_edge_cnt <= 4'h0;
            rx_clk_edge_level <= 1'b0;
        end
    end

    // bit序列
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_data <= 8'h0;
            rx_over <= 1'b0;
        end else begin
            if (rx_start == 1'b1) begin
                // 上升沿
                if (rx_clk_edge_level == 1'b1) begin
                    case (rx_clk_edge_cnt)
                        // 起始位
                        1: begin

                        end
                        // 第1位数据位
                        2: begin
                            if (rx_pin) begin
                                rx_data <= 8'h80;
                            end else begin
                                rx_data <= 8'h0;
                            end
                        end
                        // 剩余数据位
                        3, 4, 5, 6, 7, 8, 9: begin
                            rx_data <= {rx_pin, rx_data[7:1]};
                            // 最后一位接收完成，置位接收完成标志
                            if (rx_clk_edge_cnt == 4'h9) begin
                                rx_over <= 1'b1;
                            end
                        end
                    endcase
                end
            end else begin
                rx_data <= 8'h0;
                rx_over <= 1'b0;
            end
        end
    end

    reg[31:0] spi_ctrl;
    reg[31:0] spi_data;
    reg[31:0] spi_status;

    spi  #(
        .SPI_CTRL(8'h20),
        .SPI_DATA(8'h24),
        .SPI_STATUS(8'h28)
    ) spi1 (
        .clk(clk),
        .rst(rst_n),

        .data_i(data_i),
        .addr_i(addr_i),
        .sel_i(sel_i),
        .we_i(we_i),
        .req_valid_i(req_valid_i),

        .spi_ctrl(spi_ctrl),
        .spi_data(spi_data),
        .spi_status(spi_status),

        .spi_mosi(spi_mosi),             
        .spi_miso(spi_miso),             
        .spi_ss(spi_ss),              
        .spi_clk(spi_clk)               
    );

    reg[31:0] spi2_ctrl;
    reg[31:0] spi2_data;
    reg[31:0] spi2_status;

    spi  #(
        .SPI_CTRL(8'h30),
        .SPI_DATA(8'h34),
        .SPI_STATUS(8'h38)
    ) spi2 (
        .clk(clk),
        .rst(rst_n),

        .data_i(data_i),
        .addr_i(addr_i),
        .sel_i(sel_i),
        .we_i(we_i),
        .req_valid_i(req_valid_i),

        .spi_ctrl(spi2_ctrl),
        .spi_data(spi2_data),
        .spi_status(spi2_status),

        .spi_mosi(spi2_mosi),             
        .spi_miso(spi2_miso),             
        .spi_ss(spi2_ss),              
        .spi_clk(spi2_clk)               
    );

/*
//---------------------SPI----------------------------

    // spi控制寄存器
    // addr: 0x00
    // [0]: 1: enable, 0: disable
    // [1]: CPOL
    // [2]: CPHA
    // [3]: select slave, 1: select, 0: deselect
    // [15:8]: clk div
    reg[31:0] spi_ctrl;
    // spi数据寄存器
    // addr: 0x04
    // [7:0] cmd or inout data
    reg[31:0] spi_data;
    // spi状态寄存器
    // addr: 0x08
    // [0]: 1: busy, 0: idle
    reg[31:0] spi_status;

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

    wire write_spi_ctrl_en = wen & (addr_i[7:0] == SPI_CTRL);
    wire write_spi_data_en = wen & (addr_i[7:0] == SPI_DATA);


    // 产生使能信号
    // 传输期间一直有效
    always @ (posedge clk) begin
        if (rst_n == 1'b0) begin
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
        if (rst_n == 1'b0) begin
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
        if (rst_n == 1'b0) begin
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
        if (rst_n == 1'b0) begin
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
        if (rst_n == 1'b0) begin
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
        if (rst_n == 1'b0) begin
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
//---------------------SPI----------------------------
*/
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
