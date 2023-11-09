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
//
// Library:
// Filename:ipml_spram.v
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
module ipml_spram_v1_5_ram2
 #( 
    parameter  c_SIM_DEVICE     = "LOGOS"       ,
    parameter  c_ADDR_WIDTH     = 10            ,  //write address width legal value:9~20  
    parameter  c_DATA_WIDTH     = 32            ,  //write data width legal value:1~1152
    parameter  c_OUTPUT_REG     = 0             ,  //output register legal value:0 or 1
    parameter  c_RD_OCE_EN      = 0             ,
    parameter  c_CLK_EN         = 0             ,
    parameter  c_ADDR_STROBE_EN = 0             ,
    parameter  c_RESET_TYPE     = "ASYNC_RESET" ,  //legal valve "ASYNC_RESET_SYNC_RELEASE" "SYNC_RESET" "ASYNC_RESET"
    parameter  c_POWER_OPT      = 0             ,  //0 :normal mode  1:low power mode legal value:0 or 1
    parameter  c_CLK_OR_POL_INV = 0             ,  //clk polarity invert for output register legal value 1 or 0
    parameter  c_INIT_FILE      = "NONE"        ,  //legal value:"NONE" or "initial file name"
    parameter  c_INIT_FORMAT    = "BIN"         ,  //initial data format legal valve: "bin" or "hex"
    parameter  c_WR_BYTE_EN     = 0             ,  //byte write enable legal value: 0 or 1
    parameter  c_BE_WIDTH       = 8             ,  //byte width legal value: 1~128
    parameter  c_RAM_MODE       = "SINGLE_PORT" ,
    parameter  c_WRITE_MODE     = "NORMAL_WRITE"   //"NORMAL_WRITE"; // TRANSPARENT_WRITE READ_BEFORE_WRITE
 )
  (
    input  wire [c_ADDR_WIDTH-1 : 0]  addr        ,
    input  wire [c_DATA_WIDTH-1 : 0]  wr_data     ,
    output wire [c_DATA_WIDTH-1 : 0]  rd_data     ,
    input  wire                       wr_en       ,
    input  wire                       clk         ,
    input  wire                       clk_en      ,
    input  wire                       addr_strobe ,
    input  wire                       rst         ,
    input  wire [c_BE_WIDTH-1 : 0]    wr_byte_en  ,
    input  wire                       rd_oce
  );

//*************************************************************************************************************************************************************

localparam INIT_EN = 0 ; // @IPC bool

localparam MODE_9K = 0 ; // @IPC bool

localparam MODE_18K = 1 ; // @IPC bool

//********************************************************************************************************************************************************************
//declare localparam
 //L_DATA_WIDTH is the parameter value of DATA_WIDTH_A and DATA_WIDTH_B in a instance DRM ,define witch type DRM to instance in noraml mode
//********************************************************************************************************************************************************************
localparam  c_WR_BYTE_WIDTH = c_WR_BYTE_EN ? c_DATA_WIDTH/(c_BE_WIDTH==0 ? 1 : c_BE_WIDTH) : (c_DATA_WIDTH%9 ==0 ? 9 : (c_DATA_WIDTH%8 ==0) ? 8 : 9 );
localparam  N_DATA_WIDTH = c_ADDR_WIDTH <= 9  ? ( (c_DATA_WIDTH%9 == 0) ? ( (c_ADDR_STROBE_EN == 1) ? 18 : 36 ) : 
                                                  (c_DATA_WIDTH%8 == 0) ? ( (c_ADDR_STROBE_EN == 1) ? 16 : 32 ) : 
                                                                          ( (c_ADDR_STROBE_EN == 1) ? 18 : 36 ) ):   //cascade with 512*36 type DRM 
                           c_ADDR_WIDTH == 10 ? ( (c_DATA_WIDTH%9 == 0) ? 18 : 
                                                  (c_DATA_WIDTH%8 == 0) ? 16 : 
                                                                          18 ):   //cascade with 1k*18  type DRM 
                           c_ADDR_WIDTH == 11 ? ( (c_DATA_WIDTH%9 == 0) ? 9  : 
                                                  (c_DATA_WIDTH%8 == 0) ? 8  : 
                                                                          9  ):   //cascade with 2k*9   type DRM 
                           c_ADDR_WIDTH == 12 ? 4:                                 //cascade with 4k*4   type DRM 
                           c_ADDR_WIDTH == 13 ? 2:                                 //cascade with 8k*2   type DRM 
                                                1;                                 //cascade with 16k*1  type DRM

