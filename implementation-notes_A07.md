# A07 — Bộ dịch bit tổ hợp (barrel shifter) 8-bit · Ghi chú thực hiện

> 🟢 **Hồ sơ này mô tả thiết kế ĐÃ LÀM LẠI.** Gói nguồn ban đầu chứa một ALU (`a07_alu`)
> thuộc danh mục đề cũ, không phải barrel shifter. RTL, mô hình chuẩn và testbench đã được
> viết lại từ đầu; module đỉnh mới là **`a07_barrel8`**. Bản gốc đóng băng nguyên vẹn ở
> `08_ORIGINAL_SOURCE/`. Chi tiết: `05_VERIFICATION/known_issues.md`.

---

## 1. Bài toán này thực chất là gì

Bề mặt: "dịch một byte đi 0 đến 7 vị trí". Nghe như một dòng code: `dout = din << shamt`.

Thực chất, Charter chọn A07 để dạy một điều mà dòng code đó **che mất hoàn toàn**:

> **Dịch bit đi một lượng CỐ ĐỊNH là miễn phí. Dịch đi một lượng BIẾN THIÊN thì không.**

Dịch trái 3 vị trí, khi 3 là hằng số, tốn **đúng 0 cổng logic** — nó chỉ là cách nối dây
khác đi. Nhưng khi lượng dịch là một tín hiệu, phần cứng phải **chọn** giữa các cách nối
dây, và mỗi lựa chọn là một bộ ghép kênh. Toàn bộ diện tích 425,41 µm² của A07 là tiền
trả cho chữ "chọn" đó — không một cổng nào trong đó thực sự "dịch" cái gì.

Bối cảnh ứng dụng — **bộ giải mã gói tin** — không phải trang trí. Nó là thứ ép ra kiến
trúc: lượng lệch của một trường bit chỉ biết được **khi dữ liệu đã tới**, và bộ giải mã
không được phép dừng dòng dữ liệu. Phải dịch **mọi** lượng trong **một** chu kỳ.

## 2. Bản chất kỹ thuật — cơ chế hoạt động

### 2.1 Vì sao ba tầng, và vì sao đúng ba

`shamt` là một số nhị phân ba bit:

```
shamt = 4·shamt[2] + 2·shamt[1] + 1·shamt[0]
```

Phép dịch có **tính kết hợp**: dịch `a` rồi dịch `b` cho kết quả bằng dịch `a+b`. Ghép hai
điều này lại:

```
din << shamt  =  ((din << 1·shamt[0]) << 2·shamt[1]) << 4·shamt[2]
                  └── tầng 1 ──┘  └── tầng 2 ──┘  └── tầng 4 ──┘
```

Mỗi bit của `shamt` bật hoặc tắt **đúng một** tầng có lượng dịch bằng trọng số của chính
bit đó. Vì `1 + 2 + 4 = 7` phủ trọn dải `0…7`, ba tầng là **vừa đủ** — không thiếu, không thừa.

Đây là phép **phân tích nhị phân của bài toán**, y như cách `log₂` xuất hiện trong mọi
kiến trúc "chia để trị". Số tầng cho `N` bit là `log₂N`: 8 bit → 3 tầng, 32 bit → 5 tầng.

### 2.2 Một tầng làm gì

Mỗi tầng là 8 lát cắt độc lập, mỗi lát lo một bit ra. Lát cắt `i` của tầng dịch `S`:

```
lsh[i]  = (i ≥ S)     ? din[i−S] : 1'b0     ← nhánh dịch trái : CHỈ LÀ DÂY
rsh[i]  = (i + S ≤ 7) ? din[i+S] : fill     ← nhánh dịch phải : CHỈ LÀ DÂY
sh[i]   = dir ? rsh[i] : lsh[i]             ← mux 2:1 · chọn CHIỀU
dout[i] = en  ? sh[i]  : din[i]             ← mux 2:1 · chọn CÓ DỊCH KHÔNG
```

Hai dòng đầu **không tốn cổng nào**. Hai dòng cuối là toàn bộ chi phí: 2 mux 2:1 mỗi bit,
16 mux mỗi tầng, 48 mux toàn khối theo mô tả RTL.

### 2.3 Dịch phải số học khác dịch phải logic ở đúng chỗ nào

Ở **một** dây:

```systemverilog
assign fill = arith & dir & din[7];     // 1 cổng AND3
```

