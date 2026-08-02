module pwm_gen (
    input  logic clk,
    input  logic rst,

    output logic pwm
);

    logic [7:0] count;
    logic [7:0] count_q;

    // mux + adder
    assign count = rst ? 8'd0 : count_q + 8'd1;

    // d flip-flop
    always_ff @(posedge clk)
        count_q <= count;

    // comparator
    assign pwm = (count < 8'd128);

endmodule : pwm_gen
