class O #(int W = 2); class I; localparam int M = W * 3; endclass endclass
module t; initial if (O#(5)::I::M != 15) $stop; endmodule
