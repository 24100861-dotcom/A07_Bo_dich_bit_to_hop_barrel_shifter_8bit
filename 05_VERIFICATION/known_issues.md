# A07 · Sự cố đã biết và cách xử lý (Known Issues)

---

## SỰ CỐ #1 — Mã nguồn trong gói thuộc về một đề KHÁC

**Mức độ:** 🔴 Nghiêm trọng (sai hoàn toàn đề bài)
**Trạng thái:** ✅ **ĐÃ XỬ LÝ** — thiết kế lại từ đầu
**Ngày phát hiện / xử lý:** 2026-09-24

### 1. Hiện tượng

Gói hồ sơ A07 mang tên đề *"Bộ dịch bit tổ hợp (barrel shifter) 8-bit"*, nhưng RTL bên
trong là một **ALU 4 phép** (`a07_alu`) — cộng, trừ, AND, OR — **không có một toán tử dịch
nào**.

| | Charter đòi | Gói chứa |
|---|---|---|
| Chức năng | Barrel shifter 8-bit, dịch 0–7 | ALU 4 phép ADD/SUB/AND/OR |
| Module đỉnh | — | `a07_alu` |
| Cổng vào | `din[7:0]`, `shamt[2:0]`, `mode[1:0]` | `a[7:0]`, `b[7:0]`, `op[3:0]` |
| Cổng ra | `dout[7:0]` | `y[7:0]`, `z`, `n`, `v` |
| Ngân sách chân | 13 + 8 = **21/24** ✅ | 20 + 11 = **31/24** ❌ vượt |

### 2. Đã phát hiện thế nào

Bốn dấu hiệu độc lập, xếp theo thứ tự thuyết phục tăng dần:

**① Tên gói zip gốc.** Gói có tên `A07_ALU_Implementation_Validation` — chữ "ALU" nằm
ngay trong tên file, không khớp tên đề Charter. Đây là dấu hiệu sớm nhất và rẻ nhất.

**② Danh sách cổng không khớp Charter mục 4.** Charter mục 4 ghi rõ:
*"ui_in[7:0]=dữ liệu · uio_in[2:0]=số bit dịch · uio_in[4:3]=kiểu dịch · uo_out[7:0]=kết quả"*.
RTL lại có hai toán hạng 8 bit `a`, `b` và một mã lệnh 4 bit `op` — **không có** cổng nào
nhận lượng dịch 3 bit.

**③ Mâu thuẫn về ngân sách chân.** Charter mục 4 khẳng định *"Ánh xạ chân đã khả thi,
không phải đổi gì"* (21/24 chân). Nhưng `interface.md` sinh từ RTL lại báo **vượt 7 chân**
(31/24). Một đề mà Charter nói "vừa" còn hồ sơ nói "vượt" là dấu hiệu chắc chắn của lệch
nguồn — hai con số này **không thể** cùng nói về một khối.

**④ Không có toán tử dịch trong mã nguồn.** Đọc `a07_alu.sv`: không có `<<`, `>>`, `>>>`,
không có cấu trúc tầng nào. Charter mục 9 đòi *"kiểm chứng cấu trúc 3 tầng có xuất hiện
trong đường tới hạn không"* — câu hỏi đó **vô nghĩa** với một ALU.

**Kết luận điều tra:** gói được dựng theo **một danh mục đề cũ**, trong đó vị trí A07
thuộc về một đề ALU. Khi danh mục đề được đánh số lại, mã nguồn không được gán lại theo.

### 3. Đã xử lý ra sao

Giảng viên đã **duyệt** phương án viết RTL mới đúng đề Charter.

| Việc | Chi tiết |
|---|---|
| **Đóng băng bản gốc** | Toàn bộ `a07_alu.sv`, `a07_reference.sv`, `reference_model.py`, `a07_tb.sv` được giữ **nguyên vẹn, không sửa một ký tự** tại `08_ORIGINAL_SOURCE/` |
| **Thiết kế lại** | Viết mới `a07_barrel8` + `a07_shift_stage` theo đúng kiến trúc ba tầng mà Charter mục 9 và mục 10 đòi |
| **Viết lại mô hình chuẩn** | `a07_reference.sv` (toán tử) + `reference_model.py` (hai mô hình độc lập: toán tử và ba tầng) |
| **Viết lại testbench** | Ba lớp: ca Charter mục 8, bất biến INV-1…INV-9, quét vét cạn 8 192 tổ hợp |
| **Viết lại tài liệu** | `functional_spec`, `corner_cases`, 7 file `03_ARCHITECTURE/`, `implementation-notes_A07.md` |
| **Ghi nhật ký** | `08_ORIGINAL_SOURCE/PATCHLOG.md` — nêu rõ cách quay lui |

### 4. Bản gốc nằm ở đâu

```
08_ORIGINAL_SOURCE/
├── README.md
├── rtl/a07_alu.sv                    ← ALU gốc, KHÔNG SỬA
├── golden_model/a07_reference.sv     ← reference gốc, KHÔNG SỬA
├── golden_model/reference_model.py   ← mô hình Python gốc, KHÔNG SỬA
├── testbench/a07_tb.sv               ← testbench gốc, KHÔNG SỬA
└── PATCHLOG.md                       ← nhật ký thay thế + cách quay lui
```

