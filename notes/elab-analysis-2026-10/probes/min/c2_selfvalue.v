class SelfValue #(int A = A + 1, type T = logic [A-1:0]); typedef T out_t; endclass
module t; SelfValue#()::out_t b; endmodule