localparam  L_DATA_WIDTH = c_DATA_WIDTH == 1  ? 1:                 //cascade with 16k*1  type DRM 
                           c_DATA_WIDTH == 2  ? 2:                 //cascade with 8k*2   type DRM 
                           c_DATA_WIDTH <= 4  ? 4:                 //cascade with 2k*8   type DRM
                           c_DATA_WIDTH <= 8  ? 8:                 //cascade with 2k*9   type DRM
                           c_DATA_WIDTH == 9  ? 9:                 //cascade with 4k*4   type DRM
                           c_DATA_WIDTH <= 16 ? 16:                //cascade with 1k*16  type DRM 
                           c_DATA_WIDTH <= 18 ? 18:                //cascade with 1k*18  type DRM
                       ((c_DATA_WIDTH%9 == 0) ? ( (c_ADDR_STROBE_EN == 1) ? 18 : 36 ): 
                        (c_DATA_WIDTH%8 == 0) ? ( (c_ADDR_STROBE_EN == 1) ? 16 : 32 ): 
                                                ( (c_ADDR_STROBE_EN == 1) ? 18 : 36 ) );        //cascade with 512*36 type DRM

//********************************************************************************************************************************************************************
//BYTE ENABLE parameter 
//byte_enable && WIDTH_RATIO = 1
localparam  N_BYTE_DATA_WIDTH = (c_ADDR_WIDTH <= 8) ? (c_WR_BYTE_WIDTH == 8 ? ( (c_ADDR_STROBE_EN == 1) ? 16 : 32 ) : 
                                                                              ( (c_ADDR_STROBE_EN == 1) ? 18 : 36 ) ) : 
                                                      (c_WR_BYTE_WIDTH == 8 ? 16 : 18);

localparam  L_BYTE_DATA_WIDTH = (c_WR_BYTE_WIDTH == 8) ? (c_DATA_WIDTH <= 16 ? 16 : 
                                                                               ( (c_ADDR_STROBE_EN == 1) ? 16 : 32 ) ) : 
                                                         (c_DATA_WIDTH <= 18 ? 18 : 
                                                                               ( (c_ADDR_STROBE_EN == 1) ? 18 : 36 ) );

//DRM_DATA_WIDTH is the  port parameter  of DRM
localparam  DRM_DATA_WIDTH  = (c_POWER_OPT == 1) ? (c_WR_BYTE_EN ==1 ? L_BYTE_DATA_WIDTH : L_DATA_WIDTH):
                                                   (c_WR_BYTE_EN ==1 ? N_BYTE_DATA_WIDTH : N_DATA_WIDTH);

localparam  DATA_LOOP_NUM  = (c_DATA_WIDTH%DRM_DATA_WIDTH == 0) ? (c_DATA_WIDTH/DRM_DATA_WIDTH):(c_DATA_WIDTH/DRM_DATA_WIDTH + 1);

localparam  Q_DATA_WIDTH  = (DRM_DATA_WIDTH == 36) ? 18 : (DRM_DATA_WIDTH == 32) ? 16 : DRM_DATA_WIDTH;
//DRM_ADDR_WIDTH is the ADDR_WIDTH of INSTANCE DRM primitives 
localparam  DRM_ADDR_WIDTH = DRM_DATA_WIDTH == 1  ? 14:
                             DRM_DATA_WIDTH == 2  ? 13:
                             DRM_DATA_WIDTH == 4  ? 12:
                             DRM_DATA_WIDTH == 8  ? 11:
                             DRM_DATA_WIDTH == 9  ? 11:
                             DRM_DATA_WIDTH == 16 ? 10:
                             DRM_DATA_WIDTH == 18 ? 10:
                             DRM_DATA_WIDTH == 32 ?  9:
                                                     9;

localparam  ADDR_WIDTH  = c_ADDR_WIDTH > DRM_ADDR_WIDTH ? c_ADDR_WIDTH : DRM_ADDR_WIDTH;
//CS_ADDR_WIDTH is the CS address width to choose the DRM18K CS_ADDR_WIDTH=  [ extra-addres + cs[2]+csp[1]+cs[0] ]
localparam  CS_ADDR_WIDTH  = ADDR_WIDTH - DRM_ADDR_WIDTH;

//ADDR_LOOP_NUM difine how many loops to cascade the c_ADDR_WIDTH
localparam  ADDR_LOOP_NUM  = 2**CS_ADDR_WIDTH;
//CAS_DATA_WIDTH is the cascaded  data width 
localparam  CAS_DATA_WIDTH   =  DRM_DATA_WIDTH*DATA_LOOP_NUM;
localparam  Q_CAS_DATA_WIDTH =  Q_DATA_WIDTH*DATA_LOOP_NUM;

localparam  WR_BYTE_WIDTH    =  c_WR_BYTE_EN == 1 ? c_WR_BYTE_WIDTH :
                             ( (DRM_DATA_WIDTH >=8 || DRM_DATA_WIDTH >=9 ) ? ((c_DATA_WIDTH%9 == 0) ? 9 : 8 ) : 1 );

