
import cocotb
from cocotb.triggers import Timer

@cocotb.test()
async def test_auto_tb(dut):
    """Test ALU operations without clock"""
    cocotb.log.info("Starting simulation test")

    # Example stimulus
    dut.ui_in.value = 0b1110  # 14
    dut.uio_in.value = 0b1001  # 9

    # Test addition
    dut.ena.value = 0b0000
    await Timer(10, units="ns")
    assert dut.uo_out.value == (14 + 9), "Addition failed"

    # Test subtraction
    dut.ena.value = 0b0001
    await Timer(10, units="ns")
    assert dut.uo_out.value == (14 - 9), "Subtraction failed"

    # You can add more cases like multiplication, AND, OR, etc.
    cocotb.log.info("Simulation completed successfully")
