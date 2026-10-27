# A07 - STA cho OpenSTA ban cu (2019). Giu nguyen y nghia ban goc.
set lib_file $::env(LIBERTY)
read_liberty $lib_file
read_verilog 06_GDSII/synthesis/netlist.v
link_design a07_barrel8
read_sdc 04_IMPLEMENTATION/constraints/design.sdc
report_checks -path_delay max -group_count 12 -fields {slew cap input_pin net fanout} > 06_GDSII/sta/timing_report_max.txt
report_checks -path_delay min -group_count 5 > 06_GDSII/sta/timing_report_min.txt
report_wns > 06_GDSII/sta/wns.txt
report_tns > 06_GDSII/sta/tns.txt
report_power > 06_GDSII/power/power_report.txt