`fill` là bit được độn vào từ phía MSB. Với SRL nó là `0`; với SRA nó là `din[7]`. Mọi
thứ khác trong ba tầng **giống hệt nhau**.

Điểm tinh tế: `fill` lấy từ `din[7]` **gốc**, không lấy từ MSB của tầng trước. Cả hai cách
đều cho kết quả đúng (vì với SRA, MSB mọi tầng trung gian đã bằng `din[7]`), nhưng cách
đã chọn giữ `fill` **song song** với chuỗi ba tầng thay vì nối tiếp vào nó.

### 2.4 Vì sao `SLA ≡ SLL` và mã `2'b10` không bị bỏ trống

`mode` có 2 bit ⟹ 4 mã, nhưng Charter chỉ nêu ba chế độ. Mã `2'b10` được định nghĩa
**tường minh** là bí danh của SLL, vì:

* Dịch trái đẩy bit dấu **ra khỏi** từ — không còn gì để "nối dài dấu". Mọi kiến trúc tập
  lệnh thực dụng đều không có lệnh dịch trái số học riêng vì đúng lý do này.
* Charter mục 3 xếp **rotate ngoài phạm vi**, nên không được lấy mã này cho rotate.
* Để mã trống ⟹ nhánh `case` không đủ ⟹ **suy ra latch** hoặc sinh `X`. Cả hai đều vi
  phạm Charter mục 10.

Bất biến **INV-6** khoá định nghĩa này, và TC-010 kiểm nó bằng vector thật.

## 3. Đọc mã nguồn: RTL làm gì

Toàn bộ kiến trúc nằm trong ba lời gọi module:

```systemverilog
assign fill = arith & dir & din[7];

a07_shift_stage #(.S(1)) u_stage1 (.din(din), .en(shamt[0]), .dir(dir), .fill(fill), .dout(s1));
a07_shift_stage #(.S(2)) u_stage2 (.din(s1),  .en(shamt[1]), .dir(dir), .fill(fill), .dout(s2));
a07_shift_stage #(.S(4)) u_stage4 (.din(s2),  .en(shamt[2]), .dir(dir), .fill(fill), .dout(dout));
```

Và bên trong một tầng:

```systemverilog
genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : GEN_BIT
        if (i >= S)     assign lsh[i] = din[i-S]; else assign lsh[i] = 1'b0;
        if (i + S <= 7) assign rsh[i] = din[i+S]; else assign rsh[i] = fill;
        assign sh[i]   = dir ? rsh[i] : lsh[i];
        assign dout[i] = en  ? sh[i]  : din[i];
    end
endgenerate
```

Bốn điểm cần giảng kỹ:

1. **`generate for` là nhân bản KHÔNG GIAN.** Nó tạo 8 lát cắt phần cứng tồn tại **đồng
   thời**, không phải 8 lần chạy tuần tự. Sinh viên quen lập trình phần mềm gần như luôn
   hiểu nhầm chỗ này.
2. **`if (i >= S)` là `if` LÚC BIÊN DỊCH, không phải mux.** Nó quyết định **có nối dây hay
   không**, chứ không tạo ra cổng logic nào. Đây là chỗ khác biệt cốt tử giữa `generate if`
   và `if` trong `always_comb`.
3. **Một module tham số hoá dùng cho cả ba tầng.** Ba tầng chỉ khác nhau ở `S`. Yosys vẫn
   giữ chúng thành ba instance tách biệt trong báo cáo phân cấp — đó chính là bằng chứng
   cấu trúc mà Charter mục 10 đòi.
4. **Không có `always_comb` nào trong RTL.** Toàn bộ là `assign` liên tục, nên **không tồn
   tại** khả năng thiếu gán ⟹ không thể suy ra latch. Đây là cách phòng latch mạnh hơn
   "nhớ gán giá trị mặc định".

### Điều tuyệt đối không được viết

```systemverilog
assign dout = din << shamt;          // ❌ CẤM
case (shamt) 3'd0: ... 3'd7: ...     // ❌ CẤM — đúng cái bẫy Charter mục 10
```

Toán tử tắt cho phép công cụ **tự chọn** kiến trúc, tức **xoá mất** chính thứ Charter mục 9
yêu cầu quan sát. Toán tử dịch chỉ được dùng trong `05_VERIFICATION/golden_model/`.

## 4. Vì sao chọn kiến trúc này

Không phải vì "ba tầng là chuẩn", mà vì đo ra nó thắng:

