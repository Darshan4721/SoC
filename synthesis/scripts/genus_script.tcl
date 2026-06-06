# ==============================================================================
# PROFESSIONAL GENUS SYNTHESIS SCRIPT
# TOP MODULE: soc_top
# INVOCATION DIRECTORY: /home/DARSHAN/Projects/soc_v2/synthesis/work
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Setup
# ------------------------------------------------------------------------------
set TOP_MODULE soc_top

# Read the standard cell library (adjust path if necessary)
read_libs /home/ece-server/cadance_install/FOUNDRY/digital/90nm/dig/lib/slow.lib

# ------------------------------------------------------------------------------
# 2. Read RTL File List
# ------------------------------------------------------------------------------
puts "--- Reading SystemVerilog RTL files ---"
read_hdl -sv [glob ../../code/*.sv]

# Elaborate the design
puts "--- Elaborating Design ---"
elaborate

# ------------------------------------------------------------------------------
# 3. Apply Constraints
# ------------------------------------------------------------------------------
puts "--- Applying SDC Constraints ---"
read_sdc ../constraints/input_constraints.sdc

# ------------------------------------------------------------------------------
# 4. Synthesis Flow
# ------------------------------------------------------------------------------
puts "--- Synthesizing Generic Gates ---"
syn_generic

puts "--- Mapping to Technology Library ---"
syn_map

puts "--- Optimizing Timing/Area/Power ---"
syn_opt

# ------------------------------------------------------------------------------
# 5. Write Outputs
# ------------------------------------------------------------------------------
puts "--- Writing Outputs ---"

# Create output and report directories if they don't exist
exec mkdir -p ../output ../logs ../reports/area ../reports/power ../reports/qor ../reports/timing ../reports/cell ../reports/clock ../reports/constraints

write_hdl > ../output/${TOP_MODULE}_netlist.v
write_sdc > ../output/${TOP_MODULE}_output_constraints.sdc

write_do_lec \
    -revised_design ../output/${TOP_MODULE}_netlist.v \
    -logfile ../logs/${TOP_MODULE}_lec.log \
    > ../output/${TOP_MODULE}_lec.do

write_design -base_name ../output/${TOP_MODULE}

# ------------------------------------------------------------------------------
# 6. Reports
# ------------------------------------------------------------------------------
puts "--- Generating Reports ---"

report_area              > ../reports/area/${TOP_MODULE}_area.rpt
report_power             > ../reports/power/${TOP_MODULE}_power.rpt
report_qor               > ../reports/qor/${TOP_MODULE}_qor.rpt
report_timing            > ../reports/timing/${TOP_MODULE}_timing.rpt
report_timing -lint      > ../reports/timing/${TOP_MODULE}_timing_lint.rpt
report_gates             > ../reports/cell/${TOP_MODULE}_gates.rpt
report_clock_gating      > ../reports/clock/${TOP_MODULE}_clock_gating.rpt
report_design_rules      > ../reports/constraints/${TOP_MODULE}_design_rules.rpt

puts "--- Synthesis Finished Successfully ---"

gui_show