`timescale 1ns/1ps

module tb;
    logic a;
    logic b;
    logic c;

    // Instantiate the AND gate
    top uut (
        .a(a),
        .b(b),
        .c(c)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    // Clock not needed, just stimulus
    initial begin
        
        // Print header
        $display("Time\t a b | c");
        $display("----------------");

        // Test all combinations
        a = 0; b = 0; #10 $display("%0t\t %b %b | %b", $time, a, b, c);
        a = 0; b = 1; #10 $display("%0t\t %b %b | %b", $time, a, b, c);
        a = 1; b = 0; #10 $display("%0t\t %b %b | %b", $time, a, b, c);
        a = 1; b = 1; #10 $display("%0t\t %b %b | %b", $time, a, b, c);

        $display("Testbench finished!");
        $finish;
    end
endmodule
