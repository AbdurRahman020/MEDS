module tb_gates;
    logic a, b, y1, y2, y3;
  
    gates_demo dut (
      .a(a), 
      .b(b), 
      .y_or(y1), 
      .y_and(y2), 
      .y_xor(y3)
    );
      
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
        
        a = 0; b = 0; #10;
        $display("a=%0b b=%0b y_or=%0b y_and=%0b y_xor=%0b", a, b, y1, y2, y3);
        a = 1; b = 0; #10;
        $display("a=%0b b=%0b y_or=%0b y_and=%0b y_xor=%0b", a, b, y1, y2, y3);
        a = 0; b = 1; #10;
        $display("a=%0b b=%0b y_or=%0b y_and=%0b y_xor=%0b", a, b, y1, y2, y3);
        a = 1; b = 1; #10;
        $display("a=%0b b=%0b y_or=%0b y_and=%0b y_xor=%0b", a, b, y1, y2, y3);
          
        $finish;
    end

endmodule : tb_gates
