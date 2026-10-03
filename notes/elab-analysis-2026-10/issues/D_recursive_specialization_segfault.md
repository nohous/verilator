<!-- DRAFT for filing by hand. Title suggestion: -->
# Self-recursive class specialization in a parameter default segfaults instead of erroring

### Example

```systemverilog
// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Petr Nohavica
// SPDX-License-Identifier: CC0-1.0

class NestedValue #(int A = NestedValue#()::M);
  localparam int M = A;
endclass

module t;
  localparam int C = NestedValue#()::M;
endmodule
```

### What I get

```
%Error-UNSUPPORTED: t.sv:7:45: dotted expressions in parameters
%Error: Verilator internal fault, sorry. Suggest trying --debug --gdbbt
```

This code is wrong on purpose. I'd expect an error that says so; instead it's an UNSUPPORTED followed by a segfault (same backtrace as in the `$bits` report: `DeferredResolverVisitor::visit(AstClassOrPackageRef*)`, V3Param.cpp:2201). slang reports `error: potentially infinitely recursive specialization of class 'NestedValue'`, which is the kind of message I'd hope for.

For comparison, the two simpler cycles are already handled: `type A = A` gives "Recursive type definition" and `int A = A + 1` gives "Variable's initial value is circular". It would be nice if all three cited IEEE 1800-2023 6.20.1 the way the "never given value" errors do, but the crash is the actual problem.

### Command line

`verilator --lint-only t.sv`

### Version

Verilator 5.053 devel rev vUNKNOWN-built20261003-c8171ae37 (git master as of 2026-10-03). Ubuntu 24.04, g++ 13.3.

### May we assist you in trying to fix this in Verilator yourself?

Yes.
