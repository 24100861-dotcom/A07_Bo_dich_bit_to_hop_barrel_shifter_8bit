# A07 · Đặc tả chức năng (Functional Specification)

> 🟢 **GHI CHÚ TRUY VẾT — SỰ CỐ LỆCH NGUỒN ĐÃ ĐƯỢC XỬ LÝ**
>
> Gói nguồn ban đầu (`A07_ALU_Implementation_Validation`) **không hiện thực đề Charter này**:
> RTL trong gói là `a07_alu` — một ALU 4 phép ADD/SUB/AND/OR, **không có toán tử dịch nào**.
> Gói đó được dựng theo **một danh mục đề cũ**.
>
> **Đã xử lý:** RTL, mô hình chuẩn và testbench được **thiết kế lại từ đầu** đúng đề
> *Bộ dịch bit tổ hợp (barrel shifter) 8-bit*. Module đỉnh mới là **`a07_barrel8`**.
> Bản gốc được **đóng băng nguyên vẹn** tại `08_ORIGINAL_SOURCE/` và có thể quay lui bất cứ lúc nào.
>
> * Nhật ký thay thế: `08_ORIGINAL_SOURCE/PATCHLOG.md`
> * Diễn biến sự cố và cách phát hiện: `05_VERIFICATION/known_issues.md`
> * **REQ-A07-001 nay ĐÃ THOẢ** — bằng chứng: 8 192/8 192 vector khớp mô hình chuẩn.
>
> ⚠️ Một số file **chưa được sinh lại** vẫn còn số liệu của khối ALU cũ:
> `02_SPECIFICATION/{interface,timing,parameters}.md`, `06_GDSII/`, `07_TRACEABILITY/`,
> `05_VERIFICATION/{verification_report,testplan,test_matrix}`. Chúng nằm trong diện
> **sinh lại tự động**. Số liệu đúng của thiết kế mới nằm ở §9 của tài liệu này.

---

## 1. Khối này làm gì

`a07_barrel8` nhận một byte và dịch nó đi **0 đến 7 vị trí trong đúng một lần lan truyền
tổ hợp** — không clock, không trạng thái, không nhiều nhịp.

Bối cảnh ứng dụng (Charter mục 1): **khối căn chỉnh dữ liệu trong bộ giải mã gói tin**.
Một trường bit nằm lệch bên trong dòng byte phải được kéo về biên trước khi đọc. Vì
lượng lệch chỉ biết được **khi dữ liệu đã tới**, khối phải dịch được **mọi** lượng dịch
trong cùng một chu kỳ; không được phép "dịch 1 bit mỗi chu kỳ rồi lặp".

Chính ràng buộc "mọi lượng dịch, một chu kỳ" là thứ sinh ra kiến trúc barrel shifter.

## 2. Giao diện

| Tín hiệu | Chiều | Rộng | Vai trò |
|---|---|---:|---|
| `din[7:0]` | input | 8 | Byte cần dịch |
| `shamt[2:0]` | input | 3 | Lượng dịch, 0…7 |
| `mode[1:0]` | input | 2 | Kiểu dịch |
| `dout[7:0]` | output | 8 | Kết quả |

**Không có `clk`, không có `rst`** — mạch tổ hợp thuần (REQ-A07-003).

### 2.1 Bảng ánh xạ cổng ↔ Charter mục 4

Charter dùng tên chân chung của Tiny Tapeout; RTL dùng tên gợi nhớ. Ánh xạ là **một–một,
không bỏ sót bit nào**:

| Charter mục 4 | Cổng RTL | Rộng | Ghi chú |
|---|---|---:|---|
| `ui_in[7:0]` = dữ liệu | `din[7:0]` | 8 | |
| `uio_in[2:0]` = số bit dịch | `shamt[2:0]` | 3 | |
| `uio_in[4:3]` = kiểu dịch | `mode[1:0]` | 2 | `mode[0]`↔`uio_in[3]`, `mode[1]`↔`uio_in[4]` |
| `uo_out[7:0]` = kết quả | `dout[7:0]` | 8 | |
| `uio_in[7:5]` | — | 3 | Charter không dùng; để trống |

