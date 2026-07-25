// half_adder1 using continuous assignment 
module half_adder1 (
    input logic a, b,
    output logic sum, carry_from
);

    assign sum = a ^ b;
    assign carry_from = a & b;

endmodule : half_adder1


// half_adder2 using always_comb block
module half_adder2 (
    input logic a, b,
    output logic sum, carry_from
);

    always_comb begin
        case ({a, b})
            2'b00: begin
                sum = 1'b0;
                carry_from = 1'b0;
            end
            2'b01: begin
                sum = 1'b1;
                carry_from = 1'b0;
            end
            2'b10: begin
                sum = 1'b1;
                carry_from = 1'b0;
            end
            2'b11: begin
                sum = 1'b0;
                carry_from = 1'b1;
            end
        endcase
    end

endmodule : half_adder2


// full_adder using two half adders
module full_adder (
    input logic a, b, cin,
    output logic sum, cout
);

    logic sum_half, carry_half1, carry_half2;

    half_adder1 ha1 (.a(a), .b(b), .sum(sum_half), .carry_from(carry_half1));
    half_adder2 ha2 (.a(sum_half), .b(cin), .sum(sum), .carry_from(carry_half2));

    assign cout = carry_half1 | carry_half2;

endmodule : full_adder
