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
// Filename:ram1.v
//////////////////////////////////////////////////////////////////////////////

module ram1
    (
    addr        ,
    wr_data     ,
    rd_data     ,
    wr_en       ,
    clk         ,
    
    wr_byte_en  ,
    
    rst
    );


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

localparam CLK_EN  = 0 ; // @IPC bool

localparam ADDR_STROBE_EN  = 0 ; // @IPC bool

localparam  RESET_TYPE_SEL  = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                              (RESET_TYPE == "SYNC")  ? "SYNC_RESET"  : "ASYNC_RESET_SYNC_RELEASE";
localparam  DEVICE_NAME     = "PGL22G";

localparam  DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? 10 : DATA_WIDTH;
localparam  SIM_DEVICE      = ((DEVICE_NAME == "PGL22G") || (DEVICE_NAME == "PGL22GS")) ? "PGL22G" : "LOGOS";


input  [ADDR_WIDTH-1 : 0]   addr        ;
input  [DATA_WIDTH-1 : 0]   wr_data     ;
output [DATA_WIDTH-1 : 0]   rd_data     ;
input                       wr_en       ;
input                       clk         ;

input  [BE_WIDTH-1 : 0]     wr_byte_en  ;

input                       rst         ;

wire [ADDR_WIDTH-1 : 0]     addr        ;
wire [DATA_WIDTH-1 : 0]     wr_data     ;
wire [DATA_WIDTH-1 : 0]     rd_data     ;
wire                        wr_en       ;
wire                        clk         ;
wire                        clk_en      ;
wire                        addr_strobe ;
wire                        rst         ;
wire [BE_WIDTH-1 : 0]       wr_byte_en  ;
wire                        rd_oce      ;

wire [BE_WIDTH-1 : 0]       wr_byte_en_mux  ;
wire                        rd_oce_mux      ;
wire                        clk_en_mux      ;
wire                        addr_strobe_mux ;

wire [DATA_WIDTH_WRAP-1 : 0] wr_data_wrap;
wire [DATA_WIDTH_WRAP-1 : 0] rd_data_wrap;

assign wr_byte_en_mux   = (WR_BYTE_EN     == 1) ? wr_byte_en  : -1  ;
assign rd_oce_mux       = (RD_OCE_EN      == 1) ? rd_oce      :
                          (OUTPUT_REG     == 1) ? 1'b1 : 1'B0 ;
assign clk_en_mux       = (CLK_EN         == 1) ? clk_en      : 1'b1 ;
assign addr_strobe_mux  = (ADDR_STROBE_EN == 1) ? addr_strobe : 1'b0 ;


assign wr_data_wrap    = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? {{(DATA_WIDTH_WRAP - DATA_WIDTH){1'b0}},wr_data} : wr_data;
assign rd_data         = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? rd_data_wrap[DATA_WIDTH-1 : 0] : rd_data_wrap;


//ipml_sdpram IP instance
ipml_spram_v1_5_ram1
    #(
    .c_SIM_DEVICE       (SIM_DEVICE             ),
    .c_ADDR_WIDTH       (ADDR_WIDTH             ),//write address width  legal value:9~20
    .c_DATA_WIDTH       (DATA_WIDTH_WRAP        ),//write data width     legal value:1~1152
    .c_OUTPUT_REG       (OUTPUT_REG             ),//output register      legal value:0 or 1
    .c_RD_OCE_EN        (RD_OCE_EN              ),
    .c_CLK_EN           (CLK_EN                 ),
    .c_ADDR_STROBE_EN   (ADDR_STROBE_EN         ),
    .c_RESET_TYPE       (RESET_TYPE_SEL         ),//legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"
    .c_POWER_OPT        (POWER_OPT              ),//0 :normal mode  1:low power mode legal value:0 or 1
    .c_CLK_OR_POL_INV   (CLK_OR_POL_INV         ),//clk polarity invert for output register legal value 1 or 0
    .c_INIT_FILE        ("NONE"                 ),//legal value:"NONE" or "initial file name"
    .c_INIT_FORMAT      (INIT_FORMAT            ),//initial data format   legal valve: "bin" or "hex"
    .c_WR_BYTE_EN       (WR_BYTE_EN             ),//byte write enable    legal value: 0 or 1
    .c_BE_WIDTH         (BE_WIDTH               ),//byte width legal value: 1~128
    .c_WRITE_MODE       (WRITE_MODE             ) //"NORMAL_WRITE"; // TRANSPARENT_WRITE READ_BEFORE_WRITE
    ) U_ipml_spram_ram1
    (
    .addr               ( addr                  ),
    .wr_data            ( wr_data_wrap          ),
    .rd_data            ( rd_data_wrap          ),
    .wr_en              ( wr_en                 ),
    .clk                ( clk                   ),
    .clk_en             ( clk_en_mux            ),
    .addr_strobe        ( addr_strobe_mux       ),
    .rst                ( rst                   ),
    .wr_byte_en         ( wr_byte_en_mux        ),
    .rd_oce             ( rd_oce_mux            )
    );

endmodule