//MASK_NUM the mask base value 
localparam  MASK_NUM  = ( DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH == 32 ) ? (ADDR_LOOP_NUM > 4 ? 2 : 4 ):
                        ( ADDR_LOOP_NUM >8 ) ? (( DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH == 32 ) ? 2 : 4) : 8;

localparam c_RST_TYPE = (c_RESET_TYPE == "SYNC_RESET") ? "SYNC" : ((c_RESET_TYPE == "ASYNC_RESET") ?  "ASYNC" : "ASYNC_SYNC_RELEASE");      

//parameter  check
initial begin
   if(c_ADDR_WIDTH>20 || c_ADDR_WIDTH<8 ) begin
      $display("IPSpecCheck: 01030300 ipml_flex_spram parameter setting error !!!: c_ADDR_WIDTH must between 8-20")/* PANGO PAP_CRITICAL_WARNING */;
      //$finish;
   end 
   else if( c_DATA_WIDTH>1152 || c_DATA_WIDTH<1 ) begin
      $display("IPSpecCheck: 01030301 ipml_flex_spram parameter setting error !!!: c_DATA_WIDTH must between 1-1152")/* PANGO PAP_CRITICAL_WARNING */;
      //$finish;
   end
   else if(c_OUTPUT_REG!=1 && c_OUTPUT_REG!=0 ) begin
      $display("IPSpecCheck: 01030303 ipml_flex_spram parameter setting error !!!: c_OUTPUT_REG must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_RD_OCE_EN!=0 && c_RD_OCE_EN!=1 ) begin
      $display("IPSpecCheck: 01030304 ipml_flex_spram parameter setting error !!!: c_RD_OCE_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_CLK_OR_POL_INV!=0 && c_CLK_OR_POL_INV!=1 ) begin
      $display("IPSpecCheck: 01030305 ipml_flex_spram parameter setting error !!!: c_CLK_OR_POL_INV must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_RD_OCE_EN==1 && c_OUTPUT_REG==0 ) begin
      $display("IPSpecCheck: 01030306 ipml_flex_spram parameter setting error !!!: c_OUTPUT_REG must be 1 when c_RD_OCE_EN is 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_CLK_OR_POL_INV==1 && c_OUTPUT_REG==0 ) begin
      $display("IPSpecCheck: 01030307 ipml_flex_spram parameter setting error !!!: c_OUTPUT_REG must be 1 when c_CLK_OR_POL_INV is 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_CLK_EN!=0 && c_CLK_EN!=1 ) begin
      $display("IPSpecCheck: 01030308 ipml_flex_spram parameter setting error !!!: c_CLK_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_ADDR_STROBE_EN!=0 && c_ADDR_STROBE_EN!=1 ) begin
      $display("IPSpecCheck: 01030309 ipml_flex_spram parameter setting error !!!: c_ADDR_STROBE_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if ( c_SIM_DEVICE=="PGL22G" && (c_CLK_EN==1 && c_ADDR_STROBE_EN==1) ) begin
      $display("IPSpecCheck: 01030310 ipml_flex_spram parameter setting error !!!: Clock Enable and Address Strobe only works individually when using PGL22G")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if(c_RST_TYPE!="ASYNC" && c_RST_TYPE!="SYNC" && c_RST_TYPE!="ASYNC_SYNC_RELEASE") begin
      $display("IPSpecCheck: 01030011 ipml_flex_spram parameter setting error !!!: c_RESET_TYPE must be ASYNC or SYNC or ASYNC_SYNC_RELEASE")/* PANGO PAP_ERROR */;
      $finish;
   end 
   else if(c_POWER_OPT!=1 && c_POWER_OPT!=0 ) begin
      $display("IPSpecCheck: 01030312 ipml_flex_spram parameter setting error !!!: c_POWER_OPT must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if(c_INIT_FORMAT!="BIN" && c_INIT_FORMAT!="HEX" ) begin
      $display("IPSpecCheck: 01030313 ipml_flex_spram parameter setting error !!!: c_INIT_FORMAT must be bin or hex ")/* PANGO PAP_ERROR */;
      $finish;
   end 
   else if(c_WR_BYTE_EN!=0 && c_WR_BYTE_EN!=1 ) begin
      $display("IPSpecCheck: 01030314 ipml_flex_spram parameter setting error !!!: c_WR_BYTE_EN must be 0 or 1")/* PANGO PAP_ERROR */;
      $finish;
   end
   else if(c_WR_BYTE_EN==1) begin
      if(c_WR_BYTE_WIDTH!=8 &&  c_WR_BYTE_WIDTH!=9 ) begin
         $display("IPSpecCheck: 01030315 ipml_flex_spram parameter setting error !!!: c_WR_BYTE_WIDTH must be 8 or 9")/* PANGO PAP_ERROR */;
         $finish;
      end
      if( (c_DATA_WIDTH%8)!=0 && (c_DATA_WIDTH%9)!=0 ) begin
         $display("IPSpecCheck: 01030316 ipml_flex_spram parameter setting error !!!: c_DATA_WIDTH must be 8*N or 9*N")/* PANGO PAP_ERROR */;
         $finish;
      end	
   end
   else if(c_WRITE_MODE!="NORMAL_WRITE" && c_WRITE_MODE!="TRANSPARENT_WRITE" && c_WRITE_MODE!="READ_BEFORE_WRITE") begin
         $display("IPSpecCheck: 01030317 ipml_flex_spram parameter setting error !!!: c_WRITE_MODE must be NORMAL_WRITE or TRANSPARENT_WRITE or READ_BEFORE_WRITE")/* PANGO PAP_ERROR */;
         $finish;
   end
//   else if ( (c_POWER_OPT==0 && c_ADDR_WIDTH<=9 && c_WRITE_MODE!="NORMAL_WRITE") || (c_POWER_OPT==1 && c_DATA_WIDTH>=16 && c_WRITE_MODE!="NORMAL_WRITE") ) begin
//      $display("IPSpecCheck: 01030318 ipml_flex_spram parameter setting error !!!: Only works in NORMAL_WRITE when c_POWER_OPT==0 and c_ADDR_WIDTH<=9 or c_POWER_OPT==1 and c_DATA_WIDTH>=16")/* PANGO PAP_ERROR */;
//      $finish;
//   end
   else if ( c_WR_BYTE_EN==1 && c_ADDR_STROBE_EN==1 ) begin
      $display("IPSpecCheck: 01030319 ipml_flex_spram parameter setting error !!!: When Byte Write, disable Address Strobe")/* PANGO PAP_ERROR */;
      $finish;
   end
end
//main code
//********************************************************************************************************************************************************
//inner variables

wire [CAS_DATA_WIDTH-1:0]                  wr_data_bus   ;
reg  [Q_CAS_DATA_WIDTH-1:0]                da_data_bus   ;        //the data bus of data_cascaded instance DRM
wire [Q_CAS_DATA_WIDTH*ADDR_LOOP_NUM-1:0]  qa_data_bus   ;        //the total data width of instance DRM
wire [ADDR_WIDTH-1:0]                      addr_bus      ;
reg  [DATA_LOOP_NUM*14-1:0]                drm_addr      ;        //write address to all instance DRM
reg                                        cs_bit0       ;        //write cs[0]  to all instance DRM
reg  [ADDR_LOOP_NUM-1:0]                   cs_bit1_bus   ;        //write cs[1]  to all instance DRM
reg  [ADDR_LOOP_NUM-1:0]                   cs_bit2_bus   ;        //write cs[2] bus  to every data_cascaded DRM-block
reg                                        cs_bit0_ff    ;
reg  [ADDR_LOOP_NUM-1:0]                   cs_bit1_bus_ff;
reg  [ADDR_LOOP_NUM-1:0]                   cs_bit2_bus_ff;
wire                                       cs_bit0_m     ;
wire [ADDR_LOOP_NUM-1:0]                   cs_bit1_bus_m ;
wire [ADDR_LOOP_NUM-1:0]                   cs_bit2_bus_m ;

wire                                       wr_en_b       ;
wire                                       clk_en_b      ;
reg  [CAS_DATA_WIDTH*ADDR_LOOP_NUM-1:0]    rd_data_bus   ;
reg  [Q_CAS_DATA_WIDTH-1:0]                db_data_bus   ;        //the data bus of data_cascaded instance DRM
wire [Q_CAS_DATA_WIDTH*ADDR_LOOP_NUM-1:0]  qb_data_bus   ;        //the total data width of instance DRM
reg  [DATA_LOOP_NUM*14-1:0]                drm_b_addr    ;
reg                                        csb_bit0      ;        //write cs[0]  to all instance DRM
reg  [ADDR_LOOP_NUM-1:0]                   csb_bit1_bus  ;        //write cs[1]  to all instance DRM
reg  [ADDR_LOOP_NUM-1:0]                   csb_bit2_bus  ;        //write cs[2] bus  to every data_cascaded DRM-block
wire                                       csb_bit0_m     ;
wire [ADDR_LOOP_NUM-1:0]                   csb_bit1_bus_m ;
wire [ADDR_LOOP_NUM-1:0]                   csb_bit2_bus_m ;
wire [ADDR_LOOP_NUM-1:0]                   cs2_ctrl       ;

//byte enable 
wire [CAS_DATA_WIDTH/WR_BYTE_WIDTH-1 : 0]  wr_byte_en_bus;
//********************************************************************************************************************************************************
//write data mux 
assign  wr_data_bus[CAS_DATA_WIDTH-1:0] = {{(CAS_DATA_WIDTH-c_DATA_WIDTH){1'b0}},wr_data[c_DATA_WIDTH-1:0]};

assign  addr_bus[ADDR_WIDTH-1:0] = {{(ADDR_WIDTH-c_ADDR_WIDTH){1'b0}},addr[c_ADDR_WIDTH-1:0]};
  //drive wr_byte_en_bus 
assign  wr_byte_en_bus = (c_WR_BYTE_EN == 0) ? -1 : {{(CAS_DATA_WIDTH/WR_BYTE_WIDTH-c_DATA_WIDTH/WR_BYTE_WIDTH){1'b0}},wr_byte_en[c_BE_WIDTH-1:0]};

//generate drm_addr connect to the instance DRM directly ,based on DRM_DATA_WIDTH
integer gen_wa;
always@(*) begin
   for(gen_wa=0;gen_wa < DATA_LOOP_NUM;gen_wa = gen_wa +1 ) begin
      case(DRM_DATA_WIDTH)
         1     : begin
                     drm_addr[gen_wa*14 +: 14]   = addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0];
                     drm_b_addr[gen_wa*14 +: 14] = addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0];
                 end
         2     : begin
                     drm_addr[gen_wa*14 +: 14]   = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],1'b0};
                     drm_b_addr[gen_wa*14 +: 14] = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],1'b0};
                 end
         4     : begin
                     drm_addr[gen_wa*14 +: 14]   = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],2'b00};
                     drm_b_addr[gen_wa*14 +: 14] = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],2'b00};
                 end
         8,9   : begin
                     drm_addr[gen_wa*14 +: 14]   = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],3'b000};
                     drm_b_addr[gen_wa*14 +: 14] = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],3'b000};
                 end
         16,18 : begin
                     drm_addr[gen_wa*14 +: 14]   = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],2'b00,wr_byte_en_bus[gen_wa*2 +: 2]};
                     drm_b_addr[gen_wa*14 +: 14] = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],4'b0000};
                 end
         32,36 : begin
                     if ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE"))
                     begin
                         drm_addr[gen_wa*14 +: 14]   = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],3'b000,wr_byte_en_bus[gen_wa*4 +: 2]};
                         drm_b_addr[gen_wa*14 +: 14] = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],3'b100,wr_byte_en_bus[gen_wa*4+2 +: 2]};
                     end
                     else
                     begin
                         drm_addr[gen_wa*14 +: 14]   = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],1'b0,wr_byte_en_bus[gen_wa*4 +: 4]};
                         drm_b_addr[gen_wa*14 +: 14] = {addr_bus[(ADDR_WIDTH-CS_ADDR_WIDTH-1):0],1'b0,wr_byte_en_bus[gen_wa*4 +: 4]};
                     end
                 end
         default: begin
                      drm_addr[gen_wa*14 +: 14]   = 14'b0;
                      drm_b_addr[gen_wa*14 +: 14] = 14'b0;
                  end
      endcase
   end 
end

localparam  CS_ADDR_3_LSB = (CS_ADDR_WIDTH >= 3) ? (ADDR_WIDTH-CS_ADDR_WIDTH+1) : (ADDR_WIDTH-2);  //avoid reveral index of wr_addr_bus
localparam  CS_ADDR_4_LSB = (CS_ADDR_WIDTH >= 4) ? (ADDR_WIDTH-1-CS_ADDR_WIDTH+3) : (ADDR_WIDTH-2); //avoid reveral index of wr_addr_bus

//generate  CS control signal
integer gen_m;
always@(*) begin
   for(gen_m=0;gen_m<ADDR_LOOP_NUM;gen_m=gen_m+1) begin
      if(DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH == 32) begin
         if(CS_ADDR_WIDTH == 0) begin
            cs_bit0 = 0;
            cs_bit1_bus[gen_m] = 0;
            if ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE"))
                cs_bit2_bus[gen_m] = 1'b1;
            else
                cs_bit2_bus[gen_m] = 1'b0;
         end
         else if(CS_ADDR_WIDTH == 1) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];
            cs_bit1_bus[gen_m] = 0;
            if ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE"))
                cs_bit2_bus[gen_m] = 1'b1;
            else
                cs_bit2_bus[gen_m] = 1'b0;
         end 
         else if(CS_ADDR_WIDTH == 2) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];
            cs_bit1_bus[gen_m] = addr_bus[ADDR_WIDTH-1];
            if ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE"))
                cs_bit2_bus[gen_m] = 1'b1;
            else
                cs_bit2_bus[gen_m] = 1'b0;
         end
         else if(CS_ADDR_WIDTH >= 3) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];
            cs_bit1_bus[gen_m] = (addr_bus[(ADDR_WIDTH-1):CS_ADDR_3_LSB] == (gen_m/2)) ? 0:1;
            if ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE"))
                cs_bit2_bus[gen_m] = 1'b1;
            else
                cs_bit2_bus[gen_m] = 1'b0;
         end
      end 
      else begin
         if(CS_ADDR_WIDTH == 0) begin
            cs_bit0 = 0;
            cs_bit1_bus[gen_m] = 0;
            cs_bit2_bus[gen_m] = 0;
         end 
         else if(CS_ADDR_WIDTH == 1) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];
            cs_bit1_bus[gen_m] = 0;
            cs_bit2_bus[gen_m] = 0;
         end 
         else if(CS_ADDR_WIDTH == 2) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-2];
            cs_bit1_bus[gen_m] = addr_bus[ADDR_WIDTH-1];
            cs_bit2_bus[gen_m] = 0;
         end 
         else if(CS_ADDR_WIDTH == 3) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-3];
            cs_bit1_bus[gen_m] = addr_bus[ADDR_WIDTH-2];
            cs_bit2_bus[gen_m] = addr_bus[ADDR_WIDTH-1];
         end 
         else if(CS_ADDR_WIDTH >= 4) begin
            cs_bit0 = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH];
            cs_bit1_bus[gen_m] = addr_bus[ADDR_WIDTH-CS_ADDR_WIDTH+1];
            cs_bit2_bus[gen_m] = (addr_bus[(ADDR_WIDTH-1):CS_ADDR_4_LSB] == (gen_m/4)) ? 0 : 1;
         end 
      end
   end
