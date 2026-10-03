module Sub #(parameter int W = 3, parameter int D = W + 2) (output logic [D-1:0] o); assign o = '1; endmodule
module t; logic [6:0] a, b; Sub #(.W(5)) s1 (.o(a)); Sub #(.W(5), .D(7)) s2 (.o(b)); endmodule
