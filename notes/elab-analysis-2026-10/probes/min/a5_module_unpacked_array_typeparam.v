module M #(type E = logic [7:0], type A = E [2:1]) (output A o); assign o = '{default: '1}; endmodule
module t; logic [7:0] o [2:1]; M m(.o(o)); endmodule
