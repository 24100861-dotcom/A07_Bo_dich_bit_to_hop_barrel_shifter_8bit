// =====================================================================
//  A07 — Bo dich bit to hop (barrel shifter) 8-bit  ·  MODULE DINH
// ---------------------------------------------------------------------
//  De         : A07 · Nhom A — So hoc to hop
//  Ten de     : Bo dich bit to hop (barrel shifter) 8-bit
//  Loai mach  : TO HOP THUAN (khong clock, khong reset, 0 flip-flop)
//  Nguon      : Project Charter A07, muc 1/2/4/8/9/10
//  Truy vet   : REQ-A07-001..004, 010..013, 020..021
//
//  RANG BUOC KIEN TRUC BAT BUOC
//  ----------------------------
//  KIEN TRUC: BA TANG GHEP KENH MAC NOI TIEP — dich 1, dich 2, dich 4.
//  Moi tang duoc dieu khien boi DUNG MOT bit cua luong dich shamt:
//        tang 1  <-  shamt[0]      (dich 1 vi tri)
//        tang 2  <-  shamt[1]      (dich 2 vi tri)
//        tang 4  <-  shamt[2]      (dich 4 vi tri)
//  Tong cong 1 + 2 + 4 = 7 => phu du luong dich 0..7 bang DUNG 3 tang.
//
//  KHONG DUOC THAY BANG TOAN TU TAT.
//  Cam tuyet doi viet `din << shamt`, `din >> shamt`, `din >>> shamt`
//  trong file nay. Cung cam viet mot `case (shamt)` 8 nhanh — do la
//  chinh cho hay tac ma Charter muc 10 canh bao ("Khong thay ba tang —
//  viet mot case 8 nhanh roi ngac nhien vi dien tich lon").
//  Toan tu dich CHI duoc dung trong golden model, noi chung dong vai
//  tro chuan so sanh DOC LAP voi RTL.
// =====================================================================

module a07_barrel8 (
    input  logic [7:0] din,    // Charter muc 4: ui_in[7:0]   — du lieu can dich
    input  logic [2:0] shamt,  // Charter muc 4: uio_in[2:0]  — so bit dich 0..7
    input  logic [1:0] mode,   // Charter muc 4: uio_in[4:3]  — kieu dich
    output logic [7:0] dout    // Charter muc 4: uo_out[7:0]  — ket qua
);

    // -----------------------------------------------------------------
    // GIAI MA KIEU DICH  (mode[1:0])
    // -----------------------------------------------------------------
    //   mode[0] = dir   : 0 = dich TRAI, 1 = dich PHAI
    //   mode[1] = arith : 1 = kieu SO HOC (chi co nghia khi dich phai)
    //
    //   mode  ten   y nghia
    //   ----  ----  ---------------------------------------------------
    //   2'b00 SLL   dich trai logic,   don 0 tu duoi
    //   2'b01 SRL   dich phai logic,   don 0 tu tren
    //   2'b10 SLA   dich trai so hoc  == SLL (bi danh dong co chu dich)
    //   2'b11 SRA   dich phai so hoc,  don din[7] tu tren
    //
    //   SLA == SLL khong phai la loi: dich trai lam MAT bit dau cu,
    //   khong co gi de "noi dai dau" ca. Charter muc 3 xep dich vong
    //   (rotate) NGOAI PHAM VI, nen ma 2'b10 duoc dinh nghia tuong minh
    //   la but danh cua SLL thay vi de khong xac dinh.
    // -----------------------------------------------------------------
    logic dir, arith;
    assign dir   = mode[0];
    assign arith = mode[1];

    // -----------------------------------------------------------------
    // BIT DON (fill) — toan bo su khac nhau giua SRL va SRA nam o day.
    // -----------------------------------------------------------------
    //   fill = 1 chi khi: dang dich PHAI, kieu SO HOC, va bit dau = 1.
    //   Moi bit duoc don vao tu phia MSB deu bang bit dau GOC din[7],
    //   nen fill la mot HANG SO doi voi ca ba tang — khong phai lay
    //   MSB cua tang truoc. Nho vay ba tang van doc lap ve du lieu
    //   dieu khien, chi noi tiep ve du lieu chinh.
    //
    //   Chi phi phan cung cua dich phai SO HOC so voi LOGIC: DUNG MOT
    //   cong AND 3 ngo. Do la cau tra loi dinh luong cho Charter muc 2
    //   cau 2 ("khac nhau o dung cho nao trong phan cung").
    // -----------------------------------------------------------------
    logic fill;
    assign fill = arith & dir & din[7];

    // -----------------------------------------------------------------
    // CHUOI BA TANG GHEP KENH
    // -----------------------------------------------------------------
    //          din ──▶[ tang S=1 ]──▶ s1 ──▶[ tang S=2 ]──▶ s2 ──▶[ tang S=4 ]──▶ dout
    //                    ▲ shamt[0]           ▲ shamt[1]           ▲ shamt[2]
    //
    // Thu tu 1 → 2 → 4 la mot lua chon, khong phai bat buoc: phep dich
    // co tinh ket hop nen 4 → 2 → 1 cho cung ket qua. Xem tradeoff.md.
    // -----------------------------------------------------------------
    logic [7:0] s1, s2;

    // Tang 1 — dich 1 vi tri, dieu khien boi shamt[0]
    a07_shift_stage #(.S(1)) u_stage1 (
        .din  (din),
        .en   (shamt[0]),
        .dir  (dir),
        .fill (fill),
        .dout (s1)
    );

    // Tang 2 — dich 2 vi tri, dieu khien boi shamt[1]
    a07_shift_stage #(.S(2)) u_stage2 (
        .din  (s1),
        .en   (shamt[1]),
        .dir  (dir),
        .fill (fill),
        .dout (s2)
    );

    // Tang 3 — dich 4 vi tri, dieu khien boi shamt[2]
    a07_shift_stage #(.S(4)) u_stage4 (
        .din  (s2),
        .en   (shamt[2]),
        .dir  (dir),
        .fill (fill),
        .dout (dout)
    );

endmodule
