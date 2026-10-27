// =====================================================================
//  A07 - TESTBENCH TU KIEM cho bo dich bit to hop (barrel shifter) 8-bit
//  File: 05_VERIFICATION/testbench/a07_tb.sv
// ---------------------------------------------------------------------
//  DUT      : a07_barrel8   (instance ten 'dut')
//  Chuan    : a07_reference          - dung toan tu dich
//             a07_reference_bitwise  - dung phuong trinh tung bit
//
//  BA LOP KIEM
//  -----------
//    Lop 1a : 11 vector bat buoc cua Charter muc 8  (TC-001 .. TC-004)
//    Lop 1b : 12 vector tu xay dung, trong do co ca bien (TC-005..TC-012)
//    Lop 2  : QUET VET CAN toan bo 256 x 8 x 4 = 8192 to hop
//    Lop 3  : bat bien INV-1..INV-4 va INV-9 tren TUNG vector
//
//  Tong so vector = 23 (co ten) + 8192 (vet can) = 8215.
//
//  Moi sai lech deu goi $fatal(1, ...) kem du thong tin truy vet
//  (ten ca, dau vao, ky vong, thuc te, gia tri trung gian giua cac tang).
//
//  VCD duoc ghi cho cac ca CO TEN roi $dumpoff NGAY TRUOC vong quet vet
//  can, de file waveform khong phinh to vo ich.
//
//  Cu phap: tranh nhung thu Icarus Verilog 12.0 chua ho tro - khong dung
//  'bind', 'string.getc()', 'assert property', nhan sau 'always @(...)
//  begin : ten', khai bao bien sau cau lenh trong 'initial', gan enum
//  qua toan tu '? :'. Moi bien deu khai bao o pham vi module.
// =====================================================================