end

//B port CS
always@(*) begin
   if(DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH == 32)
      csb_bit0 = cs_bit0 ;
   else
      csb_bit0 = 0;
end

always@(*) begin
   if(DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH == 32)
      csb_bit1_bus = cs_bit1_bus ;
   else
      csb_bit1_bus = 'b0;
end

always@(*) begin
   if(DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH == 32) begin
      if ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE"))
          csb_bit2_bus = cs_bit2_bus;
      else
          csb_bit2_bus = cs_bit2_bus & (~wr_en) ;
   end
   else
      csb_bit2_bus = 'b0;
end

always @(posedge clk or posedge rst)
begin
    if (rst) begin
        cs_bit0_ff     <= 0;
        cs_bit1_bus_ff <= 0;
        cs_bit2_bus_ff <= 0;
    end
    else if(~addr_strobe) begin
        cs_bit0_ff     <= cs_bit0;
        cs_bit1_bus_ff <= cs_bit1_bus;
        cs_bit2_bus_ff <= cs_bit2_bus;
    end
end

assign cs_bit0_m     = (c_SIM_DEVICE == "PGL22G") ? (addr_strobe ? cs_bit0_ff     : cs_bit0    ) : cs_bit0;
assign cs_bit1_bus_m = (c_SIM_DEVICE == "PGL22G") ? (addr_strobe ? cs_bit1_bus_ff : cs_bit1_bus) : cs_bit1_bus;
assign cs_bit2_bus_m = (c_SIM_DEVICE == "PGL22G") ? (addr_strobe ? cs_bit2_bus_ff : cs_bit2_bus) : cs_bit2_bus;

