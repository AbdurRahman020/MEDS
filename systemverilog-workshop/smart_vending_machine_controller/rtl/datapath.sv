module datapath (
    input  logic       clk,
    input  logic       reset,
    input  logic       coin_inserted,
    input  logic       select_water,
    input  logic       select_juice,
    input  logic       select_chocolate,
    input  logic       select_chips,

    // control signals from the controller fsm
    input  logic       increment_balance,
    input  logic       clear_balance,
    input  logic       decrement_stock,
    input  logic       refill_stock,
    input  logic       dispense_enable,
    input  logic       return_change_enable,

    // status signals sent back to the controller
    output logic       sufficient_balance,
    output logic       product_available,
    output logic       max_balance,
    output logic       selection_valid,
    output logic       change_nonzero,
    output logic [1:0] selected_product,

    // outputs to the vending machine hardware
    output logic       dispense_water,
    output logic       dispense_juice,
    output logic       dispense_chocolate,
    output logic       dispense_chips,
    output logic       return_change,
    output logic [3:0] change_amount,
    output logic [3:0] current_balance
);

    // product encoding
    localparam logic [1:0] WATER = 2'b00, JUICE = 2'b01, CHOCOLATE = 2'b10, CHIPS = 2'b11;

    // product selection
    logic [2:0] select_count;

    // a selection is valid only when exactly one product is chosen
    assign select_count = select_water + select_juice + select_chocolate + select_chips;
    assign selection_valid = (select_count == 3'd1);

    // encode the selected product
    assign selected_product = select_water ? WATER : select_juice ? JUICE : select_chocolate ? CHOCOLATE : CHIPS;

    // store the selected product so it remains available during the dispense cycle, since selection inputs are only pulses
    logic [1:0] active_product;
    always_ff @(posedge clk) begin
        if (reset)
            active_product <= WATER;
        else if (selection_valid)
            active_product <= selected_product;
    end

    // balance register
    logic [3:0] balance_reg, balance_next;
    logic       accept_coin;

    // stop accepting coins once the maximum balance is reached
    assign max_balance = (balance_reg == 4'd10);
    assign accept_coin = increment_balance & coin_inserted & ~max_balance;

    // update the balance based on controller commands
    always_comb begin
        if (clear_balance)
            balance_next = 4'd0;
        else if (accept_coin)
            balance_next = balance_reg + 4'd1;
        else
            balance_next = balance_reg;
    end

    always_ff @(posedge clk) begin
        if (reset)
            balance_reg <= 4'd0;
        else
            balance_reg <= balance_next;
    end

    assign current_balance = balance_reg;

    // price lookup
    logic [3:0] price;

    // determine the price of the selected product
    always_comb begin
        case (selected_product)
            WATER:     price = 4'd2;
            JUICE:     price = 4'd3;
            CHOCOLATE: price = 4'd4;
            default:   price = 4'd5;
        endcase
    end

    // check if enough balance is available for the purchase
    assign sufficient_balance = (balance_reg >= price);

    // change calculation
    logic [3:0] active_price;

    // use the stored product selection when dispensing
    always_comb begin
        case (active_product)
            WATER:     active_price = 4'd2;
            JUICE:     active_price = 4'd3;
            CHOCOLATE: active_price = 4'd4;
            default:   active_price = 4'd5;
        endcase
    end

    logic [3:0] subtract_operand;

    // calculate the remaining balance after a successful purchase
    assign subtract_operand = dispense_enable ? active_price : 4'd0;
    assign change_amount    = balance_reg - subtract_operand;
    assign change_nonzero   = (change_amount != 4'd0);
    assign return_change    = return_change_enable;

    // stock registers
    logic [3:0] water_stock, juice_stock, chocolate_stock, chips_stock;
    logic       dec_water, dec_juice, dec_chocolate, dec_chips;

    // decrement stock only for the dispensed product
    assign dec_water     = decrement_stock & (active_product == WATER);
    assign dec_juice     = decrement_stock & (active_product == JUICE);
    assign dec_chocolate = decrement_stock & (active_product == CHOCOLATE);
    assign dec_chips     = decrement_stock & (active_product == CHIPS);

    // each product starts with a stock of 10 and can be refilled
    always_ff @(posedge clk) begin
        if (reset) begin
            water_stock     <= 4'd10;
            juice_stock     <= 4'd10;
            chocolate_stock <= 4'd10;
            chips_stock     <= 4'd10;
        end else begin
            water_stock     <= refill_stock ? 4'd10 : (dec_water     ? water_stock     - 4'd1 : water_stock);
            juice_stock     <= refill_stock ? 4'd10 : (dec_juice     ? juice_stock     - 4'd1 : juice_stock);
            chocolate_stock <= refill_stock ? 4'd10 : (dec_chocolate ? chocolate_stock - 4'd1 : chocolate_stock);
            chips_stock     <= refill_stock ? 4'd10 : (dec_chips     ? chips_stock     - 4'd1 : chips_stock);
        end
    end

    logic [3:0] selected_stock;

    // read the stock level of the currently selected product
    always_comb begin
        case (selected_product)
            WATER:     selected_stock = water_stock;
            JUICE:     selected_stock = juice_stock;
            CHOCOLATE: selected_stock = chocolate_stock;
            default:   selected_stock = chips_stock;
        endcase
    end

    assign product_available = (selected_stock != 4'd0);

    // output decoder: activate only the output corresponding to the dispensed product
    assign dispense_water     = dispense_enable & (active_product == WATER);
    assign dispense_juice     = dispense_enable & (active_product == JUICE);
    assign dispense_chocolate = dispense_enable & (active_product == CHOCOLATE);
    assign dispense_chips     = dispense_enable & (active_product == CHIPS);

endmodule : datapath
