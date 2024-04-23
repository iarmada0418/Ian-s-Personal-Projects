module hex7seg(
    input [3:0]n,
    output [6:0]seg
);

    assign seg[0] = (~n[3]&~n[2]&~n[1]&n[0])+(~n[3]&n[2]&~n[1]&~n[0])+(n[3]&~n[2]&n[1]&n[0])+(n[3]&n[2]&~n[1]&n[0]);
    assign seg[1] = (~n[3]&n[2]&~n[1]&n[0])+(~n[3]&n[2]&n[1]&~n[0])+(n[3]&~n[2]&n[1]&n[0])+(n[3]&n[2]&~n[1]&~n[0])+(n[3]&n[2]&n[1]&~n[0])+(n[3]&n[2]&n[1]&n[0]);
    assign seg[2] = (~n[3]&~n[2]&n[1]&~n[0])+(n[3]&n[2]&~n[1]&~n[0])+(n[3]&n[2]&n[1]&~n[0])+(n[3]&n[2]&n[1]&n[0]);
    assign seg[3] = (~n[3]&~n[2]&~n[1]&n[0])+(~n[3]&n[2]&~n[1]&~n[0])+(~n[3]&n[2]&n[1]&n[0])+(n[3]&~n[2]&~n[1]&n[0])+(n[3]&~n[2]&n[1]&~n[0])+(n[3]&n[2]&n[1]&n[0]);
    assign seg[4] = (~n[3]&~n[2]&~n[1]&n[0])+(~n[3]&~n[2]&n[1]&n[0])+(~n[3]&n[2]&~n[1]&~n[0])+(~n[3]&n[2]&~n[1]&n[0])+(~n[3]&n[2]&n[1]&n[0])+(n[3]&~n[2]&~n[1]&n[0]);
    assign seg[5] = (~n[3]&~n[2]&~n[1]&n[0])+(~n[3]&~n[2]&n[1]&~n[0])+(~n[3]&~n[2]&n[1]&n[0])+(~n[3]&n[2]&n[1]&n[0])+(n[3]&n[2]&~n[1]&n[0]);
    assign seg[6] = (~n[3]&~n[2]&~n[1]&n[0])+(~n[3]&n[2]&n[1]&n[0])+(n[3]&n[2]&~n[1]&~n[0])+(~n[3]&~n[2]&~n[1]&~n[0]);


endmodule