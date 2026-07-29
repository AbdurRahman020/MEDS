module alu #(
    parameter int WIDTH = 8
)(
    input  logic signed [WIDTH-1:0] a_reg,    // current accumulator value (A)
    input  logic signed [WIDTH-1:0] m_reg,    // multiplicand (M)
    input  logic        [WIDTH-1:0] q_reg,    // current multiplier value (Q)
    input  logic                    q_m1,     // previous LSB (Q_{-1})

    output logic signed [WIDTH-1:0] a_next,   // updated A after Booth operation and shift
    output logic        [WIDTH-1:0] q_next,   // updated Q after shift
    output logic                    q_m1_next // updated Q_{-1} bit
);

    logic                    op_en;           // high when an add or subtract is needed (01 or 10)
    logic                    sub_en;          // when op_en is high, selects add (0) or subtract (1)
    logic signed [WIDTH-1:0] m_op;            // M or ~M depending on operation
    logic signed [WIDTH-1:0] alu_result;      // A + M, A - M, or A unchanged
 
    // Booth encoding rules:
    //      01       : add M        (op_en=1, sub_en=0)
    //      10       : subtract M   (op_en=1, sub_en=1)
    //      00 or 11 : no operation (op_en=0)
    assign op_en  = q_reg[0] ^ q_m1;
    assign sub_en = q_reg[0] & op_en;

    // single adder for add and subtract:
    //      sub_en inverts M and doubles as the carry-in, so A - M = A + (~M + 1) with no separate subtractor hardware
    assign m_op       = sub_en ? ~m_reg : m_reg;
    assign alu_result = op_en ? (a_reg + m_op + sub_en) : a_reg;

    // arithmetic right shift of {A, Q, Q_{-1}}
    always_comb begin
        a_next    = {alu_result[WIDTH-1], alu_result[WIDTH-1:1]}; // sign-extend A
        q_next    = {alu_result[0], q_reg[WIDTH-1:1]};            // shift Q right, MSB gets A's LSB
        q_m1_next = q_reg[0];                                     // Q_{-1} gets Q's LSB
    end

endmodule : alu
