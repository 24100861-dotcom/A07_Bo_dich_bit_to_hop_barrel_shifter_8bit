# A07 · Sơ đồ hệ thống (System Diagram)

---

## 1. A07 nằm ở đâu trong hệ thống thật

Bối cảnh ứng dụng theo Charter mục 1: **khối căn chỉnh dữ liệu trong bộ giải mã gói tin**.

Một gói tin đến dưới dạng dòng byte. Các trường bên trong gói — mã lệnh, độ dài, cờ —
**không** được thiết kế để nằm tròn trịa trên biên byte; chúng nằm lệch. Để đọc một
trường như vậy, phần cứng phải **kéo nó về biên** trước đã. Đó chính là việc của A07.

```
      ┌───────────── BỘ GIẢI MÃ GÓI TIN (ngoài phạm vi A07) ─────────────┐
      │                                                                   │
  ───▶│  ┌────────────┐    ┌──────────────┐        ┌──────────────┐       │
 dòng │  │ Đệm dòng   │───▶│ Bộ đếm vị trí│───────▶│ Máy trạng    │       │
 byte │  │ (THANH GHI)│    │  bit hiện tại│        │ thái giao thức│      │
      │  └─────┬──────┘    └──────┬───────┘        └──────┬───────┘       │
      │        │ din[7:0]         │ shamt[2:0]            │ mode[1:0]     │
      │        ▼                  ▼                       ▼               │
      │   ╔═══════════════════════════════════════════════════════╗       │
      │   ║            A07 · a07_barrel8                          ║       │
      │   ║   BA TẦNG GHÉP KÊNH — dịch 1 · dịch 2 · dịch 4        ║       │
      │   ║   TỔ HỢP THUẦN · KHÔNG CLOCK · 0 Ô NHỚ                ║       │
      │   ╚════════════════════════╤══════════════════════════════╝       │
      │                            │ dout[7:0]                            │
      │                            ▼                                      │
      │                    ┌───────────────┐    ┌──────────────┐          │
      │                    │ Bộ tách trường│───▶│ Kiểm tra CRC │───▶ ...  │
      │                    │  (THANH GHI)  │    └──────────────┘          │
      │                    └───────────────┘                              │
      └───────────────────────────────────────────────────────────────────┘
```

### Ai giữ trạng thái — và vì sao không phải A07

| Khối | Có ô nhớ? | Giữ cái gì |
|---|:---:|---|
| Đệm dòng byte | ✅ | Byte đang xử lý, qua các chu kỳ |
| Bộ đếm vị trí bit | ✅ | Con trỏ bit hiện tại trong dòng |
| Máy trạng thái giao thức | ✅ | Đang ở trường nào của gói tin |
| **A07 — barrel shifter** | ❌ **0** | **Không gì cả** |
| Bộ tách trường | ✅ | Trường đã căn chỉnh |

A07 ngồi **giữa hai thanh ghi**. Nó là một hàm thuần: đầu ra chỉ phụ thuộc đầu vào hiện
tại. Toàn bộ trạng thái của hệ thống nằm **bên ngoài** nó. Đây là lý do kiến trúc khiến
Charter mục 10 chốt *"dấu hiệu làm đúng: 0 ô nhớ"* — và khối đo được đúng **0 flip-flop**.

### Vì sao ứng dụng này buộc phải dùng barrel shifter

Lượng dịch `shamt` chỉ biết được **khi byte đã tới**. Nếu dùng thanh ghi dịch tuần tự
(dịch 1 bit mỗi chu kỳ), thì:

| Phương án | Chu kỳ cần | Có ô nhớ? | Dùng được cho giải mã gói tin? |
|---|:---:|:---:|---|
| Thanh ghi dịch tuần tự | 0…7 (**thay đổi**) | ✅ có | ❌ Thông lượng biến thiên; phải chặn dòng dữ liệu |
| **Barrel shifter (A07)** | **1, luôn luôn** | ❌ không | ✅ Thông lượng cố định một byte/chu kỳ |

Thông lượng **cố định** mới là yêu cầu thật. Một bộ giải mã gói tin không được phép
dừng dòng dữ liệu chỉ vì trường này lệch nhiều hơn trường kia.

## 2. Vòng đời RTL → GDSII — trạng thái THẬT

