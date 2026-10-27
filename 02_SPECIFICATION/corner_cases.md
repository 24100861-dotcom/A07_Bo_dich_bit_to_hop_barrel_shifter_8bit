# A07 · Ca biên và ca góc (Corner Cases)

Tài liệu này giải thích **vì sao từng ca được chọn**, không phải chỉ liệt kê. Một ca chỉ
đáng nằm trong danh sách nếu nó có thể **làm lộ một lỗi cụ thể** mà các ca khác bỏ sót.

Toàn bộ không gian đầu vào của A07 là `256 × 8 × 4 = 8 192` tổ hợp — đủ nhỏ để **quét vét
cạn**. Vậy tại sao vẫn cần ca có tên? Vì quét vét cạn trả lời *"có sai ở đâu không"*, còn
ca có tên trả lời *"khối cư xử thế nào ở chỗ quan trọng"* — và đó mới là thứ đem đi bảo vệ.

---

## 1. Phân loại theo tiêu chí kỹ thuật của đề

Đề A07 có đúng **ba trục** có thể gây lỗi. Mọi ca đều được xếp vào ít nhất một trục:

| Trục | Câu hỏi kỹ thuật | Lỗi điển hình mà trục này bắt |
|---|---|---|
| **T1 · Cấu trúc tầng** | Ba tầng 1-2-4 có ghép đúng thành 0…7 không? | Lệch một bit; quên một tầng; sai thứ tự tầng |
| **T2 · Bit độn** | Độn 0 hay độn bit dấu? Độn đúng số bit chưa? | SRA độn 0; SRL độn bit dấu; độn thiếu/thừa một bit |
| **T3 · Giải mã chế độ** | 4 mã `mode` có đủ và đúng không? | Mã `10` cho ra `X` hoặc sinh latch; nhầm chiều |

## 2. Ca bắt buộc theo Charter mục 8

### TC-001 · Dịch 0 — giữ nguyên  *(trục T1)*

| | |
|---|---|
| Vector | `din=0xA5`, `shamt=0`, **cả bốn** `mode` |
| Kỳ vọng | `dout = 0xA5` trong cả bốn lần |
| Vì sao chọn | Đây là ca **không tầng nào bật**. Nó kiểm rằng nhánh "đi thẳng" (`en=0`) của **cả ba** tầng dẫn dữ liệu nguyên vẹn. Nếu một tầng nào đó nối sai nhánh mặc định, ca này lộ ngay. |
| Vì sao chạy đủ 4 chế độ | "Giữ nguyên" phải đúng **bất kể** `mode`. Một hiện thực cẩu thả có thể để `mode` rò vào đường dữ liệu; chạy đủ 4 chế độ bắt được điều đó. Đây cũng là **INV-1**. |
| Mẫu `0xA5` | `1010_0101` — đối xứng gương, nên nếu mạch **đảo thứ tự bit** thì ca này **không** phát hiện được. Đó là lý do phải có thêm TC-012. |

### TC-002 · Dịch 7 — mọi tầng đều bật  *(trục T1)*

| | |
|---|---|
| Vector | `din=0xFF`, `shamt=7`, `mode ∈ {SLL, SRL}` |
| Kỳ vọng | SLL → `0x80` · SRL → `0x01` |
| Vì sao chọn | `shamt = 3'b111` là ca duy nhất bật **cả ba** tầng cùng lúc. Đây là ca **sâu nhất về cấu trúc** — dữ liệu phải đi qua đủ 3 mắt xích nối tiếp. Nếu tầng cuối bị bỏ quên, kết quả sẽ là dịch 3 thay vì dịch 7. |
| `0xFF` | Mọi bit đều là 1 nên kết quả cho biết **chính xác còn lại bao nhiêu bit** — `0x80` có đúng 1 bit, xác nhận 7 bit đã bị đẩy ra. |

### TC-003 · Dịch phải số học với bit dấu = 1  *(trục T2)*

| | |
|---|---|
| Vector | `din=0x80, shamt=3, SRA` và `din=0xB4, shamt=5, SRA` |
| Kỳ vọng | `0xF0` và `0xFD` |
| Vì sao chọn | Đây là **lý do tồn tại** của chế độ SRA. `0x80` = số âm nhỏ nhất (−128) với đúng **một** bit 1 — nên kết quả `0xF0` chứng minh ba bit `1` mới **được sinh ra** bởi cơ chế độn, không phải dịch từ đâu tới. |
| `0xB4, shamt=5` | `shamt=5 = 3'b101` bật tầng 1 và tầng 4, **bỏ qua** tầng 2. Kiểm rằng bit độn đúng ngay cả khi các tầng bật **không liên tiếp**. Đây là ca dễ sai nếu ai đó lấy `fill` từ MSB của **tầng trước** thay vì từ `din[7]` gốc. |

