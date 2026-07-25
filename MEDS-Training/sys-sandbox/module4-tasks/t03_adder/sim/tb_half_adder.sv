module tb_half_adder;
    logic a, b;
    logic sum, carry;

    half_adder2 dut (
        .a(a),
        .b(b),
        .sum(sum),
        .carry_from(carry)
    );

    task automatic check_output(input logic a, input logic b, input logic sum, input logic carry);
        logic expected_sum, expected_carry;
        expected_sum = a ^ b;
        expected_carry = a & b;

        if (sum !== expected_sum || carry !== expected_carry) begin
            $display("Test failed for a=%0b b=%0b: sum=%0b (expected %0b), carry=%0b (expected %0b)",
                      a, b, sum, expected_sum, carry, expected_carry);
        end else begin
            $display("Test passed for a=%0b b=%0b: sum=%0b, carry=%0b", 
                      a, b, sum, carry);
        end
    
    endtask

    initial begin
        for (int i = 0; i < 4; i++) begin
            {a, b} = i;
            #10;
            check_output(a, b, sum, carry);
        end

        $finish;
    end

    initial begin
         $dumpfile("dump.vcd");
        $dumpvars(0, tb_half_adder);
    end

endmodule : tb_half_adder
