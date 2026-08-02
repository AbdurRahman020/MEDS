module controller (
    input  logic      clk,
    input  logic      reset,
    input  logic      select_water,
    input  logic      select_juice,
    input  logic      select_chocolate,
    input  logic      select_chips,
    input  logic      cancel,
    input  logic      refill,

    // status signals received from the datapath
    input  logic       sufficient_balance,
    input  logic       product_available,
    input  logic       max_balance,
    input  logic       selection_valid,
    input  logic       change_nonzero,
    input  logic [1:0] selected_product,

    // control signals sent to the datapath
    output logic       increment_balance,
    output logic       clear_balance,
    output logic       decrement_stock,
    output logic       refill_stock,
    output logic       dispense_enable,
    output logic       return_change_enable,

    // status outputs for the top-level module
    output logic       out_of_stock,
    output logic       insufficient_balance,
    output logic       transaction_complete
);

    // fsm states
    typedef enum logic [2:0] {
        IDLE,
        DISPENSE,
        INSUFFICIENT,
        OUT_OF_STOCK,
        CANCEL,
        REFILL
    } state_t;

    state_t state, next_state;

    // state register
    always_ff @(posedge clk) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // next-state logic
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                // give priority to cancel and refill requests
                if (cancel)
                    next_state = CANCEL;
                else if (refill)
                    next_state = REFILL;
                else if (selection_valid) begin
                    // check stock first, then verify balance
                    if (!product_available)
                        next_state = OUT_OF_STOCK;
                    else if (!sufficient_balance)
                        next_state = INSUFFICIENT;
                    else
                        next_state = DISPENSE;
                end
            end

            // these states complete their action in one clock cycle
            DISPENSE:      next_state = IDLE;
            INSUFFICIENT:  next_state = IDLE;
            OUT_OF_STOCK:  next_state = IDLE;
            CANCEL:        next_state = IDLE;
            REFILL:        next_state = IDLE;

            default:       next_state = IDLE;
        endcase
    end

    // output logic
    always_comb begin
        // default all outputs to inactive
        increment_balance    = 1'b0;
        clear_balance        = 1'b0;
        decrement_stock      = 1'b0;
        refill_stock         = 1'b0;
        dispense_enable      = 1'b0;
        return_change_enable = 1'b0;
        out_of_stock         = 1'b0;
        insufficient_balance = 1'b0;
        transaction_complete = 1'b0;

        case (state)
            // allow coins to be accepted while waiting for user input
            IDLE: begin
                increment_balance = 1'b1;
            end

            // restore all product stocks to their initial values
            REFILL: begin
                refill_stock = 1'b1;
            end

            // complete a successful purchase
            DISPENSE: begin
                dispense_enable      = 1'b1;
                decrement_stock      = 1'b1;
                return_change_enable = 1'b1;
                clear_balance        = 1'b1;
                transaction_complete = 1'b1;
            end

            // indicate that more balance is required
            INSUFFICIENT: begin
                insufficient_balance = 1'b1;
            end

            // indicate that the selected product is unavailable
            OUT_OF_STOCK: begin
                out_of_stock = 1'b1;
            end

            // return the current balance and cancel the transaction
            CANCEL: begin
                clear_balance        = 1'b1;
                return_change_enable = 1'b1;
            end

            default: ;
        endcase
    end

endmodule : controller
