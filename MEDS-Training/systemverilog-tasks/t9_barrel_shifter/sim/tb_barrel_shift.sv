module tb_barrel_shifter;
    // inputs to both DUTs
    logic [3:0] W;
    logic shift;
    logic [1:0] sel;

    // outputs from the DUTs
    logic [3:0] Y_fixed;
    logic [3:0] Y_barrel;
    logic k;

    // test data storage
    logic [3:0] testW [0:2];

    // loop variables
    integer i, j, k_shift;
    
    // fixed right shifter instantiation
    fixed_right_shifter dut1 (
        .W(W),
        .shift(shift),
        .Y(Y_fixed),
        .k(k)
    );

    // 4-bit barrel shifter instantiation
    barrel_shifter dut2 (
        .W(W),
        .sel(sel),
        .Y(Y_barrel)
    );

    // test task: applies one set of inputs to both DUTs, waits for outputs to settle, and prints results
    task automatic test_all (
        input logic [3:0] inW,
        input logic       inShift,
        input logic [1:0] inSel
    );
    begin
        // apply inputs
        W     = inW;
        shift = inShift;
        sel   = inSel;

        // allow outputs to update
        #10;

        // the fixed shifter only depends on W and shift, so print it once for each shift value
        if (inSel == 2'b00) begin
            $display("Fixed:   W=%b shift=%b -> Y_fixed=%b k=%b", W, shift, Y_fixed, k);
        end

        // barrel shifter output changes with sel
        $display("Barrel:  W=%b sel=%b   -> Y_barrel=%b",  W, sel, Y_barrel);
    end
    endtask

    
    // test sequence
    initial begin
        // initialize control signals
        shift = 1'b0;
        sel   = 2'b00;

        // test input patterns
        testW[0] = 4'b1011;
        testW[1] = 4'b0101;
        testW[2] = 4'b1110;

        $display("========== Fixed & Barrel Sweep ==========");

        // test every input with all shift and select combinations
        for (i = 0; i < 3; i++) begin
            for (k_shift = 0; k_shift < 2; k_shift++) begin
                for (j = 0; j < 4; j++) begin
                    test_all(testW[i], k_shift[0], j[1:0]);
                end
            end
        end

        // end simulation
        $display("\nSimulation completed.");
        $finish;
    end

    initial begin
        // enable waveform generation
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_barrel_shifter);
    end

endmodule : tb_barrel_shifter
