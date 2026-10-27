> ⚠️ Số liệu trong file này là của gói gốc (Yosys 0.33, OpenSTA 3.1.0), giữ nguyên làm lịch sử. Số của lần chạy hiện tại: xem 02_SPECIFICATION/functional_spec.md §9.

# A07 · PATCHLOG — Nhật ký thay thế mã nguồn

**Ngày:** 2026-09-24
**Lý do:** Mã nguồn trong gói gốc hiện thực **một đề khác** (ALU 4 phép), không phải đề
Charter A07 *"Bộ dịch bit tổ hợp (barrel shifter) 8-bit"*.
**Thẩm quyền:** Giảng viên đã **duyệt** viết RTL mới đúng đề Charter.
**Khả năng quay lui:** ✅ Hoàn toàn — bản gốc đóng băng nguyên vẹn trong chính thư mục này.

---

## 1. File nào bị thay, bằng gì

| Đường dẫn | Trước | Sau | Thao tác |
|---|---|---|---|
| `04_IMPLEMENTATION/rtl/a07_alu.sv` | ALU 4 phép, 50 dòng | — | **XOÁ** |
| `04_IMPLEMENTATION/rtl/a07_barrel8.sv` | — | Module đỉnh: giải mã `mode`, sinh `fill`, mắc 3 tầng | **TẠO MỚI** |
| `04_IMPLEMENTATION/rtl/a07_shift_stage.sv` | — | Một tầng dịch `S` vị trí, 8 lát cắt, tham số hoá | **TẠO MỚI** |
| `05_VERIFICATION/golden_model/a07_reference.sv` | Reference của ALU | Reference dùng `<<`/`>>`/`>>>` | **THAY THẾ** |
| `05_VERIFICATION/golden_model/reference_model.py` | Mô hình ALU, 27 dòng | Hai mô hình độc lập (toán tử + ba tầng) + 9 bất biến, ~250 dòng | **THAY THẾ** |
| `05_VERIFICATION/testbench/a07_tb.sv` | TB của ALU, 41 dòng | TB ba lớp: ca Charter mục 8 + bất biến + quét vét cạn | **THAY THẾ** |
| `02_SPECIFICATION/functional_spec.md` | Đặc tả ALU | Đặc tả barrel shifter | **VIẾT LẠI** |
| `02_SPECIFICATION/corner_cases.md` | Ca biên của ALU | Ca biên của barrel shifter | **VIẾT LẠI** |
| `03_ARCHITECTURE/system_diagram.md` | | Bối cảnh giải mã gói tin | **VIẾT LẠI** |
| `03_ARCHITECTURE/block_diagram.md` | | Sơ đồ ba tầng theo đúng RTL mới | **VIẾT LẠI** |
| `03_ARCHITECTURE/datapath.md` | | Đường dữ liệu + độ sâu logic đo thật | **VIẾT LẠI** |
| `03_ARCHITECTURE/control.md` | | Vì sao không có phần điều khiển | **VIẾT LẠI** |
| `03_ARCHITECTURE/fsm.md` | | Vì sao không có FSM, 4 nguồn bằng chứng | **VIẾT LẠI** |
| `03_ARCHITECTURE/timing_diagram.md` | | Lan truyền ca xấu/tốt nhất, vùng glitch | **VIẾT LẠI** |
| `03_ARCHITECTURE/tradeoff.md` | | So 4 kiến trúc thay thế bằng số liệu thật | **VIẾT LẠI** |
| `implementation-notes_A07.md` | Ghi chú về ALU | 11 mục về barrel shifter | **VIẾT LẠI** |
| `05_VERIFICATION/known_issues.md` | — | Nhật ký sự cố lệch nguồn | **TẠO MỚI** |
| `08_ORIGINAL_SOURCE/PATCHLOG.md` | — | File này | **TẠO MỚI** |

## 2. File KHÔNG bị động tới

