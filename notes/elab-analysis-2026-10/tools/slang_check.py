#!/usr/bin/env python3
"""Legality oracle: run slang (pyslang) on SystemVerilog files, print LEGAL/REJECTED + errors."""
import sys, pyslang
def check(path):
    d = pyslang.driver.Driver()
    d.addStandardArgs()
    if not (d.parseCommandLine(f"slang --std 1800-2023 {path}") and d.processOptions()):
        return None, ["(bad command line)"]
    d.parseAllSources()
    comp = d.createCompilation()
    diags = comp.getAllDiagnostics()
    eng = d.diagEngine
    errs = []
    for g in diags:
        if eng.getSeverity(g.code, g.location) in (pyslang.DiagnosticSeverity.Error, pyslang.DiagnosticSeverity.Fatal):
            loc = d.sourceManager.getLineNumber(g.location), d.sourceManager.getColumnNumber(g.location)
            errs.append(f"{loc[0]}:{loc[1]}: {eng.formatMessage(g)}")
    return (not errs), errs
if __name__ == "__main__":
    for p in sys.argv[1:]:
        ok, errs = check(p)
        print(f"{p.split('/')[-1]:44s} slang: {'LEGAL' if ok else 'REJECTED'}")
        for e in errs: print("    " + e[:170])
