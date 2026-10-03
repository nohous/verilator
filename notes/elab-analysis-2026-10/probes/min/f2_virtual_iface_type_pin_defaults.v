interface opt_if #(type T = int, int W = 8); T data; endinterface
module t;
  class Cls #(type T = int); endclass
  typedef Cls#(virtual opt_if#(logic [6:0], 7)) cls_t;
  initial begin cls_t e; e = new; $finish; end
endmodule
