# A07 · Giản đồ thời gian (Timing Diagram)

> ⚠️ **Đọc kỹ trước khi dùng các hình dưới đây.**
> A07 **không có clock**. Mọi trục thời gian ở đây là **thời gian lan truyền tổ hợp**
> trong **một** chu kỳ của hệ thống bao ngoài, không phải chuỗi nhiều chu kỳ.
> Waveform VCD của mô phỏng là **zero-delay** — mọi tín hiệu đổi tức thời tại `#1` — nên
> waveform **không** chứng minh được độ trễ. Số liệu độ trễ ở đây đến từ **OpenSTA** chạy
> trên netlist sau tổng hợp.

---

## 1. Ca xấu nhất — 0,85 ns

Đường tới hạn đo được: `din[7] → dout[1]`, qua cổng sinh `fill` rồi cả ba tầng.

```
  t (ns)   0.00      0.16      0.23   0.40      0.49   0.66   0.74  0.78
           │         │         │      │         │      │      │     │
  din[7] ──┬─────────────────────────────────────────────────────────────▶
           │
           │  ┌──────┐
  AND3     └─▶│ _0_  │ 0.16
              └───┬──┘
  fill          ──┴──┬──────────────────────────────────────────────────▶
                     │
          ╔══════════╪══════════════════╗
          ║ u_stage1 │                  ║
          ║       ┌──▼───┐   ┌────────┐ ║
          ║       │mux2i │──▶│ a21oi  │ ║   0.07 + 0.17 = 0.24 ns
          ║       └──────┘   └────┬───┘ ║
          ╚═══════════════════════╪═════╝
  s1[7]                         ──┴──┬──────────────────────────────────▶
                                     │
          ╔══════════════════════════╪═══╗
          ║ u_stage2                 │   ║
          ║                       ┌──▼──┐║
          ║                       │mux2i│║   0.09 + 0.17 = 0.26 ns
          ║                       └──┬──┘║
          ║                       ┌──▼──┐║
          ║                       │a21oi│║
          ║                       └──┬──┘║
          ╚══════════════════════════╪═══╝
  s2[5]                            ──┴──┬────────────────────────────────▶
                                        │
          ╔═════════════════════════════╪══╗
          ║ u_stage4                    │  ║
          ║                          ┌──▼─┐║  0.08 + 0.04 = 0.12 ns
          ║                          │nand3│║
          ║                          └──┬─┘║
          ║                          ┌──▼─┐║
          ║                          │o21ai│║
          ║                          └──┬─┘║
          ╚═════════════════════════════╪══╝
  dout[1]                              ─┴──────────────────────────────▶
                                                              ỔN ĐỊNH tại 0.78
```

| Đoạn | Độ trễ | Cộng dồn |
|---|---:|---:|
| Sinh `fill` (`and3_1`) | 0,16 ns | 0,16 |
| `u_stage1` (2 cell) | 0,24 ns | 0,40 |
| `u_stage2` (2 cell) | 0,26 ns | 0,66 |
| `u_stage4` (2 cell) | 0,12 ns | 0,78 |
| **Tổng** | **0,85 ns** | |

Slack so với clock ảo 10 ns: **9,15 ns (MET)**. WNS `0,00` · TNS `0,00`.

## 2. Ca tốt nhất — 0,03 ns

```
  t (ns)     0.00                               0.03
             │                                  │
  shamt[2] ──┬──────────────────────────────────┼──────────▶
             │  ┌────────────────┐              │
             └─▶│ u_stage4/_xx_  │──────────────┤
                └────────────────┘              │
  dout[0]  ────────────────────────────────────┬┴──────────▶
                                          ỔN ĐỊNH tại 0.03
```

`shamt[2]` điều khiển tầng **cuối**, nên nó chỉ đi qua **một** cell là ra tới đầu ra.

**Chênh lệch nhanh/chậm trên cùng netlist: 0,85 / 0,03 ≈ 25–30 lần.** Đây là con số nói lên
bản chất của kiến trúc tầng: không phải mọi đầu vào đều "xa" đầu ra như nhau.

## 3. Hợp đồng lấy mẫu với tầng trên

```
      ┌──────────────── một chu kỳ hệ thống ─────────────────┐
      │                                                       │
      │  cạnh clock của          │◀── 0,85 ns ──▶│            │
      │  thanh ghi NGUỒN         │  lan truyền   │            │
      │       ▼                  │  qua A07      │            │
  ────┴───────┬──────────────────┴───────────────┴────────────┴──▶
              │
  din/shamt/  │═══════ ĐẦU VÀO ỔN ĐỊNH ═══════════════════════
  mode        │
              │        ╱╲╱╲╱╲╱╲
  dout        │═══════╳ GLITCH ╳═══ KẾT QUẢ ĐÚNG, ỔN ĐỊNH ════
              │        ╲╱╲╱╲╱╲╱     ▲
              │                     │
              │              KHÔNG lấy mẫu   Lấy mẫu ở ĐÂY trở đi
              │              trước mốc này   (cạnh clock đích)
```

