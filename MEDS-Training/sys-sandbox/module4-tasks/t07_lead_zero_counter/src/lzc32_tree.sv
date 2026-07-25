// top down binary search tree implementation of a 32-bit leading zero counter

module lzc32_tree (
    input  logic [31:0] in,
    output logic [5:0]  out
);

    logic [31:0] x;
    logic [5:0]  count; 

    always_comb begin
        x = in;
        count = 0;

        // level 1: check upper 16 bits
        if (x[31:16] == 16'b0) begin
            count = count + 16;
            x = x << 16;
        end

        // level 2: check upper 8 bits
        if (x[31:24] == 8'b0) begin
            count = count + 8;
            x = x << 8;
        end

        // level 3: check upper 4 bits
        if (x[31:28] == 4'b0) begin
            count = count + 4;
            x = x << 4;
        end

        // level 4: check upper 2 bits
        if (x[31:30] == 2'b0) begin
            count = count + 2;
            x = x << 2;
        end

        // level 5: check the final MSB bit
        if (x[31] == 1'b0) begin
            count = count + 1;
        end

        // handle all-zeros case explicitly
        if (in == 32'b0) begin
            count = 32;
        end

        // drive the actual module output
        out = count; 
    end

endmodule : lzc32_tree


// linear priority-encoder style leading zero counter using a for-loop
module lzc32_loop (
    input  logic [31:0] in,
    output logic [5:0]  out
);

    always_comb begin
        out = 6'd32;   // default: all-zero case

        // scan from MSB down to LSB, first '1' found wins (priority encoder)
        for (int i = 31; i >= 0; i--) begin
            if (in[i]) begin
                out = 31 - i;
                break;
            end
        end
    end

endmodule : lzc32_loop
