module fixed_right_shifter (
    input  logic [3:0] W,
    input  logic shift,
    output logic [3:0] Y,
    output logic k
);

    assign Y[3] = shift ? 1'b0 : W[3];
    assign Y[2] = shift ? W[3] : W[2];
    assign Y[1] = shift ? W[2] : W[1];
    assign Y[0] = shift ? W[1] : W[0];

    assign k = shift ? W[0] : 1'b0;

endmodule: fixed_right_shifter


module barrel_shifter (
    input  logic [3:0] W,
    input  logic [1:0] sel,
    output logic [3:0] Y
);

    always_comb begin
        unique case (sel)

            2'b00: Y = W;

            2'b01: begin
                Y[3] = W[0];
                Y[2] = W[3];
                Y[1] = W[2];
                Y[0] = W[1];
            end

            2'b10: begin
                Y[3] = W[1];
                Y[2] = W[0];
                Y[1] = W[3];
                Y[0] = W[2];
            end

            2'b11: begin
                Y[3] = W[2];
                Y[2] = W[1];
                Y[1] = W[0];
                Y[0] = W[3];
            end

        endcase
    end

endmodule : barrel_shifter
