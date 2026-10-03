<!-- DRAFT: file by hand at https://github.com/verilator/verilator/issues/new -->
Title: extends pkg::Outer::Inner fails with "Attempting to extend using non-class under dot"

**Can you please attach an example that shows the issue or missing feature?**

`t/t_class_extends_pkg_nested.v`:

```systemverilog
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

package p;
  class Outer;
    class Inner;
      int v = 3;
    endclass
  endclass
endpackage

class Derived extends p::Outer::Inner;
endclass

module t;
  Derived d;
  initial begin
    d = new;
    if (d.v != 3) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
```

`t/t_class_extends_pkg_nested.py`:

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
%Error: t/t_class_extends_pkg_nested.v:15:23: Attempting to extend using non-class under dot
   15 | class Derived extends p::Outer::Inner;
      |                       ^
%Error: t/t_class_extends_pkg_nested.v:15:23: Attempting to extend using non-class
   15 | class Derived extends p::Outer::Inner;
      |                       ^
```

Expected: compiles. `extends p::Base`, `extends p::Base#(5)` and `extends Outer::Inner` all work; only the package-plus-nested-class form fails. `typedef p::Outer::Inner Base; class Derived extends Base;` works around it.

**What 'verilator' command line do we use to run your example?**

`test_regress/t/t_class_extends_pkg_nested.py`, or directly `verilator --binary t/t_class_extends_pkg_nested.v`

**What 'verilator --version' are you using?  Did you try it with the git master version?  Did you try it with other simulators?**

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37, i.e. git master at c8171ae37 (2026-10-03). slang 12.0.0 (pyslang) compiles it with no diagnostics. No commercial simulator tried.

**What OS and distribution are you using?**

Ubuntu 24.04.4 LTS, g++ 13.3.0.

**May we assist you in trying to fix this in Verilator yourself?**

Yes. `V3LinkDot`'s `visit(AstClassExtends*)` handles exactly one `pkg::` level by hand; routing the extends target through the same scope-chain reduction used for type references would probably cover it.
