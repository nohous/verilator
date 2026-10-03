package p; class C #(int W = 2); localparam int M = W * 2; endclass endpackage
module t; localparam int X = p::C#(5)::M; initial if (X != 10) $stop; endmodule
