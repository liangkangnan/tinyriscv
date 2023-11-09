// Created by IP Generator (Version 2022.1 build 99559)


//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
// Library:
// Filename:TB ram1_tb.v 
//////////////////////////////////////////////////////////////////////////////
`timescale   1ns / 1ps

module  ram1_tb;
localparam  T_CLK_PERIOD       = 10 ;       //clock a half perid
localparam  T_RST_TIME         = 200 ;       //reset time 

localparam ADDR_WIDTH = 14 ; // @IPC int 9,20

localparam DATA_WIDTH = 32 ; // @IPC int 1,1152

localparam WRITE_MODE = "NORMAL_WRITE"; // @IPC enum NORMAL_WRITE,TRANSPARENT_WRITE,READ_BEFORE_WRITE

localparam OUTPUT_REG = 0 ; // @IPC bool

localparam RD_OCE_EN = 0 ; // @IPC bool

localparam CLK_OR_POL_INV = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum Sync_Internally,SYNC,ASYNC

localparam POWER_OPT = 0 ; // @IPC bool

localparam INIT_FILE = "D:/FPGA_LAB_pangomicro/tinyriscv/tinyriscv/tests/example/GAME/GAMEtest.dat" ; // @IPC string

localparam INIT_FORMAT = "HEX" ; // @IPC enum BIN,HEX

localparam WR_BYTE_EN = 1 ; // @IPC bool

localparam BE_WIDTH = 4 ; // @IPC int 2,128

localparam BYTE_SIZE = 8 ; // @IPC enum 8,9

localparam INIT_EN = 1 ; // @IPC bool

localparam CLK_EN = 0 ; // @IPC bool

localparam ADDR_STROBE_EN = 0 ; // @IPC bool

localparam c_RESET_TYPE     = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                              (RESET_TYPE == "SYNC")  ? "SYNC_RESET"  : "ASYNC_RESET_SYNC_RELEASE" ;
localparam  DEVICE_NAME     = "PGL22G";

localparam  DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? 10 : DATA_WIDTH;

//variable declaration 
reg                       clk               ;
reg                       tb_rst            ;
wire                      tb_clk            ;
reg                       tb_clk_en         ;
reg                       tb_wr_en          ;
reg   [BE_WIDTH-1:0]      tb_wr_byte_en     ;
reg   [ADDR_WIDTH  :0]    tb_addr           ;
reg                       tb_addr_strobe    ;
reg   [DATA_WIDTH-1:0]    tb_wrdata_cnt     ;
reg                       tb_rd_oce         ;
wire  [DATA_WIDTH-1:0]    tb_rddata         ;

reg                       tb_rd_en          ;
reg                       tb_rd_en_dly      ;
reg                       tb_rd_en_2dly     ;
reg   [DATA_WIDTH-1:0]    tb_rddata_cnt     ;
reg   [DATA_WIDTH-1:0]    tb_rddata_cnt_dly ;
reg   [DATA_WIDTH-1:0]    tb_expected_data  ;
reg                       check_err         ;
reg   [2:0]               results_cnt       ;

//************************************************************ CGU ****************************************************************************
initial
begin
    clk           = 1'b0 ;
    tb_addr       = {ADDR_WIDTH+1{1'b0}} ;
    tb_wrdata_cnt = {DATA_WIDTH{1'b0}} ;
    tb_wr_en      = 1'b0 ;

    tb_rd_en      = 1'b0 ;
    tb_rddata_cnt = {DATA_WIDTH{1'b0}} ;

    if (CLK_EN == 1)
        tb_clk_en = 1'b1 ;
    else
        tb_clk_en = 1'b0 ;

    if (WR_BYTE_EN == 1)
        tb_wr_byte_en = {BE_WIDTH{1'b1}} ;
    else
        tb_wr_byte_en = {BE_WIDTH{1'b0}} ;

    if (RD_OCE_EN == 1)
        tb_rd_oce = 1'b1 ;
    else
        tb_rd_oce = 1'b0 ;

    if (ADDR_STROBE_EN == 1)
        tb_addr_strobe = 1'b0;
    else
        tb_addr_strobe = 1'b0;
end

initial
begin
    forever #(T_CLK_PERIOD/2)  clk = ~clk ;
end

assign tb_clk = (CLK_OR_POL_INV == 1) ? ~clk : clk;

task write_spram;
    input write_spram ;

    begin
        while ( tb_addr < 2**ADDR_WIDTH )
        begin
            @(posedge clk) ;
            tb_wr_en  = 1'b1 ;
            tb_addr   = tb_addr + {{ADDR_WIDTH{1'b0}},1'b1} ;
        end
        tb_wr_en = 1'b0 ;
        tb_addr  = {(ADDR_WIDTH + 1){1'b0}};
    end 
endtask

task read_spram;
    input read_spram ;

    begin
        while ( tb_addr < 2**ADDR_WIDTH )
        begin
           @(posedge clk) ;
            tb_rd_en = 1'b1 ;
            tb_addr  = tb_addr + {{ADDR_WIDTH{1'b0}},1'b1} ;
        end
        tb_rd_en =1'b0 ;
        tb_addr  = {(ADDR_WIDTH + 1){1'b0}};
    end
endtask

initial
begin
    tb_rst        = 1'b1 ;
    #T_RST_TIME ;
    tb_rst        = 1'b0 ;
    #10 ;
    if(INIT_FILE == "NONE")
    begin
        $display ("Writing SPRAM") ;
        write_spram(1) ;
        #10;
        $display ("Reading SPRAM") ;
        read_spram(1) ;
        #10;
        $display ("SPRAM Simulate is Done.") ;
    end
    else
    begin
        $display ("Reading Initialized SPRAM") ;
        read_spram(1) ;
    end

    if (|results_cnt)
        $display ("Simulation Failed due to Error Found.") ;
    else
        $display ("Simulation Success.") ;

    #500 ;
    $finish ;
end

always@(posedge clk or posedge tb_rst)
begin
    if(tb_rst)
        tb_wrdata_cnt <= {DATA_WIDTH{1'b1}} ;
    else if (tb_wr_en)
        tb_wrdata_cnt <= tb_wrdata_cnt - {{DATA_WIDTH-1{1'b0}},1'b1} ;
end

always@(posedge clk or posedge tb_rst)
begin
    if(tb_rst)
        tb_rddata_cnt <= {DATA_WIDTH{1'b1}} ;
    else if (!tb_rd_en)
        tb_rddata_cnt <= {DATA_WIDTH{1'b1}} ;
    else if (((RD_OCE_EN == 1'b1) && (tb_rd_oce))
           || (RD_OCE_EN == 1'b0))
        tb_rddata_cnt <= tb_rddata_cnt - {{DATA_WIDTH-1{1'b0}},1'b1} ;
end

always@(posedge tb_clk or posedge tb_rst)
begin
    if (tb_rst)
        tb_rddata_cnt_dly <= {DATA_WIDTH{1'b0}} ;
    else
        tb_rddata_cnt_dly <= tb_rddata_cnt ;
end

always@(posedge tb_clk or posedge tb_rst)
begin
    if (tb_rst)
    begin
        tb_rd_en_dly  <= 1'b0;
        tb_rd_en_2dly <= 1'b0;
    end
    else
    begin
        tb_rd_en_dly  <= tb_rd_en;
        tb_rd_en_2dly <= tb_rd_en_dly;
    end
end

always@(posedge tb_clk or posedge tb_rst)
begin
    if (tb_rst)
        tb_expected_data <= {DATA_WIDTH{1'b0}} ;
    else if (RD_OCE_EN == 1'b1)
    begin
        if (tb_rd_oce)
            tb_expected_data <= tb_rddata_cnt_dly ;
    end
    else if (OUTPUT_REG == 1'b1)
        tb_expected_data <= tb_rddata_cnt_dly ;
    else
        tb_expected_data <= tb_rddata_cnt ;
end

always@(posedge tb_clk or posedge tb_rst)
begin
    if(tb_rst)
        check_err <= 1'b0;
    else if(INIT_FILE == "NONE")
    begin
        if (((RD_OCE_EN == 1'b1) && (tb_rd_en_2dly) && (tb_rd_oce))
         || ((OUTPUT_REG == 1'b0) && (tb_rd_en_dly))
         || ((OUTPUT_REG == 1'b1) && (tb_rd_en_2dly)))
            check_err <= (tb_expected_data != tb_rddata) ;
        else
            check_err <= 1'b0;
    end 
    else
        check_err <= 1'b0;
end

always @(posedge tb_clk or posedge tb_rst)
begin
    if (tb_rst)
        results_cnt <= 3'b000 ;
    else if (&results_cnt)
        results_cnt <= 3'b100 ;
    else if (check_err)
        results_cnt <= results_cnt + 3'd1 ;
end

//***************************************************************** DUT  INST **************************************************************************************

GTP_GRS GRS_INST(
    .GRS_N(1'b1)
    ) ;

ram1 U_ram1 (
    .addr        ( tb_addr[ADDR_WIDTH-1:0] ),
    .wr_data     ( tb_wrdata_cnt           ),
    .rd_data     ( tb_rddata               ),
    .wr_en       ( tb_wr_en                ),
    .clk         ( clk                     ),

    .wr_byte_en  ( tb_wr_byte_en           ),

    .rst         ( tb_rst                  )
    ) ;

endmodule
