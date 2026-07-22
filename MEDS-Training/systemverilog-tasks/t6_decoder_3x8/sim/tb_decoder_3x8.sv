module tb_decoder3to8;
    
    logic en;
    logic [2:0] sel;
    logic [7:0] y;

    decoder3to8 dut (
        .en(en),
        .sel(sel),
        .y(y)
    );

    task automatic check_decoder (
        input logic en_val, 
        input logic [2:0] sel_val, 
        input logic [7:0] expected_y
    );
    begin
        en = en_val;
        sel = sel_val;
        #10;
        if (y !== expected_y) begin
            $display("Test failed for en=%0b sel=%b: expected y=%b, got y=%b", en, sel, expected_y, y);
        end else begin
            $display("Test passed for en=%0b sel=%b: y=%b", en, sel, y);
        end
    end
    endtask

    initial begin
        // test all combinations of en and sel
        for (int i = 0; i < 2; i++) begin
            for (int j = 0; j < 8; j++) begin
                logic [7:0] expected_y;
                if (i == 0) begin
                    expected_y = 8'b00000000;           // disabled: every output forced low
                end else begin
                    expected_y = 8'b00000001 << j;      // enabled: only the selected output is high
                end
                check_decoder(i, j[2:0], expected_y);
            end
        end

        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_decoder3to8);
    end

endmodule: tb_decoder3to8
