# A07 · Máy trạng thái (FSM)

---

## 1. A07 **không có** máy trạng thái

Không có FSM nào để vẽ. Tài liệu này giải thích vì sao, và nêu bằng chứng — vì "không có"
cũng là một khẳng định kỹ thuật và cũng phải chứng minh.

## 2. Bằng chứng — bốn nguồn độc lập

| # | Nguồn | Bằng chứng | Kết luận |
|---|---|---|---|
| 1 | **Mã nguồn RTL** | Không có `always_ff`, không có `always @(posedge …)`, không có cổng `clk` hay `rst`. Mọi dòng đều là `assign` liên tục | Không có gì để nhớ trạng thái |
| 2 | **Bảng cell sau tổng hợp** | 86 cell, **0** cell thuộc họ `sky130_fd_sc_hd__df*` / `sdf*` / `dl*` | Không có phần tử nhớ trong netlist |
| 3 | **Báo cáo công suất** | Nhóm `Sequential` = `0,00e+00 W` = **0,0 %**; nhóm `Clock` = **0,0 %** | Không có gì để cấp clock |
| 4 | **Bước `fsm` của Yosys** | Script chạy `fsm` rồi `opt`; Yosys **không phát hiện** máy trạng thái nào để trích | Công cụ độc lập xác nhận |

Nguồn 2 và 3 đến từ **hai công cụ khác nhau** (Yosys và OpenSTA) và đồng ý với nhau.

## 3. Vì sao không có — lý do kiến trúc

Một FSM tồn tại khi đầu ra phụ thuộc **lịch sử** đầu vào. Ở A07:

```
dout = f(din, shamt, mode)
```

Đầu ra là hàm **thuần** của đầu vào hiện tại. Cùng một bộ `(din, shamt, mode)` luôn cho
cùng một `dout`, bất kể trước đó đã đưa vào cái gì. Không có "trước đó".

Đây không phải lựa chọn tuỳ tiện, mà do **yêu cầu ứng dụng ép ra**: Charter mục 1 đòi
*"dịch byte đi 0–7 vị trí trong **đúng một chu kỳ**"*. Một FSM đúng nghĩa cần **nhiều**
chu kỳ để đi qua các trạng thái — điều đó mâu thuẫn trực tiếp với yêu cầu.

## 4. Cái **giống** FSM nhưng không phải FSM

Có ba thứ ở A07 dễ bị nhầm là trạng thái:

### 4.1 `shamt[2:0]` — trông như "8 trạng thái dịch"

Có tám giá trị `shamt`, và mỗi giá trị cho một hành vi khác nhau. Nghe như 8 trạng thái.

**Không phải.** Một trạng thái là thứ mạch **tự nhớ** và **tự chuyển**. `shamt` là một
**cổng vào**: tầng trên đặt giá trị, A07 chỉ đọc. Không có chuyển trạng thái nào —
`shamt` có thể nhảy từ 0 sang 7 rồi về 3 tuỳ ý, A07 không quan tâm và không có "đường
chuyển" nào bị cấm.

Phép thử phân biệt: **cắt điện rồi cấp lại.** Một FSM cần reset để về trạng thái đầu.
A07 cấp điện lên là cho ngay kết quả đúng — không có trạng thái đầu nào cả. Đó cũng là
lý do khối **không cần** chân `rst`.

### 4.2 `s1` và `s2` — trông như "kết quả trung gian được lưu"

Testbench in ra `t1` và `t2` (chính là `dut.s1`, `dut.s2`) nên trông như mạch "lưu kết
quả từng bước".

**Không phải.** `s1` và `s2` là **dây**, không phải thanh ghi. Chúng tồn tại đồng thời
với `din` và `dout` — không có thời điểm nào `s1` "được ghi" rồi "được đọc sau". Chúng
chỉ là điện áp trên dây nối giữa hai tầng, và cả ba tầng đang tính **cùng lúc**.

### 4.3 Ba tầng nối tiếp — trông như "ba bước tuần tự"

Ba tầng chạy "lần lượt": tầng 1 xong mới tới tầng 2, rồi tầng 4.

**Đây là phụ thuộc DỮ LIỆU, không phải phụ thuộc CHU KỲ.** `u_stage2` phải chờ điện áp
trên dây `s1` xác lập — đó là **vật lý lan truyền**, không phải giao thức. Không có cạnh
clock nào ngăn cách chúng. Cả ba tầng luôn "đang bật", luôn đang tính, suốt thời gian có
điện.

## 5. Nếu A07 **có** FSM thì sao

Giả sử thay barrel shifter bằng thanh ghi dịch tuần tự — kiến trúc đó **có** FSM:

```
   ┌──────┐  start  ┌──────────┐  cnt<shamt  ┌──────────┐
   │ IDLE │────────▶│ SHIFTING │────────────▶│   DONE   │
   └──────┘         └─────┬────┘             └────┬─────┘
        ▲                 │ dịch 1 bit            │
        └─────────────────┴───────────────────────┘
```

| Hệ quả | Chi tiết |
|---|---|
| Thêm ô nhớ | ≥ 8 FF cho dữ liệu + 3 FF cho bộ đếm + FF trạng thái |
| **Vi phạm Charter mục 10** | *"Dấu hiệu làm đúng: 0 ô nhớ"* |
| Vi phạm REQ-A07-003 | Charter phân loại đề này là **Tổ hợp** |
| Thông lượng biến thiên | 0…7 chu kỳ tuỳ `shamt` — bộ giải mã gói tin không chấp nhận được |
| Không quét vét cạn được dễ dàng | Không gian kiểm chứng thành (trạng thái × đầu vào) |

Đối chiếu định lượng với các kiến trúc thay thế: `tradeoff.md` §3.

## 6. Bảng "không có gì"

| Thành phần FSM | A07 |
|---|---|
| Tập trạng thái `S` | ∅ (rỗng) |
| Trạng thái đầu `s₀` | Không có — không cần reset |
| Hàm chuyển `δ` | Không có |
| Hàm ra `λ` | Chỉ là `dout = f(din, shamt, mode)` — **hàm tổ hợp thuần**, không có tham số trạng thái |
| Loại (Mealy/Moore) | Không áp dụng |
| Mã hoá trạng thái | Không áp dụng |

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24 · Truy vết: REQ-A07-003.*
