# A07 · Đường dữ liệu (Datapath)

---

## 1. Toàn bộ khối A07 **là** datapath

A07 không có phần điều khiển tách rời. `shamt` và `mode` trông giống "lệnh", nhưng chúng
không điều phối trình tự nào cả — chúng chỉ là **chân chọn của các bộ ghép kênh**, tức là
một phần của chính đường dữ liệu. Không có tín hiệu nào là enable, là valid, hay là lệnh
chuyển bước.

```
  din[7:0] ═══════▶ ┌───────────────────────────────────┐ ═══▶ dout[7:0]
                    │  3 tầng ghép kênh nối tiếp        │
  shamt[2:0] ─────▶ │  (dịch 1 · dịch 2 · dịch 4)       │
  mode[1:0] ──────▶ │  + 1 cổng AND3 sinh bit độn       │
                    └───────────────────────────────────┘
```

## 2. Bảng các đường dữ liệu

| Đường | Rộng | Từ | Đến | Bản chất |
|---|---:|---|---|---|
| `din[7:0]` | 8 | cổng vào | `u_stage1` (8 lát) + cổng AND3 | Dữ liệu chính |
| `din[7]` | 1 | cổng vào | cổng AND3 sinh `fill` | **Bit dấu — nguồn của SRA** |
| `shamt[0]` | 1 | cổng vào | `u_stage1.en` (fanout 8) | Chọn nhánh tầng 1 |
| `shamt[1]` | 1 | cổng vào | `u_stage2.en` (fanout 8) | Chọn nhánh tầng 2 |
| `shamt[2]` | 1 | cổng vào | `u_stage4.en` (fanout 8) | Chọn nhánh tầng 4 |
| `mode[0]` = `dir` | 1 | cổng vào | **cả ba tầng** + AND3 | Chọn chiều; fanout lớn nhất khối |
| `mode[1]` = `arith` | 1 | cổng vào | chỉ cổng AND3 | Fanout nhỏ nhất: **1** |
| `fill` | 1 | AND3 | **cả ba tầng**, các lát cắt trên đỉnh | Bit độn của SRA |
| `s1[7:0]` | 8 | `u_stage1` | `u_stage2` | **Mắt xích nối tiếp 1→2** |
| `s2[7:0]` | 8 | `u_stage2` | `u_stage4` | **Mắt xích nối tiếp 2→4** |
| `dout[7:0]` | 8 | `u_stage4` | cổng ra | Kết quả |

Chỉ có **hai** dây nối tiếp giữa các tầng (`s1`, `s2`), mỗi dây 8 bit. Đó là toàn bộ
chuỗi phụ thuộc của thiết kế.

## 3. Đồ thị phụ thuộc

```
  mức 0   din[7:0]   shamt[2:0]   mode[1:0]            ← sẵn sàng ngay
             │           │            │
             │           │            ├─[1] arith ──┐
             │           │            └─[0] dir ────┼──┬──┬──┐
             ├───[7]─────┼─────────────────────────▶│  │  │  │
  mức 1      │           │                       AND3│  │  │  │
             │           │                          fill │  │  │
             │           │                           │  │  │  │
             ▼           ▼[0]                        ▼  ▼  │  │
  mức 2   ┌──────────────────────────────────────────────┐ │  │
          │              u_stage1  (dịch 1)              │ │  │
          └───────────────────────┬──────────────────────┘ │  │
                                  │ s1[7:0]                │  │
                                  ▼        ▼[1]            ▼  │
  mức 3   ┌──────────────────────────────────────────────┐    │
          │              u_stage2  (dịch 2)              │    │
          └───────────────────────┬──────────────────────┘    │
                                  │ s2[7:0]                   │
                                  ▼        ▼[2]               ▼
  mức 4   ┌──────────────────────────────────────────────┐
          │              u_stage4  (dịch 4)              │
          └───────────────────────┬──────────────────────┘
                                  ▼ dout[7:0]
```

