module tb_func_F;
    logic a, b, c;
    logic F;

    func_F dut(
        .a(a),
        .b(b),
        .c(c),
        .F(F)
    );

    task automatic check_f(
        input logic a_in, b_in, c_in,
        input logic expected_F
    );
    begin
        a = a_in;
        b = b_in;
        c = c_in;
        #10;
        if (F !== expected_F) begin
            $display("Test failed for a=%b, b=%b, c=%b: expected F=%b, got F=%b", a_in, b_in, c_in, expected_F, F);
        end else begin
            $display("Test passed for a=%b, b=%b, c=%b: F=%b", a_in, b_in, c_in, F);
        end
    end
    endtask

    initial begin
        for (int i = 0; i < 8; i++) begin
            check_f(
                i[2],               // a (MSB)
                i[1],               // b
                i[0],               // c (LSB)
                (i == 1 || i == 2 || i == 3 || i == 6 || i == 7)
            );
        end

        $display("All tests completed.");
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_func_F);
    end

endmodule : tb_func_F
