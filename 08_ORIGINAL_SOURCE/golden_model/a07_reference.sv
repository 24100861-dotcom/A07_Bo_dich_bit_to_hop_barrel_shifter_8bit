module a07_reference (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [3:0] op,
    output logic [7:0] y,
    output logic       z,
    output logic       n,
    output logic       v
);
    integer signed sa,sb,ss;
    logic [8:0] t;

    always_comb begin
        t=0; y=0; v=0;
        case(op)
            4'b0000: begin
                t={1'b0,a}+{1'b0,b};
                y=t[7:0];
                v=(a[7]==b[7])&&(y[7]!=a[7]);
            end
            4'b0001: begin
                y=a-b;
                v=(a[7]!=b[7])&&(y[7]!=a[7]);
            end
            4'b0010: y=a&b;
            4'b0011: y=a|b;
            default: y=8'h00;
        endcase
        z=(y==0);
        n=y[7];
    end
endmodule
