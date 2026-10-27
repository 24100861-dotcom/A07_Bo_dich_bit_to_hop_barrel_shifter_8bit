# A07 · Bối cảnh ứng dụng

> 🔧 **ĐỀ NÀY ĐÃ ĐƯỢC THIẾT KẾ LẠI**
>
> Gói nguồn ban đầu chứa thiết kế của **một đề khác** (thuộc danh mục đề cũ).
> RTL, mô hình chuẩn và testbench đã được **viết mới** cho đúng đề Charter
> *Bộ dịch bit tổ hợp (barrel shifter) 8-bit*, và đã xác minh bằng công cụ thật.
>
> * Mã nguồn cũ: [`08_ORIGINAL_SOURCE/`](08_ORIGINAL_SOURCE/) — giữ nguyên, quay lui được
> * Nhật ký thay đổi: [`08_ORIGINAL_SOURCE/PATCHLOG.md`](08_ORIGINAL_SOURCE/PATCHLOG.md)
> * Sự cố và cách xử lý: [`05_VERIFICATION/known_issues.md`](05_VERIFICATION/known_issues.md)



| | |
|---|---|
| Mã đề | **A07** |
| Tên đề | Bộ dịch bit tổ hợp (barrel shifter) 8-bit |
| Nhóm đề | A · Số học tổ hợp |
| Độ khó | Trung bình |
| Loại mạch | **Tổ hợp** |
| Quy mô ước lượng (Charter) | ~180–260 cell · 1×1 tile |
| Nguồn gốc | Project Charter — A07, mục 1 |

---

## 1. Mục tiêu và bối cảnh ứng dụng

Trích nguyên văn Charter mục 1:

> Phân tích khối số “Bộ dịch bit tổ hợp (barrel shifter) 8-bit” ở mức khối. Bối cảnh ứng dụng: Khối căn chỉnh dữ liệu trong bộ giải mã gói tin: dịch byte đi 0–7 vị trí trong đúng một chu kỳ để lấy trường bit nằm lệch.

## 2. Vị trí khối A07 trong hệ thống

```
   ┌──────────────┐      ┌──────────────────────────────┐      ┌──────────────┐
   │  Nguồn tín   │─────▶│      ►►► KHỐI A07 ◄◄◄        │─────▶│  Tầng tiêu   │
   │  hiệu / dữ   │      │  Bộ dịch bit tổ hợp (barrel s │      │  thụ kết quả │
   │  liệu vào    │      │  Loại mạch: Tổ hợp           │      │              │
   └──────────────┘      └──────────────────────────────┘      └──────────────┘
```

> Sơ đồ chi tiết có chú thích: `03_ARCHITECTURE/system_diagram.md`.

## 3. Phân loại analog / digital / mixed

| Khối | Phân loại | Ghi chú |
|---|---|---|
| Cảm biến / nguồn tín hiệu vật lý (nếu có) | Analog | Đại lượng liên tục |
| Chuyển đổi ADC/DAC (nếu có) | Mixed-signal | Ranh giới analog–số |
| **A07 — Bộ dịch bit tổ hợp (barrel shifter) 8-bit** | **Digital, tổ hợp** | Đầu ra chỉ phụ thuộc đầu vào hiện tại; không clock, không ô nhớ |
| Tầng xử lý phía sau | Digital | Tiêu thụ kết quả của A07 |

Bằng chứng cho dòng phân loại của A07: tổng hợp thật cho **0 flip-flop**
(`06_GDSII/synthesis/synth_stat.txt`).

---

**Truy vết:** yêu cầu sinh từ tài liệu này được đánh số `REQ-A07-0xx` trong
`01_REQUIREMENT/requirements.md`, và truy vết đến bằng chứng trong `07_TRACEABILITY/RTM.csv`.

*Phiên bản: v1.0 · Ngày: 2026-09-24*
