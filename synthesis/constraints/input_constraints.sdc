# ==============================================================================
# Synopsys Design Constraints (SDC) for GEMINI SoC Top
# Target frequency: 50 MHz reference clock, assuming PLLs handle high-speed internally
# ==============================================================================

# IMPORTANT: Explicitly set the top-level design context for Genus
# Since we elaborated 600+ modules, Genus needs to know the root of the constraint tree.
current_design soc_top

# 1. Clock Definitions
# Define a 50 MHz reference clock (Period = 20 ns)
create_clock -name ref_clk -period 20.0 [get_ports ref_clk]

# Define clock uncertainty (Jitter and Skew margin)
set_clock_uncertainty -setup 0.5 [get_clocks ref_clk]
set_clock_uncertainty -hold 0.1 [get_clocks ref_clk]

# 2. Reset Constraints
# Asynchronous Power-On Reset
# Reset signals typically span multiple clock domains and act asynchronously.
set_false_path -from [get_ports por_n]

# 3. Input Delays
# Set input delay (setup time) for all inputs relative to ref_clk.
# Assuming 4.0 ns max delay from external components
set_input_delay -max 4.0 -clock ref_clk [remove_from_collection [all_inputs] [get_ports {ref_clk por_n}]]
set_input_delay -min 0.5 -clock ref_clk [remove_from_collection [all_inputs] [get_ports {ref_clk por_n}]]

# 4. Output Delays
# Set output delay for all outputs relative to ref_clk.
# Assuming 4.0 ns max delay to external components
set_output_delay -max 4.0 -clock ref_clk [all_outputs]
set_output_delay -min 0.5 -clock ref_clk [all_outputs]

# 5. Specific Interface Constraints (DDR4 / PCIe)
# DDR4 operates on high-speed PHY clocks, but for top-level constraints before 
# physical implementation of the PHY, we constrain them to the ref_clk or define false paths.
# If integrating a true DDR4 PHY IP, these would be timed to the DQS strobes.
set_max_delay 10.0 -from [get_ports ddr4_dq*]
set_max_delay 10.0 -to   [get_ports ddr4_dq*]

# 6. Environmental Conditions
# General driving cell for input ports (e.g. a standard buffer)
# set_driving_cell -lib_cell BUFX2 [all_inputs]

# Output load capacitance (e.g. 10 pF for standard pads)
set_load 10.0 [all_outputs]

# 7. False Paths (Asynchronous interfaces)
# I2C and UART operate much slower than the main system clock and are usually multi-cycle or false paths.
set_false_path -from [get_ports uart_rx_pad]
set_false_path -to   [get_ports uart_tx_pad]
set_false_path -from [get_ports i2c_sda_i]
set_false_path -from [get_ports i2c_scl_i]
set_false_path -to   [get_ports i2c_sda_o]
set_false_path -to   [get_ports i2c_scl_o]

# SPI interfaces operate asynchronously or at divided clocks
set_false_path -from [get_ports spi_miso]
set_false_path -to   [get_ports {spi_mosi spi_sck spi_cs_n}]

# PCIe PIPE interfaces connect to external SerDes PHYs running on recovered clocks
set_false_path -from [get_ports pipe_rx_*]
set_false_path -to   [get_ports pipe_tx_*]

# ==============================================================================
# End of SDC File
# ==============================================================================
