module tb_mod3_mealy;
    logic clk = 0, rst_n, in, out;

    mod3_mealy dut (
        .clk(clk), 
        .rst_n(rst_n), 
        .in(in), 
        .out(out)
    );

    always #5 clk = ~clk;

    task automatic send_bit(input logic b, input logic expect_out);
        in = b;
        #1;
        if (out !== expect_out)
            $display("[FAIL] bit=%0b out=%0b expected=%0b", b, out, expect_out);
        else
            $display("[PASS] bit=%0b out=%0b", b, out);
        @(posedge clk);
        #1;  // move clear of the edge before the next send_bit changes `in`
    endtask

    initial begin

        rst_n = 0; in = 0;
        @(posedge clk); #1;
        rst_n = 1;

        // 110 = 6, divisible by 3
        // running values: 1(rem1, out0), 11=3(rem0, out1), 110=6(rem0, out1)
        send_bit(1, 0);
        send_bit(1, 1);
        send_bit(0, 1);

        // reset and try 101 = 5, not divisible by 3
        rst_n = 0;
        @(posedge clk); #1;
        rst_n = 1;
        // running values: 1(rem1, out0), 10=2(rem2, out0), 101=5(rem2, out0)
        send_bit(1, 0);
        send_bit(0, 0);
        send_bit(1, 0);

        // reset and try 100 = 4, not divisible by 3
        rst_n = 0;
        @(posedge clk); #1;
        rst_n = 1;
        // running values: 1(rem1, out0), 10=2(rem2, out0), 100=4(rem1, out0)
        send_bit(1, 0);
        send_bit(0, 0);
        send_bit(0, 0);

        // reset and try 1001 = 9, divisible by 3
        rst_n = 0;
        @(posedge clk); #1;
        rst_n = 1;
        // running values: 1(rem1, out0), 10=2(rem2, out0), 100=4(rem1, out0), 1001=9(rem0, out1)
        send_bit(1, 0);
        send_bit(0, 0);
        send_bit(0, 0);
        send_bit(1, 1);

        // reset and try 10101 = 21, divisible by 3
        rst_n = 0;
        @(posedge clk); #1;
        rst_n = 1;
        // running values: 1(rem1, out0), 10=2(rem2,g out0), 101=5(rem2, out0), 1010=10(rem1, out0), 10101=21(rem0, out1)
        send_bit(1, 0);
        send_bit(0, 0);
        send_bit(1, 0);
        send_bit(0, 0);
        send_bit(1, 1);

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_mod3_mealy);
    end

endmodule : tb_mod3_mealy
