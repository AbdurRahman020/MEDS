module controller (
    input  logic       clk,
    input  logic       reset,
    input  logic       select_water,
    input  logic       select_juice,
    input  logic       select_chocolate,
    input  logic       select_chips,
    input  logic       cancel,
    input  logic       refill,

    // status signals from the datapath
    input  logic        sufficient_balance,
    input  logic        product_available,
    input  logic        max_balance,
    input  logic        selection_valid,
    input  logic        change_nonzero,
    input  logic [1:0]  selected_product,

    // control signals sent to the datapath
    output logic        increment_balance,
    output logic        clear_balance,
    output logic        decrement_stock,
    output logic        refill_stock,
    output logic        dispense_enable,
    output logic        return_change_enable,

    // status outputs to the top-level module
    output logic        out_of_stock,
    output logic        insufficient_balance,
    output logic        transaction_complete
);

    // fsm state definitions
    typedef enum logic [2:0] {
        IDLE,
        DISPENSE,
        INSUFFICIENT,
        OUT_OF_STOCK,
        CANCEL,
        REFILL
    } state_t;

    state_t state, next_state;

    // flags whether selected_product currently decodes to a valid product encoding
    logic selected_product_ok;

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
                if (cancel)
                    next_state = CANCEL;
                else if (refill)
                    next_state = REFILL;
                else if (selection_valid && selected_product_ok) begin
                    if (!product_available)
                        next_state = OUT_OF_STOCK;
                    else if (!sufficient_balance)
                        next_state = INSUFFICIENT;
                    else
                        next_state = DISPENSE;
                end
            end

            // these states perform their action for one cycle before returning to IDLE
            DISPENSE:      next_state = IDLE;
            INSUFFICIENT:  next_state = IDLE;
            OUT_OF_STOCK:  next_state = IDLE;
            CANCEL:        next_state = IDLE;
            REFILL:        next_state = IDLE;

            default:       next_state = IDLE;
        endcase
    end

    // output logic: generates control signals based on the current state
    always_comb begin
        // default values to prevent unintended latches
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

            // increment the balance when a coin is inserted, unless the maximum balance has been reached
            IDLE: begin
                increment_balance = ~max_balance;
            end

            // refill all product stock
            REFILL: begin
                refill_stock = 1'b1;
            end

            // dispense the selected product, update stock, return any remaining change, and clear balance
            DISPENSE: begin
                dispense_enable      = 1'b1;
                decrement_stock      = 1'b1;
                return_change_enable = change_nonzero;
                clear_balance        = 1'b1;
                transaction_complete = 1'b1;
            end

            // notify the user that more money is required
            INSUFFICIENT: begin
                insufficient_balance = 1'b1;
            end

            // notify the user that the selected product is unavailable
            OUT_OF_STOCK: begin
                out_of_stock = 1'b1;
            end

            // cancel the transaction, clear the balance, and return any inserted money
            CANCEL: begin
                clear_balance        = 1'b1;
                return_change_enable = change_nonzero;
            end

            default: ;
        endcase
    end

    // output logic: flags whether the selected product is valid
    always_comb begin
        selected_product_ok = 1'b0;
        case (selected_product)
            2'b00, 2'b01, 2'b10, 2'b11: selected_product_ok = 1'b1;
            default:                    selected_product_ok = 1'b0;
        endcase
    end

endmodule : controller
