module button_parser (
    input  logic clk,
    input  logic rst_n,
    input  logic button,

    output logic press_event
);

    typedef enum logic {
        RELEASED,
        PRESSED
    } state_t;

    state_t state, next_state;

    // update the current state on each clock edge
    always_ff @(posedge clk or negedge rst_n) begin
        // reset starts the FSM in the released state
        if (!rst_n)
            state <= RELEASED;
        else
            state <= next_state;
    end

    // determine the next state and generate the press event
    always_comb begin
        // default values to avoid unintended latches
        next_state  = state;
        press_event = 1'b0;

        unique case (state)

            RELEASED: begin
                // detect a new button press and generate a one-cycle pulse
                if (button) begin
                    next_state  = PRESSED;
                    press_event = 1'b1;
                end
            end

            PRESSED: begin
                // wait until the button is released
                if (!button)
                    next_state = RELEASED;
            end

        endcase
    end

endmodule : button_parser
