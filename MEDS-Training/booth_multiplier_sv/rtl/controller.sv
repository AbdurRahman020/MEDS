module controller #(
    parameter int WIDTH = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic start,

    output logic load,
    output logic shift_en,
    output logic busy,
    output logic done
);

    // fsm states for controlling the multiplier operation
    typedef enum logic [1:0] {IDLE, COMPUTE, DONE} state_t;
    state_t state, next_state;

    // tracks remaining Booth iterations, now internal to the FSM
    logic [$clog2(WIDTH+1)-1:0] count;
    logic                       iter_done;

    // state register
    always_ff @(posedge clk) begin
        if (rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // iteration counter: loaded to WIDTH when a new op starts, decremented once per Booth iteration while shifting
    always_ff @(posedge clk) begin
        if (rst)
            count <= '0;
        else if (load)
            count <= WIDTH;
        else if (shift_en)
            count <= count - 1'b1;
    end

    assign iter_done = (count == 1);

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

            default: begin
                next_state = IDLE;
            end
        endcase
    end

endmodule : controller