### 2.2 Ngân sách chân — VỪA, không phải điểm mở

| Hạng mục | Số bit |
|---|---:|
| Vào (`din` 8 + `shamt` 3 + `mode` 2) | **13** |
| Ra (`dout` 8) | **8** |
| **Tổng** | **21** |
| Ô Tiny Tapeout có | **24** |
| **Còn dư** | **+3** |

Khớp đúng câu Charter mục 4: *"Ngân sách chân: 13 bit vào + 8 bit ra = 21 trên 24 chân.
Ánh xạ chân đã khả thi, không phải đổi gì."*

> 📌 File `02_SPECIFICATION/interface.md` hiện **còn ghi "vượt +7 chân"** — đó là con số
> của khối ALU cũ (20 vào + 11 ra = 31 bit). Với thiết kế mới, điểm mở đó **không còn**.
> File sẽ được sinh lại.

## 3. Bảng hành vi

### 3.1 Giải mã `mode`

`mode` được tách thành hai bit có ý nghĩa độc lập:

```
mode[0] = dir    : 0 = dịch TRÁI, 1 = dịch PHẢI
mode[1] = arith  : 1 = kiểu SỐ HỌC (chỉ có nghĩa khi dịch phải)
```

| `mode` | Tên | Ý nghĩa | Bit độn vào |
|:---:|---|---|---|
| `00` | **SLL** | Dịch trái logic | `0` (từ dưới) |
| `01` | **SRL** | Dịch phải logic | `0` (từ trên) |
| `10` | **SLA** | Dịch trái số học — **bí danh của SLL** | `0` (từ dưới) |
| `11` | **SRA** | Dịch phải số học | `din[7]` (từ trên) |

**Vì sao `SLA ≡ SLL`, và vì sao đó không phải là lỗi.** Dịch trái đẩy bit dấu **ra khỏi**
từ; không còn gì để "nối dài dấu" cả. Mọi kiến trúc tập lệnh thực dụng (RISC-V, ARM) đều
không có lệnh dịch trái số học riêng vì đúng lý do này. Charter mục 3 xếp **dịch vòng
(rotate) ngoài phạm vi**, nên mã `2'b10` **không** được dùng cho rotate. Thay vì để nó
không xác định — điều sẽ sinh latch hoặc `X` — đặc tả **định nghĩa tường minh** nó là bí
danh của SLL. Bất biến **INV-6** khoá định nghĩa này lại.

### 3.2 Phương trình từng bit

Với `i = 0…7`:

```
SLL / SLA :  dout[i] = (i ≥ shamt)     ? din[i − shamt] : 0
SRL       :  dout[i] = (i + shamt ≤ 7) ? din[i + shamt] : 0
SRA       :  dout[i] = (i + shamt ≤ 7) ? din[i + shamt] : din[7]
```

Một dòng duy nhất mô tả cả bốn chế độ:

```
fill    = arith & dir & din[7]
dout[i] = dir ? (i+shamt ≤ 7 ? din[i+shamt] : fill)
              : (i ≥ shamt   ? din[i−shamt] : 0)
```

## 4. Ràng buộc kiến trúc BẮT BUỘC

> Đây là ràng buộc **cứng**, không phải gợi ý. Nó đến từ Charter mục 9 và mục 10.

**BB-1 — Ba tầng ghép kênh mắc nối tiếp.** Khối phải được dựng từ đúng ba tầng dịch
`1 · 2 · 4`, mỗi tầng do **một** bit của `shamt` điều khiển:

```
shamt[0] → tầng dịch 1      shamt[1] → tầng dịch 2      shamt[2] → tầng dịch 4
```

Cơ sở: `shamt` là số nhị phân, `shamt = 4·shamt[2] + 2·shamt[1] + 1·shamt[0]`, và phép
dịch có tính kết hợp — dịch `a` rồi dịch `b` bằng dịch `a+b`. Vì `1+2+4 = 7` phủ trọn dải
`0…7`, **ba** tầng là đủ và không thừa.

