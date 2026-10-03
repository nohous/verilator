# Verilator parameter elaboration: where it stands, October 2026

I built upstream master (c8171ae37, today), ran the tests from your `pr-elab-convergence`
branch against it, reduced every failure to a few lines, and read `V3LinkDot`, `V3Param`,
`V3Width`/`V3Const` and your `V3Elab` sketch. This is the readable version. The dense one
with every `file:line` is `elab-analysis-detailed.md`; the repro files are in `repros/`.

## The short answer

You are right about the mechanism. Upstream has no loop that keeps resolving names,
specializing parameterized things and folding constants until nothing changes. It runs
those three jobs in a fixed order, and whenever one of them needs an answer the next one
hasn't produced yet, it either leaves raw syntax in the tree for later or recurses on the
spot and patches pointers afterwards by comparing name strings. Every new shape of
dependency has needed a new patch: about sixty commits in this corner since July, thirty of
them in `V3Param.cpp`.

Four of your six legal test cases fail on today's master, two with segfaults. Reduced,
they are four distinct bugs with one common root: a parameter default that needs another
specialization is evaluated against the template instead of the instance.

Your convergence branch has the right idea and the wrong implementation. It cannot be
rebased; it would have to be rewritten. I would not rewrite it as a fact graph. The
textbook shape for this problem is lazy, memoized specialization with in-progress marks,
and it fits the existing code better. Details in section 5.

## 1. What breaks on today's master

### A. A default that specializes another class using a sibling parameter

```systemverilog
class Channel #(type T = int); T val; endclass
class Tapped  #(type T, type BaseT = Channel#(T)); BaseT b; endclass
module t; Tapped#(.T(int)) tp; endmodule
```

Verilator reports that `T` of **`Channel`** was never given a value. It specialized
`Channel#(T)` while `T` was still the unbound template formal. Variants of the same
mistake: with `type T = byte` and a positional `Tapped#(int)` you get "Recursive type
definition"; with a value formal (`int N, type BaseT = Channel#(N)`) you get "variable
isn't const: 'N'"; with an array default (`type E = logic [7:0], type M = E [2:1]`) and
`.E(logic [3:0])` overridden you get an internal error in `V3Width`. It works only when
nothing is overridden or when every actual is spelled out. Upstream's single test of this
idiom (`t_class_param_comparator.v`) spells out both actuals, so the default is never
exercised. This is legal, ordinary SystemVerilog (IEEE 1800-2023 6.20.1) and the UVM
`#(type REQ = ..., type RSP = REQ)` family is one step away from it.

### B. `Class#(..)::localparam` inside a class parameter default

```systemverilog
class V #(int A = 1); localparam int M = A * 2; endclass
class W #(int B = V#(3)::M); localparam int K = B; endclass
module t; localparam int C = W#()::K; endmodule
```

