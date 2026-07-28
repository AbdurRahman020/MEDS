module controller (
    input  logic clk,
    input  logic rst,
    input  logic start,
    input  logic iter_done,   // high when the last Booth iteration is reached

    output logic load,
    output logic shift_en,
    output logic busy,
    output logic done
);

    // fsm states for controlling the multiplier operation
    typedef enum logic [1:0] {IDLE, COMPUTE, DONE} state_t;
    state_t state, next_state;

    // state register
    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // next-state and output logic
    always_comb begin
        next_state = state;
        load       = 1'b0;
        shift_en   = 1'b0;
        busy       = 1'b0;
        done       = 1'b0;

        unique case (state)
            IDLE: begin
                // load operands when multiplication starts
                if (start) begin
                    load       = 1'b1;
                    next_state = COMPUTE;
                end
            end

            COMPUTE: begin
                // perform one Booth iteration every clock cycle
                busy     = 1'b1;
                shift_en = 1'b1;

                // move to DONE after the final iteration
                if (iter_done)
                    next_state = DONE;
            end

            DONE: begin
                // indicate that the multiplication is complete
                done       = 1'b1;
                next_state = IDLE;
            end
        endcase
    end

endmodule : controller
