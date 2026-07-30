module mod3_mealy (
    input  logic clk, rst_n, in,
    output logic out
);

    typedef enum logic [1:0] {S0, S1, S2} state_t;
    state_t current_state, next_state;

    // block 1: state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // block 2: next-state logic
    always_comb begin
        case (current_state)
            S0: next_state = in ? S1 : S0;
            S1: next_state = in ? S0 : S2;
            S2: next_state = in ? S2 : S1;
            default: next_state = S0;
        endcase
    end

    // block 3: output logic (Mealy: state AND input)
    always_comb begin
        case (current_state)
            S0: out = ~in;
            S1: out = in;
            S2: out = 1'b0;
            default: out = 1'b0;
        endcase
    end

endmodule : mod3_mealy