```
  ┌───────────┐   ┌───────────┐   ┌───────────┐   ┌───────────┐
  │ 1. Đặc tả │──▶│ 2. Mô hình│──▶│  3. RTL   │──▶│ 4. Mô phỏng│
  │  hành vi  │   │chuẩn Python│   │  3 tầng   │   │ vét cạn    │
  │    ✅     │   │  ✅ PASS   │   │    ✅     │   │ ✅ 8192/0  │
  └───────────┘   └───────────┘   └───────────┘   └─────┬─────┘
                                                        │
  ┌───────────┐   ┌───────────┐   ┌───────────┐   ┌─────▼─────┐
  │ 8. GDSII  │◀──│ 7. DRC/LVS│◀──│  6. P&R   │◀──│5. Tổng hợp│
  │           │   │           │   │           │   │  + STA    │
  │  ⬜ CHƯA  │   │  ⬜ CHƯA  │   │  ⬜ CHƯA  │   │ ✅ 86 cell│
  │           │   │           │   │           │   │   0 FF    │
  └───────────┘   └───────────┘   └───────────┘   └───────────┘
```

| Bước | Công cụ | Trạng thái | Bằng chứng |
|---|---|:---:|---|
| 1. Đặc tả hành vi | — | ✅ | `02_SPECIFICATION/functional_spec.md` |
| 2. Mô hình chuẩn Python | CPython 3.14.4 | ✅ PASS | `reference_model.py` thoát 0 |
| 3. RTL ba tầng tường minh | — | ✅ | `04_IMPLEMENTATION/rtl/` (2 file) |
| 4. Mô phỏng vét cạn | Icarus Verilog 12.0 | ✅ 8 215 vector / 0 lỗi | `05_VERIFICATION/simulation.log` |
| 5. Tổng hợp + STA | Yosys 0.52 + OpenSTA | ✅ 86 cell · 0 FF · 0,85 ns | §3 dưới đây |
| 6. Place & Route | LibreLane + sky130A | ⬜ **chưa chạy** | — |
| 7. DRC / LVS | — | ⬜ **chưa chạy** | — |
| 8. GDSII | — | ⬜ **chưa chạy** | — |

> ⚠️ Các bước 6–8 **chưa chạy**. Không được phát biểu "đã sign-off", "đã tape-out",
> "đã chế tạo" hay "chạy được ở XXX MHz". Charter mục 3 loại tất cả khỏi phạm vi.
> Chạy LibreLane là phần **mở rộng tự nguyện**, không phải điều kiện đạt.

## 3. Phân loại analog / digital / mixed

| Tiêu chí | A07 |
|---|---|
| Miền tín hiệu | **Số thuần** — mọi nút chỉ nhận 0 hoặc 1 |
| Có phần analog? | Không. Không có ADC/DAC, không có so sánh mức, không có tụ/điện trở dùng như phần tử tính toán |
| Có phần mixed-signal? | Không |
| Loại mạch số | **Tổ hợp**, không tuần tự — Charter phân loại "Tổ hợp" |
| Bằng chứng | 0 flip-flop trong netlist; `report_power` cho nhóm Sequential = **0,0 %** |

Hai bằng chứng cho "0 ô nhớ" đến từ **hai nguồn độc lập**: bảng cell của Yosys và báo cáo
công suất của OpenSTA. Chúng đồng ý với nhau.

## 4. Ranh giới khối — cái gì ở trong, cái gì ở ngoài

| Ở **trong** A07 | Ở **ngoài** A07 |
|---|---|
| Ba tầng ghép kênh 1-2-4 | Thanh ghi đệm dòng byte |
| Logic sinh bit độn `fill` | Bộ đếm vị trí bit (sinh ra `shamt`) |
| Giải mã `mode` thành `dir`/`arith` | Máy trạng thái giao thức (sinh ra `mode`) |
| — | Thanh ghi bắt kết quả |
| — | Xử lý trường vắt qua **hai** byte |

> 📌 **Giới hạn quan trọng của phạm vi.** A07 dịch **trong một byte**. Một trường bit vắt
> qua ranh giới hai byte cần ghép hai byte rồi dịch trên 16 bit — Charter mục 3 xếp
> *"dịch trên dữ liệu rộng hơn 8 bit"* **ngoài phạm vi**. Hệ thống thật giải quyết việc
> đó ở tầng trên, không phải trong A07.

---

*Phiên bản: v2.0 (thiết kế lại) · Ngày: 2026-09-24.*