| Đường dẫn | Lý do |
|---|---|
| `08_ORIGINAL_SOURCE/rtl/a07_alu.sv` | **Bản gốc — giữ tuyệt đối** |
| `08_ORIGINAL_SOURCE/golden_model/a07_reference.sv` | **Bản gốc — giữ tuyệt đối** |
| `08_ORIGINAL_SOURCE/golden_model/reference_model.py` | **Bản gốc — giữ tuyệt đối** |
| `08_ORIGINAL_SOURCE/testbench/a07_tb.sv` | **Bản gốc — giữ tuyệt đối** |
| `01_REQUIREMENT/` | Sinh lại tự động |
| `02_SPECIFICATION/{interface,timing,parameters}.md` | Sinh lại tự động |
| `04_IMPLEMENTATION/{scripts,constraints}` | Sinh lại tự động |
| `06_GDSII/` | Sinh lại tự động |
| `07_TRACEABILITY/` | Sinh lại tự động |
| `README.md`, `implementation-notes_A07.html` | Sinh lại tự động |

> ⚠️ **Cho tới khi sinh lại, các file trên còn mang số liệu của khối ALU cũ**
> (111 cell, 671,8944 µm², 3,07 ns, 31/24 chân, top `a07_alu`). Số liệu đúng của thiết kế
> mới nằm ở §4 dưới đây và ở `02_SPECIFICATION/functional_spec.md` §9.
>
> Khi sinh lại, cần chú ý ba thay đổi:
> * **Top module:** `a07_alu` → **`a07_barrel8`**
> * **Số file RTL:** 1 → **2** (`a07_barrel8.sv`, `a07_shift_stage.sv`)
> * **Ngân sách chân:** 31/24 (vượt, 🟡 điểm mở) → **21/24 (vừa, điểm mở KHÔNG còn)**

## 3. Vì sao thay

| Lý do | Bằng chứng |
|---|---|
| RTL không hiện thực đề Charter | `a07_alu.sv` không chứa `<<`, `>>`, `>>>` hay cấu trúc tầng nào |
| Cổng không khớp Charter mục 4 | RTL có `a`,`b`,`op`; Charter đòi dữ liệu + lượng dịch + kiểu dịch |
| Câu phân tích riêng không trả lời được | Charter mục 9 đòi đếm tầng mux trên đường tới hạn — ALU không có tầng mux nào |
| Ca kiểm thử Charter mục 8 không áp dụng | "dịch 0", "dịch 7", "SRA bit dấu = 1" vô nghĩa với ALU |
| Mâu thuẫn ngân sách chân | Charter nói 21/24 vừa; hồ sơ sinh từ ALU nói 31/24 vượt |
| Gói gốc thuộc danh mục đề cũ | Tên zip `A07_ALU_Implementation_Validation` |

Chi tiết điều tra: `05_VERIFICATION/known_issues.md` §2.

## 4. Kết quả xác minh — TRƯỚC và SAU

Cả hai lần đo dùng **cùng công cụ, cùng thư viện, cùng script**:
Icarus Verilog 12.0 · Yosys 0.33 · OpenSTA · `sky130_fd_sc_hd` (`sky130hd.lib`).

| Hạng mục | TRƯỚC (`a07_alu`) | **SAU (`a07_barrel8`)** |
|---|---|---|
| Đúng đề Charter | ❌ Không | ✅ **Có** |
| Mô hình chuẩn Python | PASS | ✅ **PASS** (thoát 0) |
| Biên dịch Icarus | PASS, **9 cảnh báo** | ✅ **PASS, 0 cảnh báo** |
| Mô phỏng | PASS | ✅ **PASS** — 8 215 vector, **0 sai lệch** |
| Kiểm bất biến | (không có) | ✅ **17 458 lần, 0 vi phạm** |
| Quét vét cạn | 256 vector (một phần) | ✅ **8 192/8 192 — toàn bộ không gian** |
| Tổng hợp | PASS | ✅ **PASS** |
| **Số cell** | 111 | **75** |
| **Flip-flop** | 0 | ✅ **0** |
| **Diện tích** | 671,8944 µm² | **411,6448 µm²** |
| STA | PASS (`virtual_clock`) | ✅ **PASS** (`vclk`) |
| Startpoint → Endpoint | `b[0] → z` | **`din[7] → dout[1]`** |
| **Độ trễ** | 3,07 ns | **0,78 ns** |
| Slack | 6,93 ns | **9,22 ns (MET)** |
| WNS / TNS | 0,00 / 0,00 | **0,00 / 0,00** |
| Công suất | 2,53·10⁻⁵ W (tổ hợp 100 %) | **1,35·10⁻⁵ W (tổ hợp 100,0 %, tuần tự 0,0 %)** |
| Ngân sách chân | 31/24 ❌ vượt | **21/24 ✅ vừa** |

