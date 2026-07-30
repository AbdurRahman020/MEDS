module tb_and_gate; 
    logic a, b, y;
    logic [1:0] ab;

    and_gate dut (
        .a(a), 
        .b(b), 
        .y(y)
    );

    task automatic check (input logic a_in, input logic b_in, input logic expected_y);
        if (y !== expected_y) begin
            $display("Test failed for a=%0b, b=%0b: expected y=%0b, got y=%0b", a, b, expected_y, y);
        end else begin
            $display("Test passed for a=%0b, b=%0b: y=%0b", a, b, y);
        end
    
    endtask

    integer i;

    initial begin
        for (i = 0; i < 4; i++) begin
            {a, b} = i[1:0];
            #10;
            check(a, b, a & b);
        end

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_and_gate);
    end

endmodule : tb_and_gate
