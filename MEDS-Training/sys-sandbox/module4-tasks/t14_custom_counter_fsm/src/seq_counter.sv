module seq_counter_01347 (
    input  logic clk, rst_n,
    output logic [2:0] q
);

    logic t2, t1, t0;

    assign t2 = q[1] & q[0];
    assign t1 = q[2] | q[0];
    assign t0 = q[2] | q[1] | ~q[0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 3'b000;
        end else begin
            q[2] <= q[2] ^ t2;
            q[1] <= q[1] ^ t1;
            q[0] <= q[0] ^ t0;
        end
    end

endmodule : seq_counter_01347