> 🔎 **Bẫy kỹ thuật tại đây.** Một hiện thực sai phổ biến là để mỗi tầng độn bằng MSB
> **hiện tại** của tín hiệu vào tầng đó. Với SRA điều đó **tình cờ vẫn đúng**, vì MSB của
> tầng trước đã bằng `din[7]` rồi. Nhưng nó tạo thêm một đường phụ thuộc nối tiếp không
> cần thiết. RTL ở đây lấy `fill` **một lần** từ `din[7]` và phát cho cả ba tầng —
> xem `03_ARCHITECTURE/datapath.md` §4.

### TC-004 · So sánh logic và số học trên cùng đầu vào  *(trục T2)*

| | |
|---|---|
| Vector | `din=0x80`, `shamt=2`, chạy `SRL` rồi `SRA` |
| Kỳ vọng | SRL → `0x20` · SRA → `0xE0` |
| Vì sao chọn | Hai chế độ, **cùng dữ liệu, cùng lượng dịch**, khác nhau ở đúng một chỗ: bit độn. Đây là **cặp đối chứng có kiểm soát** — mọi biến khác đều giữ nguyên, nên chênh lệch `0x20` vs `0xE0` **chỉ có thể** đến từ bit độn. Trả lời trực tiếp câu hỏi Charter mục 2 số 2. |

**Đo định lượng kèm theo.** Testbench đếm luôn: trên 2 048 tổ hợp dịch phải,
SRL và SRA cho kết quả **khác nhau ở 896 tổ hợp** và **trùng nhau ở 1 152 tổ hợp**.
Con số 1 152 không ngẫu nhiên: `128 × 8` (mọi `din` có bit dấu = 0) `+ 128 × 1`
(mọi `din` có bit dấu = 1 nhưng `shamt = 0`) = `1 024 + 128 = 1 152`. Bất biến
*"chỉ trùng khi `din[7]=0` hoặc `shamt=0`"* được kiểm trên toàn bộ 2 048 tổ hợp, 0 vi phạm.

## 3. Ca tự xây dựng

### TC-005 · BIÊN — điểm bất động của SRA  *(trục T2)*

`din=0xFF`, `shamt=7`, SRA → `0xFF`.

Đây là ca biên **về mặt toán học**: `−1 >> n = −1` với mọi `n`. Dịch 7 vị trí mà **không
bit nào thay đổi**. Một mạch SRA sai (độn 0) sẽ cho `0x01` — sai lệch tối đa có thể. Ca này
vừa là biên trên của `shamt`, vừa là biên của miền giá trị.

### TC-006 / TC-007 · BIÊN — một bit đơn độc đi hết chiều rộng  *(trục T1)*

| Ca | Vector | Kỳ vọng |
|---|---|---|
| TC-006 | `din=0x01`, `shamt=7`, SLL | `0x80` |
| TC-007 | `din=0x80`, `shamt=7`, SRL | `0x01` |

Chỉ **một** bit 1 trong toàn byte, đi quãng đường **dài nhất có thể** (đáy → đỉnh và
ngược lại). Nếu bất kỳ tầng nào lệch một vị trí, bit đó sẽ **không** đáp đúng chỗ, và
sai số một-bit này không bị che lấp bởi các bit khác. Đây là ca nhạy nhất với lỗi
off-by-one của trục T1. Hai ca đối xứng nhau nên bắt được cả lỗi chỉ xảy ra ở một chiều.

### TC-008 · BIÊN — toàn bộ dữ liệu bị đẩy ra ngoài  *(trục T1)*

`din=0xF0`, `shamt=7`, SLL → `0x00`.

Bốn bit 1 nằm ở nửa cao; dịch trái 7 đẩy **tất cả** ra khỏi từ. Kỳ vọng là `0x00`. Ca này
kiểm rằng bit bị đẩy ra **thật sự mất**, không vòng lại — tức **không phải rotate**.
Charter mục 3 xếp rotate ngoài phạm vi, nên đây là ca chứng minh khối **không** vô tình
hiện thực rotate.

### TC-009 · Hội tụ — bit dấu = 0 thì SRA phải trùng SRL  *(trục T2, T3)*

`din=0x7F`, `shamt=4`: SRL → `0x07`, SRA → `0x07`.

Cặp đối chứng **ngược** với TC-004: ở đó hai chế độ phải **khác**, ở đây phải **trùng**.
Có cả hai chiều mới loại được giả thuyết "mạch luôn cho hai chế độ khác nhau" hoặc
"mạch bỏ quên `arith`". Đây là **INV-5**.

### TC-010 · Bí danh — `SLA ≡ SLL`  *(trục T3)*

`din=0x5A`, `shamt=3`: `mode=00` → `0xD0`, `mode=10` → `0xD0`.

Mã `2'b10` là mã duy nhất **không** được Charter mục 4 mô tả trực tiếp. Ca này khoá định
nghĩa đã chọn (§3.1 của `functional_spec.md`) và chứng minh nó **không** sinh `X`, không
sinh latch, không rơi vào nhánh mặc định lạ. Đây là **INV-6**.

