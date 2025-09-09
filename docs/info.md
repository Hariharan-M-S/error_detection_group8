<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements an autocorrelator with 2-bit error tolerance in digital logic.
A serial input bitstream is shifted into a window of configurable length (default: 32 bits).
At each clock cycle, the circuit compares this window against a fixed reference pattern.
The number of mismatched bits is counted using an adder-tree (Hamming distance).
If the mismatch count is less than or equal to 2, the circuit declares a valid match by asserting the hit output.
This allows reliable pattern detection even with up to 2 bit errors

## How to test

Connect a clock and reset to the design inputs.

Drive the ui_in[0] pin with a serial bitstream containing the target pattern.

Observe the uo_out[0] signal: it goes high whenever the reference pattern is detected with at most 2 errors.

The uo_out[1] signal indicates when the sliding window is full and the detector is active.

Optional: ui_in[7:1] can select between multiple reference patterns for demonstration.

A simple test is to feed the exact reference pattern serially; uo_out[0] should go high. If you flip one or two bits, it still goes high. With three or more flipped bits, it remains low.

## External hardware
No external hardware is required.
