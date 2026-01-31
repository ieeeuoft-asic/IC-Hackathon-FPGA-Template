`timescale 1ns/1ps

module tb;

    // Parameters
    localparam CLK_PERIOD = 10; // 100 MHz
    localparam CLK_BITS   = 10;

    // DUT signals
    logic clk;
    logic rst;
    logic [CLK_BITS-1:0] clk_per_bit;
    logic uart_rx;
    logic uart_tx;

    // Instantiate DUT
    simproc_system #(
        .CLK_BITS(CLK_BITS)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .clk_per_bit(clk_per_bit),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // Clock
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // UART helper task
    task uart_send_byte(input [7:0] data);
        integer i;
        begin
            uart_rx = 0; // start bit
            #(clk_per_bit * CLK_PERIOD);
            for (i = 0; i < 8; i = i+1) begin
                uart_rx = data[i];
                #(clk_per_bit * CLK_PERIOD);
            end
            uart_rx = 1; // stop bit
          #(2 * clk_per_bit * CLK_PERIOD);
        end
    endtask

    // Reset & initialize
    initial begin
        rst = 1;
        uart_rx = 1; // idle
        clk_per_bit = 16; // 16 system clocks per UART bit
        #(CLK_PERIOD*10);
        rst = 0;
    end

    // Single command test
    initial begin
        $dumpfile("obj_dir_sv/wave.vcd"); 
        $dumpvars(0, tb);

        // Wait for reset to finish
        @(negedge rst);
      	#20

        $display("---- TEST: CMD_PING ----");
        
        // Send only the PING command
        uart_send_byte(DUT.CMD_PING);
        uart_send_byte(8'h00); // addr dummy
        uart_send_byte(8'h00); // data dummy
      	#(CLK_PERIOD*clk_per_bit*16);
      
      	// Send only the WRITE command
      	uart_send_byte(DUT.CMD_WRITE);
        uart_send_byte(8'b00); // addr 
      	uart_send_byte(8'h05); // data dummy
      	#(CLK_PERIOD*clk_per_bit*16);
      
      	// Send only the READ command
        uart_send_byte(DUT.CMD_READ);
        uart_send_byte(8'h10); // addr 
      	uart_send_byte(8'h00); // data dummy
        #(CLK_PERIOD*clk_per_bit*16);

        // Send only the RUN command
        uart_send_byte(DUT.CMD_RUN);
        uart_send_byte(8'h10); // addr dummy
      	uart_send_byte(8'h00); // data dummy
        #(CLK_PERIOD*clk_per_bit*16);
      	
      	// rst = 1;
      	// #20
      	// rst = 0;
      	// #20

        // Send only the HALT command
        uart_send_byte(DUT.CMD_HALT);
        uart_send_byte(8'h10); // addr dummy
      	uart_send_byte(8'h00); // data dummy
        #(CLK_PERIOD*clk_per_bit*16);

        // Send only the STEP command
        uart_send_byte(DUT.CMD_STEP);
        uart_send_byte(8'h10); // addr dummy
      	uart_send_byte(8'h00); // data dummy
        #(CLK_PERIOD*clk_per_bit*16);
      	
      	// rst = 1;
      	// #20
      	// rst = 0;
      	// #20

        // Send only the SET_PC command
        uart_send_byte(DUT.CMD_SET_PC);
        uart_send_byte(8'h79); // addr 
      	uart_send_byte(8'h00); // data dummy
        #(CLK_PERIOD*clk_per_bit*16);

        // Send only the GET_PC command
        uart_send_byte(DUT.CMD_GET_PC);
        uart_send_byte(8'h79); // addr dummy
      	uart_send_byte(8'h00); // data dummy
        #(CLK_PERIOD*clk_per_bit*16);

        // Wait a bit for FSM to process
        #(CLK_PERIOD*clk_per_bit*16);

        // Inspect internal signals
        $display("UART TX: %0h", DUT.tx_data);
        $display("tx_en: %b, tx_done: %b", DUT.tx_en, DUT.tx_done);
        $display("run: %b, step_pulse: %b", DUT.run, DUT.step_pulse);
        $display("pc_val: %0h", DUT.pc_val);

        $finish;
    end

endmodule
