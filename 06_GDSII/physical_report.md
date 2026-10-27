# A07 · Báo cáo vật lý và thời gian

Phiên bản: v1.0 · Ngày: 2026-10-27

> **Place and route CHƯA chạy.** Mọi số dưới đây ở mức sau tổng hợp (Yosys 0.52-2, OpenSTA bản 2019), chưa có ký sinh dây. Điều kiện: xem `07_TRACEABILITY/limitations.md` §1.

## 1. Tổng hợp (`synthesis/synth_stat.txt`)

| Chỉ số | Giá trị |
|---|---:|
| Số cell | 86 |
| Flip-flop / latch | 0 |
| Diện tích | 425,408 µm² |
| `u_stage1` (S=1) | 31 cell · 152,6464 µm² |
| `u_stage2` (S=2) | 29 cell · 143,8880 µm² |
| `u_stage4` (S=4) | 25 cell · 122,6176 µm² |
| Mức đỉnh (`and3_1` sinh `fill`) | 1 cell · 6,2560 µm² |

## 2. Thời gian (`sta/`)

| Chỉ số | Giá trị |
|---|---:|
| Đường tới hạn | `din[7]` → `dout[1]`, 7 cell |
| Data arrival time | 0,85 ns |
| Slack (so với `vclk` 10 ns) | 9,15 ns (MET) |
| WNS / TNS | 0,00 / 0,00 |
| Đường nhanh nhất | `shamt[2]` → `dout[0]`, 0,03 ns, 1 cell |

Độ trễ từng đoạn: `fill` 0,17 · `u_stage1` 0,26 · `u_stage2` 0,27 · `u_stage4` 0,15 ns. Độ trễ xấu nhất theo cổng vào: `shamt[0]` 0,72 · `shamt[1]` 0,40 · `shamt[2]` 0,41 · `mode[0]` 0,85 · `mode[1]` 0,83 · `din[0]` 0,74 · `din[7]` 0,85 ns (`sta/per_port_max.txt`).

## 3. Công suất (`power/power_report.txt`)

| Nhóm | Công suất | Tỉ lệ |
|---|---:|---:|
| Sequential | 0,00 W | 0,0 % |
| Combinational | 2,70·10⁻⁵ W | 100,0 % |
| Tổng | 2,70·10⁻⁵ W | 100,0 % |

Activity mặc định, chỉ đọc ở mức thứ tự độ lớn.

## 4. Chưa chạy

Floorplan, placement, routing, DRC, LVS, GDSII. Script `04_IMPLEMENTATION/scripts/04_run_librelane.sh` đã có nhưng cần PDK sky130A và LibreLane; đây là phần mở rộng tự nguyện theo Charter mục 3.
