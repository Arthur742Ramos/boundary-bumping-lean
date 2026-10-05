"""Serial, bounded source, axiom, and dependency-only challenge verification.

Use a normal Lake dependency installation, or a matching read-only cache copied
into .lake/packages. No project olean is used to compile the renamed challenge.
"""
from __future__ import annotations
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import uuid

ROOT = Path(__file__).resolve().parent.parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--lean-bin", default=shutil.which("lean"))
args = parser.parse_args()
if not args.lean_bin:
    parser.error("Install elan or supply --lean-bin")
launcher = str(Path(args.lean_bin).absolute())
prefix = subprocess.check_output([launcher, "--print-prefix"], cwd=ROOT, text=True).strip()
lean = Path(prefix) / "bin" / ("lean.exe" if os.name == "nt" else "lean")
env = dict(os.environ)
env["PATH"] = str(lean.parent) + os.pathsep + env.get("PATH", "")
manifest = json.loads((ROOT / "lake-manifest.json").read_text(encoding="utf-8"))
dep_paths = [ROOT / manifest.get("packagesDir", ".lake/packages") / p["name"] /
             ".lake/build/lib/lean" for p in manifest["packages"]]
dep_paths = [p.resolve() for p in dep_paths if p.is_dir()]
if not dep_paths:
    raise SystemExit("No dependency build paths; run lake exe cache get")
for p in dep_paths:
    for name in ["Solution", "Challenge", "BoundaryBumping"]:
        if (p / (name + ".olean")).exists() or (p / name).exists():
            raise SystemExit("Project artifact contaminates dependency path")
env["LEAN_PATH"] = os.pathsep.join(map(str, dep_paths))
env.pop("LEAN_SRC_PATH", None)
if os.name == "nt":
    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    kernel.GetCurrentProcess.restype = ctypes.c_void_p
    handle = ctypes.c_void_p(kernel.GetCurrentProcess())
    process_mask, system_mask = ctypes.c_size_t(), ctypes.c_size_t()
    if not kernel.GetProcessAffinityMask(handle, ctypes.byref(process_mask), ctypes.byref(system_mask)):
        raise ctypes.WinError(ctypes.get_last_error())
    bits = [1 << i for i in range(64) if process_mask.value & (1 << i)]
    if not kernel.SetProcessAffinityMask(handle, ctypes.c_size_t(sum(bits[:2]))):
        raise ctypes.WinError(ctypes.get_last_error())
elif hasattr(os, "sched_getaffinity"):
    os.sched_setaffinity(0, sorted(os.sched_getaffinity(0))[:2])

report = {"scope": "Local compiler, transitive axiom, and exact type checks; not hosted Comparator",
          "stages": [], "sources": {}}
for name in ["Solution.lean", "Challenge.lean", "comparator.json", "lake-manifest.json",
             "scripts/CompareTypes.lean", "scripts/verify.py", "formalization.yaml"]:
    data = (ROOT / name).read_bytes()
    report["sources"][name] = {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
for name in ["Solution.lean", "Challenge.lean", "scripts/CompareTypes.lean"]:
    text = (ROOT / name).read_text(encoding="utf-8")
    header = re.sub(r"\A\s*/-.*?-/\s*", "", text, count=1, flags=re.S)
    if not header.startswith("module\n") or len(text.splitlines()) > 2000:
        raise SystemExit("Missing module header or oversized Lean source: " + name)
solution_text = (ROOT / "Solution.lean").read_text(encoding="utf-8")
if re.search(r"\b(sorry|admit|axiom|unsafe|native_decide)\b", solution_text):
    raise SystemExit("Forbidden proof admission or trust escape in Solution")
if report["sources"]["Challenge.lean"]["bytes"] > 30 * 1024:
    raise SystemExit("Challenge exceeds configured 30 KiB limit")
version = subprocess.check_output([str(lean), "--version"], env=env, text=True).strip()
if "version 4.35.0-rc2," not in version or "11acb17ec6b07a8f9e9173e6845197929540936b" not in version:
    raise SystemExit("Compiler does not match exact pin")
mathlib = next(p for p in manifest["packages"] if p["name"] == "mathlib")
if mathlib["rev"] != "065356127b1dc0016f66b7283ce0ce2c4055aa55":
    raise SystemExit("Mathlib manifest does not match exact pin")
report["lean_version"] = version
report["lean_binary_sha256"] = hashlib.sha256(lean.read_bytes()).hexdigest()
report["dependency_paths"] = list(map(str, dep_paths))

def run(stage, extra, cwd, environment):
    command = [str(lean), "-j1", "-M3072", *map(str, extra)]
    result = subprocess.run(command, cwd=cwd, env=environment, encoding="utf-8",
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=3600)
    report["stages"].append({"stage": stage, "argv": command, "cwd": str(cwd),
                             "LEAN_PATH": environment["LEAN_PATH"], "exit_code": result.returncode,
                             "output": result.stdout})
    print(result.stdout, end="", flush=True)
    if result.returncode:
        raise RuntimeError(stage + " failed")
    return result.stdout

try:
    with tempfile.TemporaryDirectory(prefix="boundary-bumping-check-") as temp:
        folder = Path(temp)
        run("fresh solution compilation", ["-DwarningAsError=true", "-o", folder / "Solution.olean",
            ROOT / "Solution.lean"], ROOT, env)
        canonical = "CanonicalChallenge_" + uuid.uuid4().hex
        (folder / (canonical + ".lean")).write_bytes((ROOT / "Challenge.lean").read_bytes())
        run("renamed dependency-only challenge", ["-o", canonical + ".olean", canonical + ".lean"],
            folder, env)
        project_env = dict(env)
        project_env["LEAN_PATH"] = str(folder) + os.pathsep + env["LEAN_PATH"]
        run("exact selected type comparison", ["--run", ROOT / "scripts/CompareTypes.lean", canonical],
            folder, project_env)
        names = ["BoundaryBumping.exists_clopen_between_component_and_open",
                 "BoundaryBumping.closed_component_meets_frontier",
                 "BoundaryBumping.exists_subcontinuum_meeting_frontier"]
        (folder / "AxiomAudit.lean").write_text("import Solution\n" +
            "\n".join("#print axioms " + name for name in names) + "\n", encoding="utf-8")
        output = run("transitive axiom audit", [folder / "AxiomAudit.lean"], folder, project_env)
        audits = re.findall(r"depends on axioms: \[([^\]]*)\]", output)
        if len(audits) != len(names):
            raise RuntimeError("Incomplete axiom audit")
        permitted = {"propext", "Classical.choice", "Quot.sound"}
        if any({item.strip() for item in a.split(",")} - permitted for a in audits):
            raise RuntimeError("Unexpected transitive axiom")
        report["status"] = "pass"
finally:
    report.setdefault("status", "fail")
    (ROOT / "verification.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
print("ALL LOCAL GATES PASS", flush=True)
