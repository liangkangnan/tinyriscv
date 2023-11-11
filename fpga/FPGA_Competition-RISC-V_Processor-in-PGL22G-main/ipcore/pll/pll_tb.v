// Created by IP Generator (Version 2022.1 build 99559)


   
//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//               
// Library:
// Filename:pll.v                 
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns/1 ps

module pll_tb ();

localparam CLKIN_FREQ = 50.0;
localparam integer FBDIV_SEL = 0;
localparam FBMODE = "FALSE";


// Generate testbench reset and clock
reg pll_rst;
reg rstodiv;
reg pll_pwd;
reg clkin1;
reg clkin2;
reg clkin_dsel;
reg clkin_dsel_en;
reg pfden;
reg clkout0_gate;
reg clkout0_2pad_gate;
reg clkout1_gate;
reg clkout2_gate;
reg clkout3_gate;
reg clkout4_gate;
reg clkout5_gate;
reg [9:0] dyn_idiv;
reg [9:0] dyn_odiv0;
reg [9:0] dyn_odiv1;
reg [9:0] dyn_odiv2;
reg [9:0] dyn_odiv3;
reg [9:0] dyn_odiv4;
reg [9:0] dyn_fdiv;
reg [9:0] dyn_duty0;
reg [9:0] dyn_duty1;
reg [9:0] dyn_duty2;
reg [9:0] dyn_duty3;
reg [9:0] dyn_duty4;
reg [12:0] dyn_phase0;
reg [12:0] dyn_phase1;
reg [12:0] dyn_phase2;
reg [12:0] dyn_phase3;
reg [12:0] dyn_phase4;
reg            err_chk;
reg   [2:0]    results_cnt; 

reg rst_n;
reg clk_tb;

wire clkout0;
wire clkout1;
wire clkout2;
wire clkout3;
wire clkout4;
wire clkfb = (FBMODE    == "FALSE") ? clkin1  : 
             (FBDIV_SEL == 0      ) ? clkout0 :
             (FBDIV_SEL == 1      ) ? clkout1 :
             (FBDIV_SEL == 2      ) ? clkout2 :
             (FBDIV_SEL == 3      ) ? clkout3 :
             (FBDIV_SEL == 4      ) ? clkout4 : clkin1;
    

initial
begin
    rst_n = 0;
    #20
    rst_n = 1;
end

initial
begin
    clk_tb = 0;
    forever #1 clk_tb = ~clk_tb;
end

parameter CLOCK_PERIOD1 = (500.0/CLKIN_FREQ);
//parameter CLOCK_PERIOD2 = (500.0/CLKIN_FREQ);

initial
begin
    clkin1 = 0;
    forever #(CLOCK_PERIOD1) clkin1 = ~clkin1;
end


initial
begin
    pll_pwd = 0;
    pll_rst = 0;
    rstodiv = 0;
    clkin_dsel = 0;
    clkin_dsel_en = 0;
    pfden = 0;
    clkout0_gate = 0;
    clkout0_2pad_gate = 0;
    clkout1_gate = 0;
    clkout2_gate = 0;
    clkout3_gate = 0;
    clkout4_gate = 0;
    clkout5_gate = 0;
    dyn_idiv = 10'd2;
    dyn_fdiv = 10'd32;
    dyn_odiv0 = 10'd100;
    dyn_odiv1 = 10'd100;
    dyn_odiv2 = 10'd100;
    dyn_odiv3 = 10'd100;
    dyn_odiv4 = 10'd100;
    dyn_duty0 = 10'd100;
    dyn_duty1 = 10'd100;
    dyn_duty2 = 10'd100;
    dyn_duty3 = 10'd100;
    dyn_duty4 = 10'd100;
    dyn_phase0 = 13'd16;
    dyn_phase1 = 13'd16; 
    dyn_phase2 = 13'd16;
    dyn_phase3 = 13'd16;
    dyn_phase4 = 13'd16;

    #10
    pll_pwd = 1;
    #20
    pll_pwd = 0;

    pll_rst = 0;
    #10
    pll_rst = 1;
    #20
    pll_rst = 0;

    #1000000
    dyn_odiv0 = 10'd200;
    dyn_odiv1 = 10'd200;
    dyn_odiv2 = 10'd200;
    dyn_odiv3 = 10'd200;
    dyn_odiv4 = 10'd200;
    dyn_duty0 = 10'd200;
    dyn_duty1 = 10'd200;
    dyn_duty2 = 10'd200;
    dyn_duty3 = 10'd200;
    dyn_duty4 = 10'd200;
    #3000000
    $finish;
end

initial
begin
   $display("Simulation Starts.") ;
   $display("Simulation is done.") ;
   if (|results_cnt)
       $display("Simulation Failed due to Error Found.") ;
   else
       $display("Simulation Success.") ;
end


GTP_GRS GRS_INST(
  .GRS_N(1'b1)
 );

pll U_pll (
.clkout0(clkout0),
    .clkout1(clkout1),
    
    .clkin1(clkin1),
    
    .pll_lock(pll_lock)
    );


//******************Results Cheching************************

reg [2:0] pll_lock_shift;
wire      pll_lock_pulse = ~pll_lock_shift[2] & pll_lock_shift[1];
always @( posedge clk_tb or negedge rst_n )
begin
    if (!rst_n)
    begin
        pll_lock_shift <= 3'd0;
    end
    else
    begin
        pll_lock_shift[0]   <= pll_lock;
        pll_lock_shift[2:1] <= pll_lock_shift[1:0];
    end
end

reg [1:0] pll_lock_pulse_cnt;
always @( posedge clk_tb or negedge rst_n )
begin
    if (!rst_n)
    begin
        pll_lock_pulse_cnt <= 2'd0;
    end
    else
    begin
        if (pll_lock_pulse)
            pll_lock_pulse_cnt <= pll_lock_pulse_cnt + 1;
        else ;
    end
end


always @( posedge clk_tb or negedge rst_n )
begin
    if (!rst_n)
    begin
        err_chk <= 1'b0;
    end
    else
    begin
        if ((!pll_lock) && (^pll_lock_pulse_cnt))
            err_chk <= 1'b1;
        else if (pll_lock_pulse_cnt[1])
            err_chk <= 1'b1;
        else
            err_chk <= 1'b0;
    end
end
always @(posedge clk_tb or negedge rst_n)
begin
    if (!rst_n)
        results_cnt <= 3'b000 ;
    else if (&results_cnt)
        results_cnt <= 3'b100 ;
    else if (err_chk)
        results_cnt <= results_cnt + 3'd1 ;
end


integer  result_fid;
initial begin
   result_fid = $fopen ("sim_results.log","a");   
   $fmonitor(result_fid,"err_chk=%b", err_chk);
end

endmodule
