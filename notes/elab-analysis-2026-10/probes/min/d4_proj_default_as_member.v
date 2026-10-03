class IW #(type T = int); typedef T same_t; endclass
class Deep #(type I0 = byte, type I1 = IW#(I0)::same_t); I1 val; endclass
module t; Deep#() d; initial begin d = new; if ($bits(d.val) != 8) $stop; end endmodule
