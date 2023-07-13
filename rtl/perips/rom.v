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


module rom #(
    parameter DP = 4096)(

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
    input wire rsp_ready_i

    );

    wire[31:0] addr = addr_i[31:2];
    wire[3:0] wen;
    assign wen = ({4{we_i}} & sel_i);

    ip_dual_port_ram u_ip_ram(
        .wr_data     ( data_i     ),
        .wr_addr     ( addr     ),
        .wr_en       ( we_i       ),
        .wr_clk      ( clk      ),
        .wr_rst      ( ~rst_n      ),
        .wr_byte_en  ( wen  ),
        .rd_data     ( data_o     ),
        .rd_addr     ( addr     ),
        .rd_clk      ( clk      ),
        .rd_rst      ( ~rst_n      )
    );

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
