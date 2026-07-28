module tb_controller;

    logic clk;
    logic rst;
    logic start;
    logic iter_done;

    logic load;
    logic shift_en;
    logic busy;
    logic done;

    // instantiate the controller DUT
    controller dut (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .iter_done (iter_done),
        .load      (load),
        .shift_en  (shift_en),
        .busy      (busy),
        .done      (done)
    );

    // Generate a 10 ns clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    localparam int WIDTH = 8;
    int count;

    // simple counter model to generate iter_done for testing
    always_ff @(posedge clk) begin
        if (rst)
            count <= 0;
        else if (load)
            count <= WIDTH;
        else if (shift_en)
            count <= count - 1;
    end

    // assert iter_done during the last iteration
    assign iter_done = (count == 1);

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
