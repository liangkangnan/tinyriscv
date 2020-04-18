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


module uart_tx(

	input wire clk,
	input wire rst,

    input wire we_i,
    input wire req_i,
    input wire[31:0] addr_i,
    input wire[31:0] data_i,

    output reg[31:0] data_o,
    output reg ack_o,
	output wire tx_pin

    );


    localparam BAUD_115200 = 32'h1B8;

    localparam S_IDLE       = 4'b0001;
    localparam S_START      = 4'b0010;
    localparam S_SEND_BYTE  = 4'b0100;
    localparam S_STOP       = 4'b1000;

    reg tx_data_valid;
    reg tx_data_ready;

    reg[3:0] state;
    reg[15:0] cycle_cnt;
    reg[3:0] bit_cnt;
    reg[7:0] tx_data;
    reg tx_reg;

    localparam UART_CTRL = 4'h0;
    localparam UART_STATUS = 4'h4;
    localparam UART_BAUD = 4'h8;
    localparam UART_TXDATA = 4'hc;

    // addr: 0x00
    // rw. bit[0]: tx enable, 1 = enable, 0 = disable
    reg[31:0] uart_ctrl;

    // addr: 0x04
    // ro. bit[0]: tx busy, 1 = busy, 0 = idle
    // must check this bit before tx data
    reg[31:0] uart_status;

    // addr: 0x08
    // rw. clk div
    reg[31:0] uart_baud;


    assign tx_pin = tx_reg;


    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            uart_ctrl <= 32'h0;
            uart_status <= 32'h0;
            uart_baud <= BAUD_115200;
            tx_data_valid <= 1'b0;
        end else begin
            if (we_i == 1'b1) begin
                case (addr_i[3:0])
                    UART_CTRL: begin
                        uart_ctrl <= data_i;
                    end
                    UART_BAUD: begin
                        uart_baud <= data_i;
                    end
                    UART_TXDATA: begin
                        if (uart_ctrl[0] == 1'b1 && uart_status[0] == 1'b0) begin
                            tx_data <= data_i[7:0];
                            uart_status <= 32'h1;
                            tx_data_valid <= 1'b1;
                        end
                    end
                endcase
            end else begin
                tx_data_valid <= 1'b0;
                if (tx_data_ready == 1'b1) begin
                    uart_status <= 32'h0;
                end
            end
        end
    end

    always @ (*) begin
        if (rst == 1'b0) begin
            data_o <= 32'h0;
        end else begin
            case (addr_i[3:0])
                UART_CTRL: begin
                    data_o <= uart_ctrl;
                end
                UART_STATUS: begin
                    data_o <= uart_status;
                end
                UART_BAUD: begin
                    data_o <= uart_baud;
                end
                default: begin
                    data_o <= 32'h0;
                end
            endcase
        end
    end

    always @ (posedge clk) begin
        if (rst == 1'b0) begin
            state <= S_IDLE;
            cycle_cnt <= 16'd0;
            tx_reg <= 1'b0;
            bit_cnt <= 4'd0;
            tx_data_ready <= 1'b0;
        end else begin
            if (state == S_IDLE) begin
                tx_reg <= 1'b1;
                tx_data_ready <= 1'b0;
                if (tx_data_valid == 1'b1) begin
                    state <= S_START;
                    cycle_cnt <= 16'd0;
                    bit_cnt <= 4'd0;
                    tx_reg <= 1'b0;
                end
            end else begin
                cycle_cnt <= cycle_cnt + 16'd1;
                if (cycle_cnt == uart_baud[15:0]) begin
                    cycle_cnt <= 16'd0;
                    case (state)
                        S_START: begin
                            tx_reg <= tx_data[bit_cnt];
                            state <= S_SEND_BYTE;
                            bit_cnt <= bit_cnt + 4'd1;
                        end
                        S_SEND_BYTE: begin
                            bit_cnt <= bit_cnt + 4'd1;
                            if (bit_cnt == 4'd8) begin
                                state <= S_STOP;
                                tx_reg <= 1'b1;
                            end else begin                
                                tx_reg <= tx_data[bit_cnt];
                            end
                        end
                        S_STOP: begin
                            tx_reg <= 1'b1;
                            state <= S_IDLE;
                            tx_data_ready <= 1'b1;
                        end
                    endcase
                end
            end
        end
    end

endmodule
