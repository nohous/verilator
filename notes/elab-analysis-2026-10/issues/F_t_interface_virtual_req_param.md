<!-- DRAFT: file by hand at https://github.com/verilator/verilator/issues/new -->
Title: Virtual interface with required parameters as class type parameter: "never given value" although the values are given

**Can you please attach an example that shows the issue or missing feature?**

`t/t_interface_virtual_req_param.v`:

```systemverilog
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

interface required_if #(
    type T,
    int W
);
  T data;
endinterface

module t;
  class Cls #(type T = int);
  endclass

  typedef Cls#(virtual required_if#(logic [6:0], 7)) cls_t;

  initial begin
    cls_t e;
    e = new;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
```

`t/t_interface_virtual_req_param.py`:

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
%Error: t/t_interface_virtual_req_param.v:7:11: Class parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T'
    7 | interface required_if #(
      |           ^~~~~~~~~~~
%Error: t/t_interface_virtual_req_param.v:8:10: Parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T'
    8 |     type T,
      |          ^
%Error: t/t_interface_virtual_req_param.v:9:9: Parameter without default value is never given value (IEEE 1800-2023 6.20.1): 'W'
    9 |     int W
      |         ^
```

Expected: compiles. Both parameters are given in `required_if#(logic [6:0], 7)`; if the interface has defaults the file compiles, so the pins of a virtual interface used as a class type parameter are checked for missing defaults before they are applied. The first message also calls `required_if` a "Class parameter".

**What 'verilator' command line do we use to run your example?**

`test_regress/t/t_interface_virtual_req_param.py`, or directly `verilator --binary t/t_interface_virtual_req_param.v`

**What 'verilator --version' are you using?  Did you try it with the git master version?  Did you try it with other simulators?**

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37, i.e. git master at c8171ae37 (2026-10-03). slang 12.0.0 (pyslang) compiles it with no diagnostics. No commercial simulator tried.

**What OS and distribution are you using?**

Ubuntu 24.04.4 LTS, g++ 13.3.0.

**May we assist you in trying to fix this in Verilator yourself?**

Yes.
