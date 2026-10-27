#!/usr/bin/env python3
# =====================================================================
#  A07 - Mo hinh chuan Python cho bo dich bit to hop (barrel shifter)
#  File: 05_VERIFICATION/golden_model/reference_model.py
# ---------------------------------------------------------------------
#  De        : A07 . Nhom A - So hoc to hop
#  Loai mach : TO HOP THUAN (khong clock, khong trang thai)
#
#  VAI TRO
#  -------
#  Day la CHUAN SO SANH DOC LAP, duoc viet TRUOC va KIEM TRUOC khi dong
#  toi Verilog. No lam ba viec:
#
#    1. Dung HAI mo hinh nghi khac nhau:
#         - model_op()   : dung toan tu dich cua Python
#         - model_tree() : mo phong dung so do BA TANG 1-2-4 cua RTL
#       roi chung minh chung TRUNG KHIT tren ca 8192 to hop (INV-A).
#       Day la cach bien cau khang dinh kien truc "ba tang phu du 0..7"
#       tu mot loi noi thanh mot bang chung chay duoc.
#
#    2. Kiem 23 vector co ten cua Charter muc 8 + cac ca tu xay dung.
#
#    3. Kiem 9 bat bien INV-1..INV-9 tren TOAN BO khong gian dau vao.
#
#  Chay:  python3 reference_model.py      -> in PASS/FAIL, thoat 0 khi dat
# =====================================================================

import sys

MASK8 = 0xFF

# Ma kieu dich - mode[0] = dir (1 = phai), mode[1] = arith
SLL = 0b00
SRL = 0b01
SLA = 0b10
SRA = 0b11

MODE_NAME = {SLL: "SLL", SRL: "SRL", SLA: "SLA", SRA: "SRA"}


# =====================================================================
#  1. HAI MO HINH DOC LAP
# =====================================================================

def model_op(din, shamt, mode):
    """Mo hinh 1 - dung TOAN TU DICH, khong co tang nao.

    Cach nghi: coi phep dich la mot phep toan nguyen khoi. Day la cach
    nghi cua nguoi viet dac ta, khong phai cua nguoi ve mach.
    """
    dir_r = mode & 0b01
    arith = (mode >> 1) & 0b01

    if not dir_r:                          # SLL va SLA
        return (din << shamt) & MASK8

    if not arith:                          # SRL - don 0 tu tren
        return (din >> shamt) & MASK8

    # SRA - lam viec trong mien SO CO DAU cua Python roi quay lai 8 bit.
    # Python co so nguyen do dai tuy y va dich phai la dich SO HOC san,
    # nen chi can doi din sang gia tri co dau truoc khi dich.
    signed = din - 256 if (din & 0x80) else din
    return (signed >> shamt) & MASK8


def model_tree(din, shamt, mode):
    """Mo hinh 2 - mo phong dung SO DO BA TANG 1-2-4 cua Charter muc 10.

    Cach nghi: moi tang la mot bo ghep kenh, dich dung S vi tri hoac di
    thang. Khong dung toan tu dich cua Python o muc toan tu tren ca tu;
    moi tang duoc dung lai TUNG BIT MOT tu danh sach bit.
    """
    dir_r = mode & 0b01
    arith = (mode >> 1) & 0b01

    # 'fill' duoc lay MOT LAN tu bit dau GOC, dung nhu RTL dac ta.
    fill = 1 if (arith and dir_r and (din & 0x80)) else 0

    bits = [(din >> i) & 1 for i in range(8)]      # bits[i] = bit trong so 2^i

    for stage, s in enumerate((1, 2, 4)):
        if not ((shamt >> stage) & 1):
            continue                                # tang nay di thang
        out = [0] * 8
        for i in range(8):
            if not dir_r:                           # dich TRAI S vi tri
                out[i] = bits[i - s] if i >= s else 0
            else:                                   # dich PHAI S vi tri
                out[i] = bits[i + s] if (i + s) <= 7 else fill
        bits = out

    val = 0
    for i in range(8):
        val |= bits[i] << i
    return val


