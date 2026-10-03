class NestedValue #(int A = NestedValue#()::M); localparam int M = A; endclass
module t; localparam int C = NestedValue#()::M; endmodule
