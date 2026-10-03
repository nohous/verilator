#!/bin/bash
# Run the owner's convergence-branch test cases against the upstream verilator build.
# Usage: run_probes.sh <verilator_root> <tests_dir> <outdir>
VROOT=$1; T=$2; OUT=$3; mkdir -p "$OUT"
VL="$VROOT/bin/verilator"
run() { # name, kind(sim|lint), file
  local name=$1 kind=$2 f=$3; local d="$OUT/$name"; rm -rf "$d"; mkdir -p "$d"
  echo "################ $name ($kind)"
  if [ "$kind" = lint ]; then
    (cd "$d" && timeout 300 "$VL" --lint-only -Wno-fatal --timing "$f") > "$d/log" 2>&1; rc=$?
    echo "rc=$rc"; grep -E '^%(Error|Warning)' "$d/log" | head -12
  else
    (cd "$d" && timeout 900 "$VL" --binary --timing -Wno-fatal -Wno-WIDTH -Wno-UNUSED --Mdir obj -o sim "$f") > "$d/log" 2>&1; rc=$?
    if [ $rc -ne 0 ]; then echo "VERILATE/BUILD FAILED rc=$rc"; grep -E '^%(Error|Warning)|Internal|Assert|Aborting|error:' "$d/log" | head -12
    else (cd "$d" && timeout 120 ./obj/sim) > "$d/run.log" 2>&1; rrc=$?
      echo "run rc=$rrc"; grep -E 'All Finished|WRONG|stop|fatal|Error' "$d/run.log" | head -8; fi
  fi
}
run t_class_param_dep_type         sim  "$T/t_class_param_dep_type.v"
run t_module_param_dep_type        sim  "$T/t_module_param_dep_type.v"
run t_lparam_dep_converge          sim  "$T/t_lparam_dep_converge.v"
run t_class_default_type_param     sim  "$T/t_class_default_type_param.v"
run t_interface_virtual_param      sim  "$T/t_interface_virtual_param.v"
run t_interface_virtual_nocell     sim  "$T/t_interface_virtual_nocell.v"
run t_class_param_dep_cycle_bad    lint "$T/t_class_param_dep_cycle_bad.v"
run t_interface_param_another_bad  lint "$T/t_interface_param_another_bad.v"
run t_class_param_bad2             lint "$T/t_class_param_bad2.v"
