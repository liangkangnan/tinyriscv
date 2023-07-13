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

`define DTM_OP_NOP        2'b00
`define DTM_OP_READ       2'b01
`define DTM_OP_WRITE      2'b10


module jtag_dm #(
    parameter DMI_ADDR_BITS = 6,
    parameter DMI_DATA_BITS = 32,
    parameter DMI_OP_BITS = 2)(

    clk,
    rst_n,

    // rx
    dm_ack_o,
    dtm_req_valid_i,
    dtm_req_data_i,

    // tx
    dtm_ack_i,
    dm_resp_data_o,
    dm_resp_valid_o,

    dm_reg_we_o,
    dm_reg_addr_o,
    dm_reg_wdata_o,
    dm_reg_rdata_i,
    dm_mem_we_o,
    dm_mem_addr_o,
    dm_mem_wdata_o,
    dm_mem_rdata_i,
    dm_mem_sel_o,

    req_valid_o,
    req_ready_i,
    rsp_valid_i,
    rsp_ready_o,

    dm_halt_req_o,
    dm_reset_req_o

    );

    parameter DM_RESP_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;
    parameter DTM_REQ_BITS = DMI_ADDR_BITS + DMI_DATA_BITS + DMI_OP_BITS;
    parameter SHIFT_REG_BITS = DTM_REQ_BITS;

    // 输入输出信号
    input wire clk;
    input wire rst_n;
    output wire dm_ack_o;
    input wire dtm_req_valid_i;
    input wire[DTM_REQ_BITS-1:0] dtm_req_data_i;
    input wire dtm_ack_i;
    output wire[DM_RESP_BITS-1:0] dm_resp_data_o;
    output wire dm_resp_valid_o;
    output wire dm_reg_we_o;
    output wire[4:0] dm_reg_addr_o;
    output wire[31:0] dm_reg_wdata_o;
    input wire[31:0] dm_reg_rdata_i;
    output wire dm_mem_we_o;
    output wire[31:0] dm_mem_addr_o;
    output wire[31:0] dm_mem_wdata_o;
    input wire[31:0] dm_mem_rdata_i;
    output wire[3:0] dm_mem_sel_o;
    output wire req_valid_o;
    input wire req_ready_i;
    input wire rsp_valid_i;
    output wire rsp_ready_o;
    output wire dm_halt_req_o;
    output wire dm_reset_req_o;

    // DM模块寄存器
    reg[31:0] dcsr;
    reg[31:0] dmstatus;
    reg[31:0] dmcontrol;
    reg[31:0] hartinfo;
    reg[31:0] abstractcs;
    reg[31:0] data0;
    reg[31:0] sbcs;
    reg[31:0] sbaddress0;
    reg[31:0] sbdata0;
    reg[31:0] command;

    // DM模块寄存器地址
    localparam DCSR       = 16'h7b0;
    localparam DMSTATUS   = 6'h11;
    localparam DMCONTROL  = 6'h10;
    localparam HARTINFO   = 6'h12;
    localparam ABSTRACTCS = 6'h16;
    localparam DATA0      = 6'h04;
    localparam SBCS       = 6'h38;
    localparam SBADDRESS0 = 6'h39;
    localparam SBDATA0    = 6'h3C;
    localparam COMMAND    = 6'h17;
    localparam DPC        = 16'h7b1;

    localparam OP_SUCC    = 2'b00;

    localparam STATE_IDLE = 3'b001;
    localparam STATE_EXE  = 3'b010;
    localparam STATE_END  = 3'b100;

    reg[2:0] state;
    reg[31:0] read_data;
    reg dm_reg_we;
    reg[4:0] dm_reg_addr;
    reg[31:0] dm_reg_wdata;
    reg dm_mem_we;
    reg[31:0] dm_mem_addr;
    reg[31:0] dm_mem_wdata;
    reg[31:0] dm_mem_rdata;
    reg dm_halt_req;
    reg dm_reset_req;
    reg need_resp;
    reg is_read_reg;
    wire rx_valid;
    wire[DTM_REQ_BITS-1:0] rx_data;     // driver请求数据
    reg[DTM_REQ_BITS-1:0] rx_data_r;

    wire[3:0] dm_mem_sel = (sbcs[19:17] == 3'd0)? 4'b0001:
                           (sbcs[19:17] == 3'd1)? 4'b0011:
                           4'b1111;
    wire[2:0] address_inc_step = (sbcs[19:17] == 3'd0)? 3'd1:
                                 (sbcs[19:17] == 3'd1)? 3'd2:
                                 3'd4;
    wire[31:0] sbaddress0_next = sbaddress0 + {29'h0, address_inc_step};
    wire[DM_RESP_BITS-1:0] dm_resp_data;

    wire[DMI_OP_BITS-1:0] op = rx_data_r[DMI_OP_BITS-1:0];
    wire[DMI_DATA_BITS-1:0] data = rx_data_r[DMI_DATA_BITS+DMI_OP_BITS-1:DMI_OP_BITS];
    wire[DMI_ADDR_BITS-1:0] address = rx_data_r[DTM_REQ_BITS-1:DMI_DATA_BITS+DMI_OP_BITS];

    wire req_sys_bus = ~(address == DMSTATUS);

    always @ (posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dm_mem_we <= 1'b0;
            dm_reg_we <= 1'b0;
            dm_halt_req <= 1'b0;
            dm_reset_req <= 1'b0;
            dm_mem_addr <= 32'h0;
            dm_reg_addr <= 5'h0;
            sbaddress0 <= 32'h0;
            dcsr <= 32'h0;
            hartinfo <= 32'h0;
            sbcs <= 32'h20040404;
            dmcontrol <= 32'h0;
            abstractcs <= 32'h1000003;
            data0 <= 32'h0;
            sbdata0 <= 32'h0;
            command <= 32'h0;
            dm_reg_wdata <= 32'h0;
            dm_mem_wdata <= 32'h0;
            dm_mem_rdata <= 32'h0;
            dmstatus <= 32'h430c82;
            is_read_reg <= 1'b0;
            read_data <= 32'h0;
            need_resp <= 1'b0;
            state <= STATE_IDLE;
        end else begin
            case (state)
                STATE_IDLE: begin
                    // 接收到driver的请求
                    if (rx_valid) begin
                        rx_data_r <= rx_data;
                        state <= STATE_EXE;
                    end
                end
                STATE_EXE: begin
                    state <= STATE_END;
                    need_resp <= 1'b1;
                    case (op)
                        `DTM_OP_READ: begin
                            case (address)
                                DMSTATUS: begin
                                    read_data <= dmstatus;
                                end
                                DMCONTROL: begin
                                    read_data <= dmcontrol;
                                end
                                HARTINFO: begin
                                    read_data <= hartinfo;
                                end
                                SBCS: begin
                                    read_data <= sbcs;
                                end
                                ABSTRACTCS: begin
                                    read_data <= abstractcs;
                                end
                                DATA0: begin
                                    if (is_read_reg == 1'b1) begin
                                        read_data <= dm_reg_rdata_i;
                                    end else begin
                                        read_data <= data0;
                                    end
                                    is_read_reg <= 1'b0;
                                end
                                SBDATA0: begin
                                    read_data <= dm_mem_rdata;
                                    if (sbcs[16] == 1'b1) begin
                                        sbaddress0 <= sbaddress0_next;
                                    end
                                    if (sbcs[15] == 1'b1) begin
                                        dm_mem_addr <= sbaddress0_next;
                                    end
                                end
                                default: begin
                                    read_data <= {(DMI_DATA_BITS){1'b0}};
                                end
                            endcase
                        end

                        `DTM_OP_WRITE: begin
                            read_data <= {(DMI_DATA_BITS){1'b0}};
                            case (address)
                                DMCONTROL: begin
                                    // reset DM module
                                    if (data[0] == 1'b0) begin
                                        dcsr <= 32'hc0;
                                        dmstatus <= 32'h430c82;  // not halted, all running
                                        hartinfo <= 32'h0;
                                        sbcs <= 32'h20040404;
                                        abstractcs <= 32'h1000003;
                                        dmcontrol <= data;
                                        dm_halt_req <= 1'b0;
                                        dm_reset_req <= 1'b0;
                                    // DM is active
                                    end else begin
                                        // we have only one hart
                                        dmcontrol <= (data & ~(32'h3fffc0)) | 32'h10000;
                                        // halt
                                        if (data[31] == 1'b1) begin
                                            dm_halt_req <= 1'b1;
                                            // clear ALLRUNNING ANYRUNNING and set ALLHALTED
                                            dmstatus <= {dmstatus[31:12], 4'h3, dmstatus[7:0]};
                                        // reset
                                        end else if (data[1] == 1'b1) begin
                                            dm_reset_req <= 1'b1;
                                            dm_halt_req <= 1'b0;
                                            dmstatus <= {dmstatus[31:12], 4'hc, dmstatus[7:0]};
                                        // resume
                                        end else if (dm_halt_req == 1'b1 && data[30] == 1'b1) begin
                                            dm_halt_req <= 1'b0;
                                            // set ALLRUNNING ANYRUNNING and clear ALLHALTED
                                            dmstatus <= {dmstatus[31:12], 4'hc, dmstatus[7:0]};
                                        end
                                    end
                                end
                                COMMAND: begin
                                    // access reg
                                    if (data[31:24] == 8'h0) begin
                                        if (data[22:20] > 3'h2) begin
                                            abstractcs <= abstractcs | (1'b1 << 9);
                                        end else begin
                                            abstractcs <= abstractcs & (~(3'h7 << 8));
                                            // read or write
                                            if (data[18] == 1'b0) begin
                                                dm_reg_addr <= data[15:0] - 16'h1000;
                                                // read
                                                if (data[16] == 1'b0) begin
                                                    if (data[15:0] == DCSR) begin
                                                        data0 <= dcsr;
                                                    end else if (data[15:0] < 16'h1020) begin
                                                        is_read_reg <= 1'b1;
                                                    end
                                                // write
                                                end else begin
                                                    if (data[15:0] < 16'h1020) begin
                                                        dm_reg_we <= 1'b1;
                                                        dm_reg_wdata <= data0;
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                DATA0: begin
                                    data0 <= data;
                                end
                                SBCS: begin
                                    sbcs <= data;
                                end
                                SBADDRESS0: begin
                                    sbaddress0 <= data;
                                    if (sbcs[20] == 1'b1) begin
                                        dm_mem_addr <= data;
                                    end
                                end
                                SBDATA0: begin
                                    sbdata0 <= data;
                                    dm_mem_addr <= sbaddress0;
                                    dm_mem_wdata <= data;
                                    dm_mem_we <= 1'b1;
                                    if (sbcs[16] == 1'b1) begin
                                        sbaddress0 <= sbaddress0_next;
                                    end
                                end
                            endcase
                        end

                        `DTM_OP_NOP: begin
                            read_data <= {(DMI_DATA_BITS){1'b0}};
                        end
                    endcase
                end
                STATE_END: begin
                    state <= STATE_IDLE;
                    dm_mem_rdata <= dm_mem_rdata_i;
                    need_resp <= 1'b0;
                    dm_mem_we <= 1'b0;
                    dm_reg_we <= 1'b0;
                    dm_reset_req <= 1'b0;
                end
            endcase
        end
    end

    wire jtag_req_hsked = (req_valid_o & req_ready_i);
    wire jtag_rsp_hsked = (rsp_valid_i & rsp_ready_o);

    assign rsp_ready_o = (~rst_n)? 1'b0: 1'b1;
    assign dm_mem_sel_o = dm_mem_sel;


    assign dm_reg_we_o = dm_reg_we;
    assign dm_reg_addr_o = dm_reg_addr;
    assign dm_reg_wdata_o = dm_reg_wdata;
    assign dm_mem_we_o = dm_mem_we;
    assign dm_mem_addr_o = dm_mem_addr;
    assign dm_mem_wdata_o = dm_mem_wdata;

    assign req_valid_o = (state != STATE_IDLE) & req_sys_bus;
    assign dm_halt_req_o = dm_halt_req;
    assign dm_reset_req_o = dm_reset_req;

    assign dm_resp_data = {address, read_data, OP_SUCC};


    full_handshake_tx #(
        .DW(DM_RESP_BITS)
    ) tx(
        .clk(clk),
        .rst_n(rst_n),
        .ack_i(dtm_ack_i),
        .req_i(need_resp),
        .req_data_i(dm_resp_data),
        .idle_o(),
        .req_o(dm_resp_valid_o),
        .req_data_o(dm_resp_data_o)
    );

    full_handshake_rx #(
        .DW(DTM_REQ_BITS)
    ) rx(
        .clk(clk),
        .rst_n(rst_n),
        .req_i(dtm_req_valid_i),
        .req_data_i(dtm_req_data_i),
        .ack_o(dm_ack_o),
        .recv_data_o(rx_data),
        .recv_rdy_o(rx_valid)
    );

endmodule
