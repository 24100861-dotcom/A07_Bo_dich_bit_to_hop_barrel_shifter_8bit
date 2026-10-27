module a07_tb;
    logic [7:0] a,b,y,yr;
    logic [3:0] op;
    logic z,n,v,zr,nr,vr;

    a07_alu dut(.a(a),.b(b),.op(op),.y(y),.z(z),.n(n),.v(v));
    a07_reference ref_i(.a(a),.b(b),.op(op),.y(yr),.z(zr),.n(nr),.v(vr));

    task automatic check(input logic [7:0] aa,input logic [7:0] bb,input logic [3:0] oo);
        begin
            a=aa;b=bb;op=oo;#1;
            assert(y===yr) else $fatal(1,"Y mismatch");
            assert(z===zr) else $fatal(1,"Z mismatch");
            assert(n===nr) else $fatal(1,"N mismatch");
            assert(v===vr) else $fatal(1,"V mismatch");
        end
    endtask

    initial begin
        // Representative operation cases
        check(8'd10,8'd5,4'b0000);
        check(8'd10,8'd5,4'b0001);
        check(8'hA5,8'h5A,4'b0010);
        check(8'hA5,8'h5A,4'b0011);

        // Arithmetic boundaries
        check(8'd127,8'd1,4'b0000);
        check(8'h80,8'd1,4'b0001);
        check(8'd0,8'd1,4'b0001);
        check(8'hFF,8'd1,4'b0000);

        // All 4 operations, selected deterministic operand sweep
        for (int unsigned aa=0;aa<256;aa=aa+17)
            for (int unsigned bb=0;bb<256;bb=bb+19)
                for (int unsigned oo=0;oo<4;oo++)
                    check(aa[7:0],bb[7:0],oo[3:0]);

        $display("A07 functional validation PASS");
        $finish;
    end
endmodule
