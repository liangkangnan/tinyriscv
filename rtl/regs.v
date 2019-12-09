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

// common reg module
module regs (

    input wire clk,
    input wire rst,

    input wire we,                  // reg write enable
    input wire[`RegAddrBus] waddr,  // reg write addr
    input wire[`RegBus] wdata,      // reg write data

    input wire re1,                 // reg1 read enable
    input wire[`RegAddrBus] raddr1, // reg1 read addr
    output reg[`RegBus] rdata1,     // reg1 read data

    input wire re2,                 // reg2 read enable
    input wire[`RegAddrBus] raddr2, // reg2 read addr
    output reg[`RegBus] rdata2      // reg2 read data

);

    reg[`RegBus] regs[0:`RegNum - 1];

    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            rdata1 <= `ZeroWord;
        end else if(raddr1 == `RegNumLog2'h0) begin
            rdata1 <= `ZeroWord;
        end else if(re1 == `ReadEnable) begin
            rdata1 <= regs[raddr1];
        end else begin
            rdata1 <= `ZeroWord;
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            rdata2 <= `ZeroWord;
        end else if(raddr2 == `RegNumLog2'h0) begin
            rdata2 <= `ZeroWord;
        end else if(re2 == `ReadEnable) begin
            rdata2 <= regs[raddr2];
        end else begin
            rdata2 <= `ZeroWord;
        end
    end

endmodule
