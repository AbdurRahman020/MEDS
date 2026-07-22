module tb_req_ctrl;
    logic clk = 0, rst_n, start, cancel, busy, done;

    req_ctrl #(.BUSY_CYCLES(4)) dut (
        .clk(clk), .rst_n(rst_n),
        .start(start), .cancel(cancel),
        .busy(busy), .done(done)
    );

    always #5 clk = ~clk;

    task automatic check(input string label, input logic exp_busy, input logic exp_done);
        if (busy !== exp_busy || done !== exp_done)
            $display("[FAIL] %s busy=%0b done=%0b expected busy=%0b done=%0b", label, busy, done, exp_busy, exp_done);
        else
            $display("[PASS] %s busy=%0b done=%0b", label, busy, done);
    endtask

    initial begin
        rst_n = 0; start = 0; cancel = 0;
        @(posedge clk); #1;
        rst_n = 1;
        check("idle", 0, 0);

        // normal start->busy->done->idle
        start = 1;
        @(posedge clk); #1;
        start = 0;
        check("entered busy", 1, 0);

        repeat (3) begin
            @(posedge clk); #1;
            check("busy", 1, 0);
        end

        @(posedge clk); #1;
        check("done", 0, 1);

        @(posedge clk); #1;
        check("back to idle", 0, 0);

        // start->busy->cancel->idle
        start = 1;
        @(posedge clk); #1;
        start = 0;
        check("entered busy again", 1, 0);

        @(posedge clk); #1;
        check("busy again", 1, 0);

        cancel = 1;
        @(posedge clk); #1;
        cancel = 0;
        check("cancelled to idle", 0, 0);

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_req_ctrl);
    end

endmodule: tb_req_ctrl
