<!-- DRAFT: file by hand at https://github.com/verilator/verilator/issues/new -->
Title: Interface specialized through a dependent default and through the equal explicit value are different interfaces

**Can you please attach an example that shows the issue or missing feature?**

`t/t_interface_virtual_param_dep.v`:

```systemverilog
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

interface Bus #(
    parameter int W = 3,
    parameter int D = W + 2
);
  logic [D-1:0] data;
endinterface

module t;
  Bus #(.W(5)) intf ();
  virtual Bus #(.W(5), .D(7)) v = intf;
  initial begin
    intf.data = 7'h55;
    if (v.data != 7'h55) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
```

`t/t_interface_virtual_param_dep.py`:

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
%Error: t/t_interface_virtual_param_dep.v:16:35: Operator ASSIGN expected 'Bus__W5_D7' interface on Assign RHS but 'intf' is a different interface ('Bus__W5').
   16 |   virtual Bus #(.W(5), .D(7)) v = intf;
      |                                   ^~~~
```

Expected: compiles; with `W = 5` the default makes `D = 7`, so `Bus #(.W(5))` and `Bus #(.W(5), .D(7))` are the same specialization. With a literal default `parameter int D = 7` the same file compiles, so "equal to the default" is only recognized when the default is a literal constant.

**What 'verilator' command line do we use to run your example?**

`test_regress/t/t_interface_virtual_param_dep.py`, or directly `verilator --binary t/t_interface_virtual_param_dep.v`

**What 'verilator --version' are you using?  Did you try it with the git master version?  Did you try it with other simulators?**

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37, i.e. git master at c8171ae37 (2026-10-03). slang 12.0.0 (pyslang) compiles it with no diagnostics. No commercial simulator tried.

**What OS and distribution are you using?**

Ubuntu 24.04.4 LTS, g++ 13.3.0.

**May we assist you in trying to fix this in Verilator yourself?**

Yes. I think the comparison in `cellPinCleanup` needs the default after the other pins are substituted rather than requiring it to be a `Const` in the template.
