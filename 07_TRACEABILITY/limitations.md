# A07 · Kết luận và giới hạn

Phiên bản: v1.0 · Ngày: 2026-10-27

## 1. Điều kiện tạo ra bằng chứng

| Hạng mục | Giá trị |
|---|---|
| Hệ điều hành | Ubuntu 26.04.1 LTS (chạy trong WSL) |
| Mô phỏng | Icarus Verilog 12.0-3 (`-g2012`) |
| Tổng hợp | Yosys 0.52-2 |
| STA + công suất | OpenSTA, gói Ubuntu `opensta` 0~20191111 |
| Thư viện | `sky130_fd_sc_hd__tt_025C_1v80.lib` (typical, 25 °C, 1,80 V) |
| Ràng buộc | clock ảo `vclk` 10 ns, input/output delay 0 (`design.sdc`) |
| Script STA | `03_run_sta_old.tcl`, `05_per_port_delay.tcl` (bản OpenSTA cũ không nhận `-group_path_count`) |

## 2. Đã chứng minh được

1. Hàm của `a07_barrel8` đúng trên toàn bộ không gian đầu vào: 8 192/8 192 tổ hợp, 8 215 vector, 0 sai lệch so với hai mô hình chuẩn độc lập (`simulation.log`).
2. Chín bất biến của đặc tả giữ trên toàn bộ vector: 17 458 lần kiểm, 0 vi phạm.
3. Mô hình Python ba tầng 1-2-4 trùng khít mô hình toán tử trên 8 192 tổ hợp (35/35 phép kiểm).
4. 0 ô nhớ: 0 flip-flop trong bảng cell của Yosys (86 cell), và công suất nhóm Sequential = 0,0 % trong báo cáo OpenSTA.
5. Cấu trúc ba tầng có thật trong netlist đã tổng hợp: ba instance `u_stage1`, `u_stage2`, `u_stage4` trong phân cấp, và ba tên đó trên đường tới hạn.
6. Đường tới hạn `din[7]` → `dout[1]` dài 0,85 ns, qua 7 cell; độ trễ các đoạn: `fill` 0,17; tầng 1: 0,26; tầng 2: 0,27; tầng 4: 0,15 ns. Slack 9,15 ns so với `vclk` 10 ns.
7. Ngân sách chân vừa: 13 bit vào + 8 bit ra = 21/24.

## 3. Chưa chứng minh được

| Chưa chứng minh | Vì sao |
|---|---|
| Netlist tương đương RTL | Chưa mô phỏng gate-level |
| Không có glitch gây hại | Mô phỏng RTL là zero-delay |
| Độ trễ thật sau routing | Số liệu sau tổng hợp, chưa có ký sinh dây (RC) |
| Biên an toàn qua các góc PVT | Chỉ đo một góc: typical, 25 °C, 1,80 V |
| Công suất thật của ứng dụng | Activity mặc định, không lấy từ VCD của ứng dụng |
| Layout đúng quy tắc (DRC), khớp netlist (LVS), có GDSII | Chưa chạy place and route |
| Kiến trúc ba tầng tốt hơn `case` 8 nhánh bằng số của tôi | Các số V2 đến V5 là của gói gốc (Yosys 0.33, OpenSTA 3.1.0), tôi chưa đo lại |
| So sánh với số của gói gốc | Khác phiên bản công cụ (Yosys 0.52 và OpenSTA 2019 so với 0.33 và 3.1.0): 86 cell, 425,408 µm², 0,85 ns so với 75 cell, 411,6448 µm², 0,78 ns. Không so chéo hai môi trường |
| Độ chính xác của OpenSTA bản 2019 | Bản cũ so với 3.1.0; báo cáo làm tròn 0,01 ns nên cộng dồn có thể lệch 0,01 ns |

## 4. Ngoài phạm vi, không được khẳng định

Không viết "đã sign-off", "đã tape-out", "đã chế tạo", "đã kiểm tra sau chế tạo", "chạy được ở XXX MHz". Chu kỳ 10 ns của `vclk` chỉ là mốc quy chiếu để STA tính slack, không phải yêu cầu tần số. Dịch vòng (rotate) và dịch trên dữ liệu rộng hơn 8 bit nằm ngoài phạm vi theo Charter mục 3.