| | V1 ba tầng (chọn) | V2 case 8 nhánh | V3 đảo-dịch-đảo |
|---|---:|---:|---:|
| Diện tích | **411,64 µm²** | 480,46 µm² (+16,7 %) | 456,69 µm² (+10,9 %) |
| Độ trễ | **0,78 ns** | 1,21 ns (+55,1 %) | 1,45 ns (+85,9 %) |
| Đúng chức năng | ✅ 8192/8192 | ✅ 8192/8192 | ✅ 8192/8192 |

Cả ba **tương đương chức năng hoàn toàn** — chúng là ba lựa chọn thật, và V1 thắng trên
**cả hai** trục. Phân tích đầy đủ, kèm hai phương án bóc tách chi phí: `03_ARCHITECTURE/tradeoff.md`.

Với ứng dụng giải mã gói tin, tiêu chí quyết định là:

| Tiêu chí ứng dụng | V1 đáp ứng? |
|---|---|
| Mọi lượng dịch trong **một** chu kỳ | ✅ 0,85 ns, tổ hợp thuần |
| Thông lượng **cố định** một byte/chu kỳ | ✅ Không trạng thái, không vòng lặp |
| 0 ô nhớ (Charter mục 10) | ✅ 0 flip-flop |
| Netlist thấy rõ ba tầng (Charter mục 10) | ✅ Ba instance có tên, xuất hiện trên đường tới hạn |
| Quy mô 1×1 tile | ✅ 86 cell — dưới ước lượng 180–260 của Charter |

## 5. Cách thực hiện — lộ trình 8 bước

| # | Bước | Công cụ | Bằng chứng sinh ra | Trạng thái |
|---|---|---|---|---|
| 1 | Suy bảng hành vi từ Charter mục 1, 4, 8 | — | `02_SPECIFICATION/functional_spec.md` | ✅ |
| 2 | Viết **hai** mô hình Python: toán tử và ba tầng, chứng minh chúng trùng nhau | CPython 3.14.4 | `reference_model.py` thoát 0 | ✅ PASS |
| 3 | Viết RTL ba tầng **tường minh** | — | `04_IMPLEMENTATION/rtl/` (2 file) | ✅ |
| 4 | Viết testbench tự kiểm 3 lớp + quét vét cạn | Icarus Verilog 12.0 | `simulation.log` | ✅ 8 215 vector / **0 lỗi** |
| 5 | Tổng hợp lên sky130, **kiểm 0 flip-flop** | Yosys 0.52-2 | bảng cell | ✅ 86 cell · **0 FF** |
| 6 | Tổng hợp thêm **4 phương án đối chứng** để so bằng số | Yosys 0.33 (gói gốc, chưa đo lại) | `tradeoff.md` §2 | ✅ |
| 7 | STA với clock ảo, **đếm tầng trên đường tới hạn** | OpenSTA | `datapath.md` §5 | ✅ 0,85 ns · 3 tầng |
| 8 | Physical design RTL→GDSII | LibreLane + sky130A | `06_GDSII/` | ⬜ **chưa chạy** |

Bước 2 đáng nói riêng: mô hình **ba tầng** bằng Python được viết **trước khi** động đến
Verilog, và được chứng minh trùng khít mô hình toán tử trên cả 8 192 tổ hợp. Nhờ đó, khi
RTL sai thì biết chắc lỗi ở **hiện thực**, không phải ở **ý tưởng kiến trúc**.

## 6. Số liệu thật đã đo được và cách đọc chúng

| Chỉ số | Giá trị | Công cụ |
|---|---:|---|
| Mô hình chuẩn Python | **PASS**, thoát 0 | CPython 3.14.4 |
| Vector mô phỏng | **8 215**, sai lệch **0** | Icarus Verilog 12.0 |
| Lần kiểm bất biến | **17 458**, vi phạm **0** | Icarus Verilog 12.0 |
| Cảnh báo biên dịch | **0** | Icarus Verilog 12.0 |
| Số cell | **86** | Yosys 0.52-2 + sky130_fd_sc_hd |
| **Flip-flop** | **0** | Yosys 0.52-2 |
| Diện tích | **425,408 µm²** | Yosys 0.52-2 |
| — `u_stage1` (S=1) | 31 cell · 152,6464 µm² | Yosys 0.52-2 |
| — `u_stage2` (S=2) | 29 cell · 143,8880 µm² | Yosys 0.52-2 |
| — `u_stage4` (S=4) | 25 cell · 122,6176 µm² | Yosys 0.52-2 |
| — mức đỉnh (`and3_1` sinh `fill`) | 1 cell · 6,2560 µm² | Yosys 0.52-2 |
| Đường tới hạn | `din[7] → dout[1]`, **7 cell** | OpenSTA |
| **Độ trễ tổ hợp** | **0,85 ns** | OpenSTA |
| Đường nhanh nhất | `shamt[2] → dout[0]`, **0,03 ns** | OpenSTA |
| Slack | **9,15 ns (MET)** · WNS 0,00 · TNS 0,00 | OpenSTA |
| Công suất | **2,70·10⁻⁵ W** — tổ hợp **100,0 %**, tuần tự **0,0 %** | OpenSTA |

