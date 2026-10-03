<!-- DRAFT: file by hand at https://github.com/verilator/verilator/issues/new -->
Title: Class#(..)::localparam in a class parameter default gives UNSUPPORTED then segfaults

**Can you please attach an example that shows the issue or missing feature?**

`t/t_class_param_default_lparam.v`:

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

`t/t_class_param_default_lparam.py`:

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
%Error-UNSUPPORTED: t/t_class_param_default_lparam.v:11:26: dotted expressions in parameters
                                                          : ... Suggest use a typedef
   11 | class W #(int B = V#(3)::M);
      |                          ^
%Error: Verilator internal fault, sorry. Suggest trying --debug --gdbbt
```

Expected: compiles, `C == 6`. The same `V#(3)::M` in a module localparam or a module parameter default works.

Backtrace from a debug build:

```
#0  AstNode::iterateAndNext                                            V3Ast.cpp:1085
#3  ParamProcessor::DeferredResolverVisitor::visit(AstClassOrPackageRef*)  V3Param.cpp:2201
#7  ParamProcessor::resolveDeferredDotsReachableFrom                   V3Param.cpp:2271
#8  ParamProcessor::nodeDeparam                                        V3Param.cpp:2316
#9  ParamVisitor::processWorkQ                                         V3Param.cpp:2766
```

Mixing a type and a value projection of the same class in one header (`class W #(int A = 3, type T = V#(A)::t, int B = V#(A)::M)`) gives `%Error: Internal Error: ... V3Param.cpp:2757: Expected module parameterization` instead.

**What 'verilator' command line do we use to run your example?**

`test_regress/t/t_class_param_default_lparam.py`, or directly `verilator --binary t/t_class_param_default_lparam.v`

**What 'verilator --version' are you using?  Did you try it with the git master version?  Did you try it with other simulators?**

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37, i.e. git master at c8171ae37 (2026-10-03). slang 12.0.0 (pyslang) compiles it with no diagnostics. No commercial simulator tried.

**What OS and distribution are you using?**

Ubuntu 24.04.4 LTS, g++ 13.3.0.

**May we assist you in trying to fix this in Verilator yourself?**

Yes. The stack is the same as in the `$bits()` report I'm filing alongside, so they probably share a fix.
