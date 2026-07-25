module fifo_controller #(
    parameter int ADDR_WIDTH = 3,   // depth = 2**ADDR_WIDTH
    parameter int DATA_WIDTH = 8
)(
    input  logic                  clk,
    input  logic                  rst_n,     // async active-low reset

    // write port
    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic                  wr_ready,

    // read port
    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  rd_valid,

    // status
    output logic                  full,
    output logic                  empty,
    output logic [ADDR_WIDTH:0]   count
);

    localparam int DEPTH = 1 << ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH:0]   wr_ptr, rd_ptr;   // extra MSB disambiguates full vs empty

    // write pointer + memory write
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
        end else if (wr_en && wr_ready) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // read pointer (fall-through read: rd_data tracks mem[rd_ptr] combinationally)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr <= '0;
        end else if (rd_en && rd_valid) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

    // status logic
    always_comb begin
        rd_data  = mem[rd_ptr[ADDR_WIDTH-1:0]];
        full     = (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]) && (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]);
        empty    = (wr_ptr == rd_ptr);
        count    = wr_ptr - rd_ptr;
        wr_ready = !full;
        rd_valid = !empty;
    end

endmodule : fifo_controller