### Từng con số chứng minh gì — và KHÔNG chứng minh gì

| Con số | **Chứng minh** | **KHÔNG chứng minh** |
|---|---|---|
| 8 192/8 192 khớp | Hàm của DUT **tương đương** golden model. Không còn ca hành vi nào chưa kiểm. | Kiến trúc là ba tầng. V2 (`case` 8 nhánh) cũng PASS 8 192/8 192. |
| 0 flip-flop | Đúng phân loại Tổ hợp, xác nhận bởi **hai nguồn độc lập** (bảng cell Yosys + công suất Sequential 0,0 % của OpenSTA) | Netlist tương đương RTL về chức năng — cần mô phỏng gate-level |
| 86 cell · 425,41 µm² | Kiến trúc tầng **nhỏ** — dưới hẳn ước lượng 180–260 cell của Charter | Diện tích sau P&R — sẽ khác vì có dây và có cell bị `dont_use` |
| 0,85 ns | Độ trễ **ở mức sau tổng hợp**, một góc PVT | Độ trễ thật sau routing (sẽ **lớn hơn**, chưa có RC dây) |
| Ba tầng trên đường tới hạn | Cấu trúc ba tầng **có thật trong mạch đã tổng hợp**, không chỉ trong RTL | Rằng nó sẽ còn nguyên sau P&R |
| 2,70·10⁻⁵ W | Thứ tự độ lớn công suất | Công suất thật của ứng dụng — dùng activity mặc định, không lấy từ VCD |

## 7. Trả lời các câu hỏi kỹ thuật của Charter (mục 2)

### Câu 1 — Vì sao dịch 0–7 trong một chu kỳ cần cấu trúc tầng (3 tầng 1-2-4) chứ không phải 8 bộ ghép kênh?

**Phương án "8 bộ ghép kênh" đã được dựng thật và đo thật** — đó chính là V2 (`case (shamt)`
8 nhánh) trong `tradeoff.md` §3.

| | Ba tầng (V1) | 8 nhánh phẳng (V2) |
|---|---:|---:|
| Diện tích | **411,6448 µm²** | **480,4608 µm²** |
| Độ trễ | **0,78 ns** | **1,21 ns** |

**Phẳng đắt hơn 16,7 % và chậm hơn 55,1 %.** Charter mục 10 nói đúng.

Nhưng câu trả lời đầy đủ phải nói thêm hai điều:

**① Ở `N = 8`, chênh lệch không lớn như lý thuyết hứa.** Lý thuyết: phẳng cần
`N(N−1) = 56` mux, tầng cần `N·log₂N = 24` mux — tỉ lệ 2,3×. Đo thật: 1,17×. Vì rất nhiều
nhánh của `case` có toán hạng là hằng số 0 và `abc` rút gọn chúng đi.

**② Lý do thật để dùng kiến trúc tầng là độ co giãn, không phải con số 16,7 %:**

| `N` | Tầng: `N·log₂N` | Phẳng: `N(N−1)` | Tỉ lệ |
|---:|---:|---:|---:|
| 8 | 24 | 56 | 2,3× |
| 32 | 160 | 992 | **6,2×** |
| 64 | 384 | 4 032 | **10,5×** |

`O(N log N)` so với `O(N²)`. Ở `N = 8` khoảng cách còn khiêm tốn; ở `N = 64` nó là một
bậc độ lớn. A07 chọn `N = 8` vì đó là cỡ nhỏ nhất mà **ba tầng còn nhìn thấy được**.

### Câu 2 — Dịch phải số học khác dịch phải logic ở đúng chỗ nào trong phần cứng?

**Ở đúng một dây: bit độn `fill`.**

