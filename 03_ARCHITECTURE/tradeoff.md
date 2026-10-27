# A07 · Đánh đổi kiến trúc (Trade-off)

Tài liệu này so kiến trúc đã chọn với **bốn** kiến trúc thay thế. Mọi con số đều là số
**đo thật**: mỗi phương án được viết thành RTL chạy được, kiểm tương đương với cùng golden
model, rồi tổng hợp và chạy STA bằng **cùng một script, cùng thư viện `sky130_fd_sc_hd`,
cùng máy, cùng ngày**. Không có con số nào ước lượng trên giấy.

---

## 1. Kiến trúc đã chọn

**V1 — Ba tầng ghép kênh lưỡng hướng (1 · 2 · 4).**
Mỗi tầng tự xử lý cả hai chiều bằng một mux 3:1 mỗi bit (hiện thực bằng hai mux 2:1 nối
tiếp). Đây là `04_IMPLEMENTATION/rtl/`.

## 2. Bảng so sánh tổng hợp

| # | Kiến trúc | Cell | Diện tích (µm²) | FF | Độ trễ (ns) | Công suất (W) | Đúng chức năng |
|---|---|---:|---:|:---:|---:|---:|:---:|
| **V1** | **Ba tầng lưỡng hướng — ĐÃ CHỌN** | **75** | **411,6448** | **0** | **0,78** | 1,35·10⁻⁵ | ✅ 8192/8192 |
| V2 | `case (shamt)` 8 nhánh | 69 | 480,4608 | 0 | 1,21 | 1,24·10⁻⁵ | ✅ 8192/8192 |
| V3 | Đảo bit → 3 tầng một chiều → đảo bit | 41 | 456,6880 | 0 | 1,45 | 1,42·10⁻⁵ | ✅ 8192/8192 |
| V4 | Như V1 nhưng **bỏ SRA** (chỉ SLL/SRL) | 60 | 360,3456 | 0 | 0,85 | 1,27·10⁻⁵ | — (ít chức năng hơn) |
| V5 | Như V1 nhưng **chỉ dịch phải** (có SRA) | 25 | 276,5152 | 0 | 1,06 | 7,23·10⁻⁶ | — (ít chức năng hơn) |

> V2 và V3 **tương đương chức năng hoàn toàn** với V1 — đã kiểm 8 192/8 192 vector khớp
> cùng một `a07_reference`. Chúng là những lựa chọn thật, không phải hình nộm.
> V4 và V5 **bớt chức năng** một cách có chủ ý, dùng để **bóc tách chi phí** (§5).

## 3. V2 — `case (shamt)` 8 nhánh: chính xác cái bẫy Charter mục 10 cảnh báo

Charter mục 10 viết: *"Chỗ hay tắc: Không thấy ba tầng — viết một `case` 8 nhánh rồi
**ngạc nhiên vì diện tích lớn**."* Đây là kiểm chứng định lượng câu đó.

```systemverilog
// V2 — cách viết bị CẤM trong RTL nộp bài
case (shamt)
  3'd0: dout = din;
  3'd1: dout = {din[6:0], 1'b0};
  ...
  3'd7: dout = {din[0], 7'b0};
endcase
```

| | V1 (3 tầng) | V2 (case 8 nhánh) | Chênh |
|---|---:|---:|---:|
| **Diện tích** | 411,6448 µm² | **480,4608 µm²** | **+68,82 µm² · +16,7 %** |
| **Độ trễ** | 0,78 ns | **1,21 ns** | **+0,43 ns · +55,1 %** |
| Số cell | 75 | 69 | −6 · −8,0 % |
| Công suất | 1,35·10⁻⁵ W | 1,24·10⁻⁵ W | −8,1 % |

**Charter nói đúng: V2 vừa to hơn vừa chậm hơn.** Nhưng số liệu còn dạy thêm hai điều mà
câu cảnh báo không nói:

> 🔎 **① V2 có ÍT cell hơn nhưng NHIỀU diện tích hơn.** 69 cell mà 480,46 µm², so với
> 75 cell mà 411,64 µm². Nguyên nhân: `abc` gom logic của V2 vào các cell **to** (`a41oi_1`,
> `a221o_1`, `nor3b_1`), còn V1 được phân rã thành nhiều cell **nhỏ** (`nor2_1`, `a21oi_1`).
> **Đếm cell không phải là đo diện tích.** Ai chỉ nhìn cột "số cell" sẽ kết luận ngược.

