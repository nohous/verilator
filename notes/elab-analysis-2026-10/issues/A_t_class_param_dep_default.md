<!-- DRAFT: file by hand at https://github.com/verilator/verilator/issues/new -->
Title: Class type parameter default that specializes another class with a sibling parameter is resolved against the template

**Can you please attach an example that shows the issue or missing feature?**

`t/t_class_param_dep_default.v`:

```systemverilog
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class Channel #(type T = int);
  T val;
endclass

class Tapped #(type T, type BaseT = Channel#(T));
  BaseT b;
endclass

module t;
  Tapped#(.T(int)) tp;
  initial begin
    tp = new;
    tp.b = new;
    tp.b.val = 5;
    if (tp.b.val != 5) $stop;
    $write("*-* All Finished *-*\n");
    $finish;
  end
endmodule
```

`t/t_class_param_dep_default.py`:

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
%Error: t/t_class_param_dep_default.v:11:37: Class parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T'
   11 | class Tapped #(type T, type BaseT = Channel#(T));
      |                                     ^~~~~~~
%Error: t/t_class_param_dep_default.v:7:22: Parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T'
    7 | class Channel #(type T = int);
      |                      ^
%Error-PINNOTFOUND: t/t_class_param_dep_default.v:11:46: Parameter not found: '__paramNumber1'
   11 | class Tapped #(type T, type BaseT = Channel#(T));
      |                                              ^
```

Expected: compiles and prints All Finished. The second error points at `Channel`'s own `T`, so `Channel#(T)` was specialized with `T` still the unbound formal of the `Tapped` template instead of `int`.

Same thing, other symptoms:

- `class Tapped #(type T = byte, type BaseT = Channel#(T))` with positional `Tapped#(int)`: `%Error: Recursive type definition`
- `class Tapped #(int N, type BaseT = Channel#(N))` with `Tapped#(4)`: `Expecting expression to be constant, but variable isn't const: 'N'` then `Can't convert defparam value to constant: Param '__paramNumber1' of 'Channel'`
- `class Chain #(type E = logic [7:0], type M = E [2:1]); typedef M out_t; endclass` with `Chain#(.E(logic [3:0]))::out_t x;`: `%Error: Internal Error: ... V3Width.cpp:2922: Unlinked`

`Tapped#()` and `Tapped#(int, Channel#(int))` both work; so does `type U = T` without a class in the default. `t_class_param_comparator.v` has this shape but passes both actuals explicitly, so the default is never exercised there.

**What 'verilator' command line do we use to run your example?**

`test_regress/t/t_class_param_dep_default.py`, or directly `verilator --binary t/t_class_param_dep_default.v`

**What 'verilator --version' are you using?  Did you try it with the git master version?  Did you try it with other simulators?**

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37, i.e. git master at c8171ae37 (2026-10-03). slang 12.0.0 (pyslang) compiles it with no diagnostics. No commercial simulator tried.

**What OS and distribution are you using?**

Ubuntu 24.04.4 LTS, g++ 13.3.0.

**May we assist you in trying to fix this in Verilator yourself?**

Yes. The default's `ClassRefDType` pins still point at the template's `ParamTypeDType` when `cellPinCleanup` folds them; I'd try evaluating defaults in `resolveDefaultParams` with the already-bound sibling pins substituted.