def popcount(v):
    return bin(v & MASK8).count("1")


# =====================================================================
#  2. HA TANG BAO CAO
# =====================================================================

class Report:
    def __init__(self):
        self.checks = 0
        self.fails = 0
        self.lines = []

    def check(self, ok, what):
        self.checks += 1
        if not ok:
            self.fails += 1
            self.lines.append("    [FAIL] " + what)

    def section(self, title):
        print("")
        print("-" * 70)
        print("  " + title)
        print("-" * 70)


R = Report()


# =====================================================================
#  3. INV-A - HAI MO HINH PHAI TRUNG KHIT TREN TOAN BO KHONG GIAN
# =====================================================================

def check_inv_a():
    R.section("INV-A . Mo hinh BA TANG == mo hinh TOAN TU tren 8192 to hop")
    bad = 0
    n = 0
    for mode in (SLL, SRL, SLA, SRA):
        for shamt in range(8):
            for din in range(256):
                n += 1
                a = model_op(din, shamt, mode)
                b = model_tree(din, shamt, mode)
                if a != b:
                    bad += 1
                    if bad <= 5:
                        R.lines.append(
                            "    [FAIL] INV-A din=0x%02X shamt=%d %s : op=0x%02X tree=0x%02X"
                            % (din, shamt, MODE_NAME[mode], a, b))
    R.check(bad == 0, "INV-A: %d to hop lech" % bad)
    print("    da so khop : %d to hop" % n)
    print("    lech       : %d" % bad)
    print("    ==> ba tang 1-2-4 phu du dai 0..7 : %s" % ("DUNG" if bad == 0 else "SAI"))
    return n


# =====================================================================
#  4. CAC CA CO TEN - Charter muc 8 + ca tu xay dung
# =====================================================================
#  Bang duoi la DUNG 23 vector ma testbench SystemVerilog cung chay,
#  theo dung thu tu. Tong so vector mo phong = 23 + 8192 = 8215.
# ---------------------------------------------------------------------

NAMED = [
    # (ten ca,                              din,  shamt, mode, ky vong)
    ("TC-001a dich 0 - SLL",                0xA5, 0, SLL, 0xA5),
    ("TC-001b dich 0 - SRL",                0xA5, 0, SRL, 0xA5),
    ("TC-001c dich 0 - SLA",                0xA5, 0, SLA, 0xA5),
    ("TC-001d dich 0 - SRA",                0xA5, 0, SRA, 0xA5),
    ("TC-002a dich 7 - SLL",                0xFF, 7, SLL, 0x80),
    ("TC-002b dich 7 - SRL",                0xFF, 7, SRL, 0x01),
    ("TC-003a SRA bit dau 1",               0x80, 3, SRA, 0xF0),
    ("TC-003b SRA tang khong lien tiep",    0xB4, 5, SRA, 0xFD),
    ("TC-004a doi chung - SRL",             0x80, 2, SRL, 0x20),
    ("TC-004b doi chung - SRA",             0x80, 2, SRA, 0xE0),
    ("TC-005  BIEN diem bat dong SRA",      0xFF, 7, SRA, 0xFF),
    ("TC-006  BIEN mot bit di len dinh",    0x01, 7, SLL, 0x80),
    ("TC-007  BIEN mot bit di xuong day",   0x80, 7, SRL, 0x01),
    ("TC-008  BIEN day het ra ngoai",       0xF0, 7, SLL, 0x00),
    ("TC-009a hoi tu - SRL",                0x7F, 4, SRL, 0x07),
    ("TC-009b hoi tu - SRA",                0x7F, 4, SRA, 0x07),
    ("TC-010a bi danh - SLL",               0x5A, 3, SLL, 0xD0),
    ("TC-010b bi danh - SLA",               0x5A, 3, SLA, 0xD0),
    ("TC-011a soi tang 1",                  0x0F, 1, SLL, 0x1E),
    ("TC-011b soi tang 2",                  0x0F, 2, SLL, 0x3C),
    ("TC-011c soi tang 4",                  0x0F, 4, SLL, 0xF0),
    ("TC-011d soi tang 2+4",                0x0F, 6, SLL, 0xC0),
    ("TC-012  mau xen ke",                  0xAA, 1, SRL, 0x55),
]