> 🔎 **② Chênh lệch thực tế (+16,7 %) NHỎ HƠN nhiều so với lý thuyết.** Lý thuyết bảo
> phương án phẳng cần `N(N−1) = 56` mux 2:1 còn phương án tầng chỉ cần `N·log₂N = 24` —
> tỉ lệ 2,3×. Đo thật chỉ ra 1,17×. Vì sao? Vì rất nhiều nhánh của `case` có toán hạng là
> **hằng số 0**, và `abc` rút gọn chúng đi. **Lý thuyết cho hướng đúng nhưng sai độ lớn.**

### Vì sao chênh lệch sẽ lớn hơn nhiều ở độ rộng lớn

| Độ rộng `N` | Phương án tầng: `N·log₂N` mux | Phương án phẳng: `N(N−1)` mux | Tỉ lệ |
|---:|---:|---:|---:|
| 8 (A07) | 24 | 56 | 2,3× |
| 16 | 64 | 240 | 3,8× |
| 32 | 160 | 992 | **6,2×** |
| 64 | 384 | 4 032 | **10,5×** |

Ở `N = 8`, barrel shifter dạng tầng "chỉ" thắng 16,7 % — chưa đủ để gọi là bắt buộc. Lý do
thật để học kiến trúc tầng là **nó co giãn theo `O(N log N)` thay vì `O(N²)`**. Charter
chọn `N = 8` vì đó là cỡ nhỏ nhất còn **nhìn thấy được ba tầng**; bài học thì nhắm tới
`N` lớn. (Độ rộng > 8 bit nằm **ngoài phạm vi** theo Charter mục 3 — bảng trên chỉ để
lập luận.)

## 4. V3 — Đảo bit → dịch một chiều → đảo bit

Một mẹo kinh điển: vì `a << n = reverse(reverse(a) >> n)`, chỉ cần dựng **một** barrel
shifter dịch phải rồi kẹp hai lớp đảo bit ở hai đầu. Đảo bit là **đổi dây thuần tuý**,
không tốn cổng nào — nghe như được "miễn phí" chiều thứ hai.

```
  din ──▶[mux đảo?]──▶[tầng 1]──▶[tầng 2]──▶[tầng 4]──▶[mux đảo?]──▶ dout
            ▲                                              ▲
           dir                                            dir
```

**Đo thật cho thấy mẹo này THUA trên cả hai trục:**

| | V1 | V3 | Chênh |
|---|---:|---:|---:|
| Diện tích | 411,6448 µm² | **456,6880 µm²** | **+45,04 µm² · +10,9 %** |
| Độ trễ | 0,78 ns | **1,45 ns** | **+0,67 ns · +85,9 %** |
| Số cell | 75 | **41** | **−34 · −45,3 %** |
| Số mức mux trên đường tới hạn | 3 tầng (7 cell) | **5 mux2_1** | +2 mức |

Hai lý do, cả hai đều đọc ra từ báo cáo:

**① Đảo bit miễn phí, nhưng MUX ĐẢO thì không.** Phải có hai lớp mux 2:1 (8 bit mỗi lớp
= 16 mux) để **chọn** có đảo hay không. Tiết kiệm được ở ba tầng lại phải trả lại ở hai
đầu — và trả **đúng ở chỗ đắt nhất**: hai lớp đó nằm **nối tiếp** với ba tầng.

**② Đường tới hạn dài thêm hai mức.** Báo cáo STA của V3 liệt kê đúng năm cell:

```
_07_/X   : mux2_1     ← lớp đảo ĐẦU VÀO
u1/_6_/X : mux2_1     ← tầng 1
u2/_4_/X : mux2_1     ← tầng 2
u3/_0_/X : mux2_1     ← tầng 4
_08_/X   : mux2_1     ← lớp đảo ĐẦU RA
```

5 mức mux thay vì 3. Đó là 67 % số mức tăng thêm, và độ trễ tăng 86 %.