**BB-2 — Cấm toán tử tắt trong RTL.** Trong `04_IMPLEMENTATION/rtl/` tuyệt đối không được
viết `din << shamt`, `din >> shamt`, `din >>> shamt`. Toán tử dịch **chỉ** được dùng trong
`05_VERIFICATION/golden_model/`, nơi chúng đóng vai trò chuẩn so sánh độc lập.

**BB-3 — Cấm `case (shamt)` 8 nhánh.** Charter mục 10 nêu đích danh đây là chỗ hay tắc:
*"Không thấy ba tầng — viết một `case` 8 nhánh rồi ngạc nhiên vì diện tích lớn."*
Phương án đó đã được dựng và **đo thật** để đối chứng — xem `03_ARCHITECTURE/tradeoff.md` §3.

**BB-4 — 0 ô nhớ.** Charter mục 10: *"Dấu hiệu làm đúng: 0 ô nhớ."* RTL không có
`always_ff`, không có `clk`/`rst`; netlist sau tổng hợp phải có **đúng 0 flip-flop**.

**BB-5 — Không suy ra latch.** Mọi đường trong RTL đều là `assign` liên tục trong khối
`generate`; không có `always_comb` nào trong RTL, nên không tồn tại nhánh nào có thể thiếu
gán. `always_comb` duy nhất trong hồ sơ nằm ở golden model và đã có gán mặc định.

## 5. Bất biến (Invariants)

Các bất biến dưới đây **suy từ đặc tả**, không suy từ bất kỳ hiện thực nào. Chúng được
kiểm trên **toàn bộ** không gian đầu vào ở cả Python (`reference_model.py`) lẫn mô phỏng
RTL (`a07_tb.sv`).

| ID | Phát biểu | Kiểm ở đâu |
|---|---|---|
| **INV-1** | `shamt = 0` ⟹ `dout = din`, ở **cả bốn** chế độ | Python §3, TB `check_invariants` |
| **INV-2** | SLL/SLA ⟹ `shamt` bit **thấp** nhất của `dout` bằng 0 | Python §3, TB |
| **INV-3** | SRL ⟹ `shamt` bit **cao** nhất của `dout` bằng 0 | Python §3, TB |
| **INV-4** | SRA ⟹ `shamt+1` bit **cao** nhất của `dout` đều bằng `din[7]` | Python §3, TB |
| **INV-5** | `din[7] = 0` ⟹ SRA cho kết quả **trùng** SRL | Python §3 |
| **INV-6** | `mode=10` (SLA) cho kết quả **trùng** `mode=00` (SLL) | Python §3 |
| **INV-7** | SLL/SRL không tạo bit 1 từ hư không: `popcount(dout) ≤ popcount(din)` | Python §3 |
| **INV-8** | SRA của số âm không bao giờ ra số dương; SRA của `0xFF` luôn là `0xFF` | Python §3 |
| **INV-9** | `dout` không bao giờ chứa bit `X`/`Z` (chống latch, chống hở nhánh) | TB `check_invariants` |

Ngoài ra Python còn chứng minh một bất biến **về kiến trúc**, không phải về hành vi:

| ID | Phát biểu | Kiểm ở đâu |
|---|---|---|
| **INV-A** | Mô hình **ba tầng 1-2-4** cho kết quả **trùng khít** mô hình **toán tử** trên cả 8 192 tổ hợp | `reference_model.py` §2 |

INV-A là thứ biến câu khẳng định kiến trúc *"ba tầng phủ đủ 0…7"* từ một lời nói thành một
bằng chứng chạy được — và nó được chứng minh **trước khi** động đến Verilog.

## 6. Điều kiện biên

