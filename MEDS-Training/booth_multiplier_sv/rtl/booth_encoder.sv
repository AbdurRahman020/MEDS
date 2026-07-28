module booth_encoder (
    input  logic q0,      // LSB of the multiplier register (Q)
    input  logic q_m1,    // previous LSB (Q-1)

    output logic add_en,  // enables A + M operation
    output logic sub_en   // enables A - M operation
);

    // Booth encoding rules:
    //      01 -> add M
    //      10 -> subtract M
    assign add_en = (q0 == 1'b0) && (q_m1 == 1'b1);
    assign sub_en = (q0 == 1'b1) && (q_m1 == 1'b0);

endmodule : booth_encoder
