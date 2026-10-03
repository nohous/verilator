# Parameter elaboration analysis, October 2026

Analysis of upstream Verilator master c8171ae37 (2026-10-03) against the tests from branch
`pr-elab-convergence`, done in a Claude Code session; everything here was verified by
running the actual tools (Verilator built from that commit, slang 12.0.0 via pyslang).

- `elab-analysis.md` – the readable write-up: what fails, how upstream works, review of the
  convergence sketch, recommended path.
- `elab-analysis-detailed.md` – same content with `file:line` references for every claim.
- `lrm-algebra-and-generator.md` – the LRM-implied model in six rules and a test generator
  design built on it.
- `issues/` – eight issue drafts (A–H) answering upstream's issue template question by question.
  `issues/t/` holds each example as a real `test_regress` test (`t_<name>.v` + `.py` driver);
  all eight were run through the harness and fail with exactly the quoted diagnostics.
- `probes/min/` – 48 minimal probes bisecting the failures (`min_results.md` is the table).
- `probes/scope/` – the multi-level `::` matrix (29 cases).
- `probes/owner_tests_vs_master.txt` – raw output of the branch's own tests against master.
- `tools/slang_check.py` – legality oracle (`pip install pyslang`); `tools/run_probes.sh`.

Status of each draft against master c8171ae37: A wrong environment for dependent defaults
(4 symptoms); B `Cls#(..)::lparam` in class default, UNSUPPORTED + segfault; C `$bits()` of
a projected type parameter, segfault; D recursive specialization, segfault instead of error;
E interface identity differs for equal pins; F virtual interface required pins not applied;
G `Outer#(P)::Inner::T` not found; H `extends p::Outer::Inner` rejected.
