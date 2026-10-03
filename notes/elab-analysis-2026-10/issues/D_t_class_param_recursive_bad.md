<!-- DRAFT: file by hand at https://github.com/verilator/verilator/issues/new -->
Title: Self-recursive class specialization in a parameter default segfaults instead of erroring

**Can you please attach an example that shows the issue or missing feature?**

`t/t_class_param_recursive_bad.v`:

```systemverilog
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class NestedValue #(int A = NestedValue#()::M);
  localparam int M = A;
endclass

module t;
  localparam int C = NestedValue#()::M;
endmodule
```

`t/t_class_param_recursive_bad.py`:

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

test.scenarios('linter')

test.lint(fails=True, expect_filename=test.golden_filename)

test.passes()
```

**What output from that test indicates it is wrong, and what is the correct or expected output?  (Or, please make test self-checking if possible.)**

```
%Error-UNSUPPORTED: t/t_class_param_recursive_bad.v:7:45: dotted expressions in parameters
                                                        : ... Suggest use a typedef
    7 | class NestedValue #(int A = NestedValue#()::M);
      |                                             ^
%Error: Verilator internal fault, sorry. Suggest trying --debug --gdbbt
```

The code is deliberately wrong; expected an error, got UNSUPPORTED followed by a segfault (same backtrace as the `$bits()` report: `DeferredResolverVisitor::visit(AstClassOrPackageRef*)`, V3Param.cpp:2201). No `.out` golden attached since there is no stable output to record yet. `type A = A` and `int A = A + 1` are already caught ("Recursive type definition" / "Variable's initial value is circular").

**What 'verilator' command line do we use to run your example?**

`test_regress/t/t_class_param_recursive_bad.py`, or directly `verilator --lint-only t/t_class_param_recursive_bad.v`

**What 'verilator --version' are you using?  Did you try it with the git master version?  Did you try it with other simulators?**

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37, i.e. git master at c8171ae37 (2026-10-03). slang 12.0.0 rejects it with `error: potentially infinitely recursive specialization of class 'NestedValue'`.

**What OS and distribution are you using?**

Ubuntu 24.04.4 LTS, g++ 13.3.0.

**May we assist you in trying to fix this in Verilator yourself?**

Yes.
