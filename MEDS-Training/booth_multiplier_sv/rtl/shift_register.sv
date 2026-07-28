module shift_register #(
    parameter int WIDTH = 8
)(
    input  logic signed [WIDTH-1:0] alu_result, // result from the adder/subtractor (A)
    input  logic        [WIDTH-1:0] q_reg,      // current multiplier register (Q)

    output logic signed [WIDTH-1:0] a_next,     // next value of A after arithmetic shift
    output logic        [WIDTH-1:0] q_next,     // next value of Q after shift
    output logic                    q_m1_next   // next value of Q-1
);

    // performs one arithmetic right shift on {A, Q, Q-1}
    always_comb begin
        a_next    = {alu_result[WIDTH-1], alu_result[WIDTH-1:1]}; // sign-extend A
        q_next    = {alu_result[0], q_reg[WIDTH-1:1]};            // shift Q right, MSB gets A's LSB
        q_m1_next = q_reg[0];                                     // Q-1 gets Q's LSB
    end

endmodule : shift_register
