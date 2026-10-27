# A07 · Phần điều khiển (Control)

---

## 1. Kết luận trước: A07 **không có** phần điều khiển

Không có bộ điều khiển, không có máy trạng thái, không có bộ đếm bước, không có tín hiệu
handshake. Toàn bộ khối là đường dữ liệu.

Bằng chứng trực tiếp:

| Dấu hiệu của một phần điều khiển | Có trong A07? |
|---|:---:|
| Thanh ghi trạng thái | ❌ — 0 flip-flop trong netlist |
| Tín hiệu `clk` | ❌ — không có trong danh sách cổng |
| Tín hiệu `rst` | ❌ — không có trạng thái để đặt lại |
| `valid` / `ready` / `ack` | ❌ |
| `start` / `done` / `busy` | ❌ |
| Bộ đếm bước | ❌ |
| Nhánh rẽ phụ thuộc kết quả trước đó | ❌ — đầu ra chỉ là hàm của đầu vào hiện tại |

## 2. Nhưng A07 **có** tín hiệu điều khiển — hai thứ đó khác nhau

Đây là chỗ dễ nhầm nhất của đề này. `shamt[2:0]` và `mode[1:0]` rõ ràng "điều khiển" hành
vi của khối. Vậy sao lại nói không có phần điều khiển?

| | Tín hiệu điều khiển (A07 **có**) | Phần điều khiển (A07 **không có**) |
|---|---|---|
| Là gì | Một dây chọn nhánh của mux | Một khối logic **sinh ra** các dây đó |
| Có trạng thái không | Không | Có — nhớ đang ở bước nào |
| Phụ thuộc thời gian | Không | Có — quyết định theo lịch sử |
| Trong A07 | `shamt`, `mode` là **cổng vào** | Nằm **ngoài** A07 |

`shamt` và `mode` là **đầu vào** của A07, không phải thứ A07 tính ra. Chúng là dữ liệu
đi vào chân chọn của bộ ghép kênh — về mặt mạch, một chân chọn mux không khác gì một chân
dữ liệu: cả hai đều chỉ là một dây có điện áp.

## 3. Phần điều khiển thật nằm ở đâu

Theo bối cảnh Charter mục 1 (bộ giải mã gói tin):

```
   ┌────────────────────┐
   │ Bộ đếm vị trí bit  │───── shamt[2:0] ───┐     ← CÓ ô nhớ, CÓ clock
   │   (TUẦN TỰ)        │                    │
   └────────────────────┘                    ▼
   ┌────────────────────┐              ╔═══════════════╗
   │ Máy trạng thái     │─ mode[1:0] ─▶║ A07           ║   ← KHÔNG ô nhớ
   │ giao thức (TUẦN TỰ)│              ║ a07_barrel8   ║      KHÔNG clock
   └────────────────────┘              ╚═══════════════╝
```

| Ai quyết định | Cái gì | Vì sao nó phải tuần tự |
|---|---|---|
| Bộ đếm vị trí bit | `shamt` — trường này lệch mấy bit | Phải **nhớ** đã đọc tới đâu trong dòng byte |
| Máy trạng thái giao thức | `mode` — trường này là số có dấu hay không | Phải **nhớ** đang ở trường nào của gói |

Cả hai khối đó **có** ô nhớ và **có** clock. A07 thì không. Ranh giới được vạch đúng chỗ:
mọi trạng thái dồn về phía tầng trên, A07 giữ vai trò một hàm thuần.

## 4. Vì sao chia như vậy lại là thiết kế tốt

| Lợi ích | Giải thích |
|---|---|
| **Dùng lại được** | Cùng một `a07_barrel8` phục vụ được bộ giải mã gói tin, khối dịch của ALU, khối chuẩn hoá số dấu phẩy động — vì nó không giả định gì về ngữ cảnh |
| **Kiểm chứng vét cạn được** | Không trạng thái ⟹ không gian đầu vào là hữu hạn và nhỏ: 8 192 tổ hợp. Đã quét **toàn bộ**. Nếu có ô nhớ, không gian sẽ là (trạng thái × đầu vào) và quét vét cạn thành bất khả thi |
| **Không có ca đua** | Không clock trong khối ⟹ không có vi phạm setup/hold **nội bộ**; ràng buộc thời gian chỉ nằm ở hai thanh ghi kẹp hai đầu, thuộc trách nhiệm tầng trên |
| **STA đơn giản** | Chỉ có đường vào-ra tổ hợp; không có đường clock, không có cây clock |

## 5. Hợp đồng với tầng trên

A07 không có handshake, nên hợp đồng nằm hoàn toàn ở phía **thời gian**:

| Điều khoản | Ai bảo đảm |
|---|---|
| `din`, `shamt`, `mode` phải ổn định (không `X`/`Z`) trước khi lấy mẫu `dout` | Tầng trên |
| Phải đợi ít nhất **0,85 ns** (số đo sau tổng hợp) kể từ khi đầu vào cuối cùng ổn định | Tầng trên |
| Trong khoảng chờ đó, `dout` **có thể** đi qua các giá trị trung gian vô nghĩa (glitch) | Tầng trên phải **không** dùng các giá trị đó |
| Mọi giá trị `shamt` (0…7) và `mode` (cả 4 mã) đều hợp lệ | A07 — không có tổ hợp nào gây `X` |

> ⚠️ **0,85 ns là số sau tổng hợp, chưa có ký sinh dây.** Sau P&R con số sẽ **lớn hơn**.
> Không được dùng nó làm cam kết thời gian.

## 6. Nếu ai đó bắt buộc muốn thấy một "phần điều khiển"

Có thể gọi cổng AND3 sinh `fill` là "phần giải mã lệnh" của A07:

```
   fill = arith & dir & din[7]
```

Nó dịch `mode[1:0]` thành một tín hiệu điều khiển nội bộ. Nhưng gọi như vậy là **phóng
đại**: đó là **một** cổng logic (`and3_1`, 6,2560 µm², chiếm **1,5 %** diện tích khối),
không có trạng thái, không có trình tự. Nó là một mẩu logic tổ hợp, không phải một bộ
điều khiển.

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24.*
