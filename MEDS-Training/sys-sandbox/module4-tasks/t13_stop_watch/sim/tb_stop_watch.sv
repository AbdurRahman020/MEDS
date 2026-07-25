module tb_stopwatch;

    // use a small clock frequency to speed up simulation
    localparam CLK_FREQ_SIM = 10;

    logic clk;
    logic rst;
    logic [3:0] minute;
    logic [3:0] sec_tens;
    logic [3:0] sec_ones;
    logic [3:0] tenths;

    // instantiate the stopwatch with the simulation clock frequency
    stopwatch #(.CLK_FREQ(CLK_FREQ_SIM)) dut (
        .clk(clk),
        .rst(rst),
        .minute(minute),
        .sec_tens(sec_tens),
        .sec_ones(sec_ones),
        .tenths(tenths)
    );

    // generate a 10 ns clock period
    always #5 clk = ~clk;

    // module-scope registers used only for force/release operations
    logic [3:0] force_min, force_stens, force_sones, force_tenths;
    logic [$clog2((CLK_FREQ_SIM/10)>1 ? (CLK_FREQ_SIM/10):1)-1 : 0] force_tickcnt;

    // compare the DUT outputs against the expected values
    task automatic check_state(input [3:0] exp_min, exp_stens, exp_sones, exp_tenths, input string label);
        if (minute !== exp_min || sec_tens !== exp_stens || sec_ones !== exp_sones || tenths !== exp_tenths) begin
            $display("FAIL [%s]: got %0d:%0d%0d:%0d, expected %0d:%0d%0d:%0d",
                       label, minute, sec_tens, sec_ones, tenths,
                       exp_min, exp_stens, exp_sones, exp_tenths);
            $stop;
        end
        else
            $display("PASS [%s]: %0d:%0d%0d:%0d", label, minute, sec_tens, sec_ones, tenths);
    endtask

    // force the DUT into a specific stopwatch state
    task automatic jump_to_state(input [3:0] m, st, so, t);
        force_min     = m;
        force_stens   = st;
        force_sones   = so;
        force_tenths  = t;
        force_tickcnt = '0;

        @(negedge clk);
        force dut.minute       = force_min;
        force dut.sec_tens     = force_stens;
        force dut.sec_ones     = force_sones;
        force dut.tenths       = force_tenths;
        force dut.tick_counter = force_tickcnt;
        @(negedge clk);
        release dut.minute;
        release dut.sec_tens;
        release dut.sec_ones;
        release dut.tenths;
        release dut.tick_counter;
    endtask

    // reference model that calculates the expected state after one tenth-of-a-second tick
    task automatic expected_next(input  [3:0] m, st, so, t, output [3:0] nm, nst, nso, nt);
        logic t_roll, so_roll, st_roll;

        t_roll  = (t == 9);
        nt      = t_roll ? 0 : t + 1;

        so_roll = t_roll && (so == 9);
        nso     = t_roll ? (so_roll ? 0 : so + 1) : so;

        st_roll = so_roll && (st == 5);
        nst     = so_roll ? (st_roll ? 0 : st + 1) : st;

        nm      = st_roll ? ((m == 9) ? 0 : m + 1) : m;
    endtask

    initial begin
        // apply reset and verify initial state
        clk = 0;
        rst = 1;
        @(posedge clk);
        @(negedge clk);
        check_state(0, 0, 0, 0, "after rst");
        rst = 0;

        // verify tenths counting before rollover
        repeat (9) @(posedge clk);
        @(negedge clk);
        check_state(0, 0, 0, 9, "tenths at 9 before rollover");

        // verify rollover from tenths to seconds
        @(posedge clk);
        @(negedge clk);
        check_state(0, 0, 1, 0, "tenths rollover -> sec_ones increments");

        // force the stopwatch to its maximum value
        jump_to_state(4'd9, 4'd5, 4'd9, 4'd9);
        check_state(9, 5, 9, 9, "forced to max state 9:59:9");

        // verify complete rollover back to zero
        @(posedge clk);
        @(negedge clk);
        check_state(0, 0, 0, 0, "full rollover 9:59:9 -> 0:00:0");

        // randomized verification using the reference model
        begin
            logic [3:0] rm, rst, rso, rt;
            logic [3:0] em, est, eso, et;
            string      label;

            for (int i = 0; i < 20; i++) begin
                rm  = $urandom_range(9, 0);
                rst = $urandom_range(5, 0);
                rso = $urandom_range(9, 0);
                rt  = $urandom_range(9, 0);

                jump_to_state(rm, rst, rso, rt);
                expected_next(rm, rst, rso, rt, em, est, eso, et);

                @(posedge clk);
                @(negedge clk);

                label = $sformatf("random#%0d from %0d:%0d%0d:%0d", i, rm, rst, rso, rt);
                check_state(em, est, eso, et, label);
            end
        end

        // verify continuous counting across the minute rollover
        jump_to_state(4'd9, 4'd3, 4'd0, 4'd0);
        check_state(9, 3, 0, 0, "jumped to 9:30:0");

        // run from 9:30.0 to 9:59.9
        repeat (300) begin
            @(posedge clk);
            @(negedge clk);
        end
        check_state(0, 0, 0, 0, "rollover reached after running from 9:30:0");

        // continue counting from 0:00.0 to 0:30.0
        repeat (300) begin
            @(posedge clk);
            @(negedge clk);
        end
        check_state(0, 3, 0, 0, "stopped at 0:30:0");

        $display("All checks passed");
        $finish;
    end

    initial begin
        // enable waveform generation
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_stopwatch);
    end

endmodule : tb_stopwatch