Quay lui hoàn toàn khả thi: chép ngược bốn file đó về vị trí cũ. Xem `PATCHLOG.md` §5.

### 5. Kết quả sau xử lý

| Chỉ số | Bản gốc (`a07_alu`) | **Bản thiết kế lại (`a07_barrel8`)** |
|---|---:|---:|
| Đúng đề Charter | ❌ **Không** | ✅ **Có** |
| Mô phỏng | PASS (nhưng kiểm sai đề) | ✅ **PASS** — 8 215 vector, 0 lỗi |
| Bất biến | — | ✅ 17 458 lần kiểm, 0 vi phạm |
| Tổng hợp | PASS | ✅ **PASS** |
| Số cell | 111 | **86** |
| Flip-flop | 0 | ✅ **0** |
| Diện tích | 671,8944 µm² | **425,408 µm²** |
| Độ trễ | 3,07 ns | **0,85 ns** |
| Ngân sách chân | 31/24 ❌ **vượt** | **21/24** ✅ **vừa** |
| Cảnh báo biên dịch | 9 (`constant selects…`) | ✅ **0** |
| Ba tầng thấy được trong netlist | ❌ không áp dụng | ✅ **3 instance, 3 tên trên đường tới hạn** |

**REQ-A07-001 nay ĐÃ THOẢ.**

> 📌 Điểm mở về ngân sách chân (🟡 trong `interface.md` bản cũ) **không còn tồn tại**.
> Thiết kế mới dùng đúng 21/24 chân như Charter mục 4 đã tính.

---

## SỰ CỐ #2 — `ref` là từ khoá SystemVerilog

**Mức độ:** 🟡 Nhẹ (chặn biên dịch)
**Trạng thái:** ✅ Đã xử lý
**Phạm vi:** testbench gốc, và cả testbench mới

Testbench gốc đặt tên instance của golden model là `ref`. Đó là **từ khoá SystemVerilog**
(dùng cho đối số truyền tham chiếu), nên Icarus Verilog từ chối biên dịch.

**Xử lý:** đổi tên instance thành `ref_i` trong bản gốc (sửa nguồn tối thiểu, đã ghi nhận).
Testbench **mới** dùng tên `ref_m` ngay từ đầu nên không gặp lại vấn đề này.

---

## SỰ CỐ #3 — Cảnh báo `constant selects in always_* processes`

**Mức độ:** 🟢 Thông tin
**Trạng thái:** ✅ Không còn ở thiết kế mới

Bản gốc sinh **9** cảnh báo dạng:

```
sorry: constant selects in always_* processes are not currently supported
       (all bits will be included).
```

Đây là giới hạn của Icarus Verilog 12.0 khi gặp part-select có chỉ số hằng bên trong khối
`always_*`. Cảnh báo này **có hại**: nó nói rằng công cụ đã **âm thầm mở rộng** part-select
thành toàn bộ từ, tức danh sách nhạy cảm không còn đúng như viết.

**Thiết kế mới không còn cảnh báo nào** (0/0), vì RTL mới **không dùng `always_*`** — toàn
bộ là `assign` liên tục bên trong khối `generate`. Đây là lợi ích phụ ngoài dự tính của
quyết định "mô tả tường minh từng lát cắt": nó đồng thời loại bỏ cả nguy cơ suy ra latch
lẫn cảnh báo này.

> 🔎 Cảnh báo này **vẫn xuất hiện** khi dựng phương án đối chứng V2 (`case (shamt)` 8 nhánh)
> trong `03_ARCHITECTURE/tradeoff.md`, vì V2 buộc phải dùng `always_comb` với part-select.
> Đó là một lý do kỹ thuật nữa — ngoài diện tích và độ trễ — để không chọn V2.

---

## Các mục CHƯA làm được (không phải sự cố, nhưng phải nói rõ)

| # | Nội dung | Vì sao chưa |
|---|---|---|
| 1 | Mô phỏng gate-level trên netlist | Chưa chạy — chưa chứng minh netlist ⟺ RTL |
| 2 | Mô phỏng có độ trễ để quan sát glitch | Testbench hiện tại là zero-delay |
| 3 | Place & Route, DRC, LVS, GDSII | Chưa chạy; Charter mục 3 xếp là mở rộng **tự nguyện** |
| 4 | Nhiều góc PVT | Mới đo một góc của `sky130_fd_sc_hd` |
| 5 | Công suất từ VCD của ứng dụng thật | Đang dùng activity mặc định |
| 6 | Sinh lại `06_GDSII/`, `07_TRACEABILITY/`, `02_SPECIFICATION/{interface,timing,parameters}.md`, `05_VERIFICATION/{verification_report,testplan,test_matrix}` | Các file này **còn số liệu của khối ALU cũ**; chúng nằm trong diện sinh lại tự động |

---

*Phiên bản: v1.0 · Ngày: 2026-09-24.*