### Phân bố cell của thiết kế mới (75 cell · 411,6448 µm²)

```
nor2_1   ×18    a21oi_1 ×16    mux2i_1 ×11    o21ai_0 ×6
nand3_1  × 6    nand2b_1× 6    clkinv_1× 6    nand2_1 ×2
a31oi_1  × 2    a21boi_0× 1    and3_1  × 1
```

Không có cell nào thuộc họ `df*` / `sdf*` / `dl*` / `sedf*` ⟹ **0 flip-flop, 0 latch**.

### Phân bố theo phân cấp — bằng chứng "ba tầng" của Charter mục 10

```
a07_barrel8                                    1     →  1 cell (and3_1) ·   6,2560 µm²
  $paramod\a07_shift_stage\S=...0001           1     → 24 cell          · 143,8880 µm²   (u_stage1)
  $paramod\a07_shift_stage\S=...0010           1     → 25 cell          · 138,8832 µm²   (u_stage2)
  $paramod\a07_shift_stage\S=...0100           1     → 25 cell          · 122,6176 µm²   (u_stage4)
                                                        ─────────────────────────────
                                                        75 cell          · 411,6448 µm²
```

### Cell trên đường tới hạn (7 cell · 0,78 ns)

```
_0_            : and3_1     (mức đỉnh — sinh fill)   0,16 ns
u_stage1/_37_  : mux2i_1                             0,07 ns
u_stage1/_39_  : a21oi_1                             0,17 ns   → tầng 1: 0,24 ns
u_stage2/_32_  : mux2i_1                             0,09 ns
u_stage2/_34_  : a21oi_1                             0,17 ns   → tầng 2: 0,26 ns
u_stage4/_23_  : nand3_1                             0,08 ns
u_stage4/_24_  : o21ai_0                             0,04 ns   → tầng 4: 0,12 ns
```

**Ba tầng xuất hiện trên đường tới hạn, gọi đúng tên instance, đúng thứ tự.**
Đây là bằng chứng trực tiếp cho câu phân tích riêng Charter mục 9 và cho dấu hiệu làm
đúng Charter mục 10 (*"Netlist phải thấy rõ ba tầng ghép kênh nối tiếp"*).

## 5. Cách quay lui

Bản gốc nằm ngay trong thư mục này và **chưa bị sửa một ký tự nào**. Để khôi phục:

```bash
D=<đường dẫn tới out/A07_Bo_dich_bit_to_hop_barrel_shifter_8bit>

# 1. Gỡ RTL mới
rm -f $D/04_IMPLEMENTATION/rtl/a07_barrel8.sv \
      $D/04_IMPLEMENTATION/rtl/a07_shift_stage.sv

# 2. Chép ngược bản gốc
cp $D/08_ORIGINAL_SOURCE/rtl/a07_alu.sv                  $D/04_IMPLEMENTATION/rtl/
cp $D/08_ORIGINAL_SOURCE/golden_model/a07_reference.sv   $D/05_VERIFICATION/golden_model/
cp $D/08_ORIGINAL_SOURCE/golden_model/reference_model.py $D/05_VERIFICATION/golden_model/
cp $D/08_ORIGINAL_SOURCE/testbench/a07_tb.sv             $D/05_VERIFICATION/testbench/

# 3. Đổi top module trong script tổng hợp/STA: a07_barrel8 -> a07_alu
```

Sau khi quay lui, hồ sơ trở về đúng trạng thái trước 2026-09-24: mã nguồn chạy được nhưng
**không đúng đề Charter**, và REQ-A07-001 trở lại **CHƯA ĐẠT**.

## 6. Lệnh xác minh đã dùng

