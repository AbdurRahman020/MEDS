module tb_freq_divider_by_10;

    logic clk;
    logic a_rst;
    logic div_clk;

    // instantiate the frequency divider
    freq_divider_by_10 dut (
        .clk(clk),
        .a_rst(a_rst),
        .div_clk(div_clk)
    );

    // clock period used for simulation
    localparam CLK_PERIOD = 10;

    // generate the simulation clock
    always #(CLK_PERIOD/2) clk = ~clk;

    integer edge_count;
    integer errors;
    integer i;
    logic prev_div_clk;

    initial begin
        clk = 0;
        a_rst = 1;
        errors = 0;

        // apply reset before starting the test
        repeat (2) @(posedge clk);
        a_rst = 0;

        // wait for the first output clock transition
        prev_div_clk = div_clk;
        while (div_clk == prev_div_clk)
            @(posedge clk);

        // verify that the output toggles every 10 input clock cycles
        for (i = 0; i < 8; i = i + 1) begin

            // apply an asynchronous reset during the test to verify correct recovery
            if (i == 3) begin
                $display("\n----- Applying asynchronous reset -----");

                a_rst = 1;
                #23;                    // assert reset asynchronously
                a_rst = 0;

                // wait for the divider to restart counting
                prev_div_clk = div_clk;
                while (div_clk == prev_div_clk)
                    @(posedge clk);

                $display("----- Reset released -----\n");
            end

            prev_div_clk = div_clk;
            edge_count = 0;

            // count input clock edges until the output toggles
            while (div_clk == prev_div_clk) begin
                @(posedge clk);
                edge_count++;
            end

            // check that exactly 10 clock cycles elapsed
            if (edge_count !== 10) begin
                $display("FAIL: iteration %0d, expected 10 clk edges, got %0d", i, edge_count);
                errors++;
            end
            else begin
                $display("PASS: iteration %0d, ratio = 10", i);
            end
        end

        // display the overall test result
        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TEST(S) FAILED", errors);

        $finish;
    end

    initial begin
        // enable waveform generation
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_freq_divider_by_10);
    end

endmodule : tb_freq_divider_by_10