**③ V3 có ít cell hơn hẳn (41 vs 75) mà vẫn to hơn.** Lần thứ hai trong tài liệu này, cột
"số cell" chỉ hướng sai. V3 gồm 40 cell `mux2_1` — mux **đầy đủ**, cell to. V1 bị phân rã
thành cell nhỏ. Bài học lặp lại: **so diện tích, đừng so số cell.**

> ✅ **Kết luận về V3.** Mẹo đảo-dịch-đảo là mẹo hay khi phần cứng dịch một chiều **đã có
> sẵn** và ta chỉ muốn thêm chiều thứ hai gần như miễn phí. Khi được thiết kế từ đầu như
> ở đây, cho mỗi tầng tự lo cả hai chiều rẻ hơn. Một mẹo được truyền miệng là hay vẫn cần
> **đo lại trong ngữ cảnh của mình**.

## 5. Bóc tách chi phí bằng V4 và V5

Hai phương án này **không** phải ứng viên thay thế — chúng bớt chức năng. Chúng tồn tại
để trả lời câu hỏi *"phần nào của khối tốn bao nhiêu?"*, bằng cách tổng hợp cùng kiến
trúc với đúng một tính năng bị gỡ bỏ.

### 5.1 Dịch phải SỐ HỌC tốn bao nhiêu? (V1 so V4)

| Phiên bản | Chức năng | Cell | Diện tích |
|---|---|---:|---:|
| V4 | Chỉ SLL + SRL | 60 | 360,3456 µm² |
| **V1** | SLL + SRL + **SRA** | 75 | 411,6448 µm² |
| **Chênh** | | **+15 cell** | **+51,30 µm² · +14,2 %** |

> 🔎 **Con số này bác bỏ câu trả lời trực giác.** Nhìn RTL, khác biệt giữa SRA và SRL chỉ
> là **một** cổng AND3 sinh `fill` — nên ai cũng đoán chi phí là "1 cell, ~1,5 %". Đo thật
> ra **15 cell, 14,2 %** — gấp **mười lần** ước lượng.
>
> Nguyên nhân: khi bỏ SRA, `fill` trở thành **hằng số 0**. Bảy lát cắt trên đỉnh của ba
> tầng (1 lát ở S=1, 2 lát ở S=2, 4 lát ở S=4) lúc đó không còn phải **chọn** giữa hai
> tín hiệu sống nữa — chúng thoái hoá thành cổng AND đơn giản, và `abc` rút gọn tiếp
> sang các cell nhỏ hơn. Chi phí thật của SRA **không** nằm ở cổng sinh `fill`, mà nằm ở
> chỗ **`fill` biến 7 nút hằng số thành 7 nút sống** lan khắp ba tầng.

### 5.2 Hỗ trợ CẢ HAI CHIỀU tốn bao nhiêu? (V1 so V5)

| Phiên bản | Chức năng | Cell | Diện tích |
|---|---|---:|---:|
| V5 | Chỉ dịch phải (SRL + SRA) | 25 | 276,5152 µm² |
| **V1** | Cả trái và phải | 75 | 411,6448 µm² |
| **Chênh** | | **+50 cell · 3,0×** | **+135,13 µm² · +48,9 %** |

Chiều thứ hai gần như **nhân ba** số cell. Hợp lý: mỗi lát cắt đi từ một mux 2:1 lên một
mux 3:1. Nhưng diện tích **chỉ** tăng 48,9 %, không phải 200 %, vì V5 dùng toàn cell
`mux2_1` to còn V1 được phân rã thành cell nhỏ.

**Tổng chi phí tính năng:** trên nền 276,52 µm² của một bộ dịch phải đơn thuần, hai tính
năng bổ sung cộng thêm 135,13 µm² (chiều trái) — bản thân V5 đã bao gồm SRA.

## 6. Các kiến trúc Charter xếp NGOÀI PHẠM VI

| Kiến trúc | Vì sao không xét | Nguồn |
|---|---|---|
| **Dịch vòng (rotate)** | Charter mục 3: *"Ngoài phạm vi: Dịch vòng (rotate)"* | mục 3 |
| **Dịch trên dữ liệu > 8 bit** | Charter mục 3: *"…dịch trên dữ liệu rộng hơn 8 bit"* | mục 3 |
| **Thanh ghi dịch tuần tự** | Có ô nhớ ⟹ vi phạm Charter mục 10 *"0 ô nhớ"*; thông lượng biến thiên, không hợp bối cảnh giải mã gói tin | mục 10 |
| **Tự tối ưu netlist bằng tay** | Charter mục 3 loại khỏi phạm vi với mọi đề | mục 3 |
| Funnel shifter (dịch trên 16 bit ghép từ 2 byte) | Suy ra từ "> 8 bit" | mục 3 |

