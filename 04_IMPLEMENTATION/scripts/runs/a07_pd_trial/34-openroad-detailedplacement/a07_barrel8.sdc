###############################################################################
# Created by write_sdc
###############################################################################
current_design a07_barrel8
###############################################################################
# Timing Constraints
###############################################################################
create_clock -name vclk -period 10.0000 
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {din[0]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {din[1]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {din[2]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {din[3]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {din[4]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {din[5]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {din[6]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {din[7]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {mode[0]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {mode[1]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {shamt[0]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {shamt[1]}]
set_input_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {shamt[2]}]
set_output_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {dout[0]}]
set_output_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {dout[1]}]
set_output_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {dout[2]}]
set_output_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {dout[3]}]
set_output_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {dout[4]}]
set_output_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {dout[5]}]
set_output_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {dout[6]}]
set_output_delay 0.0000 -clock [get_clocks {vclk}] -add_delay [get_ports {dout[7]}]
###############################################################################
# Environment
###############################################################################
###############################################################################
# Design Rules
###############################################################################
