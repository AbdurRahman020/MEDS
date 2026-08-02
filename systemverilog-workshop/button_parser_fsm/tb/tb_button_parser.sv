module tb_button_parser;

    logic clk, rst_n, button, press_event;
    int errors = 0;

    button_parser dut (.*);

    // generate a 10 ns clock
    always #5 clk = ~clk;

    // simple task to report failed checks
    task automatic check(input logic cond, input string msg);
        if (!cond) begin
            errors++;
            $display("FAIL: %s", msg);
        end
    endtask

    initial begin
        // initialize inputs
        clk = 0;
        rst_n = 0;
        button = 0;

        // hold reset for two clock cycles
        @(posedge clk); #1;
        @(posedge clk); #1;
        check(press_event == 0, "reset: press_event low during reset");

        // release reset and verify the idle state
        rst_n = 1;
        @(posedge clk); #1;
        check(press_event == 0, "idle: press_event low, button not pressed");

        // press the button and check for a one-cycle pulse
        button = 1;
        #1;
        check(press_event == 1, "press: press_event asserted on button rising edge");

        // after the next clock, the FSM enters PRESSED and the pulse ends
        @(posedge clk); #1;
        check(press_event == 0, "held: press_event low one cycle after the press, still held");

        // keep holding the button to verify no additional pulses
        @(posedge clk); #1;
        check(press_event == 0, "held: press_event stays low while button stays held");

        // release the button
        button = 0;
        #1;
        check(press_event == 0, "release: press_event stays low on release");

        // verify the FSM returns to the released state
        @(posedge clk); #1;
        check(press_event == 0, "released: back in RELEASED state, press_event low");

        // press the button again to confirm another pulse is generated
        button = 1;
        #1;
        check(press_event == 1, "second press: press_event asserted again");

        // the pulse should last for only one cycle
        @(posedge clk); #1;
        check(press_event == 0, "second press held: press_event drops after one cycle");

        button = 0;

        // print the final test result
        if (errors == 0)
            $display("ALL CHECKS PASSED");
        else
            $display("%0d CHECKS FAILED", errors);

        $finish;
    end

endmodule : tb_button_parser
