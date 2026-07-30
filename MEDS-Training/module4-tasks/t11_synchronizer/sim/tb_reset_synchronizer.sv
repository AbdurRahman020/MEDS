module tb_reset_synchronizer;
    logic clk;
    logic rst_n_async;
    logic rst_n_sync;

    reset_synchronizer dut (
        .clk         (clk),
        .rst_n_async (rst_n_async),
        .rst_n_sync  (rst_n_sync)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task automatic check_aligned_to_clk (
        input string msg
    );
    begin
        @(posedge clk);
        #1;
        $display("Check %s: rst_n_sync=%b at time=%0t", msg, rst_n_sync, $time);
    end
    endtask

    task automatic pulse_reset (
        input time assert_delay,
        input time deassert_delay,
        input string msg
    );
    begin
        #assert_delay;
        rst_n_async = 0;
        #1;
        if (rst_n_sync !== 1'b0) begin
            $display("Test failed for %s: rst_n_sync did not assert immediately", msg);
        end else begin
            $display("Test passed for %s: rst_n_sync asserted immediately", msg);
        end
        #deassert_delay;
        rst_n_async = 1;
    end
    endtask

    initial begin
        rst_n_async = 1;

        // case 1: deassert well away from any clk edge
        pulse_reset(23, 17, "deassert mid-cycle");
        repeat (3) check_aligned_to_clk("after mid-cycle deassert");

        // case 2: deassert right at a clk edge
        @(posedge clk);
        rst_n_async = 0;
        #1;
        if (rst_n_sync !== 1'b0) begin
            $display("Test failed for deassert-at-edge: rst_n_sync did not assert immediately");
        end else begin
            $display("Test passed for deassert-at-edge: rst_n_sync asserted immediately");
        end
        @(posedge clk);
        rst_n_async = 1; // released exactly on an edge
        repeat (3) check_aligned_to_clk("after deassert-at-edge");

        // case 3: deassert just before an edge (near-violation window)
        @(posedge clk);
        #1;
        @(posedge clk);
        #1;
        pulse_reset(8, 1, "deassert near edge");
        repeat (3) check_aligned_to_clk("after near-edge deassert");

        $display("All tests completed");
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_reset_synchronizer);
    end

endmodule : tb_reset_synchronizer