```systemverilog
assign fill = arith & dir & din[7];   // SRA: fill = din[7]   ·   SRL: fill = 0
```

Ba tầng hoàn toàn giống nhau ở hai chế độ; chỉ giá trị độn vào từ phía MSB là khác.

**Bằng chứng hành vi.** TC-004: cùng `din=0x80`, cùng `shamt=2`, chỉ đổi `mode` —
SRL cho `0x20`, SRA cho `0xE0`. Mọi biến khác giữ nguyên nên chênh lệch **chỉ có thể** đến
từ bit độn. Đo trên toàn không gian: trong 2 048 tổ hợp dịch phải, hai chế độ khác nhau ở
**896** tổ hợp và trùng nhau ở **1 152** tổ hợp — đúng bằng `128×8 + 128×1` (mọi `din` có
bit dấu 0, cộng mọi `din` âm nhưng `shamt = 0`).

**Bằng chứng chi phí — và đây là chỗ trực giác sai.** Nhìn RTL thì SRA "chỉ tốn một cổng
AND3". Tổng hợp lại hai phiên bản cùng kiến trúc, chỉ khác có SRA hay không:

| Phiên bản | Cell | Diện tích |
|---|---:|---:|
| Chỉ SLL + SRL (V4) | 60 | 360,3456 µm² |
| Có thêm SRA (V1) | 75 | 411,6448 µm² |
| **Chênh** | **+15 cell** | **+51,30 µm² · +14,2 %** |

**Gấp mười lần ước lượng "một cổng".** Vì khi bỏ SRA, `fill` thành hằng số 0, và **bảy**
lát cắt trên đỉnh của ba tầng thoái hoá từ "chọn giữa hai tín hiệu sống" xuống "AND với
hằng số". Chi phí thật của SRA không nằm ở cổng sinh `fill` mà ở chỗ nó **biến 7 nút hằng
số thành 7 nút sống** lan khắp ba tầng.

### Câu 3 — Đường tới hạn đi qua mấy tầng ghép kênh?

**Đủ cả ba tầng, cộng một cổng sinh `fill` nằm ngoài chúng.** Xem §8.

## 8. Trả lời câu phân tích riêng (Charter mục 9)

> *"Barrel shifter được dựng thành 3 tầng ghép kênh (dịch 1, 2, 4). Kiểm chứng cấu trúc
> 3 tầng này có xuất hiện trong đường tới hạn của báo cáo STA không, và độ trễ mỗi tầng
> khoảng bao nhiêu."*

### Có. Ba tầng xuất hiện trên đường tới hạn, gọi đúng tên instance.

```
Startpoint: din[7]      Endpoint: dout[1]      Độ trễ: 0,78 ns      Slack: 9,22 ns (MET)
```

| Mốc | Cell | Thuộc | Độ trễ | Cộng dồn |
|---|---|---|---:|---:|
| `_0_` | `and3_1` | mức đỉnh — sinh `fill` | 0,16 | 0,16 |
| `u_stage1/_37_` | `mux2i_1` | **u_stage1** | 0,07 | 0,23 |
| `u_stage1/_39_` | `a21oi_1` | **u_stage1** | 0,17 | 0,40 |
| `u_stage2/_32_` | `mux2i_1` | **u_stage2** | 0,09 | 0,49 |
| `u_stage2/_34_` | `a21oi_1` | **u_stage2** | 0,17 | 0,66 |
| `u_stage4/_23_` | `nand3_1` | **u_stage4** | 0,08 | 0,74 |
| `u_stage4/_24_` | `o21ai_0` | **u_stage4** | 0,04 | **0,78** |

Thứ tự `u_stage1 → u_stage2 → u_stage4` khớp **chính xác** thứ tự mắc trong RTL.

### Độ trễ mỗi tầng

| Đoạn | Cell | Độ trễ | Tỉ lệ |
|---|---:|---:|---:|
| Sinh `fill` (**ngoài** ba tầng) | 1 | 0,16 ns | 20,5 % |
| `u_stage1` | 2 | 0,24 ns | 30,8 % |
| `u_stage2` | 2 | 0,26 ns | 33,3 % |
| `u_stage4` | 2 | 0,12 ns | 15,4 % |
| **Tổng** | **7** | **0,78 ns** | 100 % |

**Độ trễ trung bình mỗi tầng ≈ 0,21 ns** (`(0,78 − 0,16)/3`). Mỗi tầng đúng **2 cell** —
khớp với thiết kế "2 mức mux 2:1 mỗi tầng".