### TC-011 · Soi riêng từng mắt xích  *(trục T1)*

`din=0x0F`, SLL, với `shamt ∈ {1, 2, 4, 6}`:

| `shamt` | Nhị phân | Tầng bật | `dout` |
|---:|:---:|---|---|
| 1 | `001` | chỉ tầng 1 | `0001_1110` |
| 2 | `010` | chỉ tầng 2 | `0011_1100` |
| 4 | `100` | chỉ tầng 4 | `1111_0000` |
| 6 | `110` | tầng 2 + tầng 4 | `1100_0000` |

Đây là bộ ca **chẩn đoán**, không chỉ để PASS. Mỗi lũy thừa của 2 bật **đúng một** tầng,
nên nếu một tầng hỏng thì ca tương ứng chỉ ra **ngay tầng nào**. Testbench còn in cả
giá trị trung gian `t1` (ra của tầng 1) và `t2` (ra của tầng 2) — xem §5.

### TC-012 · Mẫu xen kẽ  *(trục T1)*

`din=0xAA` (`1010_1010`), `shamt=1`, SRL → `0x55` (`0101_0101`).

Mẫu xen kẽ làm **mọi** bit đổi trạng thái khi dịch 1 vị trí. Nó bắt được lỗi mà các mẫu
đối xứng như `0xA5` hay `0xFF` bỏ sót, ví dụ hai dây liền kề bị hoán vị.

## 4. Ca KHÔNG áp dụng cho đề này

| Ca thường gặp ở đề khác | Vì sao **không** áp dụng cho A07 |
|---|---|
| Giá trị điều khiển ngoài dải | `shamt` là 3 bit ⟹ mọi giá trị `0…7` đều hợp lệ. Không tồn tại `shamt` sai. |
| Mã lệnh dự trữ / chưa định nghĩa | Cả 4 mã `mode` đều được định nghĩa tường minh. Không có mã dự trữ. |
| Tràn số (overflow) | Phép dịch **không** có khái niệm tràn: bit bị đẩy ra là mất, theo đúng định nghĩa. Không có cờ `C`/`V` như A01. |
| Chia cho 0 | Không có phép chia. |
| Ca reset / khởi động | Không có ô nhớ, không có trạng thái, không có reset. |
| Ca đua tín hiệu (race) qua clock | Không có clock. Glitch tổ hợp có tồn tại nhưng là hiện tượng **trong** chu kỳ — xem `03_ARCHITECTURE/timing_diagram.md` §4. |

## 5. Artifact số có chú thích

Testbench in kèm **giá trị trung gian giữa các tầng** cho mọi ca có tên:

```
  TC-002b dich 7 - SRL    din=11111111 SRL shamt=7 | t1=01111111 t2=00011111 | OUT=00000001  [PASS]
                                                       └ sau tầng 1  └ sau tầng 2   └ sau tầng 4
```

Đọc hàng này là **đọc trực tiếp ba mắt xích**: `11111111` → dịch 1 → `01111111` →
dịch 2 → `00011111` → dịch 4 → `00000001`. Đây là artifact số chứng minh kiến trúc ba
tầng **có thật trong mạch đang chạy**, không phải chỉ có trong sơ đồ. Waveform VCD
(`a07_waves.vcd`) chứa cùng thông tin dưới dạng tín hiệu `dut.s1`, `dut.s2`.

## 6. Ca cần bổ sung ở mức gate-level (chưa chạy)

Mô phỏng hiện tại là **mức RTL, zero-delay**. Những ca sau **chưa** được kiểm và chỉ có
ý nghĩa khi chạy mô phỏng gate-level có độ trễ, hoặc sau P&R:

1. **Glitch khi `shamt` đổi nhiều bit cùng lúc.** Ví dụ `shamt` đi từ `3` (`011`) sang
   `4` (`100`): cả ba bit điều khiển đổi. Ba tầng chuyển nhánh **không đồng thời**, nên
   `dout` có thể đi qua các giá trị trung gian không thuộc bất kỳ phép dịch hợp lệ nào.
   Mô phỏng zero-delay **không thể** thấy điều này.
2. **Glitch khi đổi `mode` giữa SRL và SRA.** Tín hiệu `fill` đổi trạng thái và lan qua
   cả ba tầng với độ trễ khác nhau theo từng bit.
3. **Tương đương netlist ⟺ RTL.** Hiện mới chứng minh RTL ⟺ golden model. Netlist sau
   `abc` chưa được mô phỏng lại.
4. **Các góc PVT khác.** Mới đo ở một góc thư viện `sky130_fd_sc_hd`.

Cả bốn đều nằm trong mục "chưa chứng minh được" của `implementation-notes_A07.md` §11.

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24 · Truy vết: REQ-A07-010, REQ-A07-011.*