assign csb_bit0_m     = cs_bit0_m;
assign csb_bit1_bus_m = cs_bit1_bus_m;
assign csb_bit2_bus_m = cs_bit2_bus_m;

wire [18*DATA_LOOP_NUM*ADDR_LOOP_NUM-1:0]  QA_bus;
wire [18*DATA_LOOP_NUM*ADDR_LOOP_NUM-1:0]  QB_bus;
wire [18*DATA_LOOP_NUM-1:0]                DA_bus;
wire [18*DATA_LOOP_NUM-1:0]                DB_bus;

integer  drm_d_i;
always@(*) begin
   for (drm_d_i = 0; drm_d_i <DATA_LOOP_NUM; drm_d_i = drm_d_i+1) begin
      db_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] = 'b0;
      da_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] = 'b0;
      if(DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH == 32)
         {db_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] ,da_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH]} = wr_data_bus[drm_d_i*DRM_DATA_WIDTH +:DRM_DATA_WIDTH];
      else begin
         da_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] = wr_data_bus[drm_d_i*DRM_DATA_WIDTH +:DRM_DATA_WIDTH];
         db_data_bus[drm_d_i*Q_DATA_WIDTH +:Q_DATA_WIDTH] = 'b0;
      end
   end 
end

localparam RAM_MODE_SEL       = (c_RAM_MODE == "ROM") ? "ROM"
                                                      : ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE")) ? "TRUE_DUAL_PORT"   : "SINGLE_PORT";
