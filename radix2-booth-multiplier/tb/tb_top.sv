module tb_top;

    logic clk;
    logic rst;
    logic start;
    logic signed [7:0]  multiplicand;
    logic signed [7:0]  multiplier;
    logic signed [15:0] product;
    logic busy;
    logic done;

    // keep track of passed and failed test cases
    int pass_count;
    int fail_count;

    // instantiate the Booth multiplier DUT
    booth_multiplier dut (
        .clk          (clk),
        .rst          (rst),
        .start        (start),
        .multiplicand (multiplicand),
        .multiplier   (multiplier),
        .product      (product),
        .busy         (busy),
        .done         (done)
    );

    // generate a 10 ns clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // applies inputs and compares the DUT output with the expected result
    task automatic run_test(input logic signed [7:0] a, input logic signed [7:0] b);
        logic signed [15:0] expected;
        begin
            @(negedge clk);
            multiplicand = a;
            multiplier   = b;
            start        = 1'b1;

            @(negedge clk);
            start = 1'b0;

            // wait for multiplication to complete
            wait (done);
            expected = $signed(a) * $signed(b);

            // self-checking comparison
            if (product !== expected) begin
                fail_count++;
                $display("FAIL: %0d x %0d = %0d (expected %0d)", a, b, product, expected);
            end
            else begin
                pass_count++;
            end

            @(negedge clk);
        end
    endtask

    initial begin
        pass_count   = 0;
        fail_count   = 0;
        rst          = 1'b1;
        start        = 1'b0;
        multiplicand = '0;
        multiplier   = '0;

        // apply reset
        repeat (2) @(negedge clk);
        rst = 1'b0;
        @(negedge clk);

        // directed test cases
        run_test(8'sd5,     8'sd9);      // positive x positive
        run_test(-8'sd5,    8'sd9);      // negative x positive
        run_test(8'sd5,    -8'sd9);      // positive x negative
        run_test(-8'sd5,   -8'sd9);      // negative x negative
        run_test(8'sd0,     8'sd0);      // 0 x 0
        run_test(8'sd0,     8'sd42);     // 0 x X
        run_test(8'sd42,    8'sd0);      // X x 0
        run_test(8'sd127,   8'sd127);    // maximum positive value
        run_test(-8'sd128, -8'sd1);      // minimum negative x -1
        run_test(-8'sd128,  8'sd127);    // minimum negative x maximum positive
        run_test(-8'sd1,   -8'sd1);      // -1 x -1
        run_test(8'sd1,    -8'sd128);    // 1 x minimum negative
        run_test(-8'sd128, -8'sd128);    // minimum negative x minimum negative

        // test all combinations of important edge values
        begin
            logic signed [7:0] edge_vals[5];

            edge_vals[0] = 8'sd0;
            edge_vals[1] = 8'sd1;
            edge_vals[2] = -8'sd1;
            edge_vals[3] = 8'sd127;
            edge_vals[4] = -8'sd128;

            for (int i = 0; i < 5; i++) begin
                for (int j = 0; j < 5; j++) begin
                    run_test(edge_vals[i], edge_vals[j]);
                end
            end
        end

        // perform randomized testing
        for (int i = 0; i < 500; i++) begin
            run_test($urandom_range(0, 255), $urandom_range(0, 255));
        end

        // display test summary
        $display("--------------------------------------------------");
        $display("TESTS COMPLETE: %0d passed, %0d failed", pass_count, fail_count);
        $display("--------------------------------------------------");

        $finish;
    end

endmodule : tb_top
