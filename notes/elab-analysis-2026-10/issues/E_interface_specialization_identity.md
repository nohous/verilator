<!-- DRAFT for filing by hand. Title suggestion: -->
# Interface specialized via a dependent default and via the equal explicit value are treated as different interfaces

### Example

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

### What I get

```
%Error: t.sv:16:35: Operator ASSIGN expected 'Bus__W5_D7' interface on Assign RHS but 'intf' is a different interface ('Bus__W5').
```

With `W = 5`, `D` defaults to 7, so `Bus #(.W(5))` and `Bus #(.W(5), .D(7))` are the same specialization (IEEE 1800-2023 6.20.2 / 25.8). Verilator names them differently and then refuses the assignment. If I change the default to the literal `parameter int D = 7` the same file compiles, so the problem is that "equal to the default" is only recognized when the default is a literal constant, not when it depends on another parameter.

slang 12.0.0 accepts the file.

### Command line

`verilator --binary t.sv`

### Version

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37 (git master as of 2026-10-03). Ubuntu 24.04, g++ 13.3.

### May we assist you in trying to fix this in Verilator yourself?

Yes. I think the comparison in `cellPinCleanup` needs to see the default after substitution of the other pins rather than requiring it to already be a `Const` in the template.
