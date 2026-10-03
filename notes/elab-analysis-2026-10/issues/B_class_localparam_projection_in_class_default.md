<!-- DRAFT for filing by hand. Title suggestion: -->
# Class#(..)::localparam in a class parameter default is Unsupported and then segfaults

Reading a localparam of a specialized class inside a *class* parameter default fails with an UNSUPPORTED error and then Verilator crashes. The same expression in a module localparam or module parameter default works.

### Example

```systemverilog
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class V #(int A = 1);
  localparam int M = A * 2;
endclass

class W #(int B = V#(3)::M);
  localparam int K = B;
endclass

module t;
  localparam int C = W#()::K;
  initial begin
    if (C != 6) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
```

### What I get

```
%Error-UNSUPPORTED: t.sv:11:26: dotted expressions in parameters
                                ... Suggest use a typedef
%Error: Verilator internal fault, sorry. Suggest trying --debug --gdbbt
```

The crash is a segfault; backtrace below. Expected: compiles, `C == 6`.

If I move `V#(3)::M` into a module (`module t; localparam int C = V#(3)::M;`) or into a module parameter default (`module M #(int N = V#(3)::M)`), both work, so the deferred-localparam machinery covers module scope but not class defaults.

A variant that mixes a type projection and a value projection of the same class in one header, `class W #(int A = 3, type T = V#(A)::t, int B = V#(A)::M)`, gives `%Error: Internal Error: ... V3Param.cpp:2757: Expected module parameterization` instead of the segfault.

Backtrace (debug build):

```
#0  AstNode::iterateAndNext                                   V3Ast.cpp:1085
#3  ParamProcessor::DeferredResolverVisitor::visit(AstClassOrPackageRef*)  V3Param.cpp:2201
#6  ParamProcessor::DeferredResolverVisitor::DeferredResolverVisitor      V3Param.cpp:2240
#7  ParamProcessor::resolveDeferredDotsReachableFrom          V3Param.cpp:2271
#8  ParamProcessor::nodeDeparam                               V3Param.cpp:2316
#9  ParamVisitor::processWorkQ                                V3Param.cpp:2766
```

slang 12.0.0 accepts both files.

### Command line

`verilator --lint-only t.sv`

### Version

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37 (git master as of 2026-10-03). Ubuntu 24.04, g++ 13.3.

### May we assist you in trying to fix this in Verilator yourself?

Yes, happy to. The crash itself looks like the same use-after-free as in the `$bits` report I'm filing alongside this one (identical stack), so they may want to be fixed together.
