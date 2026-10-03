<!-- DRAFT: file by hand at https://github.com/verilator/verilator/issues/new -->
Title: Typedef of a nested class reached through a parameterized outer class is not found (Outer#(P)::Inner::T)

**Can you please attach an example that shows the issue or missing feature?**

`t/t_class_param_outer_inner_tdef.v`:

```systemverilog
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class Outer #(int W = 2);
  class Inner;
    typedef logic [W-1:0] T;
    localparam int M = W * 3;
  endclass
endclass

module t;
  Outer#(5)::Inner::T x;
  initial begin
    if ($bits(x) != 5) $stop;
    if (Outer#(5)::Inner::M != 15) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
```

`t/t_class_param_outer_inner_tdef.py`:

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
%Error: t/t_class_param_outer_inner_tdef.v:15:21: Can't find typedef/interface: 'T'
   15 |   Outer#(5)::Inner::T x;
      |                     ^
```

Expected: compiles, `x` is 5 bits. Only the typedef path fails: `Outer#(5)::Inner::M`, `Outer#(5)::Inner::f()` and `Outer#(5)::Inner obj;` resolve through the same chain, `Inner::T` works inside `Outer`'s body, and `Outer#()::Inner::T` fails the same way even when `T` does not use `W`. With a non-parameterized outer (`Outer::Inner::T`, or `p::A::B::C::T`) it works.

**What 'verilator' command line do we use to run your example?**

`test_regress/t/t_class_param_outer_inner_tdef.py`, or directly `verilator --binary t/t_class_param_outer_inner_tdef.v`

**What 'verilator --version' are you using?  Did you try it with the git master version?  Did you try it with other simulators?**

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37, i.e. git master at c8171ae37 (2026-10-03). slang 12.0.0 (pyslang) compiles it with no diagnostics. No commercial simulator tried.

**What OS and distribution are you using?**

Ubuntu 24.04.4 LTS, g++ 13.3.0.

**May we assist you in trying to fix this in Verilator yourself?**

Yes. A `RefDType` whose `::` chain has a parameterized class in the middle is left for V3Param, and the lookup there seems to find members of the specialization but not typedefs one nested class further down.
