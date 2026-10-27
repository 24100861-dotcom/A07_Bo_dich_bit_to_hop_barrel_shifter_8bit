# A07 · Sơ đồ khối bên trong (Block Diagram)

Sơ đồ dưới đây vẽ theo **đúng RTL đã viết** (`04_IMPLEMENTATION/rtl/a07_barrel8.sv` và
`a07_shift_stage.sv`), không phải sơ đồ minh hoạ chung chung. Mọi tên tín hiệu và tên
instance trong hình đều tra được trong mã nguồn.

---

## 1. Toàn cảnh — ba tầng mắc nối tiếp

```
   mode[1:0]
      │
      ├──[0]──▶ dir   ─────────────────┬──────────────┬──────────────┐
      │                                │              │              │
      └──[1]──▶ arith ──┐              │              │              │
                        │              │              │              │
   din[7]──────────────▶│ &            │              │              │
   dir ────────────────▶│ &  (and3_1)  │              │              │
   arith ──────────────▶│ &            │              │              │
                        └──▶ fill ─────┼──────┬───────┼──────┬───────┼──────┐
                                       │      │       │      │       │      │
                                       ▼      ▼       ▼      ▼       ▼      ▼
  din[7:0]  ╔═══════════════════╗  ╔═══════════════════╗  ╔═══════════════════╗
  ════8════▶║   u_stage1        ║  ║   u_stage2        ║  ║   u_stage4        ║
            ║   a07_shift_stage ║s1║   a07_shift_stage ║s2║   a07_shift_stage ║  dout[7:0]
            ║   #(.S(1))        ║══║   #(.S(2))        ║══║   #(.S(4))        ║════8════▶
            ║   DỊCH 1 VỊ TRÍ   ║8 ║   DỊCH 2 VỊ TRÍ   ║8 ║   DỊCH 4 VỊ TRÍ   ║
            ╚═════════▲═════════╝  ╚═════════▲═════════╝  ╚═════════▲═════════╝
                      │ en                   │ en                   │ en
                 shamt[0]               shamt[1]               shamt[2]
                  (trọng số 1)           (trọng số 2)           (trọng số 4)
```

**Đọc hình này ra một câu:** `shamt` là số nhị phân, mỗi bit của nó bật/tắt đúng một tầng
có lượng dịch bằng trọng số của chính bit đó. `shamt = 5 = 4+1` ⟹ bật tầng 4 và tầng 1,
bỏ qua tầng 2.

| `shamt` | nhị phân | u_stage1 | u_stage2 | u_stage4 | Tổng dịch |
|---:|:---:|:---:|:---:|:---:|---:|
| 0 | `000` | đi thẳng | đi thẳng | đi thẳng | 0 |
| 1 | `001` | **dịch 1** | đi thẳng | đi thẳng | 1 |
| 2 | `010` | đi thẳng | **dịch 2** | đi thẳng | 2 |
| 3 | `011` | **dịch 1** | **dịch 2** | đi thẳng | 3 |
| 4 | `100` | đi thẳng | đi thẳng | **dịch 4** | 4 |
| 5 | `101` | **dịch 1** | đi thẳng | **dịch 4** | 5 |
| 6 | `110` | đi thẳng | **dịch 2** | **dịch 4** | 6 |
| 7 | `111` | **dịch 1** | **dịch 2** | **dịch 4** | 7 |

Cột cuối phủ trọn `0…7`, mỗi giá trị đúng một lần — đó là toàn bộ lý lẽ của kiến trúc.

## 2. Bên trong một tầng — lát cắt một bit

Mỗi tầng là 8 lát cắt giống nhau, mỗi lát cắt lo đúng một bit ra. Đây là lát cắt bit `i`
của tầng có lượng dịch `S`:

```
      din[i−S]  ──────────▶┐ (0)
      hoặc 1'b0 nếu i < S  │  mux 2:1    lsh[i]
                           │             ────────┐
                           │                     │
                           └─────────────────────┤ (0)
                                                 │  mux 2:1  ──▶ sh[i]
      din[i+S]  ──────────▶┐                     │     ▲
      hoặc fill nếu i+S>7  │             rsh[i]  │     │
                           └─────────────────────┘ (1) │
                                                      dir
                                                          sh[i] ──▶┐ (1)
                                                                   │  mux 2:1 ──▶ dout[i]
                                                       din[i] ────▶┘ (0)  ▲
                                                                          │
                                                                         en
```

Rút gọn thành hai mức ghép kênh nối tiếp:

```
   mức A  ·  chọn CHIỀU      :  sh[i]   = dir ? rsh[i] : lsh[i]
   mức B  ·  chọn CÓ DỊCH KHÔNG :  dout[i] = en  ? sh[i]  : din[i]
```

Ghép hai mức 2:1 lại chính là một bộ ghép kênh **3:1**: {giữ nguyên · dịch trái S · dịch phải S}.

> 🔎 **Điểm cốt lõi thường bị bỏ qua.** Hai "nhánh dịch" `lsh` và `rsh` **không tốn một
> cổng logic nào**. Chúng chỉ là cách **đổi dây**: `lsh[i]` nối thẳng tới `din[i−S]`.
> Trong phần cứng, "dịch bit" bằng một lượng **cố định** là **miễn phí** — nó là hình học
> của dây dẫn. Toàn bộ chi phí của barrel shifter nằm ở việc **chọn** giữa các cách nối
> dây đó, tức ở các mux. Đây là lý do cách đếm "8 lượng dịch × 8 bit = 64 cổng" là sai
> hoàn toàn.

## 3. Các lát cắt suy biến — không phải lát nào cũng tốn một mux

