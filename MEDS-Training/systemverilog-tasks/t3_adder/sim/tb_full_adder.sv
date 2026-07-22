module tb_full_adder;
    logic a, b, cin;
    logic sum, cout;
    
    full_adder dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    task automatic check (input logic a_in, input logic b_in, input logic cin_in, input logic sum, input logic cout);
        logic expected_sum, expected_cout;
        expected_sum = a_in ^ b_in ^ cin_in;
        expected_cout = (a_in & b_in) | (cin_in & (a_in ^ b_in));

        if (sum !== expected_sum || cout !== expected_cout) begin
            $display("Test failed for a=%0b, b=%0b, cin=%0b: expected sum=%0b, cout=%0b; got sum=%0b, cout=%0b",
                 a, b, cin, expected_sum, expected_cout, sum, cout);
        end else begin
            $display("Test passed for a=%0b, b=%0b, cin=%0b: sum=%0b, cout=%0b", a, b, cin, sum, cout);
        end
    endtask

    initial begin
        for (int i = 0; i < 8; i++) begin
            {a, b, cin} = i;
            #10;
            check(a, b, cin, sum, cout);
        end
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_full_adder);
    end

endmodule : tb_full_adder
