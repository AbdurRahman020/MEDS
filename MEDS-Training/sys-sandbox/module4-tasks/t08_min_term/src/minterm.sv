module mux4to1(
    input  logic s1, s0, d0, d1, d2, d3,
    output logic y
);

    always_comb begin
        case ({s1,s0})
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            2'b11: y = d3;
        endcase
    end

endmodule: mux4to1


// F = Σm(1,2,3,6,7)
module func_F(
    input  logic a, b, c,
    output logic F
);

    mux4to1 M1(
        .s1(a),
        .s0(b),
        .d0(c),      // d0 = c
        .d1(1'b1),   // d1 = 1
        .d2(1'b0),   // d2 = 0
        .d3(1'b1),   // d3 = 1
        .y(F)
    );

endmodule : func_F
