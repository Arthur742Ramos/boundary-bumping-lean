# Boundary bumping in Lean

Every connected component of a proper closed subset of a compact connected
Hausdorff space meets the boundary of that subset. This small repository proves
that classical theorem and one consequence: through every point of the closed
subset there is a compact connected subset meeting its boundary.

The statements use Mathlib's ordinary `connectedComponentIn`, `frontier`,
`IsCompact`, and `IsConnected`. No metrizability, local connectedness, or algebraic
topology infrastructure is assumed.

## Theorems

`BoundaryBumping.closed_component_meets_frontier` proves
`(connectedComponentIn F x ∩ frontier F).Nonempty` when `F` is closed and proper
and `x ∈ F`, in a compact connected Hausdorff space.

`BoundaryBumping.exists_subcontinuum_meeting_frontier` produces a set `K` with
`IsCompact K`, `IsConnected K`, `x ∈ K`, `K ⊆ F`, and
`(K ∩ frontier F).Nonempty`. The witness is the component itself.

The additional helper `exists_clopen_between_component_and_open` says that an
open neighborhood of a component in a compact Hausdorff space contains a clopen
neighborhood of that whole component.

## Build

Install Lean's `elan`, then run:

```sh
lake update
lake exe cache get
python scripts/verify.py
```

The pins are Lean `v4.35.0-rc2` (compiler commit
`11acb17ec6b07a8f9e9173e6845197929540936b`) and Mathlib
`065356127b1dc0016f66b7283ce0ce2c4055aa55`.
Verification uses one compiler, at most two CPUs, a 3 GiB Lean memory cap, and a
60 minute timeout for each stage.

`Solution.lean` contains the complete proofs and imports only Mathlib.
`Challenge.lean` has the same two selected statements with deliberate theorem
holes and imports only Mathlib. The challenge can be renamed and elaborated
without this repository's compiled artifacts. `comparator.json` selects only
these two declarations. Local checks do not imply hosted Comparator acceptance
or registry submission.

## Credits and review

Maintainers: Arthur Freitas Ramos, David Barros Hulak, and Ruy Jose Guerra
Barretto de Queiroz. The spelling is preserved from existing project metadata.

This is a formalization of classical topology, with AI-assisted proof construction.
It does not claim mathematical novelty or priority across proof assistants.
See [PROVENANCE.md](PROVENANCE.md) for sources, including an earlier Isabelle
formalization, and [VERIFICATION.md](VERIFICATION.md) for the current checks and
remaining review status. Licensed under Apache 2.0.

All three Lean source files use Lean's module system. Metadata was checked
against the complete [official v0.4 schema](https://github.com/mathlib-initiative/formalization.yaml/blob/99c678e569c7c4c0772db297c5ddd5e4c9b6322e/schema/v0.4.schema.json)
and the current [Palomar metadata contract](https://github.com/PalomarRegistry/PalomarSubmission/blob/d4e41c1d5b0d114c4859e6e5831dc6d3ad1d0d44/scripts/submission_contract.py).
The local receipt is `formalization-validation.json`.
