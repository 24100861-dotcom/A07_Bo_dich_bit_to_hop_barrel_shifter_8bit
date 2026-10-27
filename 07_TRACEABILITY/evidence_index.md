# A07 · Chỉ mục bằng chứng và cách tái lập

Phiên bản: v1.0 · Ngày: 2026-10-27

| Bằng chứng | File | Lệnh tạo ra (từ thư mục gốc dự án) |
|---|---|---|
| Mô hình Python PASS | (in ra màn hình) | `python3 05_VERIFICATION/golden_model/reference_model.py` |
| Mô phỏng RTL | `05_VERIFICATION/simulation.log` | `bash 04_IMPLEMENTATION/scripts/01_run_sim.sh` |
| Waveform | `05_VERIFICATION/waveforms/a07_waves.vcd` | như trên |
| Tổng hợp | `06_GDSII/synthesis/synth_stat.txt`, `netlist.v` | `export LIBERTY=~/lib/sky130_fd_sc_hd__tt_025C_1v80.lib; bash 04_IMPLEMENTATION/scripts/02_run_synth.sh` |
| STA | `06_GDSII/sta/timing_report_max.txt`, `timing_report_min.txt` | `sta -no_splash -exit 04_IMPLEMENTATION/scripts/03_run_sta_old.tcl` |
| Độ trễ theo cổng vào | `06_GDSII/sta/per_port_max.txt` | `sta -no_splash -exit 04_IMPLEMENTATION/scripts/05_per_port_delay.tcl > 06_GDSII/sta/per_port_max.txt` |
| Công suất | `06_GDSII/power/power_report.txt` | (do `03_run_sta_old.tcl` tạo) |
| Phiên bản công cụ | `06_GDSII/tool_versions_my_run.txt` | xem `limitations.md` §1 |
