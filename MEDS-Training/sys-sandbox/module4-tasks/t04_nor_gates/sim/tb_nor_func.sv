module tb_nor_func;
    logic a, b, c, d, f;

    nor_only dut (
        .a(a), 
        .b(b), 
        .c(c), 
        .d(d), 
        .f(f)
    );

    task automatic test_nor(input logic a_in, input logic b_in, input logic c_in, input logic d_in);
        begin
            a = a_in; b = b_in; c = c_in; d = d_in;
            $display("a=%0b b=%0b c=%0b d=%0b f=%0b", a, b, c, d, f);
        end
    endtask

    initial begin
        for (int i = 0; i < 16; i++) begin
            test_nor(i[3], i[2], i[1], i[0]);
            #10;
        end
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_nor_func);
    end

endmodule : tb_nor_func
