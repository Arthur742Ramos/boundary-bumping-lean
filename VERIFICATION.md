# Verification status

All local gates passed on the pinned toolchain. The machine-readable receipt is
`verification.json`, binding the checked sources to their SHA-256 hashes.

- Fresh Solution compilation, with warnings treated as errors.
- Renamed Challenge compilation in a fresh temporary working directory, with
  only external dependency paths and no repository oleans.
- Exact Lean expression equality of both selected declaration types in
  separately imported Challenge and Solution environments.
- Transitive axiom audits of both targets and the public clopen-neighborhood
  helper: only `propext`, `Classical.choice`, and `Quot.sound`.
- No Solution `sorry`, `admit`, authored `axiom`, `unsafe`, or `native_decide`.
- Solution: 115 lines, 4,992 bytes. Challenge: 39 lines, 1,382 bytes, well below
  the configured 30 KiB limit.

Each compiler stage ran serially with `-j1 -M3072`, inherited affinity to at
most two CPUs, and a 60 minute timeout. Challenge's two deliberate theorem
holes produce the expected warnings; they are absent from Solution.

All three Lean files use the module system, public imports, and an exposed
public section. Reversing only those module-system edits reproduces the
pre-port Lean source bytes exactly. The theorem statements and proof bodies
are unchanged.

`formalization-validation.json` records full official v0.4 Draft-7 schema
validation and acceptance by the unmodified current Palomar metadata loader.
It also records checks of source headers, source/Challenge sizes, canonical
Lake manifest spelling, public GitHub commit pins, and the Apache-2.0 license.
The Isabelle attribution note is retained. This is a local intake check, not
a full Lake build, actual Comparator/NanoDa run, or hosted acceptance.

The pinned Mathlib source search found no boundary-bumping declaration.
The exact Lean version and Mathlib commit were independently confirmed.
Dependency artifacts were copied into an owned workspace with complete module
artifact families, including `.ir.sig`; the source cache was never modified.

Independent AI source review found no mathematical or packaging blocker. It
independently checked the pinned Mathlib HEAD and scanned 8,536 source files,
confirmed maintainer spellings against prior metadata, and checked the
classical and prior Isabelle references. See REVIEW.md. Public publication, collaborator
access, hosted Comparator, and registry submission have not been performed.

Git initialization and a subsequent read-only status check succeeded. No Git
ownership exception or security setting was changed. The parent task handles
public publication and collaborator access.

A local commit was not created: the sandbox blocks writes to `.git/index`,
while the normal-user Git invocation rejects the sandbox-owned `.git` directory.
No ownership exception was added. The source bundle excludes `.git`; the parent
can extract it into a normal-user checkout for commit and publication.
