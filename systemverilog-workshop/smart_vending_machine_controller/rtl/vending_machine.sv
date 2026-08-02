module vending_machine (
    input  logic clk,
    input  logic reset,
    input  logic coin_inserted,
    input  logic select_water,
    input  logic select_juice,
    input  logic select_chocolate,
    input  logic select_chips,
    input  logic cancel,
    input  logic refill,

    output logic       dispense_water,
    output logic       dispense_juice,
    output logic       dispense_chocolate,
    output logic       dispense_chips,
    output logic       return_change,
    output logic [3:0] change_amount,
    output logic [3:0] current_balance,
    output logic       out_of_stock,
    output logic       insufficient_balance,
    output logic       transaction_complete
);

    // internal signals connecting the controller and datapath
    logic       sufficient_balance, product_available, max_balance;
    logic       selection_valid, change_nonzero;
    logic [1:0] selected_product;
    logic       increment_balance, clear_balance, decrement_stock;
    logic       refill_stock, dispense_enable, return_change_enable;

    // controller fsm: generates control signals based on datapath status
    controller u_controller (
        .clk(clk),
        .reset(reset),
        .select_water(select_water),
        .select_juice(select_juice),
        .select_chocolate(select_chocolate),
        .select_chips(select_chips),
        .cancel(cancel),
        .refill(refill),
        .sufficient_balance(sufficient_balance),
        .product_available(product_available),
        .max_balance(max_balance),
        .selection_valid(selection_valid),
        .change_nonzero(change_nonzero),
        .selected_product(selected_product),
        .increment_balance(increment_balance),
        .clear_balance(clear_balance),
        .decrement_stock(decrement_stock),
        .refill_stock(refill_stock),
        .dispense_enable(dispense_enable),
        .return_change_enable(return_change_enable),
        .out_of_stock(out_of_stock),
        .insufficient_balance(insufficient_balance),
        .transaction_complete(transaction_complete)
    );

    // datapath: manages balance, stock, change calculation, and product dispensing
    datapath u_datapath (
        .clk(clk),
        .reset(reset),
        .coin_inserted(coin_inserted),
        .select_water(select_water),
        .select_juice(select_juice),
        .select_chocolate(select_chocolate),
        .select_chips(select_chips),
        .increment_balance(increment_balance),
        .clear_balance(clear_balance),
        .decrement_stock(decrement_stock),
        .refill_stock(refill_stock),
        .dispense_enable(dispense_enable),
        .return_change_enable(return_change_enable),
        .sufficient_balance(sufficient_balance),
        .product_available(product_available),
        .max_balance(max_balance),
        .selection_valid(selection_valid),
        .change_nonzero(change_nonzero),
        .selected_product(selected_product),
        .dispense_water(dispense_water),
        .dispense_juice(dispense_juice),
        .dispense_chocolate(dispense_chocolate),
        .dispense_chips(dispense_chips),
        .return_change(return_change),
        .change_amount(change_amount),
        .current_balance(current_balance)
    );

endmodule : vending_machine