Ở lát cắt `i` của tầng `S`, một trong hai nhánh có thể trở thành **hằng số** hoặc thành
tín hiệu `fill` dùng chung:

| Tầng | Lát cắt có `lsh[i] = 0` | Lát cắt có `rsh[i] = fill` | Số lát "đủ hai nhánh sống" |
|---|---|---|---:|
| S=1 | `i = 0` (1 lát) | `i = 7` (1 lát) | 6 |
| S=2 | `i = 0,1` (2 lát) | `i = 6,7` (2 lát) | 4 |
| S=4 | `i = 0,1,2,3` (4 lát) | `i = 4,5,6,7` (4 lát) | **0** |

Ở tầng `S=4`, **mọi** lát cắt đều có ít nhất một nhánh suy biến; không lát nào cần một
mux 3:1 đầy đủ. Hệ quả đo được, và nó **ngược trực giác**:

| Tầng | Số cell | Diện tích (µm²) | Cell chính |
|---|---:|---:|---|
| `u_stage1` (S=1) | 24 | **143,8880** | `mux2i_1`×7, `nor2_1`×8, `a21oi_1`×8, `nand2_1`×1 |
| `u_stage2` (S=2) | 25 | **138,8832** | `mux2i_1`×4, `nor2_1`×6, `a21oi_1`×4, … |
| `u_stage4` (S=4) | 25 | **122,6176** | **0 mux**; toàn `nand3_1`, `o21ai_0`, `nand2b_1`, `clkinv_1` |

**Tầng dịch XA NHẤT lại là tầng RẺ NHẤT.** Và tầng `S=4` sau tổng hợp **không còn cell
mux nào** — `abc` đã thay tất cả bằng cổng NAND/OAI đơn giản, vì mỗi lát cắt của nó chỉ
còn là một phép chọn giữa *một tín hiệu* và *một hằng số / một dây dùng chung*.
Số liệu lấy từ `stat -liberty` phân theo module.

## 4. Sinh bit độn `fill` — nơi duy nhất SRA khác SRL

```
   din[7] ──┐
   dir    ──┼──▶ AND3 ──▶ fill ──▶ phát tới cả BA tầng
   arith  ──┘
            (sky130_fd_sc_hd__and3_1 · 1 cell · 6,2560 µm²)
```

Chỉ **một** cổng AND3 ở mức đỉnh, nằm ngoài cả ba tầng. `fill` là **hằng số đối với chuỗi
ba tầng**: nó lấy từ `din[7]` **gốc**, không lấy từ MSB của tầng trước. Nhờ vậy `fill`
**không** nối dài chuỗi phụ thuộc nối tiếp giữa các tầng.

## 5. Cấu trúc file RTL

| File | Module | Vai trò | Dòng |
|---|---|---|---:|
| `a07_barrel8.sv` | `a07_barrel8` | Module đỉnh: giải mã `mode`, sinh `fill`, mắc 3 tầng | ~115 |
| `a07_shift_stage.sv` | `a07_shift_stage #(S)` | Một tầng dịch `S` vị trí, 8 lát cắt | ~100 |

Dùng **một** module tham số hoá cho cả ba tầng, thay vì viết ba module riêng, vì cấu trúc
ba tầng hoàn toàn giống nhau, chỉ khác tham số `S`. Yosys giữ đúng ba instance tách biệt
trong báo cáo phân cấp:

```
   a07_barrel8                                1
     $paramod\a07_shift_stage\S=...0001       1      ← u_stage1
     $paramod\a07_shift_stage\S=...0010       1      ← u_stage2
     $paramod\a07_shift_stage\S=...0100       1      ← u_stage4
```

Đây là **bằng chứng cấu trúc** mà Charter mục 10 đòi: *"Netlist phải thấy rõ ba tầng ghép
kênh nối tiếp."* Ba tầng nhìn thấy được **bằng tên**, không phải bằng suy đoán.

## 6. Bảng cell toàn khối

| Cell | Số lượng | Vai trò chính |
|---|---:|---|
| `sky130_fd_sc_hd__nor2_1` | 18 | Mux phân rã |
| `sky130_fd_sc_hd__a21oi_1` | 16 | Mux phân rã |
| `sky130_fd_sc_hd__mux2i_1` | 11 | Mux 2:1 còn nguyên dạng |
| `sky130_fd_sc_hd__o21ai_0` | 6 | Mux phân rã |
| `sky130_fd_sc_hd__nand3_1` | 6 | Lát cắt suy biến (tầng 2, 4) |
| `sky130_fd_sc_hd__nand2b_1` | 6 | Lát cắt suy biến |
| `sky130_fd_sc_hd__clkinv_1` | 6 | Đảo cực tính |
| `sky130_fd_sc_hd__nand2_1` | 2 | |
| `sky130_fd_sc_hd__a31oi_1` | 2 | |
| `sky130_fd_sc_hd__a21boi_0` | 1 | |
| `sky130_fd_sc_hd__and3_1` | 1 | **Sinh `fill`** |
| **Tổng** | **75** | **Diện tích 411,6448 µm²** |
| Flip-flop / latch | **0** | ✅ Charter mục 10 |

> 🔎 Chỉ **11** cell mux còn giữ nguyên dạng trên tổng 24 mux 2:1 mà RTL mô tả. Phần còn
> lại đã bị `abc` phân rã thành NOR/AOI/OAI. Kết luận: **không thể đếm số tầng bằng cách
> đếm cell mux trong netlist.** Bằng chứng cấu trúc phải đọc từ **phân cấp module** (§5)
> và từ **tên instance trên đường tới hạn** (`datapath.md` §5).

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24.*
