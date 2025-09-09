`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Dump the signals to a VCD file
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Replace tt_um_example with your module name:
  tt_um_autocorrelator dut (
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  // Test sequence
  initial begin
    // Initialize
    ena = 1;
    rst_n = 0;
    ui_in = 8'h7c;
    uio_in = 8'h23; // preamble = 5'b00001 (lower 5 bits)
    
    $display("Starting simulation with preamble: %b", uio_in[4:0]);
    
    // Release reset after some time
    #20 rst_n = 1;
    $display("Reset released");
    
    // Wait for header generation
    #500;
    
    // Test sequence 1
    ui_in = 8'h16;
    uio_in = 8'h7c;
    #200;
    $display("Test 1: ui_in=%h, uio_in=%h, uo_out=%h", ui_in, uio_in, uo_out);
    
    // Test sequence 2
    ui_in = 8'h6e;
    uio_in = 8'ha2;
    #200;
    $display("Test 2: ui_in=%h, uio_in=%h, uo_out=%h", ui_in, uio_in, uo_out);
    
    // Test sequence 3
    ui_in = 8'h6e;
    uio_in = 8'ha3;
    #200;
    $display("Test 3: ui_in=%h, uio_in=%h, uo_out=%h", ui_in, uio_in, uo_out);
    
    #200;
    $display("Simulation completed");
    $finish;
  end

  // Monitor outputs
  always @(posedge clk) begin
    if (rst_n) begin
      $display("Time %0t: uo_out = %b (cmp_result = %b)", $time, uo_out, uo_out[1:0]);
    end
  end

endmodule