### Bốn kết quả đáng nói

**① Đường tới hạn bắt đầu ở `din[7]`, không ở `shamt[0]`.** Trái trực giác — người ta
mong tín hiệu điều khiển của tầng đầu tiên là chậm nhất. Thực tế `shamt[0]` chỉ mất
0,64 ns, còn `din[7]` mất 0,78 ns, vì `din[7]` phải đi qua cổng `and3_1` sinh `fill`
(0,16 ns) **trước khi** vào tầng 1. **Đường tới hạn là đường của tính năng dịch phải số
học**, không phải đường dữ liệu thường.

**② Độ trễ các tầng KHÔNG đều, và tầng cuối rẻ nhất.** 0,24 / 0,26 / 0,12 ns. Tầng `S=4`
nhanh hơn hẳn vì **mọi** lát cắt của nó đều có một nhánh suy biến (nửa dưới độn hằng số 0,
nửa trên độn `fill`), nên sau tổng hợp nó **không còn cell mux nào** — toàn `nand3`/`o21ai`.
Cùng lý do, nó cũng là tầng có **diện tích nhỏ nhất**: 122,6176 µm² so với 143,8880 µm²
của tầng `S=1`. **Tầng dịch xa nhất lại là tầng rẻ nhất và nhanh nhất.**

**③ "Ba tầng phải tạo thành cái thang đều" là sai.** Đo độ trễ xấu nhất từ từng bit điều khiển:

| Cổng vào | Số tầng phải qua | Độ trễ xấu nhất |
|---|:---:|---:|
| `shamt[0]` | 3 | **0,64 ns** |
| `shamt[1]` | 2 | 0,37 ns |
| `shamt[2]` | 1 | **0,38 ns** |

`shamt[0]` đúng là chậm hơn hẳn, nhưng `shamt[1]` và `shamt[2]` **ngang nhau** — thậm chí
`shamt[2]`, bit đi qua **ít** tầng nhất, còn nhỉnh hơn một chút. Vì `shamt[2]` có fanout 8,
phải lái cả tám lát cắt của tầng cuối. **Số mức logic không phải là độ trễ**; tải điện dung
và lựa chọn cell cũng quan trọng không kém. Đây đúng là lý do Charter mục 9 đòi **số liệu**
chứ không đòi lý luận.

**④ Chênh nhanh/chậm 26× trên cùng netlist.** `shamt[2] → dout[0]` mất 0,03 ns;
`din[7] → dout[1]` mất 0,78 ns. Cùng thư viện, cùng netlist, khác nhau 26 lần — con số
này nói lên bản chất kiến trúc tầng: không phải đầu vào nào cũng "xa" đầu ra như nhau.

## 9. Những chỗ sinh viên hay sai và cách phát hiện

