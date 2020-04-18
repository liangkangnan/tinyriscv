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


// RIB总线模块
module rib(

    input wire clk,
    input wire rst,

    // master 0 interface
    input wire[`MemAddrBus] m0_addr_i,     // 主设备0读、写地址
    input wire[`MemBus] m0_data_i,         // 主设备0写数据
    output reg[`MemBus] m0_data_o,         // 主设备0读取到的数据
    output reg m0_ack_o,                   // 主设备0访问完成标志
    input wire m0_req_i,                   // 主设备0访问请求标志
    input wire m0_we_i,                    // 主设备0写标志

    // master 1 interface
    input wire[`MemAddrBus] m1_addr_i,     // 主设备1读、写地址
    input wire[`MemBus] m1_data_i,         // 主设备1写数据
    output reg[`MemBus] m1_data_o,         // 主设备1读取到的数据
    output reg m1_ack_o,                   // 主设备1访问完成标志
    input wire m1_req_i,                   // 主设备1访问请求标志
    input wire m1_we_i,                    // 主设备1写标志

    // master 2 interface
    input wire[`MemAddrBus] m2_addr_i,     // 主设备2读、写地址
    input wire[`MemBus] m2_data_i,         // 主设备2写数据
    output reg[`MemBus] m2_data_o,         // 主设备2读取到的数据
    output reg m2_ack_o,                   // 主设备2访问完成标志
    input wire m2_req_i,                   // 主设备2访问请求标志
    input wire m2_we_i,                    // 主设备2写标志

    // slave 0 interface
    output reg[`MemAddrBus] s0_addr_o,     // 从设备0读、写地址
    output reg[`MemBus] s0_data_o,         // 从设备0写数据
    input wire[`MemBus] s0_data_i,         // 从设备0读取到的数据
    input wire s0_ack_i,                   // 从设备0访问完成标志
    output reg s0_req_o,                   // 从设备0访问请求标志
    output reg s0_we_o,                    // 从设备0写标志

    // slave 1 interface
    output reg[`MemAddrBus] s1_addr_o,     // 从设备1读、写地址
    output reg[`MemBus] s1_data_o,         // 从设备1写数据
    input wire[`MemBus] s1_data_i,         // 从设备1读取到的数据
    input wire s1_ack_i,                   // 从设备1访问完成标志
    output reg s1_req_o,                   // 从设备1访问请求标志
    output reg s1_we_o,                    // 从设备1写标志

    // slave 2 interface
    output reg[`MemAddrBus] s2_addr_o,     // 从设备2读、写地址
    output reg[`MemBus] s2_data_o,         // 从设备2写数据
    input wire[`MemBus] s2_data_i,         // 从设备2读取到的数据
    input wire s2_ack_i,                   // 从设备2访问完成标志
    output reg s2_req_o,                   // 从设备2访问请求标志
    output reg s2_we_o,                    // 从设备2写标志

    // slave 3 interface
    output reg[`MemAddrBus] s3_addr_o,     // 从设备3读、写地址
    output reg[`MemBus] s3_data_o,         // 从设备3写数据
    input wire[`MemBus] s3_data_i,         // 从设备3读取到的数据
    input wire s3_ack_i,                   // 从设备3访问完成标志
    output reg s3_req_o,                   // 从设备3访问请求标志
    output reg s3_we_o,                    // 从设备3写标志

    // slave 4 interface
    output reg[`MemAddrBus] s4_addr_o,     // 从设备4读、写地址
    output reg[`MemBus] s4_data_o,         // 从设备4写数据
    input wire[`MemBus] s4_data_i,         // 从设备4读取到的数据
    input wire s4_ack_i,                   // 从设备4访问完成标志
    output reg s4_req_o,                   // 从设备4访问请求标志
    output reg s4_we_o,                    // 从设备4写标志

    output reg hold_flag_o                 // 暂停流水线标志

    );


    // 访问地址的最高4位决定要访问的是哪一个从设备
    // 因此最高支持16个从设备
    parameter [3:0]slave_0 = 4'b0000;
    parameter [3:0]slave_1 = 4'b0001;
    parameter [3:0]slave_2 = 4'b0010;
    parameter [3:0]slave_3 = 4'b0011;
    parameter [3:0]slave_4 = 4'b0100;

    parameter [1:0]grant0 = 2'h0;
    parameter [1:0]grant1 = 2'h1;
    parameter [1:0]grant2 = 2'h2;


    wire[2:0] req;
    reg[1:0] grant;
    reg[1:0] next_grant;


    // 主设备请求信号
    assign req = {m2_req_i, m1_req_i, m0_req_i};


    // 授权主设备切换
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            grant <= grant1;
        end else begin
            grant <= next_grant;
        end
    end

    // 仲裁逻辑
    // 固定优先级仲裁机制
    // 优先级由高到低：主设备0，主设备2，主设备1
    always @ (*) begin
        if (rst == `RstEnable) begin
            next_grant <= grant1;
            hold_flag_o <= `HoldDisable;
        end else begin
            case (grant)
                grant0: begin
                    if (req[0]) begin
                        next_grant <= grant0;
                        hold_flag_o <= `HoldEnable;
                    end else if (req[2]) begin
                        next_grant <= grant2;
                        hold_flag_o <= `HoldEnable;
                    end else begin
                        next_grant <= grant1;
                        hold_flag_o <= `HoldDisable;
                    end
                end
                grant1: begin
                    if (req[0]) begin
                        next_grant <= grant0;
                        hold_flag_o <= `HoldEnable;
                    end else if (req[2]) begin
                        next_grant <= grant2;
                        hold_flag_o <= `HoldEnable;
                    end else begin
                        next_grant <= grant1;
                        hold_flag_o <= `HoldDisable;
                    end
                end
                grant2: begin
                    if (req[0]) begin
                        next_grant <= grant0;
                        hold_flag_o <= `HoldEnable;
                    end else if (req[2]) begin
                        next_grant <= grant2;
                        hold_flag_o <= `HoldEnable;
                    end else begin
                        next_grant <= grant1;
                        hold_flag_o <= `HoldDisable;
                    end
                end
                default: begin
                    next_grant <= grant1;
                    hold_flag_o <= `HoldDisable;
                end
            endcase
        end
    end

    // 根据授权结果，选择(访问)对应的从设备
    always @ (*) begin
        if (rst == `RstEnable) begin
            m0_ack_o <= `RIB_NACK;
            m1_ack_o <= `RIB_NACK;
            m2_ack_o <= `RIB_NACK;
            m0_data_o <= `ZeroWord;
            m1_data_o <= `INST_NOP;
            m2_data_o <= `ZeroWord;

            s0_addr_o <= `ZeroWord;
            s1_addr_o <= `ZeroWord;
            s2_addr_o <= `ZeroWord;
            s3_addr_o <= `ZeroWord;
            s4_addr_o <= `ZeroWord;
            s0_data_o <= `ZeroWord;
            s1_data_o <= `ZeroWord;
            s2_data_o <= `ZeroWord;
            s3_data_o <= `ZeroWord;
            s4_data_o <= `ZeroWord;
            s0_req_o <= `RIB_NREQ;
            s1_req_o <= `RIB_NREQ;
            s2_req_o <= `RIB_NREQ;
            s3_req_o <= `RIB_NREQ;
            s4_req_o <= `RIB_NREQ;
            s0_we_o <= `WriteDisable;
            s1_we_o <= `WriteDisable;
            s2_we_o <= `WriteDisable;
            s3_we_o <= `WriteDisable;
            s4_we_o <= `WriteDisable;
        end else begin
            m0_ack_o <= `RIB_NACK;
            m1_ack_o <= `RIB_NACK;
            m2_ack_o <= `RIB_NACK;
            m0_data_o <= `ZeroWord;
            m1_data_o <= `INST_NOP;
            m2_data_o <= `ZeroWord;

            s0_addr_o <= `ZeroWord;
            s1_addr_o <= `ZeroWord;
            s2_addr_o <= `ZeroWord;
            s3_addr_o <= `ZeroWord;
            s4_addr_o <= `ZeroWord;
            s0_data_o <= `ZeroWord;
            s1_data_o <= `ZeroWord;
            s2_data_o <= `ZeroWord;
            s3_data_o <= `ZeroWord;
            s4_data_o <= `ZeroWord;
            s0_req_o <= `RIB_NREQ;
            s1_req_o <= `RIB_NREQ;
            s2_req_o <= `RIB_NREQ;
            s3_req_o <= `RIB_NREQ;
            s4_req_o <= `RIB_NREQ;
            s0_we_o <= `WriteDisable;
            s1_we_o <= `WriteDisable;
            s2_we_o <= `WriteDisable;
            s3_we_o <= `WriteDisable;
            s4_we_o <= `WriteDisable;

            case (grant)
                grant0: begin
                    case (m0_addr_i[31:28])
                        slave_0: begin
                            s0_req_o <= m0_req_i;
                            s0_we_o <= m0_we_i;
                            s0_addr_o <= {{4'h0}, {m0_addr_i[27:0]}};
                            s0_data_o <= m0_data_i;
                            m0_ack_o <= s0_ack_i;
                            m0_data_o <= s0_data_i;
                        end
                        slave_1: begin
                            s1_req_o <= m0_req_i;
                            s1_we_o <= m0_we_i;
                            s1_addr_o <= {{4'h0}, {m0_addr_i[27:0]}};
                            s1_data_o <= m0_data_i;
                            m0_ack_o <= s1_ack_i;
                            m0_data_o <= s1_data_i;
                        end
                        slave_2: begin
                            s2_req_o <= m0_req_i;
                            s2_we_o <= m0_we_i;
                            s2_addr_o <= {{4'h0}, {m0_addr_i[27:0]}};
                            s2_data_o <= m0_data_i;
                            m0_ack_o <= s2_ack_i;
                            m0_data_o <= s2_data_i;
                        end
                        slave_3: begin
                            s3_req_o <= m0_req_i;
                            s3_we_o <= m0_we_i;
                            s3_addr_o <= {{4'h0}, {m0_addr_i[27:0]}};
                            s3_data_o <= m0_data_i;
                            m0_ack_o <= s3_ack_i;
                            m0_data_o <= s3_data_i;
                        end
                        slave_4: begin
                            s4_req_o <= m0_req_i;
                            s4_we_o <= m0_we_i;
                            s4_addr_o <= {{4'h0}, {m0_addr_i[27:0]}};
                            s4_data_o <= m0_data_i;
                            m0_ack_o <= s4_ack_i;
                            m0_data_o <= s4_data_i;
                        end
                        default: begin

                        end
                    endcase
                end
                grant1: begin
                    case (m1_addr_i[31:28])
                        slave_0: begin
                            s0_req_o <= m1_req_i;
                            s0_we_o <= m1_we_i;
                            s0_addr_o <= {{4'h0}, {m1_addr_i[27:0]}};
                            s0_data_o <= m1_data_i;
                            m1_ack_o <= s0_ack_i;
                            m1_data_o <= s0_data_i;
                        end
                        slave_1: begin
                            s1_req_o <= m1_req_i;
                            s1_we_o <= m1_we_i;
                            s1_addr_o <= {{4'h0}, {m1_addr_i[27:0]}};
                            s1_data_o <= m1_data_i;
                            m1_ack_o <= s1_ack_i;
                            m1_data_o <= s1_data_i;
                        end
                        slave_2: begin
                            s2_req_o <= m1_req_i;
                            s2_we_o <= m1_we_i;
                            s2_addr_o <= {{4'h0}, {m1_addr_i[27:0]}};
                            s2_data_o <= m1_data_i;
                            m1_ack_o <= s2_ack_i;
                            m1_data_o <= s2_data_i;
                        end
                        slave_3: begin
                            s3_req_o <= m1_req_i;
                            s3_we_o <= m1_we_i;
                            s3_addr_o <= {{4'h0}, {m1_addr_i[27:0]}};
                            s3_data_o <= m1_data_i;
                            m1_ack_o <= s3_ack_i;
                            m1_data_o <= s3_data_i;
                        end
                        slave_4: begin
                            s4_req_o <= m1_req_i;
                            s4_we_o <= m1_we_i;
                            s4_addr_o <= {{4'h0}, {m1_addr_i[27:0]}};
                            s4_data_o <= m1_data_i;
                            m1_ack_o <= s4_ack_i;
                            m1_data_o <= s4_data_i;
                        end
                        default: begin

                        end
                    endcase
                end
                grant2: begin
                    case (m2_addr_i[31:28])
                        slave_0: begin
                            s0_req_o <= m2_req_i;
                            s0_we_o <= m2_we_i;
                            s0_addr_o <= {{4'h0}, {m2_addr_i[27:0]}};
                            s0_data_o <= m2_data_i;
                            m2_ack_o <= s0_ack_i;
                            m2_data_o <= s0_data_i;
                        end
                        slave_1: begin
                            s1_req_o <= m2_req_i;
                            s1_we_o <= m2_we_i;
                            s1_addr_o <= {{4'h0}, {m2_addr_i[27:0]}};
                            s1_data_o <= m2_data_i;
                            m2_ack_o <= s1_ack_i;
                            m2_data_o <= s1_data_i;
                        end
                        slave_2: begin
                            s2_req_o <= m2_req_i;
                            s2_we_o <= m2_we_i;
                            s2_addr_o <= {{4'h0}, {m2_addr_i[27:0]}};
                            s2_data_o <= m2_data_i;
                            m2_ack_o <= s2_ack_i;
                            m2_data_o <= s2_data_i;
                        end
                        slave_3: begin
                            s3_req_o <= m2_req_i;
                            s3_we_o <= m2_we_i;
                            s3_addr_o <= {{4'h0}, {m2_addr_i[27:0]}};
                            s3_data_o <= m2_data_i;
                            m2_ack_o <= s3_ack_i;
                            m2_data_o <= s3_data_i;
                        end
                        slave_4: begin
                            s4_req_o <= m2_req_i;
                            s4_we_o <= m2_we_i;
                            s4_addr_o <= {{4'h0}, {m2_addr_i[27:0]}};
                            s4_data_o <= m2_data_i;
                            m2_ack_o <= s4_ack_i;
                            m2_data_o <= s4_data_i;
                        end
                        default: begin

                        end
                    endcase
                end
                default: begin
                    
                end
            endcase
        end
    end

endmodule
