package p; class C #(int W = 2); static function int f(); return W; endfunction endclass endpackage
module t; initial if (p::C#(5)::f() != 5) $stop; endmodule