**Đặc điểm đáng chú ý:** `shamt[2]` — bit **nặng nhất**, điều khiển tầng dịch **xa nhất** —
lại đi vào **mức sâu nhất**, tức nó chỉ phải đi qua **một** tầng. Ngược lại `shamt[0]`,
bit nhẹ nhất, phải đi qua **cả ba**. Trọng số số học và độ sâu logic **nghịch nhau**.

## 4. Vì sao `fill` lấy từ `din[7]` chứ không từ tầng trước

Có hai cách hiện thực SRA, và chúng khác nhau về **hình dạng đồ thị phụ thuộc**:

| Cách | Mô tả | Hệ quả |
|---|---|---|
| ❌ Mỗi tầng độn bằng MSB của **tín hiệu vào tầng đó** | `u_stage2` độn bằng `s1[7]` | Đúng về chức năng, nhưng thêm một đường phụ thuộc qua các tầng; MSB trở thành nút cổ chai |
| ✅ **Cách đã chọn:** cả ba tầng độn bằng `fill` sinh **một lần** từ `din[7]` | `fill` là hằng số với cả chuỗi | Các tầng chỉ nối tiếp qua đường dữ liệu chính; `fill` đi **song song** vào cả ba tầng |

Cách ❌ vẫn cho kết quả đúng vì với SRA, MSB của mọi tầng trung gian **đã bằng** `din[7]`.
Nhưng nó biến một tín hiệu vốn sẵn sàng ngay từ mức 0 thành một tín hiệu phải chờ tầng
trước. Cách ✅ giữ `fill` ở mức 1 và phát song song.

## 5. Độ sâu logic — đo thật, không ước lượng

Đo bằng OpenSTA trên netlist sau tổng hợp, clock ảo `vclk` chu kỳ 10 ns (mốc quy chiếu,
**không** phải tuyên bố tần số hoạt động).

### 5.1 Đường tới hạn

```
Startpoint: din[7]        Endpoint: dout[1]        Độ trễ: 0,85 ns        Slack: 9,15 ns (MET)
```

| Mốc | Cell | Thuộc | Độ trễ cell | Thời điểm |
|---|---|---|---:|---:|
| `din[7]` | — | cổng vào | — | 0,00 ns |
| `_0_` | `and3_1` | **mức đỉnh** (sinh `fill`) | 0,16 | 0,16 ns |
| `u_stage1/_37_` | `mux2i_1` | **u_stage1** | 0,07 | 0,23 ns |
| `u_stage1/_39_` | `a21oi_1` | **u_stage1** | 0,17 | 0,40 ns |
| `u_stage2/_32_` | `mux2i_1` | **u_stage2** | 0,09 | 0,49 ns |
| `u_stage2/_34_` | `a21oi_1` | **u_stage2** | 0,17 | 0,66 ns |
| `u_stage4/_23_` | `nand3_1` | **u_stage4** | 0,08 | 0,74 ns |
| `u_stage4/_24_` | `o21ai_0` | **u_stage4** | 0,04 | 0,85 ns |
| `dout[1]` | — | cổng ra | — | **0,85 ns** |

**Ba tầng xuất hiện trên đường tới hạn, gọi đúng tên instance**, theo đúng thứ tự
`u_stage1 → u_stage2 → u_stage4`. Đây là câu trả lời trực tiếp cho Charter mục 9.

### 5.2 Độ trễ từng tầng

| Đoạn | Số cell | Độ trễ | Tỉ lệ |
|---|---:|---:|---:|
| Sinh `fill` (ngoài ba tầng) | 1 | **0,16 ns** | 20,5 % |
| `u_stage1` | 2 | **0,24 ns** | 30,8 % |
| `u_stage2` | 2 | **0,26 ns** | 33,3 % |
| `u_stage4` | 2 | **0,12 ns** | 15,4 % |
| **Tổng** | **7** | **0,85 ns** | 100 % |

Độ trễ trung bình mỗi tầng: `(0,78 − 0,16) / 3 = 0,207 ns ≈ **0,21 ns/tầng**`.
Mỗi tầng đúng **2 cell** trên đường tới hạn — khớp với thiết kế "2 mức mux 2:1 mỗi tầng".