localparam DRM_DATA_WIDTH_SEL = (c_RAM_MODE == "ROM") ? DRM_DATA_WIDTH
                                                      : ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE")) ? (DRM_DATA_WIDTH/2) : DRM_DATA_WIDTH;

//generate constructs: ADDR_LOOP to cascade request address  and  DATA LOOP to cascade request data 
genvar gen_i,gen_j;
generate 
  for(gen_j=0;gen_j<ADDR_LOOP_NUM;gen_j=gen_j+1) begin:ADDR_LOOP 
     for(gen_i=0;gen_i<DATA_LOOP_NUM;gen_i=gen_i+1) begin:DATA_LOOP
        localparam [2:0] CSA_MASK     = ( DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH == 32 ) ? (gen_j%MASK_NUM & 3'b011) : (gen_j%MASK_NUM);
        localparam [2:0] CSB_MASK     = ( DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH == 32 ) ? (gen_j%MASK_NUM & 3'b011) : (gen_j%MASK_NUM);
        localparam [2:0] CSA_MASK_SEL = ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE")) ? (3'b100 | gen_j%MASK_NUM) : CSA_MASK;
        localparam [2:0] CSB_MASK_SEL = ((DRM_DATA_WIDTH > 18) && (c_WRITE_MODE != "NORMAL_WRITE")) ? (3'b100 | gen_j%MASK_NUM) : CSB_MASK;

     //write data
        if( Q_DATA_WIDTH == 16 ) begin
           assign  qa_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH] = {QA_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM+9) +:8],QA_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:8]};
           assign  {DA_bus[(gen_i*18+9) +:8 ],DA_bus[gen_i*18 +:8]} = da_data_bus[gen_i*Q_DATA_WIDTH +:Q_DATA_WIDTH];
        end
        else begin
           assign  qa_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH] = QA_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:Q_DATA_WIDTH];
           assign  DA_bus[gen_i*18 +:Q_DATA_WIDTH] = da_data_bus[gen_i*Q_DATA_WIDTH +:Q_DATA_WIDTH];
        end

        if( Q_DATA_WIDTH == 16 ) begin
           assign  qb_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH] = {QB_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM+9) +:8],QB_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:8]};
           assign  {DB_bus[(gen_i*18+9) +:8],DB_bus[gen_i*18 +:8]} = db_data_bus[gen_i*Q_DATA_WIDTH +:Q_DATA_WIDTH];
        end
        else begin
           assign  qb_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH] = QB_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:Q_DATA_WIDTH];
           assign  DB_bus[gen_i*18 +:Q_DATA_WIDTH] = db_data_bus[gen_i*Q_DATA_WIDTH +:Q_DATA_WIDTH];
        end 

        assign wr_en_b  = (DRM_DATA_WIDTH <= 18) ? 1'b0 : (c_WRITE_MODE == "NORMAL_WRITE") ? 1'b0 : wr_en;
        assign clk_en_b = (DRM_DATA_WIDTH <= 18) ? 1'b0 : (c_WRITE_MODE == "NORMAL_WRITE") ? ~wr_en & clk_en : clk_en;

        GTP_DRM18K # (
        
                 .GRS_EN                   ( "FALSE"                  ),
                 .SIM_DEVICE               ( c_SIM_DEVICE             ),
                 .CSA_MASK                 ( CSA_MASK_SEL             ),
                 .CSB_MASK                 ( CSB_MASK_SEL             ),  
                 .DATA_WIDTH_A             ( DRM_DATA_WIDTH_SEL       ),    // 1 2 4 8 16 9 18 
                 .DATA_WIDTH_B             ( DRM_DATA_WIDTH_SEL       ),    // 1 2 4 8 16 9 18                     
                 .WRITE_MODE_A             ( c_WRITE_MODE             ),
                 .WRITE_MODE_B             ( c_WRITE_MODE             ),   
                 .DOA_REG                  ( c_OUTPUT_REG             ),
                 .DOB_REG                  ( c_OUTPUT_REG             ),
                 .DOA_REG_CLKINV           ( c_CLK_OR_POL_INV         ),
                 .DOB_REG_CLKINV           ( c_CLK_OR_POL_INV         ),
                 .RST_TYPE                 ( c_RST_TYPE               ),    // ASYNC_RESET_SYNC_RELEASE SYNC_RESET
                 .RAM_MODE                 ( RAM_MODE_SEL             ),    // TRUE_DUAL_PORT                   
                 .INIT_FILE                ( c_INIT_FILE              ),                 
                 .BLOCK_X                  ( gen_i                    ),
                 .BLOCK_Y                  ( gen_j                    ),
                 .RAM_ADDR_WIDTH           ( ADDR_WIDTH               ),
                 .RAM_DATA_WIDTH           ( CAS_DATA_WIDTH           ),
                 .INIT_FORMAT              ( c_INIT_FORMAT            )    //binary or hex       
        ) U_GTP_DRM18K (
                .DOA(QA_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:18]),
                .ADDRA(drm_addr[gen_i*14 +: 14]),            //wr_addr[13:0]
                .ADDRA_HOLD(addr_strobe),
                .DIA(DA_bus[gen_i*18 +:18]),
                .CSA({cs_bit2_bus_m[gen_j],cs_bit1_bus_m[gen_j],cs_bit0_m}),
                .WEA(wr_en),
                .CLKA(clk),
                .CEA(clk_en),
                .ORCEA(rd_oce),
                .RSTA(rst),

                .DOB(QB_bus[(gen_i*18+gen_j*18*DATA_LOOP_NUM) +:18]),
                .ADDRB(drm_b_addr[gen_i*14 +: 14]),             //rd_addr[13:0]
                .ADDRB_HOLD(addr_strobe),
                .DIB(DB_bus[gen_i*18 +:18]),
                .CSB({csb_bit2_bus_m[gen_j],csb_bit1_bus_m[gen_j],csb_bit0_m}),
                .WEB(wr_en_b),
                .CLKB(clk),
                .CEB(clk_en_b),
                .ORCEB(rd_oce),
                .RSTB(rst)
       );

        //rd_data_bus 
        always@(*)
        begin
           if(DRM_DATA_WIDTH == 36 || DRM_DATA_WIDTH ==32)
              rd_data_bus[gen_i*DRM_DATA_WIDTH+gen_j*CAS_DATA_WIDTH +:DRM_DATA_WIDTH] = {qb_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH] ,qa_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH]};
           else
              rd_data_bus[gen_i*DRM_DATA_WIDTH+gen_j*CAS_DATA_WIDTH +:DRM_DATA_WIDTH] = qa_data_bus[gen_i*Q_DATA_WIDTH+gen_j*Q_CAS_DATA_WIDTH +:Q_DATA_WIDTH];
        end 
     end 
  end 
