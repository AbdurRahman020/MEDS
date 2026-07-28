module alu #(
    parameter int WIDTH = 8
)(
    input  logic signed [WIDTH-1:0] a_reg,    // current accumulator value (A)
    input  logic signed [WIDTH-1:0] m_reg,    // multiplicand (M)
    input  logic        [WIDTH-1:0] q_reg,    // current multiplier value (Q)
    input  logic                    add_en,   // enable addition operation
    input  logic                    sub_en,   // enable subtraction operation

    output logic signed [WIDTH-1:0] a_next,   // updated A after Booth operation and shift
    output logic        [WIDTH-1:0] q_next,   // updated Q after shift
    output logic                    q_m1_next // updated Q_{-1} bit
);

    // stores the result of the add/sub operation
    logic signed [WIDTH-1:0] alu_result;

    // performs A + M, A - M, or passes A unchanged
    adder_subtractor #(.WIDTH(WIDTH)) u_adder_sub (
        .a      (a_reg),
        .m      (m_reg),
        .add_en (add_en),
        .sub_en (sub_en),
        .result (alu_result)
    );

    // performs the arithmetic right shift on {A, Q, Q-1}
    shift_register #(.WIDTH(WIDTH)) u_shifter (
        .alu_result (alu_result),
        .q_reg      (q_reg),
        .a_next     (a_next),
        .q_next     (q_next),
        .q_m1_next  (q_m1_next)
    );

endmodule : alu
