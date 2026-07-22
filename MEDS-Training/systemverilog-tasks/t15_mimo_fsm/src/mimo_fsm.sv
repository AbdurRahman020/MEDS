module req_ctrl #(
    parameter int BUSY_CYCLES = 4
)(
    input  logic clk, rst_n,
    input  logic start, cancel,
    output logic busy, done
);

    typedef enum logic [1:0] {IDLE, BUSY, DONE} state_t;
    state_t current_state, next_state;

    logic [$clog2(BUSY_CYCLES+1)-1:0] count;

    // block 1: state register
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // counter
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= '0;
        else if (current_state == BUSY && next_state == BUSY)
            count <= count + 1;
        else
            count <= '0;
    end

    // block 2: next-state logic
    always_comb begin
        case (current_state)
            IDLE: next_state = start ? BUSY : IDLE;
            BUSY: next_state = cancel ? IDLE : (count == BUSY_CYCLES-1) ? DONE : BUSY;
            DONE: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // block 3: output logic
    always_comb begin
        busy = (current_state == BUSY);
        done = (current_state == DONE);
    end

endmodule: req_ctrl
