interface required_if #(type T, int W); T data; endinterface
module t;
  class Cls #(type T = int); endclass
  typedef Cls#(virtual required_if#(logic [6:0], 7)) cls_t;
  initial begin cls_t e; e = new; $finish; end
endmodule