`timescale 1ns / 1ps

module a07_tb;

    // -----------------------------------------------------------------
    // Tin hieu kich thich va quan sat
    // -----------------------------------------------------------------
    logic [7:0] din;
    logic [2:0] shamt;
    logic [1:0] mode;

    logic [7:0] dout;        // tu DUT
    logic [7:0] ref_op;      // tu mo hinh chuan dung toan tu
    logic [7:0] ref_bit;     // tu mo hinh chuan dung phuong trinh tung bit

    // -----------------------------------------------------------------
    // Bo dem
    // -----------------------------------------------------------------
    integer n_vec;           // tong so vector da ap
    integer n_named;         // so vector co ten
    integer n_exh;           // so vector cua vong vet can
    integer n_err;           // so sai lech so voi mo hinh chuan
    integer n_inv;           // so LAN kiem bat bien
    integer n_inv_bad;       // so lan vi pham bat bien

    integer n_diff;          // so to hop dich phai ma SRL khac SRA
    integer n_same;          // so to hop dich phai ma SRL trung SRA
    logic [7:0] srl_hold;    // giu ket qua SRL de so voi SRA cung (din,shamt)

    // -----------------------------------------------------------------
    // Bien vong lap (khai bao o pham vi module - Icarus khong cho khai
    // bao bien sau cau lenh trong 'initial')
    // -----------------------------------------------------------------
    integer i_din, i_sh, i_md, k;
    integer lo_bits, hi_bits;
    reg     inv_ok;

    // =================================================================
    // DUT - ten instance BAT BUOC la 'dut'
    // =================================================================
    a07_barrel8 dut (
        .din   (din),
        .shamt (shamt),
        .mode  (mode),
        .dout  (dout)
    );

    // =================================================================
    // Hai mo hinh chuan, dat NGAY CANH DUT, cung dau vao
    // =================================================================
    a07_reference u_ref_op (
        .din   (din),
        .shamt (shamt),
        .mode  (mode),
        .dout  (ref_op)
    );

    a07_reference_bitwise u_ref_bit (
        .din   (din),
        .shamt (shamt),
        .mode  (mode),
        .dout  (ref_bit)
    );

    // =================================================================
    // Ten che do dich - tra ve 3 ky tu ASCII, in bang %0s
    // (khong dung enum, khong dung 'string' de an toan voi Icarus)
    // =================================================================
    function [8*3-1:0] mode_name;
        input [1:0] m;
        begin
            case (m)
                2'b00:   mode_name = "SLL";
                2'b01:   mode_name = "SRL";
                2'b10:   mode_name = "SLA";
                default: mode_name = "SRA";
            endcase
        end
    endfunction

    // =================================================================
    // LOP 3 - kiem bat bien tren vector hien hanh
    // -----------------------------------------------------------------
    //  INV-1  shamt = 0        => dout = din, o CA BON che do
    //  INV-2  SLL/SLA (dir=0)  => 'shamt' bit THAP nhat cua dout bang 0
    //  INV-3  SRL              => 'shamt' bit CAO nhat cua dout bang 0
    //  INV-4  SRA              => 'shamt+1' bit CAO nhat deu bang din[7]
    //  INV-9  dout khong bao gio chua bit X/Z (chong latch, chong ho nhanh)
    //
    //  Moi bat bien DUOC AP DUNG cho vector nay dem THEM MOT lan vao
    //  n_inv. Vi vay n_inv la so LAN KIEM chu khong phai so vector.
    // =================================================================
    task check_invariants;
        begin
            // ---------- INV-9 : ap dung cho MOI vector ----------
            n_inv = n_inv + 1;
            if ((^dout) === 1'bx) begin
                n_inv_bad = n_inv_bad + 1;
                $display("[FATAL] INV-9 vi pham: dout co bit X/Z");
                $fatal(1, "INV-9: din=%02h shamt=%0d mode=%0s dout=%b",
                       din, shamt, mode_name(mode), dout);
            end

            // ---------- INV-1 : chi ap dung khi shamt = 0 ----------
            if (shamt == 3'd0) begin
                n_inv = n_inv + 1;
                if (dout !== din) begin
                    n_inv_bad = n_inv_bad + 1;
                    $display("[FATAL] INV-1 vi pham: shamt=0 ma dout != din");
                    $fatal(1, "INV-1: din=%02h mode=%0s dout=%02h",
                           din, mode_name(mode), dout);
                end
            end

            // ---------- INV-2 : chi ap dung cho dich TRAI ----------
            if (mode[0] == 1'b0) begin
                n_inv = n_inv + 1;
                inv_ok  = 1'b1;
                lo_bits = 0;
                for (k = 0; k < 8; k = k + 1) begin
                    if (k < shamt) begin
                        lo_bits = lo_bits + 1;
                        if (dout[k] !== 1'b0) inv_ok = 1'b0;
                    end
                end
                if (!inv_ok) begin
                    n_inv_bad = n_inv_bad + 1;
                    $display("[FATAL] INV-2 vi pham: %0d bit thap phai bang 0", lo_bits);
                    $fatal(1, "INV-2: din=%02h shamt=%0d mode=%0s dout=%b",
                           din, shamt, mode_name(mode), dout);
                end
            end

            // ---------- INV-3 : chi ap dung cho SRL ----------
            if (mode == 2'b01) begin
                n_inv = n_inv + 1;
                inv_ok  = 1'b1;
                hi_bits = 0;
                for (k = 0; k < 8; k = k + 1) begin
                    if (k >= (8 - shamt)) begin
                        hi_bits = hi_bits + 1;
                        if (dout[k] !== 1'b0) inv_ok = 1'b0;
                    end
                end
                if (!inv_ok) begin
                    n_inv_bad = n_inv_bad + 1;
                    $display("[FATAL] INV-3 vi pham: %0d bit cao phai bang 0", hi_bits);
                    $fatal(1, "INV-3: din=%02h shamt=%0d dout=%b", din, shamt, dout);
                end
            end

            // ---------- INV-4 : chi ap dung cho SRA ----------
            if (mode == 2'b11) begin
                n_inv = n_inv + 1;
                inv_ok  = 1'b1;
                hi_bits = 0;
                for (k = 0; k < 8; k = k + 1) begin
                    if (k >= (7 - shamt)) begin
                        hi_bits = hi_bits + 1;
                        if (dout[k] !== din[7]) inv_ok = 1'b0;
                    end
                end
                if (!inv_ok) begin
                    n_inv_bad = n_inv_bad + 1;
                    $display("[FATAL] INV-4 vi pham: %0d bit cao phai bang din[7]=%b",
                             hi_bits, din[7]);
                    $fatal(1, "INV-4: din=%02h shamt=%0d dout=%b", din, shamt, dout);
                end
            end
        end
    endtask

    // =================================================================
    // Ap mot vector va so voi CA HAI mo hinh chuan
    // =================================================================
    task apply;
        input [7:0] d;
        input [2:0] s;
        input [1:0] m;
        begin
            din   = d;
            shamt = s;
            mode  = m;
            #1;                       // cho mach to hop on dinh

            n_vec = n_vec + 1;

            if (dout !== ref_op) begin
                n_err = n_err + 1;
                $display("[FATAL] Lech so voi mo hinh chuan (toan tu)");
                $display("        din=%b (%02h)  shamt=%0d  mode=%0s (%b)",
                         d, d, s, mode_name(m), m);
                $display("        trung gian: t1=%b  t2=%b", dut.s1, dut.s2);
                $display("        DUT=%b (%02h)   REF=%b (%02h)",
                         dout, dout, ref_op, ref_op);
                $fatal(1, "A07: DUT khac mo hinh chuan toan tu");
            end

            if (dout !== ref_bit) begin
                n_err = n_err + 1;
                $display("[FATAL] Lech so voi mo hinh chuan (phuong trinh tung bit)");
                $display("        din=%b (%02h)  shamt=%0d  mode=%0s (%b)",
                         d, d, s, mode_name(m), m);
                $display("        trung gian: t1=%b  t2=%b", dut.s1, dut.s2);
                $display("        DUT=%b (%02h)   REF=%b (%02h)",
                         dout, dout, ref_bit, ref_bit);
                $fatal(1, "A07: DUT khac mo hinh chuan tung bit");
            end

            check_invariants;
        end
    endtask

    // =================================================================
    // Ap mot vector CO TEN: kiem them gia tri ky vong viet tay, va in ra
    // ca gia tri trung gian giua ba tang de doc duoc tung mat xich.
    // =================================================================
    task named_case;
        input [8*34-1:0] tag;
        input [7:0] d;
        input [2:0] s;
        input [1:0] m;
        input [7:0] exp;
        begin
            apply(d, s, m);
            n_named = n_named + 1;

            if (dout !== exp) begin
                n_err = n_err + 1;
                $display("[FATAL] %0s: ky vong %b (%02h), thuc te %b (%02h)",
                         tag, exp, exp, dout, dout);
                $fatal(1, "A07: ca co ten sai ky vong");
            end

            $display("  %0s din=%b %0s shamt=%0d | t1=%b t2=%b | OUT=%b  [PASS]",
                     tag, d, mode_name(m), s, dut.s1, dut.s2, dout);
        end
    endtask

    // =================================================================
    // CHUONG TRINH CHINH
    // =================================================================
    initial begin
        n_vec     = 0;
        n_named   = 0;
        n_exh     = 0;
        n_err     = 0;
        n_inv     = 0;
        n_inv_bad = 0;
        n_diff    = 0;
        n_same    = 0;
        srl_hold  = 8'h00;
        din       = 8'h00;
        shamt     = 3'd0;
        mode      = 2'b00;

        $dumpfile("a07_waves.vcd");
        $dumpvars(0, a07_tb);

        $display("======================================================================");
        $display("  A07 . TESTBENCH - Bo dich bit to hop (barrel shifter) 8-bit");
        $display("  DUT: a07_barrel8   Chuan: a07_reference + a07_reference_bitwise");
        $display("======================================================================");

        // -------------------------------------------------------------
        // LOP 1a - CAC CA BAT BUOC CUA CHARTER MUC 8
        // -------------------------------------------------------------
        $display("");
        $display("[1a] Ca bat buoc cua Charter muc 8");
        $display("----------------------------------------------------------------------");

        // TC-001 . dich 0 phai giu nguyen du lieu o CA BON che do (INV-1)
        named_case("TC-001a dich 0 - SLL             ", 8'hA5, 3'd0, 2'b00, 8'hA5);
        named_case("TC-001b dich 0 - SRL             ", 8'hA5, 3'd0, 2'b01, 8'hA5);
        named_case("TC-001c dich 0 - SLA             ", 8'hA5, 3'd0, 2'b10, 8'hA5);
        named_case("TC-001d dich 0 - SRA             ", 8'hA5, 3'd0, 2'b11, 8'hA5);

        // TC-002 . dich 7 - ca duy nhat bat CA BA tang cung luc
        named_case("TC-002a dich 7 - SLL             ", 8'hFF, 3'd7, 2'b00, 8'h80);
        named_case("TC-002b dich 7 - SRL             ", 8'hFF, 3'd7, 2'b01, 8'h01);

        // TC-003 . SRA voi bit dau = 1 - ly do ton tai cua che do SRA
        named_case("TC-003a SRA bit dau 1            ", 8'h80, 3'd3, 2'b11, 8'hF0);
        named_case("TC-003b SRA tang khong lien tiep ", 8'hB4, 3'd5, 2'b11, 8'hFD);

        // TC-004 . cap doi chung co kiem soat: SRL va SRA cung dau vao
        named_case("TC-004a doi chung - SRL          ", 8'h80, 3'd2, 2'b01, 8'h20);
        named_case("TC-004b doi chung - SRA          ", 8'h80, 3'd2, 2'b11, 8'hE0);

        // -------------------------------------------------------------
        // LOP 1b - CA TU XAY DUNG (trong do co ca bien)
        // -------------------------------------------------------------
        $display("");
        $display("[1b] Ca tu xay dung - co ca bien");
        $display("----------------------------------------------------------------------");

        // TC-005 . BIEN: -1 la diem bat dong cua SRA voi moi luong dich
        named_case("TC-005  BIEN diem bat dong SRA   ", 8'hFF, 3'd7, 2'b11, 8'hFF);

        // TC-006/007 . BIEN: mot bit don doc di het chieu rong cua tu
        named_case("TC-006  BIEN mot bit len dinh    ", 8'h01, 3'd7, 2'b00, 8'h80);
        named_case("TC-007  BIEN mot bit xuong day   ", 8'h80, 3'd7, 2'b01, 8'h01);

        // TC-008 . BIEN: toan bo du lieu bi day ra ngoai - chung minh
        //          khoi KHONG phai la dich vong (rotate)
        named_case("TC-008  BIEN day het ra ngoai    ", 8'hF0, 3'd7, 2'b00, 8'h00);

        // TC-009 . hoi tu: bit dau = 0 thi SRA phai TRUNG SRL
        named_case("TC-009a hoi tu - SRL             ", 8'h7F, 3'd4, 2'b01, 8'h07);
        named_case("TC-009b hoi tu - SRA             ", 8'h7F, 3'd4, 2'b11, 8'h07);

        // TC-010 . bi danh: SLA phai TRUNG SLL, khong duoc sinh X/latch
        named_case("TC-010a bi danh - SLL            ", 8'h5A, 3'd3, 2'b00, 8'hD0);
        named_case("TC-010b bi danh - SLA            ", 8'h5A, 3'd3, 2'b10, 8'hD0);

        // TC-011 . soi rieng tung mat xich: moi luy thua cua 2 bat DUNG
        //          MOT tang, nen neu tang nao hong thi biet ngay tang nao
        named_case("TC-011a soi tang 1               ", 8'h0F, 3'd1, 2'b00, 8'h1E);
        named_case("TC-011b soi tang 2               ", 8'h0F, 3'd2, 2'b00, 8'h3C);
        named_case("TC-011c soi tang 4               ", 8'h0F, 3'd4, 2'b00, 8'hF0);
        named_case("TC-011d soi tang 2+4             ", 8'h0F, 3'd6, 2'b00, 8'hC0);

        // TC-012 . mau xen ke - bat loi hoan vi hai day lien ke
        named_case("TC-012  mau xen ke               ", 8'hAA, 3'd1, 2'b01, 8'h55);

        $display("");
        $display("  Vector co ten da chay: %0d", n_named);

        // -------------------------------------------------------------
        // LOP 2 - QUET VET CAN
        // -------------------------------------------------------------
        // Tat ghi VCD TRUOC vong quet: 8192 vector se lam file waveform
        // phinh to ma khong them thong tin nao doc duoc bang mat.
        // -------------------------------------------------------------
        $dumpoff;

        $display("");
        $display("[2] Quet vet can toan bo khong gian dau vao");
        $display("----------------------------------------------------------------------");
        $display("  256 din x 8 shamt x 4 mode = 8192 to hop");

        for (i_din = 0; i_din < 256; i_din = i_din + 1) begin
            for (i_sh = 0; i_sh < 8; i_sh = i_sh + 1) begin
                for (i_md = 0; i_md < 4; i_md = i_md + 1) begin
                    apply(i_din[7:0], i_sh[2:0], i_md[1:0]);
                    n_exh = n_exh + 1;

                    // Do dinh luong cho TC-004: voi cung (din, shamt),
                    // che do 01 (SRL) chay TRUOC che do 11 (SRA), nen
                    // chi can giu lai ket qua SRL roi so khi toi SRA.
                    if (i_md == 1) srl_hold = dout;
                    if (i_md == 3) begin
                        if (dout === srl_hold) n_same = n_same + 1;
                        else                   n_diff = n_diff + 1;
                    end
                end
            end
        end

        $display("  Da quet: %0d/8192 to hop, sai lech: %0d", n_exh, n_err);

        // -------------------------------------------------------------
        // LOP 2b - DOI CHIEU DINH LUONG SRL so voi SRA
        // -------------------------------------------------------------
        $display("");
        $display("[2b] Do dinh luong: SRL so voi SRA tren 2048 to hop dich phai");
        $display("----------------------------------------------------------------------");
        $display("  khac nhau : %0d to hop", n_diff);
        $display("  trung nhau: %0d to hop  (ly thuyet 128*8 + 128*1 = 1152)", n_same);

        if (n_same !== 1152 || n_diff !== 896) begin
            $fatal(1, "A07: phan bo SRL/SRA sai - trung=%0d khac=%0d, cho doi 1152/896",
                   n_same, n_diff);
        end
        $display("  ==> chi trung khi din[7]=0 HOAC shamt=0 : DUNG");

        // -------------------------------------------------------------
        // TONG KET
        // -------------------------------------------------------------
        $display("");
        $display("======================================================================");
        $display("  TONG KET A07");
        $display("======================================================================");
        $display("  Vector co ten            : %0d", n_named);
        $display("  Vector quet vet can      : %0d/8192", n_exh);
        $display("  TONG SO VECTOR           : %0d", n_vec);
        $display("  Sai lech so voi chuan    : %0d", n_err);
        $display("  Lan kiem bat bien        : %0d", n_inv);
        $display("  Vi pham bat bien         : %0d", n_inv_bad);
        $display("  Flip-flop trong RTL      : 0 (khong co always_ff, khong co clk/rst)");

        if (n_err != 0 || n_inv_bad != 0 || n_exh != 8192) begin
            $display("");
            $display("  KET QUA A07: FAIL");
            $fatal(1, "A07: testbench that bai");
        end

        $display("");
        $display("  KET QUA A07: PASS - %0d vector, 0 sai lech, %0d lan kiem bat bien, 0 vi pham",
                 n_vec, n_inv);
        $finish;
    end

endmodule
