class O #(int W = 2); class I; static function int f(); return W; endfunction endclass endclass
module t; initial if (O#(5)::I::f() != 5) $stop; endmodule
