module tb_up_down_counter;
    logic       clk;
    logic       rst_n;
    logic       up_down;
    logic [3:0] count;

    up_down_counter dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .up_down (up_down),
        .count   (count)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_count (
        input logic [3:0] expected_out,
        input string      msg
    );
    begin
        if (count !== expected_out) begin
            $display("Test failed for %s: expected %d, got %d", msg, expected_out, count);
        end else begin
            $display("Test passed for %s: got %d", msg, count);
        end
    end
    endtask

    task automatic apply_reset ();
    begin
        rst_n = 0;
        #1;
        check_count(4'd0, "async reset");
        rst_n = 1;
    end
    endtask

    initial begin
        rst_n   = 1;
        up_down = 1;

        apply_reset();

        // count up through wraparound at 15
        for (int i = 0; i < 17; i++) begin
            @(posedge clk);
            #1;
            check_count((4'd1 + i[3:0]), "up count");
        end

        // assert reset mid-count, away from clock edge
        @(posedge clk);
        #1;
        @(posedge clk);
        #1;
        #2;
        apply_reset();

        // count down through wraparound at 0
        up_down = 0;
        for (int i = 0; i < 17; i++) begin
            @(posedge clk);
            #1;
            check_count((4'd15 - i[3:0]), "down count");
        end

        // resume up counting
        up_down = 1;
        for (int i = 0; i < 3; i++) begin
            @(posedge clk);
            #1;
            check_count((4'd0 + i[3:0]), "resumed up count");
        end

        // assert reset again mid-count
        #3;
        apply_reset();

        $display("All tests completed");
        $finish;
    end

    initial begin
         $dumpfile("dump.vcd");
        $dumpvars(0, tb_up_down_counter);
    end

endmodule : tb_up_down_counter