| # | Sai lầm | Hậu quả | Phát hiện bằng bằng chứng nào |
|---|---|---|---|
| 1 | Viết `assign dout = din << shamt;` cho gọn | Mất kiến trúc; không đếm được tầng trên đường tới hạn | Đọc RTL; STA sẽ không có tên `u_stage*` nào trên đường tới hạn |
| 2 | Viết `case (shamt)` 8 nhánh | Đúng cái bẫy Charter mục 10 | Đo: +16,7 % diện tích, +55,1 % độ trễ (`tradeoff.md` §3) |
| 3 | Kết luận "V2 nhỏ hơn" vì nó có **ít cell hơn** (69 < 75) | Kết luận ngược hoàn toàn | So **diện tích**: 480,46 > 411,64 µm². Đếm cell ≠ đo diện tích |
| 4 | Dùng `>>>` trên toán hạng **không dấu** trong golden model | `>>>` hành xử như `>>`, golden model sai theo cùng lỗi với DUT | Phải ép `$signed()` tường minh. TC-003 (`0x80 SRA 3`) phát hiện ngay |
| 5 | Để mỗi tầng độn bằng MSB của tầng trước | Vẫn đúng chức năng nhưng thêm phụ thuộc nối tiếp vô ích | Đọc `datapath.md` §4; STA sẽ thấy MSB thành nút cổ chai |
| 6 | Để mã `mode = 2'b10` không định nghĩa | Suy ra latch hoặc sinh `X` ⟹ vi phạm "0 ô nhớ" | INV-9 (`^dout === 1'bx`) trong testbench; `synth_stat` có cell `dl*` |
| 7 | Nghĩ SRA "chỉ tốn một cổng AND" | Ước lượng diện tích sai 10 lần | Tổng hợp hai phiên bản: +15 cell, +14,2 % (`tradeoff.md` §5.1) |
| 8 | Tưởng `shamt[0]` chắc chắn là đường chậm nhất | Chọn sai vector đo timing | Đo thật: đường tới hạn bắt đầu ở `din[7]` (0,85 ns), không ở `shamt[0]` (0,72 ns) |
| 9 | Đếm cell mux trong netlist để suy ra số tầng | RTL mô tả 24 mux 2:1, netlist của tôi không còn cell mux nào (ABC phân rã thành NAND/NOR/AOI/OAI) | Bằng chứng cấu trúc phải đọc từ **phân cấp module** và **tên instance trên đường tới hạn** |
| 10 | Kết luận "mô phỏng PASS ⟹ kiến trúc đúng" | Kiểm chứng chức năng **mù về cấu trúc** | V2 và V3 cũng PASS 8 192/8 192 với cùng golden model |
| 11 | Dùng waveform để chứng minh độ trễ | Waveform hành vi là zero-delay | Mở VCD: mọi tín hiệu đổi tức thời tại `#1` |
| 12 | Diễn giải "period 10 ns" thành "chạy được ở 100 MHz" | Khẳng định vượt mức | `vclk` chỉ là mốc quy chiếu; A07 không có clock |
| 13 | So số cell/diện tích của A07 với đề khác | Hai đề có thể chạy môi trường khác | Chỉ so trong cùng một lần chạy, cùng script, cùng thư viện |

## 10. Câu hỏi mentor nên đặt khi bảo vệ

| # | Câu hỏi | Đáp án mong đợi |
|---|---|---|
| 1 | Vì sao khối này có đúng 0 flip-flop? | Vì là mạch tổ hợp: `dout` chỉ là hàm của `(din, shamt, mode)` hiện tại. Byte đang xử lý nằm ở thanh ghi đệm **ngoài** A07. |
| 2 | Vì sao **ba** tầng, không phải hai hay bốn? | Vì `shamt` là 3 bit và `1+2+4 = 7` phủ trọn `0…7`. Tổng quát: `log₂N` tầng cho `N` bit. |
| 3 | "Dịch 3 vị trí" tốn bao nhiêu cổng? | **Không cổng nào**, nếu 3 là hằng số — đó chỉ là cách nối dây. Chi phí nằm ở việc **chọn** giữa các cách nối dây, tức ở mux. |
| 4 | Không có clock, vậy sao ba tầng lại "chạy lần lượt"? | "Lần lượt" là phụ thuộc **dữ liệu**, không phải phụ thuộc **chu kỳ**. `u_stage2` chờ điện áp trên dây `s1` xác lập — vật lý, không phải giao thức. |
| 5 | SRA khác SRL ở đâu trong phần cứng? Cho ví dụ số. | Ở một dây: `fill`. Ví dụ `din=0x80, shamt=2`: SRL→`0x20`, SRA→`0xE0`. Trên toàn không gian, hai chế độ khác nhau ở **896/2 048** tổ hợp. |
| 6 | SRA tốn thêm bao nhiêu diện tích? | **+15 cell, +14,2 %** — gấp mười lần ước lượng "một cổng AND", vì `fill` biến 7 nút hằng số thành 7 nút sống. |
| 7 | Mã `mode = 2'b10` nghĩa là gì? Vì sao không để trống? | Bí danh của SLL (dịch trái số học ≡ dịch trái logic). Để trống sẽ suy ra latch hoặc sinh `X`. Rotate nằm ngoài phạm vi nên không được dùng mã này. |
| 8 | Đường tới hạn đi qua mấy tầng? Bắt đầu ở đâu? | Đủ **ba** tầng (`u_stage1→u_stage2→u_stage4`), **cộng** cổng `and3_1` sinh `fill`. Bắt đầu ở `din[7]`, **không** ở `shamt[0]`. 7 cell, 0,85 ns. |
| 9 | Tầng nào đắt nhất? | Tầng `S=1` (143,89 µm²), **không** phải tầng `S=4` (122,62 µm²). Tầng dịch xa nhất lại rẻ nhất vì mọi lát cắt của nó đều có một nhánh suy biến. |
| 10 | Bạn nói có ba tầng — chứng minh bằng netlist đi. | Ba instance riêng trong báo cáo phân cấp Yosys; ba tên `u_stage1/…`, `u_stage2/…`, `u_stage4/…` trên đường tới hạn của OpenSTA. **Không** chứng minh bằng cách đếm cell mux — netlist chỉ còn 11/24. |
| 11 | 8 192/8 192 PASS — chứng minh mạch là ba tầng chưa? | **Chưa.** Kiểm chứng chức năng mù về cấu trúc. V2 (`case` 8 nhánh) cũng PASS 8 192/8 192 với cùng golden model. |
| 12 | Mẹo đảo-dịch-đảo tiết kiệm được gì? | **Không tiết kiệm gì ở đây.** Đo thật: +10,9 % diện tích, +85,9 % độ trễ, vì hai lớp mux đảo nằm nối tiếp và thêm 2 mức vào đường tới hạn. |
| 13 | Con số 0,85 ns có phải độ trễ thật của chip không? | Không. Độ trễ **sau tổng hợp**, chưa có RC dây, một góc PVT. Sau routing sẽ lớn hơn. |
| 14 | Vì sao `shamt[2]` không nhanh hơn `shamt[1]` dù đi qua ít tầng hơn? | Vì `shamt[2]` có fanout 8 và lái cả tám lát cắt của tầng cuối. Số mức logic không phải là độ trễ. |
| 15 | Ngân sách chân có vấn đề gì không? | Không. 13 bit vào + 8 bit ra = **21/24 chân**, còn dư 3 — đúng như Charter mục 4 ghi. |

