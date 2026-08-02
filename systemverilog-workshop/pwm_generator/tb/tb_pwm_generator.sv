module tb_pwm_gen;

    logic clk, rst, pwm;
    int errors = 0;
    logic [7:0] expected_count = 8'd0;

    pwm_gen dut (.*);

    // generate a 10 ns clock
    always #5 clk = ~clk;

    initial begin
        // initialize signals
        clk = 0;
        rst = 1;

        // hold reset for two clock cycles
        @(posedge clk); #1;
        @(posedge clk); #1;

        // while reset is active, the counter stays at 0 so pwm should be high
        if (pwm !== 1'b1) begin
            errors++;
            $display("FAIL: pwm should be high while count=0 during reset");
        end

        // release reset and synchronize the reference counter
        rst = 0;
        #1;
        expected_count = dut.count;

        // run for two complete pwm periods and verify the output each cycle
        for (int i = 0; i < 512; i++) begin
            @(posedge clk); #1;

            // update the expected counter to match the DUT
            expected_count = expected_count + 8'd1;

            // check that the pwm output matches the expected duty cycle
            if (pwm !== (expected_count < 8'd128)) begin
                errors++;
                $display("FAIL: cycle %0d, count=%0d, pwm=%b, expected=%b", i, expected_count, pwm, (expected_count < 8'd128));
            end

            // apply a reset during the test to verify recovery
            if (i == 200) begin
                rst = 1;
                @(posedge clk); #1;
                @(posedge clk); #1;

                // pwm should return high while reset is active
                if (pwm !== 1'b1) begin
                    errors++;
                    $display("FAIL: pwm should go high again on mid-test reset (i=%0d)", i);
                end

                // release reset and resynchronize the reference counter
                rst = 0;
                #1;
                expected_count = dut.count;
            end
        end

        // print the final test result
        if (errors == 0)
            $display("ALL CHECKS PASSED (512 cycles, 2 full pwm periods)");
        else
            $display("%0d CHECKS FAILED", errors);

        $finish;
    end

endmodule : tb_pwm_gen
