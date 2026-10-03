class SelfType #(type A = A); typedef A out_t; endclass
module t; SelfType#()::out_t a; endmodule
