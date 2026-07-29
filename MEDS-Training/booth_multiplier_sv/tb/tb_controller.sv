module tb_controller;

    logic clk;
    logic rst;
    logic start;

    logic load;
    logic shift_en;
    logic busy;
    logic done;

    localparam int WIDTH = 8;

    // instantiate the controller DUT
    controller #(.WIDTH(WIDTH)) dut (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .load      (load),
        .shift_en  (shift_en),
        .busy      (busy),
        .done      (done)
    );

    // Generate a 10 ns clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        // apply reset
        rst   = 1'b1;
        start = 1'b0;
        repeat (2) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        // check that the controller is in the IDLE state
        if (busy !== 1'b0 || done !== 1'b0)
            $display("FAIL: controller not idle after reset");
        else
            $display("PASS: controller idle after reset");

        // start a multiplication operation
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        // check that the load signal is asserted
        if (load !== 1'b1)
            $display("FAIL: load not asserted on start");
        else
            $display("PASS: load asserted on start");

        // wait for the controller to finish all iterations
        begin
            int wait_cycles;
            wait_cycles = 0;

            while (!done && wait_cycles < WIDTH + 5) begin
                @(posedge clk);
                wait_cycles++;
            end

            if (done)
                $display("PASS: done asserted after %0d iterations", WIDTH);
            else
                $display("FAIL: done never asserted (timeout)");
        end

        @(posedge clk);
        $finish;
    end

endmodule : tb_controller
