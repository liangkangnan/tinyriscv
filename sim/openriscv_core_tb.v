`timescale 1 ns / 1 ps

`include "defines.v"

// top module
module openriscv_core_tb;

    reg clk;
    reg rst;

    always #10 clk = ~clk;     // 50MHz

    wire[`RegBus] x3 = u_openriscv_core.u_regs.regs[3];
    wire[`RegBus] x26 = u_openriscv_core.u_regs.regs[26];
    wire[`RegBus] x27 = u_openriscv_core.u_regs.regs[27];

    integer r;
    initial begin
        clk = 0;
        rst = `RstEnable;
        $display("test running...");
        #40
        rst = `RstDisable;
        #100
        wait(x26 == 32'b1)   // wait sim end, when x26 == 1
        #100
        if (x27 == 32'b1) begin
            $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
            $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        end else begin
            $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("fail testnum = %2d", x3);
            for (r = 0; r < 32; r++)
                $display("x%2d = 0x%x", r, u_openriscv_core.u_regs.regs[r]);
        end
        $finish;
    end

    // sim timeout
    initial begin
        #100000
        $display("Time Out.");
        $finish;
    end

    // read mem data
    initial begin
        $readmemh ("inst.data", u_openriscv_core.u_sim_ram.ram);
    end

    // generate wave file, use by gtkwave
    initial begin
        $dumpfile("openriscv_core_tb.vcd");
        $dumpvars(0, openriscv_core_tb);
    end

    openriscv_core u_openriscv_core(
        .clk(clk),
        .rst(rst)
    );

endmodule
