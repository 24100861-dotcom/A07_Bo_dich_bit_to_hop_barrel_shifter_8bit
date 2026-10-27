# Do do tre xau nhat (max) xuat phat tu tung cong vao
read_liberty $::env(LIBERTY)
read_verilog 06_GDSII/synthesis/netlist.v
link_design a07_barrel8
read_sdc 04_IMPLEMENTATION/constraints/design.sdc
foreach p {shamt\[0\] shamt\[1\] shamt\[2\] mode\[0\] mode\[1\] din\[0\] din\[7\]} {
  puts "=========== TU CONG VAO: $p"
  report_checks -path_delay max -from [get_ports $p]
}
