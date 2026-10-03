<!-- DRAFT for filing by hand. Title suggestion: -->
# Class type parameter default that specializes another class with a sibling parameter is evaluated against the template

A default of the form `type BaseT = Channel#(T)`, where `T` is another parameter of the same class, is resolved with `T` still unbound. Depending on how the class is then specialized this shows up as a wrong error, a wrong "recursive type" error, or an internal error. It only works when nothing is overridden or when every actual is written out explicitly.

### Example

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

### What I get

```
%Error: t.sv:11:37: Class parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T'
%Error: t.sv:7:22: Parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T'
%Error-PINNOTFOUND: t.sv:11:46: Parameter not found: '__paramNumber1'
```

The second message points at `Channel`'s own `T`, i.e. `Channel#(T)` was specialized while `T` was the unbound formal of the `Tapped` template rather than `int`. I'd expect this to compile and print All Finished.

Same root cause, other symptoms (each is a separate small file, happy to attach them):

- Give `T` a default and use a positional actual, `class Tapped #(type T = byte, type BaseT = Channel#(T))` with `Tapped#(int)`: `%Error: Recursive type definition`.
- Value parameter instead of type: `class Tapped #(int N, type BaseT = Channel#(N))` with `Tapped#(4)`: `Expecting expression to be constant, but variable isn't const: 'N'` followed by `Can't convert defparam value to constant: Param '__paramNumber1' of 'Channel'`.
- Array of the sibling, no second class involved: `class Chain #(type E = logic [7:0], type M = E [2:1]); typedef M out_t; endclass` used as `Chain#(.E(logic [3:0]))::out_t x;`: `%Error: Internal Error: ... V3Width.cpp:2922: Unlinked`.

`Tapped#()` (all defaults) and `Tapped#(int, Channel#(int))` (everything explicit) both work. `type U = T` without a class specialization in the default also works, so this is specifically about a default that needs another specialization built from the sibling.

slang 12.0.0 accepts all four files. The existing test `t_class_param_comparator.v` has this shape (`type comp_type = builtin_comp#(T)`) but spells out both actuals, so the default is never exercised there.

### Command line

`verilator --lint-only t.sv` (also `--binary`)

### Version

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37 (git master as of 2026-10-03). Ubuntu 24.04, g++ 13.3.

### May we assist you in trying to fix this in Verilator yourself?

Yes. From what I can see the pins of the default's `ClassRefDType` still point at the template's `ParamTypeDType` when `cellPinCleanup` folds them, so the fix is probably in `resolveDefaultParams` evaluating defaults with the already-bound sibling pins substituted. I'd like to try, if that sounds like the right place.
