module datapath #(
    parameter int WIDTH = 8
)(
    input  logic                      clk,
    input  logic                      rst,
    input  logic                      load,
    input  logic                      shift_en,

    input  logic signed [WIDTH-1:0]   multiplicand,
    input  logic signed [WIDTH-1:0]   multiplier,

    output logic                      iter_done,
    output logic signed [2*WIDTH-1:0] product
);

    // internal registers used in Booth's algorithm
    logic signed [WIDTH-1:0] m_reg;
    logic signed [WIDTH-1:0] a_reg;
    logic        [WIDTH-1:0] q_reg;
    logic                    q_m1;

    // Control and next-state signals
    logic add_en, sub_en;
    logic signed [WIDTH-1:0] a_next;
    logic        [WIDTH-1:0] q_next;
    logic                    q_m1_next;

    // generates add/subtract control signals based on Q[0] and Q-1
    booth_encoder u_encoder (
        .q0     (q_reg[0]),
        .q_m1   (q_m1),
        .add_en (add_en),
        .sub_en (sub_en)
    );

    // performs Booth add/sub operation followed by arithmetic right shift
    alu #(.WIDTH(WIDTH)) u_alu (
        .a_reg     (a_reg),
        .m_reg     (m_reg),
        .q_reg     (q_reg),
        .add_en    (add_en),
        .sub_en    (sub_en),
        .a_next    (a_next),
        .q_next    (q_next),
        .q_m1_next (q_m1_next)
    );

    // keeps track of the number of Booth iterations
    counter #(.WIDTH(WIDTH)) u_counter (
        .clk       (clk),
        .rst       (rst),
        .load      (load),
        .shift_en  (shift_en),
        .iter_done (iter_done)
    );

    // stores and updates Booth registers
    always_ff @(posedge clk) begin
        if (rst) begin
            m_reg <= '0;
            a_reg <= '0;
            q_reg <= '0;
            q_m1  <= 1'b0;
        end
        else if (load) begin
            m_reg <= multiplicand;
            a_reg <= '0;
            q_reg <= multiplier;
            q_m1  <= 1'b0;
        end
        else if (shift_en) begin
            a_reg <= a_next;
            q_reg <= q_next;
            q_m1  <= q_m1_next;
        end
    end

    // final product is obtained by concatenating A and Q
    assign product = {a_reg, q_reg};

endmodule : datapath