endgenerate

//rd_data: extra mux combination  logic
localparam   ADDR_SEL_LSB = (CS_ADDR_WIDTH > 0) ? (ADDR_WIDTH - CS_ADDR_WIDTH) : (ADDR_WIDTH - 1);

wire [CS_ADDR_WIDTH-1:0]   addr_bus_rd_sel;
reg  [CS_ADDR_WIDTH-1:0]   addr_bus_rd_ce;
reg  [CS_ADDR_WIDTH-1:0]   addr_bus_rd_ce_ff;
wire [CS_ADDR_WIDTH-1:0]   addr_bus_rd_ce_mux;
reg  [CS_ADDR_WIDTH-1:0]   addr_bus_rd_oce;
reg  [CS_ADDR_WIDTH-1:0]   addr_bus_rd_invt;
reg  [CAS_DATA_WIDTH-1:0]  rd_full_data;

reg     wr_en_ff;

//CE
always @(posedge clk or posedge rst)
begin
    if (rst)
        addr_bus_rd_ce <= 0;
    else if (~addr_strobe & clk_en)
        addr_bus_rd_ce <= addr_bus[ADDR_WIDTH-1:ADDR_SEL_LSB];
end

always @(posedge clk or posedge rst)
begin
    if (rst)
        wr_en_ff <= 1'b0;
    else if (clk_en)
        wr_en_ff <= wr_en;