def check_named():
    R.section("Ca co ten . Charter muc 8 + ca tu xay dung (%d vector)" % len(NAMED))
    for name, din, shamt, mode, exp in NAMED:
        got_op = model_op(din, shamt, mode)
        got_tr = model_tree(din, shamt, mode)
        ok = (got_op == exp) and (got_tr == exp)
        R.check(ok, "%s: din=0x%02X shamt=%d %s ky vong 0x%02X, op=0x%02X tree=0x%02X"
                % (name, din, shamt, MODE_NAME[mode], exp, got_op, got_tr))
        print("    %-34s din=%s %s shamt=%d | OUT=%s  [%s]"
              % (name, format(din, "08b"), MODE_NAME[mode], shamt,
                 format(got_op, "08b"), "PASS" if ok else "FAIL"))
    return len(NAMED)


# =====================================================================
#  5. BAT BIEN INV-1 .. INV-9 TREN TOAN BO KHONG GIAN DAU VAO
# =====================================================================

def check_invariants():
    R.section("Bat bien INV-1..INV-9 tren toan bo khong gian dau vao")

    n_inv1 = n_inv2 = n_inv3 = n_inv4 = 0
    n_inv5 = n_inv6 = n_inv7 = n_inv8 = n_inv9 = 0
    bad = [0] * 10

    for din in range(256):
        for shamt in range(8):
            r = {m: model_op(din, shamt, m) for m in (SLL, SRL, SLA, SRA)}

            # INV-1 : shamt = 0  =>  dout = din o CA BON che do
            if shamt == 0:
                for m in (SLL, SRL, SLA, SRA):
                    n_inv1 += 1
                    if r[m] != din:
                        bad[1] += 1

            # INV-2 : SLL/SLA  =>  'shamt' bit THAP nhat cua dout bang 0
            for m in (SLL, SLA):
                n_inv2 += 1
                if r[m] & ((1 << shamt) - 1):
                    bad[2] += 1

            # INV-3 : SRL      =>  'shamt' bit CAO nhat cua dout bang 0
            n_inv3 += 1
            if shamt > 0 and (r[SRL] >> (8 - shamt)):
                bad[3] += 1

            # INV-4 : SRA      =>  'shamt+1' bit CAO nhat deu bang din[7]
            n_inv4 += 1
            sbit = (din >> 7) & 1
            for k in range(7 - shamt, 8):
                if ((r[SRA] >> k) & 1) != sbit:
                    bad[4] += 1
                    break

            # INV-5 : din[7] = 0  =>  SRA trung SRL
            if sbit == 0:
                n_inv5 += 1
                if r[SRA] != r[SRL]:
                    bad[5] += 1

            # INV-6 : SLA trung SLL
            n_inv6 += 1
            if r[SLA] != r[SLL]:
                bad[6] += 1

            # INV-7 : SLL/SRL khong tao bit 1 tu hu khong
            for m in (SLL, SRL):
                n_inv7 += 1
                if popcount(r[m]) > popcount(din):
                    bad[7] += 1

            # INV-8 : SRA cua so am khong bao gio ra so duong
            if sbit == 1:
                n_inv8 += 1
                if ((r[SRA] >> 7) & 1) != 1:
                    bad[8] += 1
                if din == 0xFF and r[SRA] != 0xFF:
                    bad[8] += 1

            # INV-9 : khong bit nao ngoai dai 0..255 (thay cho kiem X/Z)
            for m in (SLL, SRL, SLA, SRA):
                n_inv9 += 1
                if not (0 <= r[m] <= 255):
                    bad[9] += 1

    table = [
        ("INV-1", "shamt=0 => dout=din (ca 4 che do)",          n_inv1, bad[1]),
        ("INV-2", "SLL/SLA => shamt bit thap = 0",              n_inv2, bad[2]),
        ("INV-3", "SRL     => shamt bit cao  = 0",              n_inv3, bad[3]),
        ("INV-4", "SRA     => shamt+1 bit cao = din[7]",        n_inv4, bad[4]),
        ("INV-5", "din[7]=0 => SRA == SRL",                     n_inv5, bad[5]),
        ("INV-6", "SLA == SLL",                                 n_inv6, bad[6]),
        ("INV-7", "popcount(dout) <= popcount(din) (SLL/SRL)",  n_inv7, bad[7]),
        ("INV-8", "SRA so am khong ra so duong; -1 bat dong",   n_inv8, bad[8]),
        ("INV-9", "dout luon nam tron trong 8 bit",             n_inv9, bad[9]),
    ]
    total = 0
    for tag, desc, n, b in table:
        total += n
        R.check(b == 0, "%s vi pham %d lan" % (tag, b))
        print("    %-6s %-42s %6d lan, %d vi pham" % (tag, desc, n, b))
    print("    %-6s %-42s %6d lan" % ("TONG", "so lan kiem bat bien", total))
    return total


