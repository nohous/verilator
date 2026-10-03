<!-- DRAFT for filing by hand. Title suggestion: -->
# extends pkg::Outer::Inner fails: "Attempting to extend using non-class under dot"

### Example

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

### What I get

```
%Error: t.sv:15:23: Attempting to extend using non-class under dot
   15 | class Derived extends p::Outer::Inner;
%Error: t.sv:15:23: Attempting to extend using non-class
   15 | class Derived extends p::Outer::Inner;
```

The limit seems to be one package prefix in the extends clause: `extends p::Base` works, `extends p::Base#(5)` works, `extends Outer::Inner` without the package works, but `extends p::Outer::Inner` does not. Putting a typedef in between (`typedef p::Outer::Inner Base; class Derived extends Base;`) works, so this is about the extends clause and not about the nested class itself.

Expected: compiles and prints All Finished.

slang 12.0.0 accepts the file.

### Command line

`verilator --lint-only t.sv`

### Version

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37 (git master as of 2026-10-03). Ubuntu 24.04, g++ 13.3.

### May we assist you in trying to fix this in Verilator yourself?

Yes. `V3LinkDot`'s `visit(AstClassExtends*)` handles exactly one `pkg::` level by hand; routing the extends target through the same scope-chain reduction used for type references would probably cover it.
