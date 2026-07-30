module tb_fifo_controller_ext;

    localparam ADDR_WIDTH = 3;
    localparam DATA_WIDTH = 8;
    localparam DEPTH      = 1 << ADDR_WIDTH;

    logic clk, rst_n;
    logic wr_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic wr_ready;
    logic rd_en;
    logic [DATA_WIDTH-1:0] rd_data;
    logic rd_valid;
    logic full, empty;
    logic [ADDR_WIDTH:0] count;
    logic almost_full, almost_empty;

    int pass_count = 0;
    int fail_count = 0;

    fifo_controller_ext #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .wr_en        (wr_en),
        .wr_data      (wr_data),
        .wr_ready     (wr_ready),
        .rd_en        (rd_en),
        .rd_data      (rd_data),
        .rd_valid     (rd_valid),
        .full         (full),
        .empty        (empty),
        .count        (count),
        .almost_full  (almost_full),
        .almost_empty (almost_empty)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task check(input string name, input logic cond);
        if (cond) begin
            pass_count++;
            $display("[%0t] [PASS] %s", $time, name);
        end else begin
            fail_count++;
            $display("[%0t] [FAIL] %s", $time, name);
        end
    endtask

    task do_reset();
        rst_n   = 0;
        wr_en   = 0;
        rd_en   = 0;
        wr_data = '0;
        repeat (2) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        $display("[%0t] Reset released", $time);
    endtask

    task write_word(input [DATA_WIDTH-1:0] data);
        @(negedge clk);
        wr_data = data;
        wr_en   = 1;
        @(posedge clk); #1;
        $display("[%0t] Wrote 0x%0h | count=%0d full=%b almost_full=%b",
                  $time, data, count, full, almost_full);
        wr_en = 0;
    endtask

    task automatic read_word(output [DATA_WIDTH-1:0] data);
        @(negedge clk);
        rd_en = 1;
        @(posedge clk); #1;
        data = rd_data;
        $display("[%0t] Read  0x%0h | count=%0d empty=%b almost_empty=%b",
                  $time, data, count, empty, almost_empty);
        rd_en = 0;
    endtask

    logic [DATA_WIDTH-1:0] rdata;

    initial begin
        wr_en = 0; rd_en = 0; wr_data = '0;

        do_reset();
        check("reset: empty asserted", empty == 1'b1);
        check("reset: almost_empty deasserted", almost_empty == 1'b0);
        check("reset: almost_full deasserted", almost_full == 1'b0);

        // fill to DEPTH-1: almost_full must assert, full must not
        $display("\n--- Filling to depth-1 ---");
        for (int i = 0; i < DEPTH - 1; i++) write_word(8'(i));
        check("almost_full asserted at depth-1", almost_full == 1'b1);
        check("full NOT asserted at depth-1", full == 1'b0);

        // one more write reaches full: almost_full should drop, full should assert
        write_word(8'(DEPTH - 1));
        check("full asserted at depth", full == 1'b1);
        check("almost_full deasserted once truly full", almost_full == 1'b0);

        // drain down to 1 item remaining: almost_empty must assert, empty must not
        $display("\n--- Draining to 1 item remaining ---");
        for (int i = 0; i < DEPTH - 1; i++) read_word(rdata);
        check("almost_empty asserted at 1 item", almost_empty == 1'b1);
        check("empty NOT asserted at 1 item", empty == 1'b0);

        // final read: FIFO now empty, almost_empty should drop
        read_word(rdata);
        check("empty asserted after final read", empty == 1'b1);
        check("almost_empty deasserted once truly empty", almost_empty == 1'b0);

        $display("\n=== SUMMARY: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fifo_controller_ext);
    end

endmodule : tb_fifo_controller_ext