Riêng thanh ghi dịch tuần tự đáng nói thêm một câu: nó **nhỏ hơn hẳn** về diện tích logic
tổ hợp (chỉ 8 mux 2:1), nhưng phải cộng ≥ 8 flip-flop cộng bộ đếm cộng FSM. Và quan trọng
hơn, nó **đổi loại mạch** — điều mà Charter đã chốt từ đầu.

## 7. Vì sao chọn V1

| Tiêu chí của ứng dụng (giải mã gói tin) | V1 đáp ứng? |
|---|---|
| Dịch **mọi** lượng 0–7 trong **một** chu kỳ | ✅ Tổ hợp thuần, 0,78 ns |
| Thông lượng **cố định** một byte/chu kỳ | ✅ Không có trạng thái, không có vòng lặp |
| **0 ô nhớ** (Charter mục 10) | ✅ 0 flip-flop, hai nguồn xác nhận |
| Netlist **thấy rõ ba tầng** (Charter mục 10) | ✅ Ba instance có tên trong phân cấp; ba tầng xuất hiện trên đường tới hạn |
| Nhỏ hơn ước lượng 180–260 cell của Charter | ✅ 75 cell |
| Nhỏ nhất trong các phương án **đủ chức năng** | ✅ 411,64 < 456,69 (V3) < 480,46 (V2) |
| Nhanh nhất trong các phương án **đủ chức năng** | ✅ 0,78 < 1,21 (V2) < 1,45 (V3) |

V1 thắng **cả hai trục** so với hai ứng viên đủ chức năng. Đó là một kết quả may mắn —
thường thì diện tích và tốc độ đánh đổi nhau — và nó xảy ra vì V2 và V3 đều trả giá ở
cùng một chỗ: chúng thêm mức logic **nối tiếp** mà không giảm được logic song song.

## 8. Cảnh báo về cách đọc các con số này

> ⚠️ **1. So diện tích thì vững, so độ trễ thì có nhiễu.** Mỗi phương án được `abc` ánh xạ
> **độc lập**, nên lựa chọn cell khác nhau. Bằng chứng rõ nhất: **V4 (bỏ SRA, ít chức năng
> hơn, ít cell hơn) lại CHẬM HƠN V1** — 0,85 ns so với 0,78 ns. Và **V5 (chỉ dịch phải,
> chỉ 25 cell) chậm hơn cả V1** — 1,06 ns so với 0,78 ns. Điều đó **không** có nghĩa
> "thêm chức năng làm mạch nhanh hơn"; nó có nghĩa `abc` đã chọn cho V4/V5 các cell
> `mux2_1` to và chậm hơn. Chênh lệch dưới ~15 % về độ trễ **không** nên diễn giải là
> khác biệt kiến trúc.
>
> ⚠️ **2. Tất cả là số SAU TỔNG HỢP, chưa có ký sinh dây.** Sau P&R mọi con số sẽ **lớn
> hơn**, và thứ hạng **có thể đổi** — đặc biệt với V3, vốn có nhiều dây chéo do hai lớp
> đảo bit. Chưa chạy P&R.
>
> ⚠️ **3. Một góc PVT duy nhất.** Mới đo ở một góc của `sky130_fd_sc_hd`.
>
> ⚠️ **4. Công suất dùng activity mặc định**, không lấy từ VCD của ứng dụng thật. Chỉ nên
> đọc ở mức thứ tự độ lớn.

## 9. Mã nguồn các phương án thay thế

V2–V5 được viết để **đo**, không nằm trong hồ sơ nộp bài, và **không** được đưa vào
`04_IMPLEMENTATION/rtl/`. Cách dựng lại chúng được mô tả đầy đủ ở §3–§5 (mỗi phương án
chỉ khác V1 ở một điểm đã nêu rõ). Quy trình đo: cùng script Yosys và cùng file SDC như
`02_run_synth.sh` và `03_run_sta.tcl`, chỉ đổi tên module đỉnh.

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24.*
