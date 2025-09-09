/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_autocorrelator (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Wire declarations
  wire [31:0] header;
  wire [1:0] cmp_out;
  reg [31:0] sender, receiver;
  reg [4:0] preamble;
  reg rst_cmp, rst_auto;
  
  // Assign inputs from ui_in and uio_in
  always @(*) begin
    preamble = uio_in[4:0];          // Preamble from lower 5 bits of uio_in
    sender = {ui_in, uio_in, ui_in, uio_in}; // Create 32-bit sender from inputs
  end
  
  // Instantiate header generator
  header_gen h1(
    .header(header),
    .preamble(preamble),
    .clk(clk),
    .rst(~rst_n)  // Active high reset
  );
  
  // Instantiate comparator
  cmp32 c1(
    .out(cmp_out),
    .a(sender),
    .b(receiver),
    .clk(clk),
    .rst(~rst_n)  // Active high reset
  );
  
  // Update receiver with generated header
  always @(posedge clk) begin
    if (~rst_n) begin
      receiver <= 32'b0;
    end else begin
      receiver <= header;
    end
  end
  
  // Output assignments
  assign uo_out = {6'b0, cmp_out};   // Output comparison result on lower 2 bits
  assign uio_out = 8'b0;             // Not used
  assign uio_oe = 8'b0;              // All IOs as inputs
  
  // Unused signals to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule

// Header Generator Module - EXACT IMPLEMENTATION FROM PDF
module header_gen(output reg [31:0] header, input [4:0] preamble, input clk, rst);
    reg xor_in1, xor_in2, xor_out;
    reg [4:0] sr;
    reg [31:0] out;
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin 
            sr = preamble; 
            i = 0;
            out = 0;
            header = 0;
        end else begin
            if(i < 31) begin
                xor_in1 = sr[0];
                xor_in2 = sr[3];
                xor_out = xor_in1 ^ xor_in2;
                out[i] = sr[0];
                sr[3:0] = sr[4:1];
                sr[4] = xor_out;
                i = i + 1;
            end
            else if(i == 31) begin
                out[31] = 0;
                header = out;
                i = i + 1;
            end
        end
    end
endmodule

// 32-bit Comparator with Error Detection
module cmp32(output reg [1:0] out, input [31:0] a, b, input clk, rst);
    reg [5:0] count;
    integer i;
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin 
            i = 0; 
            count = 0;
            out = 2'b11;
        end else begin
            if(i < 32) begin
                if(!(a[i] ^ b[i])) count = count + 1;
                i = i + 1;
            end
            else if(i == 32) begin
                case(count)
                    6'b100000: out = 2'b00;
                    6'b011111: out = 2'b01;
                    6'b011110: out = 2'b10;
                    default: out = 2'b11;
                endcase
                i = 0;
                count = 0;
            end
        end
    end
endmodule
