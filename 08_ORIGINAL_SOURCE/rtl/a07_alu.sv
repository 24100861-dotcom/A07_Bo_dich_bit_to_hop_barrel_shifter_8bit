module a07_alu (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic [3:0] op,
    output logic [7:0] y,
    output logic       z,
    output logic       n,
    output logic       v
);
    logic [8:0] tmp;
    logic [7:0] arith_y;
    logic       arith_v;

    always_comb begin
        tmp = 9'd0;
        arith_y = 8'd0;
        arith_v = 1'b0;

        case (op)
            4'b0000: begin // ADD
                tmp = {1'b0,a}+{1'b0,b};
                arith_y = tmp[7:0];
                arith_v = (~(a[7]^b[7])) & (arith_y[7]^a[7]);
            end
            4'b0001: begin // SUB
                tmp = {1'b0,a}+{1'b0,(~b)}+9'd1;
                arith_y = tmp[7:0];
                arith_v = (a[7]^b[7]) & (arith_y[7]^a[7]);
            end
            default: begin
                tmp = 9'd0;
                arith_y = 8'd0;
                arith_v = 1'b0;
            end
        endcase
    end

    always_comb begin
        case (op)
            4'b0000,4'b0001: y = arith_y;
            4'b0010:         y = a & b;
            4'b0011:         y = a | b;
            default:         y = 8'h00;
        endcase

        z = (y == 8'h00);
        n = y[7];
        v = ((op==4'b0000) || (op==4'b0001)) ? arith_v : 1'b0;
    end
endmodule
