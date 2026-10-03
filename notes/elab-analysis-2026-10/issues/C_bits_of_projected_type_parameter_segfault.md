<!-- DRAFT for filing by hand. Title suggestion: -->
# $bits() of a type parameter whose default is Class#(param)::typedef segfaults in V3Param

### Example

```systemverilog
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class E #(int W = 2);
  typedef logic [W-1:0] value_t;
endclass

module M #(
    int W = 3,
    int D = W + 2,
    type T = E#(D)::value_t,
    int N = $bits(T) + 4
) (
    output T value
);
  assign value = T'(N);
endmodule

module t;
  logic [6:0] value;
  M #(.W(5)) dut (.*);
  initial begin
    if ($bits(value) != 7) $stop;
    if (dut.N != 11) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
```

### What I get

```
%Error: Verilator internal fault, sorry. Suggest trying --debug --gdbbt
```

Segfault. Moving the `$bits` into the body (`localparam int N = $bits(T) + 4;`) crashes the same way. Without the `$bits` (e.g. `int N = D + 4`) it compiles, and so does `$bits(T)` when `T`'s default is not a `::` projection, so the combination is what matters. Expected: compiles, `value` is 7 bits wide and `N == 11`.

Backtrace from a debug build:

```
Program received signal SIGSEGV, Segmentation fault.
#0  AstNode::iterateAndNext                                   V3Ast.cpp:1085
#1  AstNode::iterateChildren                                  V3Ast.cpp:1059
#3  ParamProcessor::DeferredResolverVisitor::visit(AstClassOrPackageRef*)  V3Param.cpp:2201
#6  ParamProcessor::DeferredResolverVisitor::DeferredResolverVisitor      V3Param.cpp:2240
#7  ParamProcessor::resolveDeferredDotsReachableFrom          V3Param.cpp:2271
#8  ParamProcessor::nodeDeparam                               V3Param.cpp:2316
#9  ParamVisitor::processWorkQ                                V3Param.cpp:2766
#10 ParamVisitor::visit(AstNodeModule*)                       V3Param.cpp:3109
```

`--debugi-V3Param 9` shows it dies right after `E` has been specialized to `E__W7` for the deferred `E#(D)::value_t`. It looks like `DeferredResolverVisitor` is iterating the children of a `ClassOrPackageRef` whose pins were already deleted by that specialization, which is the situation the comment above the visitor says must not happen.

slang 12.0.0 accepts the file.

### Command line

`verilator --binary t.sv` (or `--lint-only`)

### Version

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37 (git master as of 2026-10-03). Ubuntu 24.04, g++ 13.3.

### May we assist you in trying to fix this in Verilator yourself?

Yes. I'd try collecting the Dots first and resolving them after the walk, or making the resolver not free pins the walk still holds; whichever you prefer.
