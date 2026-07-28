module booth_multiplier (
    input  logic clk,
    input  logic rst,
    input  logic start,

    input  logic signed [7:0]  multiplicand,
    input  logic signed [7:0]  multiplier,

    output logic signed [15:0] product,
    output logic busy,
    output logic done
);

    // control signals between the controller and datapath
    logic load, shift_en, iter_done;

    // controls the overall multiplication process using an FSM
    controller u_controller (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .iter_done (iter_done),
        .load      (load),
        .shift_en  (shift_en),
        .busy      (busy),
        .done      (done)
    );

    // performs the Booth multiplication operations
    datapath #(.WIDTH(8)) u_datapath (
        .clk          (clk),
        .rst          (rst),
        .load         (load),
        .shift_en     (shift_en),
        .multiplicand (multiplicand),
        .multiplier   (multiplier),
        .iter_done    (iter_done),
        .product      (product)
    );

endmodule : booth_multiplier