### 5.3 Đường nhanh nhất

```
Startpoint: shamt[2]      Endpoint: dout[0]        Độ trễ: 0,03 ns
```

`shamt[2]` chỉ điều khiển tầng **cuối**, nên nó đi qua đúng **một** cell là tới đầu ra.
Chênh khoảng **25–30 lần** so với đường tới hạn 0,85 ns, trên cùng một netlist, cùng thư viện.

### 5.4 Độ trễ xấu nhất theo từng cổng vào

| Cổng vào | Điều khiển | Số tầng phải đi qua | Độ trễ xấu nhất |
|---|---|:---:|---:|
| `shamt[0]` | tầng 1 (đầu tiên) | **3** | **0,64 ns** |
| `shamt[1]` | tầng 2 (giữa) | 2 | 0,37 ns |
| `shamt[2]` | tầng 4 (cuối) | 1 | **0,38 ns** |
| `mode[0]` = `dir` | cả 3 tầng + AND3 | 3 | **0,85 ns** |
| `mode[1]` = `arith` | AND3 → cả 3 tầng | 3 | 0,77 ns |
| `din[7]` | dữ liệu + AND3 | 3 | **0,85 ns** |
| `din[0]` | chỉ dữ liệu | 3 | 0,66 ns |

> 🔎 **Kết quả không như dự đoán, và phải nói thẳng.** Dự đoán tự nhiên là một cái thang
> đều: `shamt[0]` chậm nhất, `shamt[1]` trung bình, `shamt[2]` nhanh nhất. Thực tế
> `shamt[0]` (0,64 ns) **đúng** là chậm hơn hẳn, nhưng `shamt[1]` (0,37) và `shamt[2]`
> (0,38) **ngang nhau**, thậm chí `shamt[2]` còn nhỉnh hơn một chút.
>
> Lý do: `shamt[2]` có **fanout 8** và phải lái toàn bộ tám lát cắt của tầng cuối, trong
> khi đường của `shamt[1]` qua hai tầng lại được `abc` ánh xạ vào các cell nhanh hơn.
> **Số mức logic không phải là độ trễ.** Tải điện dung và lựa chọn cell của công cụ cũng
> quan trọng không kém. Đây là lý do câu hỏi Charter mục 9 đòi **số liệu**, chứ không đòi
> lý luận.

## 6. Vì sao không có thanh ghi trong datapath

| Câu hỏi | Trả lời |
|---|---|
| Dữ liệu có cần giữ qua chu kỳ không? | Không — A07 tính xong trong một lần lan truyền |
| Có pipeline không? | Không — Charter chốt loại mạch **Tổ hợp** |
| Byte đang xử lý giữ ở đâu? | Ở thanh ghi đệm **bên ngoài** — xem `system_diagram.md` §1 |
| Nếu thêm thanh ghi thì sao? | Vi phạm REQ-A07-003 và Charter mục 10 (*"dấu hiệu làm đúng: 0 ô nhớ"*) |
| Bằng chứng 0 ô nhớ | Bảng cell Yosys: 0 flip-flop · `report_power`: Sequential **0,0 %** |

## 7. Cơ hội pipeline (chỉ để thảo luận — **ngoài phạm vi**)

Nếu được phép thêm ô nhớ, có thể chèn thanh ghi giữa tầng 2 và tầng 4:

```
  [u_stage1 · u_stage2] ──▶ REG 8-bit ──▶ [u_stage4]
   độ trễ tổ hợp dài nhất giảm từ 0,85 ns xuống ≈ 0,70 ns và ≈ 0,15 ns
   chi phí: +8 FF, +1 chu kỳ độ trễ, đổi loại mạch sang Tuần tự
```

Phương án này **không được dùng**: nó phá vỡ chính dấu hiệu làm đúng của Charter mục 10.
Và với đường tới hạn chỉ 0,85 ns, chia đôi một con số vốn đã rất nhỏ là **tối ưu sai chỗ**.
Ghi ở đây chỉ để trả lời khi bảo vệ. Xem thêm `tradeoff.md`.

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24.*