# =====================================================================
#  6. DO DINH LUONG - SRL so voi SRA (corner_cases.md muc 2, TC-004)
# =====================================================================

def measure_srl_vs_sra():
    R.section("Do dinh luong . SRL so voi SRA tren 2048 to hop dich phai")
    diff = same = 0
    for din in range(256):
        for shamt in range(8):
            if model_op(din, shamt, SRL) == model_op(din, shamt, SRA):
                same += 1
            else:
                diff += 1
    # Du doan tu ly thuyet: trung nhau <=> din[7] = 0 HOAC shamt = 0
    pred_same = 128 * 8 + 128 * 1
    R.check(same == pred_same,
            "so to hop trung nhau = %d, ly thuyet = %d" % (same, pred_same))
    R.check(diff + same == 2048, "tong khong bang 2048")
    print("    khac nhau : %4d to hop" % diff)
    print("    trung nhau: %4d to hop  (ly thuyet 128*8 + 128*1 = %d)" % (same, pred_same))
    print("    ==> chi trung khi din[7]=0 HOAC shamt=0 : %s"
          % ("DUNG" if same == pred_same else "SAI"))


# =====================================================================
#  7. CHUONG TRINH CHINH
# =====================================================================

def main():
    print("=" * 70)
    print("  A07 . MO HINH CHUAN PYTHON - bo dich bit to hop 8-bit")
    print("  Khong gian dau vao: 256 din x 8 shamt x 4 mode = 8192 to hop")
    print("=" * 70)

    n_space = check_inv_a()
    n_named = check_named()
    n_invchk = check_invariants()
    measure_srl_vs_sra()

    print("")
    print("=" * 70)
    print("  TONG KET")
    print("=" * 70)
    print("  To hop da quet vet can   : %d" % n_space)
    print("  Vector co ten            : %d" % n_named)
    print("  Lan kiem bat bien        : %d" % n_invchk)
    print("  So phep kiem             : %d" % R.checks)
    print("  So phep kiem that bai    : %d" % R.fails)

    if R.fails:
        for line in R.lines[:40]:
            print(line)
        print("")
        print("  A07 REFERENCE MODEL: FAIL")
        return 1

    print("")
    print("  A07 REFERENCE MODEL: PASS - %d/%d phep kiem dat, 0 sai lech"
          % (R.checks, R.checks))
    return 0


if __name__ == "__main__":
    sys.exit(main())
