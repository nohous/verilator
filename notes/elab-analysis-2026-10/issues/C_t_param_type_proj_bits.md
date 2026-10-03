<!-- DRAFT: file by hand at https://github.com/verilator/verilator/issues/new -->
Title: $bits() of a type parameter whose default is Class#(param)::typedef segfaults in V3Param

**Can you please attach an example that shows the issue or missing feature?**

`t/t_param_type_proj_bits.v`:

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

`t/t_param_type_proj_bits.py`:

```python
#!/usr/bin/env python3
# DESCRIPTION: Verilator: Verilog Test driver/expect definition
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of either the GNU Lesser General Public License Version 3
# or the Perl Artistic License Version 2.0.
# SPDX-FileCopyrightText: 2026 Wilson Snyder
# SPDX-License-Identifier: LGPL-3.0-only OR Artistic-2.0

import vltest_bootstrap

test.scenarios('simulator')

test.compile()

test.execute()

test.passes()
```

**What output from that test indicates it is wrong, and what is the correct or expected output?  (Or, please make test self-checking if possible.)**

```
%Error: Verilator internal fault, sorry. Suggest trying --debug --gdbbt
```

Segfault. Expected: compiles, `value` is 7 bits and `N == 11`. Moving the `$bits` into the body as `localparam int N = $bits(T) + 4;` crashes the same way; without the `$bits` (e.g. `int N = D + 4`) it compiles, and so does `$bits(T)` when `T`'s default is not a `::` projection.

Backtrace from a debug build:

```
Program received signal SIGSEGV, Segmentation fault.
#0  AstNode::iterateAndNext                                            V3Ast.cpp:1085
#1  AstNode::iterateChildren                                           V3Ast.cpp:1059
#3  ParamProcessor::DeferredResolverVisitor::visit(AstClassOrPackageRef*)  V3Param.cpp:2201
#6  ParamProcessor::DeferredResolverVisitor::DeferredResolverVisitor   V3Param.cpp:2240
#7  ParamProcessor::resolveDeferredDotsReachableFrom                   V3Param.cpp:2271
#8  ParamProcessor::nodeDeparam                                        V3Param.cpp:2316
#9  ParamVisitor::processWorkQ                                         V3Param.cpp:2766
```

`--debugi-V3Param 9` shows it dies right after `E` is specialized to `E__W7` for the deferred `E#(D)::value_t`; it looks like the visitor keeps iterating a `ClassOrPackageRef` whose pins that specialization just deleted.

**What 'verilator' command line do we use to run your example?**

`test_regress/t/t_param_type_proj_bits.py`, or directly `verilator --binary t/t_param_type_proj_bits.v`

**What 'verilator --version' are you using?  Did you try it with the git master version?  Did you try it with other simulators?**

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37, i.e. git master at c8171ae37 (2026-10-03). slang 12.0.0 (pyslang) compiles it with no diagnostics. No commercial simulator tried.

**What OS and distribution are you using?**

Ubuntu 24.04.4 LTS, g++ 13.3.0.

**May we assist you in trying to fix this in Verilator yourself?**

Yes.
