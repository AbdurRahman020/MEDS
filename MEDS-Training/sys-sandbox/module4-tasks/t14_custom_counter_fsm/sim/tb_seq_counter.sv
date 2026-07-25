module tb_seq_counter_01347;
    logic clk = 0, rst_n;
    logic [2:0] q;

    seq_counter_01347 dut (
        .clk(clk), 
        .rst_n(rst_n), 
        .q(q)
    );

    always #5 clk = ~clk;

    int expected[5] = '{0,1,3,4,7};

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, seq_counter_01347);

        rst_n = 0;
        @(posedge clk); #1;
        rst_n = 1;

        rst_n = 0;
        @(posedge clk); #1;
        rst_n = 1;

        for (int cycle = 0; cycle < 3; cycle++) begin
            for (int idx = 0; idx < 5; idx++) begin
                if (q !== expected[idx])
                    $display("[FAIL] cycle=%0d idx=%0d q=%0d expected=%0d", cycle, idx, q, expected[idx]);
                else
                    $display("[PASS] cycle=%0d idx=%0d q=%0d", cycle, idx, q);
                if (q == 2 || q == 5 || q == 6)
                    $display("[FAIL] entered unused state %0d", q);

                @(posedge clk); #1;
                end
        end
        $finish;
    end
    
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_seq_counter_01347);
    end

endmodule : tb_seq_counter_01347