## 11. Giới hạn: đã chứng minh được gì, chưa chứng minh được gì

### Đã chứng minh

1. Hàm của A07 đúng trên **toàn bộ** không gian đầu vào: 8 192/8 192 tổ hợp, 0 sai lệch.
2. Chín bất biến của đặc tả luôn giữ: 17 458 lần kiểm, 0 vi phạm.
3. **Ba** hiện thực độc lập đồng ý với nhau: Python toán tử, Python ba tầng, SV reference, RTL.
4. Cấu trúc ba tầng **phủ đủ** lượng dịch 0…7 — chứng minh bằng Python trước khi viết RTL.
5. **0 ô nhớ** — xác nhận bởi hai bằng chứng độc lập (bảng cell Yosys + công suất Sequential 0,0 %).
6. **Ba tầng có thật trong mạch đã tổng hợp**: ba instance trong phân cấp, ba tên trên đường tới hạn.
7. Kiến trúc tầng **nhỏ hơn** phương án `case` phẳng: 411,64 so 480,46 µm² (−14,3 %). *(số của gói gốc, Yosys 0.33)*
8. Kiến trúc tầng **nhanh hơn** phương án `case` phẳng: 0,78 so 1,21 ns (−35,5 %). *(số của gói gốc, Yosys 0.33)*
9. Chi phí của SRA: **+15 cell, +14,2 % diện tích** — đo bằng cách tổng hợp hai phiên bản.
10. Chi phí của chiều thứ hai: **+50 cell, +48,9 % diện tích**.
11. Độ trễ mỗi tầng: **≈ 0,21 ns**, chi tiết 0,24 / 0,26 / 0,12 ns.

### Chưa chứng minh

1. Netlist tương đương RTL về chức năng — cần **mô phỏng gate-level**.
2. Không có glitch gây hại — mô phỏng hiện tại là **zero-delay**, không thể thấy glitch.
3. Độ trễ **thật sau routing** — 0,85 ns chưa tính ký sinh dây.
4. Biên an toàn qua các **góc PVT** — mới đo ở một góc.
5. Công suất thật của ứng dụng — 2,70·10⁻⁵ W dùng activity mặc định, không lấy từ VCD.
6. Layout tuân thủ quy tắc chế tạo (DRC), khớp netlist (LVS), và có file GDSII.
7. Thứ hạng giữa V1/V2/V3 **sau P&R** — có thể đổi, nhất là với V3 vốn nhiều dây chéo.

### Ngoài phạm vi — không được khẳng định

"Đã sign-off", "đã tape-out", "đã chế tạo", "đã kiểm tra sau chế tạo", "chạy được ở
XXX MHz". Charter mục 3 loại tất cả khỏi phạm vi. Dịch vòng (rotate) và dịch trên dữ liệu
rộng hơn 8 bit cũng nằm ngoài phạm vi.

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24*
