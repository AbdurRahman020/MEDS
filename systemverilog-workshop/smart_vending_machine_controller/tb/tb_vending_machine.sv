module tb_vending_machine;

    logic clk, reset;
    logic coin_inserted;
    logic select_water, select_juice, select_chocolate, select_chips;
    logic cancel, refill;

    logic dispense_water, dispense_juice, dispense_chocolate, dispense_chips;
    logic return_change;
    logic [3:0] change_amount;
    logic [3:0] current_balance;
    logic out_of_stock, insufficient_balance, transaction_complete;

    int errors = 0;
    int checks = 0;

    // instantiate the vending machine under test
    vending_machine dut (.*);

    // read internal stock registers for self-checking
    wire [3:0] water_stock_probe     = dut.u_datapath.water_stock;
    wire [3:0] juice_stock_probe     = dut.u_datapath.juice_stock;
    wire [3:0] chocolate_stock_probe = dut.u_datapath.chocolate_stock;
    wire [3:0] chips_stock_probe     = dut.u_datapath.chips_stock;

    // generate the system clock
    always #5 clk = ~clk;

    // helper functions

    // return the price of the selected product
    function automatic int price_of(input int p);
        case (p)
            0: price_of = 2;
            1: price_of = 3;
            2: price_of = 4;
            default: price_of = 5;
        endcase
    endfunction

    // return the product name for reporting
    function automatic string pname(input int p);
        case (p)
            0: pname = "water";
            1: pname = "juice";
            2: pname = "chocolate";
            default: pname = "chips";
        endcase
    endfunction

    // return the dispense output for the selected product
    function automatic logic dispense_line(input int p);
        case (p)
            0: dispense_line = dispense_water;
            1: dispense_line = dispense_juice;
            2: dispense_line = dispense_chocolate;
            default: dispense_line = dispense_chips;
        endcase
    endfunction

    // return the current stock of the selected product
    function automatic logic [3:0] stock_of(input int p);
        case (p)
            0: stock_of = water_stock_probe;
            1: stock_of = juice_stock_probe;
            2: stock_of = chocolate_stock_probe;
            default: stock_of = chips_stock_probe;
        endcase
    endfunction

    // helper tasks

    // clear all input signals
    task automatic clear_inputs;
        coin_inserted = 0; select_water = 0; select_juice = 0;
        select_chocolate = 0; select_chips = 0; cancel = 0; refill = 0;
    endtask

    // advance the simulation by one clock cycle
    task automatic tick;
        @(posedge clk); #1;
    endtask

    // reset the vending machine
    task automatic do_reset;
        reset = 1; clear_inputs(); tick(); tick();
        reset = 0; tick();
    endtask

    // wait until the controller returns to the idle state
    task automatic settle;
        while (dut.u_controller.state !== 3'd0) tick();
    endtask

    // insert a single coin
    task automatic insert_coin;
        settle(); clear_inputs();
        coin_inserted = 1; tick(); coin_inserted = 0;
    endtask

    // insert multiple coins
    task automatic insert_coins(input int n);
        for (int i = 0; i < n; i++) insert_coin();
    endtask

    // select a product
    task automatic select_product(input int p);
        settle(); clear_inputs();
        case (p)
            0: select_water = 1;
            1: select_juice = 1;
            2: select_chocolate = 1;
            3: select_chips = 1;
        endcase
        tick(); clear_inputs();
    endtask

    // cancel the current transaction
    task automatic do_cancel;
        settle(); clear_inputs();
        cancel = 1; tick(); clear_inputs();
    endtask

    // refill all product stocks
    task automatic do_refill;
        settle(); clear_inputs();
        refill = 1; tick(); clear_inputs();
    endtask

    // check a condition and record any failures
    task automatic check(input logic cond, input string msg);
        checks++;
        if (!cond) begin
            errors++;
            $display("FAIL: %s", msg);
        end
    endtask

    // random test session: execute random customer transactions until the selected products are depleted
    task automatic random_session_until(input logic [3:0] target_mask, input string label);
        int exp_balance;
        int exp_stock[4];
        int p, coins, guard;
        bit done;

        exp_balance = 0;
        for (int k = 0; k < 4; k++) exp_stock[k] = stock_of(k);

        done = 0;
        guard = 0;
        while (!done && guard < 300) begin
            guard++;

            coins = $urandom_range(0, 4);
            if (coins > 0) begin
                insert_coins(coins);
                exp_balance = (exp_balance + coins > 10) ? 10 : exp_balance + coins;
            end

            if ($urandom_range(0, 9) == 0) begin
                do_cancel(); tick();
                check(current_balance == 0, {label, ": balance cleared after random cancel"});
                exp_balance = 0;
            end else begin
                p = $urandom_range(0, 3);
                select_product(p);

                if (exp_stock[p] == 0) begin
                    check(out_of_stock == 1, {label, ": ", pname(p), " out_of_stock correctly flagged"});
                    check(dispense_line(p) == 0, {label, ": no dispense while depleted"});
                end else if (exp_balance < price_of(p)) begin
                    check(insufficient_balance == 1, {label, ": insufficient_balance correctly flagged"});
                    check(dispense_line(p) == 0, {label, ": no dispense on insufficient balance"});
                end else begin
                    check(dispense_line(p) == 1, {label, ": ", pname(p), " dispensed correctly"});
                    check(change_amount == (exp_balance - price_of(p)), {label, ": change matches model"});
                    exp_stock[p] = exp_stock[p] - 1;
                    exp_balance = 0;
                end

                tick();
                check(stock_of(p) == exp_stock[p], {label, ": stock matches model"});
                check(current_balance == exp_balance, {label, ": balance matches model"});
            end

            done = 1;
            for (int k = 0; k < 4; k++)
                if (target_mask[k] && exp_stock[k] != 0) done = 0;
        end

        if (exp_balance != 0) begin
            do_cancel();
            tick();
        end

        check(done, {label, ": all targeted products ran out within the round limit"});
    endtask

    // test sequence

    initial begin
        $dumpfile("vending_machine.vcd");
        $dumpvars(0, tb_vending_machine);

        clk = 0;
        do_reset();

        // run random transactions until water and chips are depleted
        $display("t=%0t ---- SESSION 1: random until water + chips run out ----", $time);
        random_session_until(4'b1001, "session1");
        $display("t=%0t session1 done -> water=%0d juice=%0d chocolate=%0d chips=%0d", $time, water_stock_probe, juice_stock_probe, chocolate_stock_probe, chips_stock_probe);

        // refill all products
        $display("t=%0t ---- RESTOCK ----", $time);
        do_refill();
        tick();
        check(water_stock_probe == 4'd10 && juice_stock_probe == 4'd10 && chocolate_stock_probe == 4'd10 && chips_stock_probe == 4'd10, "session1: refill restores all four stocks");
        $display("t=%0t after refill -> water=%0d juice=%0d chocolate=%0d chips=%0d", $time, water_stock_probe, juice_stock_probe, chocolate_stock_probe, chips_stock_probe);

        // run another random session after refilling
        $display("t=%0t ---- SESSION 2: random until water + juice + chips run out ----", $time);
        random_session_until(4'b1011, "session2");
        $display("t=%0t session2 done -> water=%0d juice=%0d chocolate=%0d chips=%0d", $time, water_stock_probe, juice_stock_probe, chocolate_stock_probe, chips_stock_probe);

        $display("----------------------------");
        if (errors == 0)
            $display("ALL %0d CHECKS PASSED", checks);
        else
            $display("%0d/%0d CHECKS FAILED", errors, checks);
        $display("----------------------------");
        $finish;
    end

endmodule : tb_vending_machine
