module nor_only (
    input logic a, b, c, d,
    output logic f
);

    // assign f =  (b | c | d) & (~a | b | c) & (~a | d);

    logic a_n;
    logic x_n, y_n, z_n;

    assign a_n = ~(a | a);          // a' = ~(a + a) = ~a

    assign x_n = ~(b | c | d);      // (b + c + d)'
    assign y_n = ~(a_n | b | c);    // (a' + b + c)'
    assign z_n = ~(a_n | d);        // (a' + d)'

    assign f = ~(x_n | y_n | z_n);

endmodule : nor_only