Tầng trên phải bảo đảm khoảng cách giữa hai cạnh clock **lớn hơn** `0,85 ns` cộng với
thời gian setup của thanh ghi đích, cộng biên an toàn. Với 0,85 ns, ràng buộc này
rất dễ thoả ở mọi tần số thực tế — nhưng đó là **kết luận của tầng trên**, không phải của
A07, và phải tính lại sau P&R.

## 4. Vùng glitch — vì sao nó tồn tại và khi nào nó quan trọng

Glitch (xung ma) xuất hiện khi các đường tín hiệu tới cùng một cổng **không đến cùng lúc**.
Ở A07 có ba nguồn glitch rõ rệt:

| Nguồn | Cơ chế | Ví dụ cụ thể |
|---|---|---|
| **G1 · `shamt` đổi nhiều bit** | Ba tầng chuyển nhánh không đồng thời | `shamt` đi `3` (`011`) → `4` (`100`): cả ba bit đổi. Trong khoảnh khắc chuyển, mạch có thể tạm hiện kết quả của dịch 7 hoặc dịch 0 |
| **G2 · `fill` tới trễ** | `fill` phải đi qua `and3_1` (0,17 ns) trong khi dữ liệu `din` vào tầng 1 gần như ngay lập tức | Đổi `mode` từ SRL sang SRA: các lát cắt trên đỉnh nhận `fill` **muộn hơn** các lát cắt dưới nhận dữ liệu |
| **G3 · Độ trễ lệch giữa các bit** | `dout[1]` ổn định ở 0,85 ns, `dout[0]` có đường chỉ 0,03 ns | Trong khoảng `0,03…0,85 ns`, `dout` là **hỗn hợp** giữa bit đã đúng và bit chưa đúng |

```
   Minh hoạ G3 — các bit ra KHÔNG ổn định cùng lúc:

   t:      0.00        0.30        0.60        0.78
           │           │           │           │
   dout[0] ══╳════ ổn định sớm ════════════════════════▶
   dout[4] ════╳══════════ ổn định ═══════════════════▶
   dout[1] ══╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳╳════ ổn định ══▶
                                              ▲
                              Chỉ TỪ ĐÂY toàn bộ dout mới đúng
```

### Glitch có gây sai không?

**Không — với điều kiện tầng trên tôn trọng hợp đồng §3.** Glitch là hiện tượng **bên
trong** chu kỳ. Thanh ghi đích chỉ lấy mẫu tại cạnh clock; nếu cạnh đó nằm sau mốc ổn
định, giá trị bắt được luôn đúng.

Glitch **có** gây hai hệ quả thật:

1. **Tốn công suất chuyển mạch.** Mỗi lần một nút đổi trạng thái vô ích đều tiêu năng
   lượng. Công suất đo được của A07 là `2,70·10⁻⁵ W`, trong đó **26,0 %** là công suất
   chuyển mạch (`7,03·10⁻⁶ W`) — phần này tỉ lệ với hoạt động chuyển mạch, kể cả glitch.
2. **Nguy hiểm nếu tầng trên dùng `dout` bằng logic tổ hợp không đồng bộ.** Ví dụ nếu ai
   đó lấy `dout` làm tín hiệu enable ghi. Hợp đồng §3 cấm điều đó.

> ⚠️ **Mô phỏng hiện tại KHÔNG thấy glitch.** Testbench chạy zero-delay: mọi tín hiệu đổi
> tức thời. Muốn thấy G1–G3 phải chạy **mô phỏng gate-level có độ trễ** trên netlist —
> việc này **chưa làm**, đã ghi vào `02_SPECIFICATION/corner_cases.md` §6.

## 5. Bảng số liệu thời gian

| Chỉ số | Giá trị | Nguồn |
|---|---:|---|
| Mốc quy chiếu `vclk` | 10,0 ns | `constraints/design.sdc` |
| Đường tới hạn | `din[7] → dout[1]` | OpenSTA |
| Độ trễ đường tới hạn | **0,85 ns** | OpenSTA |
| Số cell trên đường tới hạn | **7** | OpenSTA |
| Số **tầng** trên đường tới hạn | **3** (`u_stage1`, `u_stage2`, `u_stage4`) | OpenSTA |
| Độ trễ trung bình mỗi tầng | **≈ 0,23 ns** | Tính từ bảng `datapath.md` §5.2 |
| Đường nhanh nhất | `shamt[2] → dout[0]`, **0,03 ns** | OpenSTA |
| Slack | **9,15 ns (MET)** | OpenSTA |
| WNS / TNS | 0,00 / 0,00 | OpenSTA |

> 📌 **`vclk` chu kỳ 10 ns KHÔNG có nghĩa "A07 chạy ở 100 MHz".** Đó chỉ là mốc quy chiếu
> để STA tính ra được slack cho một mạch vốn không có clock. Khẳng định về tần số hoạt
> động nằm **ngoài phạm vi** theo Charter mục 3.

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24.*
