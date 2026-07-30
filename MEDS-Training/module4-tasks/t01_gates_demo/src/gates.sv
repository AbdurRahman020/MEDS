module gates_demo (
    input logic a, b,
    output logic y_or, y_and, y_xor
);
  
    assign y_or = a | b;
    assign y_and = a & b;
    assign y_xor = a ^ b;
  
endmodule : gates_demo
