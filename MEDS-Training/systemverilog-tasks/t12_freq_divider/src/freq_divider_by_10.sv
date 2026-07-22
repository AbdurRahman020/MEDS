module freq_divider_by_10 (
    input  logic clk,
    input  logic a_rst,
    output logic div_clk
);

    // counter used to divide the input clock frequency
    logic [3:0] count;

    // count input clock cycles and toggle the output after every 10 clock cycles
    always_ff @(posedge clk or posedge a_rst) begin
        if (a_rst) begin
            count   <= 4'd0;
            div_clk <= 1'b0;
        end
        else begin
            if (count == 4'd9) begin
                count   <= 4'd0;
                div_clk <= ~div_clk;      // toggle the divided clock
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule : freq_divider_by_10
