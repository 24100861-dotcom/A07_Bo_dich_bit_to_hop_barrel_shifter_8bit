// =====================================================================
//  A07 — Mot TANG cua bo dich bit to hop (barrel shifter) 8-bit
// ---------------------------------------------------------------------
//  De         : A07 · Nhom A — So hoc to hop
//  Ten de     : Bo dich bit to hop (barrel shifter) 8-bit
//  Loai mach  : TO HOP THUAN (khong clock, khong reset, 0 flip-flop)
//  Nguon      : Project Charter A07, muc 4 (giao dien), muc 9 (phan tich)
//
//  RANG BUOC KIEN TRUC BAT BUOC
//  ----------------------------
//  KHONG duoc thay bang toan tu tat: cam viet `din << S`, `din >> S`,
//  `din >>> S` trong file nay. Toan tu dich CHI duoc dung trong
//  golden model o 05_VERIFICATION/golden_model/.
//  Ly do: Charter muc 9 yeu cau KIEM CHUNG cau truc 3 tang mux (1-2-4)
//  co xuat hien tren duong toi han hay khong. Neu viet toan tu tat thi
//  cong cu tong hop tu chon cau truc, va thu can quan sat bien mat.
//
//  VAI TRO CUA MODULE NAY
//  ----------------------
//  Day la MOT mat xich trong chuoi 3 tang. Tang duoc tham so hoa boi S
//  (so vi tri dich cua rieng tang nay: 1, 2 hoac 4) va duoc dieu khien
//  boi DUNG MOT bit cua luong dich (cong 'en').
//
//  Moi bit ra di qua DUNG hai muc ghep kenh 2:1 mac noi tiep:
//      muc A: chon CHIEU  (dir)  -> lay nhanh dich trai hay dich phai
//      muc B: chon CO DICH (en)  -> lay nhanh da dich hay giu nguyen
//  Ghep lai chinh la mot bo ghep kenh 3:1 (giu / trai S / phai S).
//
//  Hai "nhanh dich" lsh/rsh KHONG ton cong logic nao: chung chi la
//  cach DOI DAY (re-wiring) cac bit cua din, cong voi hang so don vao.
//  Toan bo chi phi phan cung cua mot tang nam o 16 mux 2:1.
// =====================================================================

module a07_shift_stage #(
    parameter int S = 1          // So vi tri dich cua rieng tang nay: 1 / 2 / 4
) (
    input  logic [7:0] din,      // Du lieu vao tang
    input  logic       en,       // Bit tuong ung cua luong dich: 1 = tang nay dich
    input  logic       dir,      // 0 = dich TRAI, 1 = dich PHAI
    input  logic       fill,     // Bit don vao tu phia MSB khi dich PHAI
    output logic [7:0] dout      // Du lieu ra tang
);

    // lsh = nhanh "da dich trai S vi tri" — chi la day noi + hang so 0
    // rsh = nhanh "da dich phai S vi tri" — chi la day noi + bit 'fill'
    logic [7:0] lsh, rsh;

    // sh  = ket qua sau muc ghep kenh chon CHIEU
    logic [7:0] sh;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : GEN_BIT

            // ---------------------------------------------------------
            // Nhanh DICH TRAI S vi tri.
            // Bit ra thu i lay tu bit vao thu (i-S). Cac vi tri thap hon
            // S khong co nguon nao ca => luon don 0.
            // Dich trai KHONG bao gio don bit dau: dich trai so hoc va
            // dich trai logic la CUNG MOT phep (xem functional_spec.md).
            // ---------------------------------------------------------
            if (i >= S) begin : GEN_L_SRC
                assign lsh[i] = din[i-S];
            end else begin : GEN_L_ZERO
                assign lsh[i] = 1'b0;
            end

            // ---------------------------------------------------------
            // Nhanh DICH PHAI S vi tri.
            // Bit ra thu i lay tu bit vao thu (i+S). Cac vi tri cao hon
            // 7-S khong co nguon => don bit 'fill'.
            // 'fill' la 0 khi dich phai LOGIC, la din[7] khi dich phai
            // SO HOC. Day la DIEM KHAC BIET DUY NHAT giua hai kieu dich
            // phai trong toan bo phan cung (Charter muc 2, cau 2).
            // ---------------------------------------------------------
            if (i + S <= 7) begin : GEN_R_SRC
                assign rsh[i] = din[i+S];
            end else begin : GEN_R_FILL
                assign rsh[i] = fill;
            end

            // ---------------------------------------------------------
            // Muc ghep kenh A — chon CHIEU.
            // ---------------------------------------------------------
            assign sh[i] = dir ? rsh[i] : lsh[i];

            // ---------------------------------------------------------
            // Muc ghep kenh B — chon CO DICH HAY KHONG.
            // Day la muc duoc dieu khien boi MOT bit cua luong dich.
            // Khi en = 0, tang nay la day noi thang: dout = din.
            // ---------------------------------------------------------
            assign dout[i] = en ? sh[i] : din[i];

        end
    endgenerate

endmodule
