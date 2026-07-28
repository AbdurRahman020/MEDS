module counter #(
    parameter int WIDTH = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic load,
    input  logic shift_en,

    output logic iter_done
);

    // counts the remaining Booth iterations
    logic [$clog2(WIDTH+1)-1:0] count;

    always_ff @(posedge clk) begin
        if (rst)
            count <= '0;
        else if (load)
            count <= WIDTH;          // initialize counter to operand width
        else if (shift_en)
            count <= count - 1'b1;   // decrement after each Booth iteration
    end

    // indicates that the current iteration is the last one
    assign iter_done = (count == 1);

endmodule : counter
