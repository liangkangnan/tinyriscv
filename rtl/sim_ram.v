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

// simulation ram module
module sim_ram (

    input wire clk,
    input wire rst,

    input wire we_i,                     // write enable
    input wire[`SramAddrBus] waddr_i,    // write addr
    input wire[`SramBus] wdata_i,        // write data

    input wire pc_re_i,                  // pc read enable
    input wire[`SramAddrBus] pc_raddr_i, // pc read addr
    output reg[`SramBus] pc_rdata_o,     // pc read data

    input wire ex_re_i,                  // ex read enable
    input wire[`SramAddrBus] ex_raddr_i, // ex read addr
    output reg[`SramBus] ex_rdata_o      // ex read data

);

    reg[`SramBus] ram[0:`SramMemNum - 1];

    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if(we_i == `WriteEnable) begin
                ram[waddr_i[13:2]] <= wdata_i;
            end
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            pc_rdata_o <= `ZeroWord;
        end else if((pc_raddr_i == waddr_i) && (pc_re_i == `ReadEnable)) begin
            pc_rdata_o <= wdata_i;
        end else if(pc_re_i == `ReadEnable) begin
            pc_rdata_o <= ram[pc_raddr_i >> 2];
        end else begin
            pc_rdata_o <= `ZeroWord;
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            ex_rdata_o <= `ZeroWord;
        end else if(ex_re_i == `ReadEnable) begin
            ex_rdata_o <= ram[ex_raddr_i[13:2]];
        end else begin
            ex_rdata_o <= `ZeroWord;
        end
    end

endmodule
