module tb_parity_check;
    logic [3:0] data_in;
    logic parity_out;

    parity_check dut (
        .data_in(data_in),
        .parity_out(parity_out)
    );

    task automatic check (input logic [3:0] data);
        logic expected_parity;

        begin
            expected_parity = $countones(data) % 2; // odd parity

            data_in = data;
            #10;

            if (parity_out !== expected_parity) begin
                $display("Test FAILED: data_in=%b expected=%b got=%b",
                 data, expected_parity, parity_out);
            end else begin
                $display("Test PASSED: data_in=%b parity_out=%b", data, parity_out);
            end
        end
    endtask

    initial begin
        for (int i = 0; i < 16; i++) begin
            check(i[3:0]);
        end
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_parity_check);
    end

endmodule : tb_parity_check