end

always @(posedge clk or posedge rst)
begin
    if (rst)
        addr_bus_rd_ce_ff   <= 0;
    else if (~wr_en_ff)
        addr_bus_rd_ce_ff   <= addr_bus_rd_ce;
end

assign addr_bus_rd_ce_mux = (c_WRITE_MODE != "NORMAL_WRITE") ? addr_bus_rd_ce : wr_en_ff ? addr_bus_rd_ce_ff : addr_bus_rd_ce;

//OCE
always @(posedge clk or posedge rst)
begin
    if (rst)
        addr_bus_rd_oce <= 0;
    else if (rd_oce)
        addr_bus_rd_oce <= addr_bus_rd_ce_mux;
end

//INVT
always @(negedge clk or posedge rst)
begin
    if (rst)
        addr_bus_rd_invt <= 0;
    else if (rd_oce)
        addr_bus_rd_invt <= addr_bus_rd_ce_mux;
end

assign  addr_bus_rd_sel = (c_CLK_OR_POL_INV == 1) ? addr_bus_rd_invt : (c_OUTPUT_REG == 1) ? addr_bus_rd_oce : addr_bus_rd_ce_mux;

integer n;
always@(*)
begin
   rd_full_data = 0;
   if(ADDR_LOOP_NUM>1) begin 
      for(n=0;n<ADDR_LOOP_NUM;n=n+1) begin
         if(addr_bus_rd_sel == n)
            rd_full_data = rd_data_bus[n*CAS_DATA_WIDTH +: CAS_DATA_WIDTH];
      end
   end
   else begin
      rd_full_data = rd_data_bus;
   end
end

assign  rd_data = rd_full_data[c_DATA_WIDTH-1:0];


endmodule