```bash
D=<đường dẫn tới thư mục đề>
LIB=<đường dẫn tới sky130hd.lib>
T=$(mktemp -d)

# 1. Mô hình chuẩn Python — phải thoát 0
python3 $D/05_VERIFICATION/golden_model/reference_model.py

# 2. Mô phỏng — phải PASS, 0 lỗi
iverilog -g2012 -o $T/sim.vvp $D/04_IMPLEMENTATION/rtl/*.sv \
    $D/05_VERIFICATION/golden_model/*.sv $D/05_VERIFICATION/testbench/*.sv
cd $T && vvp sim.vvp

# 3. Tổng hợp — phải PASS, 0 FF
yosys -Q -p "read_verilog -sv $D/04_IMPLEMENTATION/rtl/*.sv; \
  hierarchy -check -top a07_barrel8; proc; opt; fsm; opt; memory; opt; techmap; opt; \
  dfflibmap -liberty $LIB; abc -liberty $LIB; setundef -zero; splitnets; \
  opt_clean -purge; stat -liberty $LIB"
```

Cả ba đều **PASS**.

---

## 7. Dựng lại mô hình chuẩn và testbench (2026-09-24)

> 📌 **Đánh số.** Yêu cầu công việc gọi mục này là “§6”, nhưng §6 của tài liệu đã có sẵn
> (*Lệnh xác minh đã dùng*). Để không tạo hai mục trùng số, mục mới lấy số kế tiếp là **§7**;
> nội dung giữ nguyên như yêu cầu.

### 7.1 Vì sao phải dựng lại

Sau khi bản thiết kế lại ở §1–§6 đã xác minh xong, một bước sinh tài liệu tự động
(`generate2.py`) có lỗi: nó **chép mã nguồn cũ từ `runs/A07/work/` đè lên**
`04_IMPLEMENTATION/rtl/`, `05_VERIFICATION/golden_model/` và `05_VERIFICATION/testbench/`.
Các file bị ghi đè sau đó được dọn đi cùng với file cũ.

Hậu quả **không đồng đều**:

| Thư mục | Trạng thái sau sự cố |
|---|---|
| `04_IMPLEMENTATION/rtl/` | ✅ **Còn nguyên** — `a07_barrel8.sv`, `a07_shift_stage.sv` không mất |
| `05_VERIFICATION/golden_model/` | ❌ **Mất trắng** |
| `05_VERIFICATION/testbench/` | ❌ **Mất trắng** |

Lỗi của bộ sinh **đã được sửa** (nó không còn chép đè nữa). Vì RTL còn nguyên, công việc lần
này **không phải thiết kế lại**, mà là **dựng lại mô hình chuẩn và testbench cho khớp RTL
hiện có**, dựa trên `02_SPECIFICATION/functional_spec.md`,
`02_SPECIFICATION/corner_cases.md` và chính tài liệu này.

### 7.2 File đã dựng lại

| Đường dẫn | Nội dung |
|---|---|
| `05_VERIFICATION/golden_model/a07_reference.sv` | **Hai** module chuẩn độc lập: `a07_reference` (dùng `<<`, `>>`, `>>>`) và `a07_reference_bitwise` (dùng thẳng phương trình từng bit của `functional_spec.md` §3.2) |
| `05_VERIFICATION/golden_model/reference_model.py` | Python thuần: `model_op()` (toán tử) + `model_tree()` (ba tầng 1-2-4), INV-A, 23 ca có tên, INV-1…INV-9 trên toàn bộ 8 192 tổ hợp, đo định lượng SRL ↔ SRA. In `PASS`, thoát mã 0 |
| `05_VERIFICATION/testbench/a07_tb.sv` | Instance DUT tên **`dut`**, cạnh đó là **hai** golden reference. Ba lớp: 11 vector Charter mục 8 + 12 vector tự xây (có ca biên) + **quét vét cạn 8 192 tổ hợp**. Mọi sai lệch `$fatal(1, …)`. `$dumpoff` ngay trước vòng vét cạn |