"Unsupported: dotted expressions in parameters", and then a segfault. The same expression
in a module's `localparam` or a module parameter default works fine. The machinery that
handles it (added for #7746 in September) covers module scope but not class defaults.

### C. `$bits()` of a type parameter whose default is a projection

```systemverilog
class E #(int W = 2); typedef logic [W-1:0] value_t; endclass
module M #(int W = 3, int D = W + 2, type T = E#(D)::value_t, int N = $bits(T) + 4)
  (output T value); endmodule
```

Segfault, in the header or with `localparam int N = $bits(T) + 4` in the body. The debug
build shows the deferred-reference resolver in `V3Param` walking the children of a node
that it freed itself a moment earlier, while specializing `E#(D)`. Its own header comment
states the rule it breaks. B, C and the cycle case below all die on this one stack.

### D. Cycles through a nested reference

```systemverilog
class NestedValue #(int A = NestedValue#()::M); localparam int M = A; endclass
```

Unsupported, then segfault. The two other cycle forms (`type A = A`, `int A = A + 1`) get
two unrelated messages, neither citing the standard. Your branch's single
"Parameter default dependency is circular (IEEE 1800-2023 6.20.1)" per formal is better.

### E. The same interface specialized two ways is two types

`BusDependent #(.W(5)) intf4` becomes `BusDependent__W5`. A `virtual BusDependent` whose
pins spell out `W`, `D`, `T` and `U` explicitly becomes `BusDependent__pib39c82ee`, and
assigning one to the other is an error. Identity is a string built from the pins that
*override*, and "equal to default" is only recognized when the default is already a
constant in the template, which a dependent default like `D = W + 2` never is. Today's
#8604 fixed pin order inside one cell; it does not touch this. Your branch fixes it for
classes only; modules and interfaces still go through the old path.

### What does not break

Depth. Chains of `IW#(I_k)::same_t` from 4 to 80 levels all pass, so the "fixed recursion
guards" you were aiming at are gone. Typedef aliases of projections, struct typedefs behind
projections, `type U = T` aliases and module-scope value projections are all fine. Your big
`t_class_param_dep_type.v` fails on A, and once A is cut out it fails on A's array variant;
it is hiding several bugs behind one assertion and would be more useful split up.

## 2. How upstream does it today

The pipeline is a straight line: `LinkDot` (primary) → `Param` → `LinkDot` (paramed) →
`finalizeDeferredParams` → `Dead` → `Width`. Nothing in it runs twice because something
changed.

**LinkDot** runs three times in a verilation, and each time it builds a fresh symbol table
and throws it away afterwards. Only pointers stored in AST nodes survive. In the first run
it deliberately does not resolve anything that depends on a specialization that does not
exist yet; it leaves the dotted syntax in the tree with an "unresolved" flag, and once a
`::` chain has been consumed it deletes the chain, so later passes can only work from the
pointer it stored. Its only retry is one extra round per run for modules whose `::` prefix
failed, and anything that fails during that extra round is silently dropped. Inside a class
that extends a parameterized base, every unresolved name is swallowed without error.

**Param** is a single pass over a work queue sorted by interfaces-first, then hierarchy
level. Each module body is processed once. Parameterized classes are never visited as
templates; they are cloned when something refers to them. A specialization's identity is a
string assembled from its overriding pins at the moment it is created, and nothing can
rename or merge clones later. To fold pin values it calls `V3Width` and `V3Const` early,
on template modules that are not finished, which is why `V3Width` has seven places that
suppress errors when the module is a template, and why `V3Const`'s "must be constant" mode
quietly ignores dotted expressions. When a pin needs another class's typedef or localparam,
Param specializes that class right there, from whatever depth it happens to be at, and then
six separate passes afterwards repair pointers by looking up typedefs by name or by
comparing `origName()` strings, giving up when two sibling specializations are ambiguous.
There are two unrelated "defer" mechanisms: LinkDot defers linking to its second run, Param
defers constant folding to `finalizeDeferredParams`. Neither can trigger a new or renamed
specialization once Param has returned.

Six comments in `V3Param.cpp`, `V3Width.cpp` and `V3LinkDot.cpp` refer to a "DepGraph
architecture" that would make all of this unnecessary. They were written by em2machine in
March (#7128). No such pass exists or ever existed in the tree.

## 3. Why the fixes keep coming

Five things, each the root of several recent commits.

Identity is computed too early. Anything folded late — pin order, a `Class#(P)::lparam`, a
`$bits(type_param)`, an element type with unfolded pins — gets a wrong or duplicate name.

Templates are folded in place. Modules do not even get a pristine copy; correctness depends
on every instantiating module being processed first, which the code admits is violated.

Specializations are created as side effects. #8440 was a clone created inside a type lookup
that nobody ever elaborated; the fix was a back-channel vector into the work queue.

Links are repaired after the fact by name. Each new reference shape (typedef chains,
self-references, covergroups, classes nested in interfaces) has needed its own repair rule.

There is no feedback. A cross-module `::` dependency gets at most four attempts in the whole
pipeline, and anything first resolvable after Param cannot change what Param did.

## 4. About `pr-elab-convergence`

You called it an unreviewed sketch; I read it as one. The core abstraction is sound: one
binding per formal per reference, explicit actuals known immediately, defaults as queries
that depend on sibling bindings, a specialization's identity derived from the finished set,
and a cycle report at quiescence that names every formal in the cycle. Those are the
correct ideas and I kept them in the recommendation.

The implementation would not survive review. Facts are keyed by raw AST pointers held
across all of Param, which works only because deletions were deferred and the tree
consistency check was disabled at the new boundary. The projection graph writes into live
type nodes while it is still draining, so "replacements only at convergence boundaries" is
true for one of the four graphs. Classes specialized through the projection callback are
never queued for body elaboration, the exact bug upstream later fixed in #8440. Every
default is cloned once per reference, which has not been measured on anything UVM-sized.
And the identity change only reached classes, so bug E is still there.

Against today's master, 40 of its 72 hunks do not apply; the interface-capture part is
already obsolete because #8492 deleted that code. It is a rewrite, not a rebase.

## 5. What I would do

### The design, in one paragraph

Treat specialization as a function `specialize(template, environment)` that is lazy,
memoized and recursive. Build the environment by binding explicit actuals, then evaluating
each remaining default by cloning its expression, substituting the formals already bound,
and folding the clone, calling `specialize` recursively when the default needs another
class's member. Memoize on the finished environment, so the clone's name is assigned only
when everything is known and an explicit actual equal to the default is the same key. Keep
an in-progress set keyed on the partial environment; re-entry is a cycle and the recursion
stack is the diagnostic. Never fold the template; give modules the pristine copy that
classes and interfaces already have. Route every creation of a specialization — cells,
class references, `extends`, deferred dots, virtual interfaces — through this one function,
which also enqueues the body. Have LinkDot stop deleting the `::` chain and stop guessing,
so Param can always ask. Equivalent in power to your worklist, but it needs no separate
data store, no pointer-keyed facts and no lifetime boundary, and most of it is a
reorganization of code Param already has.

The genuinely hard part is not the recursion. It is that `V3Width` and `V3Const` are
destructive passes designed to run once on a finished tree, and evaluating a default "in an
environment" means running them on clones in a controlled way. That is the piece that
deserves a design note before any code.

### The order of work

1. File A through D as issues with the three-line repros. Two segfaults and two internal
   errors on legal code are not arguable, and `t_class_param_comparator.v` shows the shape
   is untested. Mention em2machine, who has 35 commits in this area and the DepGraph
   comments.
2. One PR making `resolveDefaultParams` evaluate dependent defaults in the instance's
   environment, for type and value formals, with a proper circular-dependency error.
   Roughly 150 lines in one file, no LinkDot or AST changes. Fixes A and D and subsumes
   three of the recent patches.
3. One PR fixing the use-after-free in the deferred resolver. Small, crash fix, fast review.
   Fixes the crashes in B, C and D.
4. One PR computing "equal to default" after substitution instead of requiring a template
   constant. Fixes E.
5. Only then the structural change, argued against the fifteen `t_class_lparam_*` tests
   that #7746 added, not against the July base.

Each of these is the size Wilson actually merges here: the typical V3Param commit this year
is 1–85 lines plus a test, and the one 2500-line PR in this area (#7128) took February to
September.

### Process constraints

Upstream added an AI policy in May (docs/CONTRIBUTING.rst). You as submitter are strictly
responsible for reviewing, verifying and testing anything I write, you certify it as your
own work via the DCO, and disclosure of significant AI use in the PR description is
encouraged. I may not edit `docs/CONTRIBUTORS` or `Changes`. The `AGENTS.md` files require
single-purpose PRs, a test that fails without the fix, `make format`, `make cppcheck`,
`make lint-py`, and a full regression run before submitting. Before filing issues I would
run the repros through slang as an independent check that they are legal.

## Appendix: where the detail is

`elab-analysis-detailed.md` has every claim above with `file:line` references, the full
probe table (48 cases), the list of upstream commits in this area since July, and the
line-by-line review of `V3Elab.cpp`. `repros/` has the nine files quoted in section 1 and
the raw output of your nine tests against master.
