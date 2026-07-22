module parity_check (
    input logic [3:0] data_in,
    output logic parity_out
);
    
    assign parity_out = ^data_in;
    
endmodule : parity_check
