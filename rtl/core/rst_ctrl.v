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

// 复位控制模块
module rst_ctrl(

    input wire clk,

    input wire rst_ext_i,
    input wire rst_jtag_i,

    output wire core_rst_n_o,
    output wire jtag_rst_n_o

    );

    wire ext_rst_r;

    gen_ticks_sync #(
        .DP(2),
        .DW(1)
    ) ext_rst_sync(
        .rst_n(rst_ext_i),
        .clk(clk),
        .din(1'b1),
        .dout(ext_rst_r)
    );

    reg[`JTAG_RESET_FF_LEVELS-1:0] jtag_rst_r;

    always @ (posedge clk) begin
        if (!rst_ext_i) begin
            jtag_rst_r[`JTAG_RESET_FF_LEVELS-1:0] <= {`JTAG_RESET_FF_LEVELS{1'b1}};
        end if (rst_jtag_i) begin
            jtag_rst_r[`JTAG_RESET_FF_LEVELS-1:0] <= {`JTAG_RESET_FF_LEVELS{1'b0}};
        end else begin
            jtag_rst_r[`JTAG_RESET_FF_LEVELS-1:0] <= {jtag_rst_r[`JTAG_RESET_FF_LEVELS-2:0], 1'b1};
        end
    end

    assign core_rst_n_o = ext_rst_r & jtag_rst_r[`JTAG_RESET_FF_LEVELS-1];
    assign jtag_rst_n_o = ext_rst_r;

endmodule
