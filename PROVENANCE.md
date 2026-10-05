# Sources and scope

The classical closed-subset Boundary Bumping Theorem is formalized for compact
connected Hausdorff spaces, with no metric assumption. The accompanying
subcontinuum-through-point result takes the connected component as its witness.

Richard N. Ball, James N. Hagler, and Nicholas Ormes, *Quotients of Bing Spaces*,
[Lemma 1.10](https://cs.du.edu/~mathfiles/preprints/nsm-math-preprint-0609.pdf),
records the clopen-neighborhood lemma and boundary bumping. The paper's compact
spaces are Hausdorff. PDF text extraction loses some closure bars; the precise
closed-subset target here is also explicitly recorded in Isabelle below.

Isabelle/HOL already proves
[`boundary_bumping_theorem_closed`](https://isa-afp.org/browser_info/current/HOL/HOL-Analysis/Abstract_Topological_Spaces.html)
in `Abstract_Topological_Spaces`. That statement assumes compactness,
connectedness, Hausdorffness, and a proper closed subset. This repository makes
no claim to the first formalization of the theorem.

The proof builds on Johannes Hölzl and Mario Carneiro's Mathlib separation and
connectedness infrastructure, especially
[`connectedComponent_eq_iInter_isClopen`](https://github.com/leanprover-community/mathlib4/blob/065356127b1dc0016f66b7283ce0ce2c4055aa55/Mathlib/Topology/Separation/Regular.lean#L756).
Finite compactness reduces an intersection of clopen neighborhoods to a finite
intersection. A component avoiding the frontier lies inside the closed set's
interior. A relatively clopen neighborhood there has an ambient clopen image,
contradicting connectedness and properness.

The relative-clopen image argument is informed by Mathlib's
[`Topology/Separation/Profinite.lean`, lines 92–113](https://github.com/leanprover-community/mathlib4/blob/065356127b1dc0016f66b7283ce0ce2c4055aa55/Mathlib/Topology/Separation/Profinite.lean#L92).
Here it is proved directly using the induced topology, without importing or
assuming total disconnectedness.

An independent local scan of all pinned Mathlib `.lean` sources found no
`boundary_bumping` or `boundaryBumping` declaration and no line combining
`connectedComponent` with `frontier`. Current upstream connectedness/clopen and
regular separation sources were also inspected on 2026-10-05. This records a
limited source search, not an exhaustive worldwide novelty claim.

Human direction selected the target, scope, and packaging constraints. Proofs
and verification scripts were constructed with AI assistance. No endorsement
by the cited authors or human proof review is claimed.
