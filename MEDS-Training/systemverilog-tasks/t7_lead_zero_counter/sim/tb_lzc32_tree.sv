module tb_lzc32;
    logic [31:0] in;
    logic [5:0]  out;

    lzc32_tree dut (
        .in(in),
        .out(out)
    );

    task automatic check_tree (
        input logic [31:0] test_in, 
        input logic [5:0] expected_out
    );
    begin
        in = test_in;
        #1;
        if (out !== expected_out) begin
            $display("Test failed for input %h: expected %d, got %d", test_in, expected_out, out);
        end else begin
            $display("Test passed for input %h: got %d", test_in, out);
        end
    end
    endtask
    
    initial begin
        for (int i = 0; i < 32; i++) begin
            check_tree(32'h00000001 << i, 31 - i);
        end
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_lzc32);
    end

endmodule : tb_lzc32
