<!-- DRAFT for filing by hand. Title suggestion: -->
# Virtual interface with required parameters as a class type parameter: "never given value" although values are given

### Example

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

### What I get

```
%Error: t.sv:7:11: Class parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T'
%Error: t.sv:8:10: Parameter type without default value is never given value (IEEE 1800-2023 6.20.1): 'T'
%Error: t.sv:9:9: Parameter without default value is never given value (IEEE 1800-2023 6.20.1): 'W'
```

Both parameters are given in `required_if#(logic [6:0], 7)`. If the interface has defaults for `T` and `W` the file compiles, so the pins of a virtual interface type used as a class type parameter are checked for missing defaults before (or without) being applied. Also, line 7 calls it a "Class parameter" although `required_if` is an interface.

slang 12.0.0 accepts the file.

### Command line

`verilator --binary t.sv`

### Version

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37 (git master as of 2026-10-03). Ubuntu 24.04, g++ 13.3.

### May we assist you in trying to fix this in Verilator yourself?

Yes.
