module adder_subtractor #(
    parameter int WIDTH = 8
)(
    input  logic signed [WIDTH-1:0] a,      // current value of accumulator (A)
    input  logic signed [WIDTH-1:0] m,      // multiplicand (M)
    input  logic                    add_en, // perform addition when high
    input  logic                    sub_en, // perform subtraction when high

    output logic signed [WIDTH-1:0] result  // output after add/sub operation
);

    // combinational logic for Booth add/sub operations
    always_comb begin
        if (add_en)
            result = a + m;   // A + M
        else if (sub_en)
            result = a - m;   // A - M
        else
            result = a;       // no operation
    end

endmodule : adder_subtractor 