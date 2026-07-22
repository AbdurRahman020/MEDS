module up_down_counter (
    input  logic       clk,
    input  logic       rst_n,      // active-low asynchronous reset
    input  logic       up_down,
    output logic [3:0] count
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 4'd0;
        else if (up_down)
            count <= count + 4'd1;
        else
            count <= count - 4'd1;
    end

endmodule : up_down_counter
