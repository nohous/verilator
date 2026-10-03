# The algebra the LRM implies, and a generator built on it

You're right that hand-written repros are special cases. The LRM never states an
elaboration algorithm; it states properties of the result, and the test surface is the
closure of a small set of constructs under nesting. That closure is enumerable. Here is the
model I'd write down first, then the generator that walks it.

## The model (what the LRM pins down, in six rules)

A *scope template* S has an ordered list of formals f1..fn, each a value formal (with a
type) or a type formal, each with an optional default d_i that may mention f_j for j < i
(6.20.1; Verilator also allows j > i, which is an extension and should be generated only
when testing Verilator against itself).

1. **Environment.** A reference `S#(actuals)` denotes the environment env = {f_i -> v_i}
   where v_i is the explicit actual (positional or named), else d_i evaluated in env
   restricted to the already-bound formals, else an error "never given value".
   Evaluation of d_i may itself denote another reference `S'#(...)` and project a member
   of it (`::T`, `::M`), so denotation is recursive.

2. **Identity.** Two references to S denote the same specialization iff every value formal
   has the same type and value and every type formal is a *matching* type (8.25 for
   classes; 23.10 / 25.8 give the same rule for modules and interfaces via "unique
   combination of parameter values"). Explicit-equal-to-default and default are the same
   specialization. How the actual was spelled is irrelevant.

3. **Matching types** (6.22.1): the transitive closure of typedefs, same predefined type,
   same packed array range *as written in the type*, same enum/struct declaration. Note
   `type A = E [2:1]` is a packed dimension on a type identifier, so A is `E [2:1]`
   *packed*, not an unpacked array (slang caught me on this).

4. **Members of a specialization** are the template's members with env substituted:
   `S#(a)::T` is T's declaration under env; `S#(a)::M` is M's value under env; `$bits` and
   `type()` of those are defined by 20.6.2 and 6.23 on the substituted type.

5. **Default specialization.** `S` without `#()` inside its own body is the current
   specialization (8.25.1); outside, it is `S#()`.

6. **Cycles.** If computing env for S#(a) requires S#(a) itself (through any chain of
   defaults and projections), the program is erroneous (slang: "potentially infinitely
   recursive specialization"). Using a formal in its own default is use-before-declaration.

Everything in bug classes A–F is a violation of rule 1 (A, F), 2 (E), or 6 (D), plus crashes
(B, C) on inputs that rules 1 and 4 say are fine.

## The generator

Enumerate programs from a tiny grammar, compute the expected answer from the model, emit
a self-checking test, and run two tools on it.

- **Shapes:** template kind (class / module / interface / virtual interface), 1–4 formals
  with kinds (value, type) and default kinds (none, literal, sibling, `sibling op literal`,
  `Other#(sibling)::T`, `Other#(sibling)::M`, `$bits(sibling)`, `sibling [k:0]`), actual
  kinds per formal (omitted, positional, named, named-equal-to-default, empty `.X()`),
  reference kinds (direct `S#(..)::T`, typedef alias, member of a variable, `extends`,
  virtual interface variable), nesting depth 1–3.
- **Expected value:** a ~150-line Python evaluator implementing rules 1–6 over a tiny type
  algebra (logic/bit vectors with packed dims, byte/int/shortint, enum, packed struct of
  those). It yields, for each emitted probe, `$bits` of the projected type and the value
  of projected localparams, and whether two references must be the same type. The test
  body checks those with `if (... != EXPECTED) $stop;` and, for identity, assigns one
  reference's variable to the other's.
- **Oracle for the generator itself:** every emitted program is first run through slang
  (`probe/slang_check.py`). A rejection means the generator or the model is wrong, not
  Verilator; fix the model. That is how `a5` got corrected.
- **Classification of Verilator's result:** accept+correct, reject-legal (lint error),
  wrong-value (`$stop` fired), internal error, crash. Minimize failing programs
  automatically (delta debugging over the grammar, not over text) so each class yields a
  3-line repro like the ones already filed.

The point is not fuzzing for its own sake. The model *is* the acceptance criterion for
any rewrite of V3Param: a specializer is correct when the generator finds nothing at
depth 3 and the existing `t_class_lparam_*` and `t_param_*` suites still pass. It also
decides what "atomic swap" has to mean in practice — the new path can be switched in
shape by shape, and the generator tells you which shapes it already gets right.

Cost: a day or two for the evaluator and grammar, then it runs forever for free.
