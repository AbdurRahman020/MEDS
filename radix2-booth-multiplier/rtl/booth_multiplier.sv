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
    logic load, shift_en;

    // controls the overall multiplication process using an FSM
    controller #(.WIDTH(8)) u_controller (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
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
        .product      (product)
    );

endmodule : booth_multiplier