**Không** sửa bất kỳ file nào khác. `04_IMPLEMENTATION/rtl/`, `08_ORIGINAL_SOURCE/{rtl,
golden_model,testbench}/`, `01_`, `02_`, `03_`, `06_`, `07_`, `README.md`,
`implementation-notes_A07.*` giữ nguyên.

### 7.3 Kết quả xác minh lần này

Cùng công cụ, cùng thư viện, cùng script với §4: Icarus Verilog 12.0 · Yosys 0.33 ·
`sky130_fd_sc_hd` (`sky130hd.lib`).

| Hạng mục | Ghi ở §4 | **Đo lại 2026-09-24** | Khớp? |
|---|---|---|:--:|
| Mô hình chuẩn Python | PASS (thoát 0) | **PASS (thoát 0)** — 35/35 phép kiểm | ✅ |
| Biên dịch Icarus | PASS, 0 cảnh báo | **PASS, 0 cảnh báo** | ✅ |
| Mô phỏng | PASS — 8 215 vector, 0 sai lệch | **PASS — 8 215 vector, 0 sai lệch** | ✅ |
| Kiểm bất biến | 17 458 lần, 0 vi phạm | **17 458 lần, 0 vi phạm** | ✅ |
| Quét vét cạn | 8 192/8 192 | **8 192/8 192** | ✅ |
| Đo SRL ↔ SRA | khác 896 / trùng 1 152 | **khác 896 / trùng 1 152** | ✅ |
| Tổng hợp | PASS | **PASS** | ✅ |
| **Số cell** | 75 | **75** | ✅ |
| **Flip-flop** | 0 | **0** | ✅ |
| **Diện tích** | 411,6448 µm² | **411,6448 µm²** | ✅ |

Phân bố cell đo lại **trùng từng dòng** với §4:

```
nor2_1  ×18   a21oi_1 ×16   mux2i_1 ×11   o21ai_0 ×6   nand3_1 ×6
nand2b_1× 6   clkinv_1× 6   nand2_1 × 2   a31oi_1 ×2   a21boi_0×1   and3_1 ×1
```

Phân cấp cũng trùng: `u_stage1` 24 cell · 143,8880 µm² · `u_stage2` 25 cell · 138,8832 µm² ·
`u_stage4` 25 cell · 122,6176 µm² · mức đỉnh 6,2560 µm². Không có cell họ
`df*`/`sdf*`/`dl*`/`sedf*` ⟹ **0 flip-flop, 0 latch**.

> ✅ **Kết luận.** RTL không đổi nên số liệu tổng hợp phải y nguyên — và đúng là y nguyên.
> Hai con số 8 215 và 17 458 cũng khớp tuyệt đối, xác nhận bộ ca kiểm thử được dựng lại
> đúng bằng bộ cũ: 23 vector có tên (4+2+2+2 của Charter mục 8, cộng 1+1+1+1+2+2+4+1 tự xây)
> cộng 8 192 vector vét cạn.

### 7.4 Không dựng lại được cái gì

Bản mô hình chuẩn và testbench cũ **không còn tồn tại** để so từng dòng. Những gì bảo đảm
được là **hành vi quan sát được** trùng khít (số vector, số lần kiểm bất biến, số liệu định
lượng SRL ↔ SRA). Cách viết bên trong có thể khác bản cũ; điều đó **không** ảnh hưởng tới
kết luận vì cả hai đều so DUT với cùng một đặc tả.

### 7.5 Cách quay lui

Mục này chỉ **thêm file** vào hai thư mục đang rỗng, không sửa gì sẵn có. Muốn quay lui:

```bash
D=<đường dẫn tới out/A07_Bo_dich_bit_to_hop_barrel_shifter_8bit>
rm -f $D/05_VERIFICATION/golden_model/* $D/05_VERIFICATION/testbench/*
```

Hồ sơ trở lại đúng trạng thái ngay sau sự cố: RTL đúng đề nhưng **không có cách nào kiểm
chứng được**.

---

*Phiên bản: v1.1 · Ngày: 2026-09-24 (v1.0: thiết kế lại · v1.1: dựng lại mô hình chuẩn và
testbench sau sự cố bộ sinh ghi đè).*