| Điều kiện | Kết quả | Vì sao đáng quan tâm |
|---|---|---|
| `shamt = 0` | `dout = din` | Cả ba tầng cùng ở nhánh "đi thẳng". Đây là ca **không tầng nào bật**. |
| `shamt = 7` | Cả ba tầng cùng bật | Ca **sâu nhất về cấu trúc**: dữ liệu đi qua đủ 3 mắt xích. |
| `din = 0x00` | `dout = 0x00` mọi chế độ | Điểm bất động tầm thường. |
| `din = 0xFF`, SRA | `dout = 0xFF` mọi `shamt` | **Điểm bất động không tầm thường** — chỉ đúng với SRA. |
| `din = 0x80`, SRA, `shamt=7` | `0xFF` | Bit dấu lan phủ cả byte. |
| `din = 0x01`, SLL, `shamt=7` | `0x80` | Một bit đơn độc đi hết chiều rộng từ đáy lên đỉnh. |
| `din[7]=0` | SRA ≡ SRL | Hai chế độ **hội tụ**; 1 152/2 048 tổ hợp dịch phải rơi vào đây. |

**Ca KHÔNG tồn tại:** `shamt` là 3 bit nên **mọi** giá trị `0…7` đều hợp lệ — không có
giá trị `shamt` nào ngoài dải, không cần xử lý ngoại lệ. Tương tự, cả 4 mã `mode` đều được
định nghĩa; **không có mã dự trữ nào chưa xác định**. Đây là lý do khối không thể sinh `X`.

## 7. Ánh xạ yêu cầu

| Yêu cầu | Thoả bằng | Bằng chứng |
|---|---|---|
| REQ-A07-001 chức năng đúng đề | Thiết kế lại `a07_barrel8` | 8 192/8 192 vector khớp |
| REQ-A07-002 giao diện Charter mục 4 | §2.1 | Bảng ánh xạ một–một, 21/24 chân |
| REQ-A07-003 tổ hợp, 0 ô nhớ | BB-4 | 0 flip-flop; công suất Sequential 0,0 % |
| REQ-A07-004 quy mô 1×1 tile | §9 | 86 cell — dưới ước lượng 180–260 của Charter |
| REQ-A07-010 ca Charter mục 8 | TC-001…TC-004 | `a07_tb.sv` lớp 1a |
| REQ-A07-011 ≥2 ca tự xây dựng, có ca biên | TC-005…TC-012 | `a07_tb.sv` lớp 1b |
| REQ-A07-020 câu phân tích riêng | Đo STA | `implementation-notes_A07.md` §8 |
| REQ-A07-021 câu hỏi Charter mục 2 | Đo | `implementation-notes_A07.md` §7 |

## 8. Những gì đặc tả này KHÔNG nói

- **Không** định nghĩa dịch vòng (rotate) — Charter mục 3 xếp ngoài phạm vi.
- **Không** mở rộng quá 8 bit — Charter mục 3 xếp ngoài phạm vi.
- **Không** có cờ trạng thái (zero, carry-out của bit bị đẩy ra). Charter mục 4 chỉ cấp
  8 bit ra; bit bị đẩy ra khỏi từ **mất hẳn**, đúng định nghĩa phép dịch.
- **Không** nói gì về tần số hoạt động. Khối không có clock.

## 9. Số liệu đã đo của thiết kế mới

Đo ngày 2026-09-24, cùng script và cùng thư viện `sky130_fd_sc_hd` với các đề khác.

| Chỉ số | Giá trị | Công cụ |
|---|---:|---|
| Mô hình chuẩn Python | **PASS** (thoát 0) | CPython 3.14.4 |
| Vector mô phỏng | **8 215**, sai lệch **0** | Icarus Verilog 12.0 |
| Lần kiểm bất biến | **17 458**, vi phạm **0** | Icarus Verilog 12.0 |
| Số cell | **86** | Yosys 0.52-2 |
| **Flip-flop** | **0** | Yosys 0.52-2 |
| Diện tích | **425,408 µm²** | Yosys 0.52-2 |
| Đường tới hạn | `din[7] → dout[1]` | OpenSTA |
| Độ trễ tổ hợp | **0,85 ns** | OpenSTA |
| Slack | **9,15 ns** (MET) | OpenSTA |
| WNS / TNS | 0,00 / 0,00 | OpenSTA |
| Công suất | **2,70·10⁻⁵ W** — tổ hợp 100,0 %, tuần tự 0,0 % | OpenSTA |

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24 · Truy vết: REQ-A07-001…004, 010…013, 020…021.*
