module tb_fifo_controller;

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

    int pass_count = 0;
    int fail_count = 0;

    fifo_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (wr_en),
        .wr_data  (wr_data),
        .wr_ready (wr_ready),
        .rd_en    (rd_en),
        .rd_data  (rd_data),
        .rd_valid (rd_valid),
        .full     (full),
        .empty    (empty),
        .count    (count)
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
        $display("[%0t] Wrote 0x%0h | wr_ready=%b full=%b count=%0d", $time, data, wr_ready, full, count);
        wr_en = 0;
    endtask

    task automatic read_word(output [DATA_WIDTH-1:0] data);
        @(negedge clk);
        rd_en = 1;
        @(posedge clk); #1;
        data = rd_data;
        $display("[%0t] Read  0x%0h | rd_valid=%b empty=%b count=%0d", $time, data, rd_valid, empty, count);
        rd_en = 0;
    endtask

    logic [DATA_WIDTH-1:0] rdata;

    initial begin
        wr_en = 0; rd_en = 0; wr_data = '0;

        // reset behaviour
        do_reset();
        check("reset: empty asserted", empty == 1'b1);
        check("reset: full deasserted", full == 1'b0);
        check("reset: count is zero", count == 0);

        // normal write/read, FIFO ordering
        $display("\n--- Normal write/read ---");
        write_word(8'hA1);
        write_word(8'hB2);
        write_word(8'hC3);
        check("count after 3 writes", count == 3);
        read_word(rdata); check("FIFO order: 1st byte back is A1", rdata == 8'hA1);
        read_word(rdata); check("FIFO order: 2nd byte back is B2", rdata == 8'hB2);
        read_word(rdata); check("FIFO order: 3rd byte back is C3", rdata == 8'hC3);
        check("count returns to zero", count == 0);
        check("empty after draining", empty == 1'b1);

        // fill to full
        $display("\n--- Filling to full ---");
        for (int i = 0; i < DEPTH; i++) write_word(8'(i));
        check("full asserted at depth", full == 1'b1);
        check("wr_ready deasserted when full", wr_ready == 1'b0);
        check("count equals depth", count == DEPTH);

        // overflow: write on full FIFO must not corrupt stored data
        write_word(8'hFF);
        check("overflow write ignored: count unchanged", count == DEPTH);

        // drain and confirm overflow write did not sneak in / corrupt anything
        $display("\n--- Draining, checking overflow did not corrupt data ---");
        for (int i = 0; i < DEPTH; i++) begin
            read_word(rdata);
            check($sformatf("overflow check: byte %0d intact", i), rdata == 8'(i));
        end
        check("empty after full drain", empty == 1'b1);

        // underflow: read on empty FIFO must not corrupt / advance
        read_word(rdata);
        check("underflow read: rd_valid low", rd_valid == 1'b0);
        check("underflow read: count stays zero", count == 0);

        // simultaneous read and write
        $display("\n--- Simultaneous read/write ---");
        write_word(8'h11);
        @(negedge clk);
        wr_data = 8'h22; wr_en = 1; rd_en = 1;
        @(posedge clk); #1;
        check("simultaneous r/w: count stays at 1", count == 1);
        check("simultaneous r/w: read got 0x11", rd_data == 8'h11);
        wr_en = 0; rd_en = 0;
        read_word(rdata);
        check("simultaneous r/w: 2nd write readable as 0x22", rdata == 8'h22);

        $display("\n=== SUMMARY: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_fifo_controller);
    end

endmodule : tb_fifo_controller
