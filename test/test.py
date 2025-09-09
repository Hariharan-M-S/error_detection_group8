# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_auto_tb(dut):
    dut._log.info("Starting simulation test")

    # Create clocks matching your Verilog initial blocks
    cocotb.start_soon(Clock(dut.clk_cmp, 6.4, units="ns").start())   # clk_cmp toggle every 3.2 ns period ~156 MHz
    cocotb.start_soon(Clock(dut.clk_auto, 0.2, units="us").start())  # clk_auto toggle every 0.1 us period 5 MHz

    # Initialize signals as per Verilog initial block
    dut.rst_cmp.value = 1
    dut.rst_auto.value = 1
    dut.preamble.value = 0b00001
    dut.sender.value = 0x7c232be7

    # Reset release sequence following delays from Verilog
    await ClockCycles(dut.clk_auto, 2)  # corresponds to #0.2 us delay
    dut.rst_auto.value = 0
    dut._log.info("rst_auto released")

    await ClockCycles(dut.clk_cmp, 1)   # corresponding to small delay before rst_cmp release
    dut.rst_cmp.value = 0
    dut._log.info("rst_cmp released")

    # Test stimulus sequence from Verilog
    test_values = [0x167c6ea1, 0x167c6ea2, 0x167c6ea3]
    for val in test_values:
        # Apply reset and input changes as in Verilog testbench timing
        dut.rst_cmp.value = 1
        await ClockCycles(dut.clk_cmp, 34)  # Roughly matches #220 delay at clk_cmp frequency

        dut.sender.value = val
        dut.rst_cmp.value = 0
        await ClockCycles(dut.clk_cmp, 2)   # #6 delay approx

        dut._log.info(f"Sender updated to {val:#0x}, out={dut.out.value}")

    # Allow some time for final data propagation
    await ClockCycles(dut.clk_cmp, 34)

    dut._log.info(f"Final Header: {dut.header.value}")
    dut._log.info(f"Final Receiver: {dut.receiver.value}")

    # Optionally add assertions here for automated checks if expected values known
