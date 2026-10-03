<!-- DRAFT for filing by hand. Title suggestion: -->
# Typedef of a nested class reached through a parameterized outer class is not found (Outer#(P)::Inner::T)

### Example

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

### What I get

```
%Error: t.sv:15:21: Can't find typedef/interface: 'T'
   15 |   Outer#(5)::Inner::T x;
```

Only the typedef path fails. Through the same chain, `Outer#(5)::Inner::M` (a localparam), `Outer#(5)::Inner::f()` (a static function) and `Outer#(5)::Inner obj;` (the nested class as a type) all resolve, and inside `Outer`'s own body `Inner::T` works too. It also fails for the default specialization `Outer#()::Inner::T` and when `T` does not depend on `W` at all, so it is the shape of the reference rather than the dependency. If `Outer` is not parameterized (`Outer::Inner::T`) it works, as do deeper non-parameterized chains like `p::A::B::C::T`.

Expected: compiles, `x` is 5 bits wide and `M == 15`.

slang 12.0.0 accepts the file.

### Command line

`verilator --lint-only t.sv`

### Version

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37 (git master as of 2026-10-03). Ubuntu 24.04, g++ 13.3.

### May we assist you in trying to fix this in Verilator yourself?

Yes. It looks like a `RefDType` whose `::` chain has a parameterized class in the middle is left for V3Param, and the lookup there finds members of the specialization but not typedefs one nested class further down.
