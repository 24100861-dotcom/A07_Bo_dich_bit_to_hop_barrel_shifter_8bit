// =====================================================================
//  A07 - MO HINH CHUAN (golden model) cho bo dich bit to hop 8-bit
//  File: a07_reference.sv
// ---------------------------------------------------------------------
//  De        : A07 . Nhom A - So hoc to hop
//  Vai tro   : CHUAN SO SANH DOC LAP voi RTL o 04_IMPLEMENTATION/rtl/.
//  Loai mach : TO HOP THUAN (khong clock, khong reset)
//
//  VI SAO FILE NAY DUOC PHEP DUNG TOAN TU TAT
//  ------------------------------------------
//  RTL nop bai BI CAM viet `din << shamt` / `din >> shamt` / `>>>` vi
//  Charter muc 9 doi kiem chung cau truc BA TANG MUX (1-2-4). Nhung mot
//  chuan so sanh chi co gia tri khi no DUOC NGHI THEO CACH KHAC. Vi vay
//  o day lam nguoc lai: dung dung toan tu dich cua ngon ngu, khong co
//  tang nao, khong co mux nao, khong co tin hieu 'fill' nao.
//
//  Hai mo ta doc lap => neu ca hai cung sai thi phai sai theo cung mot
//  cach, dieu rat kho xay ra khi cach nghi khac han nhau.
//
//  KHONG duoc chep bat ky dong nao tu RTL sang day, va nguoc lai.
// =====================================================================

// ---------------------------------------------------------------------
//  a07_reference - mo hinh chuan bang TOAN TU NGON NGU
// ---------------------------------------------------------------------
//  mode[0] = dir   : 0 = dich TRAI, 1 = dich PHAI
//  mode[1] = arith : 1 = kieu SO HOC (chi co nghia khi dich phai)
//
//     mode  ten   bieu thuc toan tu
//     ----  ----  ---------------------------------------------
//     2'b00 SLL   din <<  shamt
//     2'b01 SRL   din >>  shamt
//     2'b10 SLA   din <<  shamt      (bi danh cua SLL - xem
//                                     functional_spec.md muc 3.1)
//     2'b11 SRA   $signed(din) >>> shamt
// ---------------------------------------------------------------------
module a07_reference (
    input  logic [7:0] din,
    input  logic [2:0] shamt,
    input  logic [1:0] mode,
    output logic [7:0] dout
);

    always_comb begin
        // Gan mac dinh ngay dau khoi: khong nhanh nao co the thieu gan
        // => khong the suy ra latch (BB-5 cua functional_spec.md).
        dout = 8'h00;

        case (mode)
            2'b00:   dout = din << shamt;                 // SLL
            2'b01:   dout = din >> shamt;                 // SRL
            2'b10:   dout = din << shamt;                 // SLA == SLL
            default: dout = $signed(din) >>> shamt;       // SRA
        endcase
    end

endmodule


// ---------------------------------------------------------------------
//  a07_reference_bitwise - mo hinh chuan THU HAI, cach nghi thu ba
// ---------------------------------------------------------------------
//  Khong dung toan tu dich, cung khong dung tang mux. Thay vao do dung
//  thang PHUONG TRINH TUNG BIT cua functional_spec.md muc 3.2:
//
//      SLL/SLA : dout[i] = (i >= shamt)     ? din[i - shamt] : 0
//      SRL     : dout[i] = (i + shamt <= 7) ? din[i + shamt] : 0
//      SRA     : dout[i] = (i + shamt <= 7) ? din[i + shamt] : din[7]
//
//  Mo hinh nay chi so hoa tren SO NGUYEN (bien 'src'), tuc la no lam
//  viec o mien chi so chu khong o mien tin hieu. Neu RTL bi loi lech
//  mot vi tri (off-by-one) thi no se lech so voi ca hai mo hinh chuan.
// ---------------------------------------------------------------------
module a07_reference_bitwise (
    input  logic [7:0] din,
    input  logic [2:0] shamt,
    input  logic [1:0] mode,
    output logic [7:0] dout
);

    // Viet duoi dang HAM thuan tuy roi noi bang 'assign' lien tuc.
    // Ham khong phai la mot qua trinh always_* nen Icarus suy dien duoc
    // do nhay day du, va bien dich sach khong canh bao.
    function [7:0] shift_by_equation;
        input [7:0] d;
        input [2:0] s;
        input [1:0] m;
        integer i;
        integer src;
        integer amt;
        reg [7:0] acc;
        reg       bitv;
        begin
            amt = s;
            acc = 8'h00;

            // Duyet tu bit CAO xuong bit THAP va don dan vao 'acc' bang
            // phep dich trai mot vi tri. Cach nay tranh gan vao bit-select
            // ben trai, giu ham gon va de doi chieu voi phuong trinh.
            for (i = 7; i >= 0; i = i - 1) begin
                bitv = 1'b0;

                if (m[0] == 1'b0) begin
                    // ----- dich TRAI (SLL va SLA) -----
                    src = i - amt;
                    if (src >= 0) bitv = d[src];
                    else          bitv = 1'b0;
                end else begin
                    // ----- dich PHAI (SRL va SRA) -----
                    src = i + amt;
                    if (src <= 7)             bitv = d[src];
                    else if (m[1] == 1'b1)    bitv = d[7];   // SRA: noi dai dau
                    else                      bitv = 1'b0;   // SRL: don 0
                end

                acc = (acc << 1) | {7'b0, bitv};
            end

            shift_by_equation = acc;
        end
    endfunction

    assign dout = shift_by_equation(din, shamt, mode);

endmodule
