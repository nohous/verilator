package p; class C; static function int f(); return 7; endfunction endclass endpackage
module t; initial if (p::C::f() != 7) $stop; endmodule
