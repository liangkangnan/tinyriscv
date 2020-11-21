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

// 数据接收端模块
// 跨时钟域传输，全(四次)握手协议
// req = 1
// ack_o = 1
// req = 0
// ack_o = 0
module full_handshake_rx #(
    parameter DW = 32)(             // RX要接收数据的位宽

    input wire clk,                 // RX端时钟信号
    input wire rst_n,               // RX端复位信号

    // from tx
    input wire req_i,               // TX端请求信号
    input wire[DW-1:0] req_data_i,  // TX端输入数据

    // to tx
    output wire ack_o,              // RX端应答TX端信号

    // to rx
    output wire[DW-1:0] recv_data_o,// RX端接收到的数据
    output wire recv_rdy_o          // RX端是否接收到数据信号

    );

    localparam STATE_IDLE     = 2'b01;
    localparam STATE_DEASSERT = 2'b10;

    reg[1:0] state;
    reg[1:0] state_next;

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
        end else begin
            state <= state_next;
        end
    end

    always @ (*) begin
        case (state)
            // 等待TX请求信号req=1
            STATE_IDLE: begin
                if (req == 1'b1) begin
                    state_next = STATE_DEASSERT;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            // 等待req=0
            STATE_DEASSERT: begin
                if (req) begin
                    state_next = STATE_DEASSERT;
                end else begin
                    state_next = STATE_IDLE;
                end
            end
            default: begin
                state_next = STATE_IDLE;
            end
        endcase
    end

    reg req_d;
    reg req;

    // 将请求信号打两拍进行同步
    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            req_d <= 1'b0;
            req <= 1'b0;
        end else begin
            req_d <= req_i;
            req <= req_d;
        end
    end

    reg[DW-1:0] recv_data;
    reg recv_rdy;
    reg ack;

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ack <= 1'b0;
            recv_rdy <= 1'b0;
            recv_data <= {(DW){1'b0}};
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (req == 1'b1) begin
                        ack <= 1'b1;
                        recv_rdy <= 1'b1;           // 这个信号只会持续一个时钟
                        recv_data <= req_data_i;    // 这个信号只会持续一个时钟
                    end
                end
                STATE_DEASSERT: begin
                    recv_rdy <= 1'b0;
                    recv_data <= {(DW){1'b0}};
                    // req撤销后ack也撤销
                    if (req == 1'b0) begin
                        ack <= 1'b0;
                    end
                end
            endcase
        end
    end

    assign ack_o = ack;
    assign recv_rdy_o = recv_rdy;
    assign recv_data_o = recv_data;

endmodule
