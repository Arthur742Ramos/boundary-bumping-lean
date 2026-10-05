/-
Copyright (c) 2026 Arthur Freitas Ramos, David Barros Hulak,
Ruy Jose Guerra Barretto de Queiroz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Arthur Freitas Ramos, David Barros Hulak, Ruy Jose Guerra Barretto de Queiroz
-/
module

public import Mathlib.Topology.Separation.Regular

/-!
# Boundary bumping for closed subsets of a continuum

Every component of a proper closed subset of a compact connected Hausdorff
space meets its frontier. The component itself gives a compact connected
subset through any specified point, meeting that frontier.

The proof uses Mathlib's compact Hausdorff component/quasicomponent theorem.
See PROVENANCE.md for classical references and the prior Isabelle formalization.
-/

@[expose] public section

open Set

namespace BoundaryBumping

variable {X : Type*} [TopologicalSpace X]

/-- An open neighborhood of a component in a compact Hausdorff space contains
a clopen neighborhood of the whole component. -/
theorem exists_clopen_between_component_and_open [CompactSpace X] [T2Space X]
    (x : X) {U : Set X} (hU : IsOpen U) (hCU : connectedComponent x ⊆ U) :
    ∃ V : Set X, IsClopen V ∧ connectedComponent x ⊆ V ∧ V ⊆ U := by
  classical
  let N := {s : Set X // IsClopen s ∧ x ∈ s}
  have hdisj : Disjoint Uᶜ (⋂ s : N, (s : Set X)) := by
    rw [← connectedComponent_eq_iInter_isClopen x]
    exact disjoint_compl_left_iff_subset.mpr hCU
  obtain ⟨a, ha⟩ := hU.isClosed_compl.isCompact.elim_finite_subfamily_closed
    (fun s : N => (s : Set X)) (fun s => s.2.1.1) hdisj
  let V : Set X := ⋂ s ∈ a, (s : Set X)
  have hV : IsClopen V := isClopen_biInter_finset fun s _ => s.2.1
  have hxV : x ∈ V := mem_iInter₂.mpr fun s _ => s.2.2
  exact ⟨V, hV, hV.connectedComponent_subset hxV,
    disjoint_compl_left_iff_subset.mp ha⟩

/-- A relatively clopen subset of a closed set, contained in its interior,
has clopen image in the ambient space. -/
private theorem clopen_image_of_subset_interior {F : Set X} (hF : IsClosed F)
    {V : Set F} (hV : IsClopen V)
    (hVF : Subtype.val '' V ⊆ interior F) : IsClopen (Subtype.val '' V) := by
  refine ⟨hF.isClosedEmbedding_subtypeVal.isClosed_iff_image_isClosed.mp hV.1, ?_⟩
  obtain ⟨O, hO, hpre⟩ := isOpen_induced_iff.mp hV.2
  have hOV : Subtype.val '' V = O ∩ F := by
    rw [← hpre, Subtype.image_preimage_coe, inter_comm]
  have hEq : Subtype.val '' V = O ∩ interior F := by
    apply Subset.antisymm
    · intro y hy
      exact ⟨(hOV ▸ hy).1, hVF hy⟩
    · intro y hy
      rw [hOV]
      exact ⟨hy.1, interior_subset hy.2⟩
  rw [hEq]
  exact hO.inter isOpen_interior

/-- **Boundary Bumping Theorem**, closed-subset version: every component of a
proper closed subset of a compact connected Hausdorff space meets its frontier. -/
theorem closed_component_meets_frontier [CompactSpace X] [T2Space X] [ConnectedSpace X]
    {F : Set X} (hF : IsClosed F) (hproper : F ≠ univ) {x : X} (hx : x ∈ F) :
    (connectedComponentIn F x ∩ frontier F).Nonempty := by
  classical
  by_contra hmiss
  have hCI : connectedComponentIn F x ⊆ interior F := by
    intro y hy
    by_contra hyI
    apply hmiss
    exact ⟨y, hy, by
      rw [frontier, hF.closure_eq]
      exact ⟨connectedComponentIn_subset F x hy, hyI⟩⟩
  have : CompactSpace F := isCompact_iff_compactSpace.mp hF.isCompact
  let p : F := ⟨x, hx⟩
  obtain ⟨V, hV, hCV, hVI⟩ := exists_clopen_between_component_and_open p
    (isOpen_interior.preimage continuous_subtype_val) (by
      intro y hy
      exact hCI (by rw [connectedComponentIn_eq_image hx]; exact ⟨y, hy, rfl⟩))
  have hImage : IsClopen (Subtype.val '' V : Set X) :=
    clopen_image_of_subset_interior hF hV (by
      rintro _ ⟨y, hy, rfl⟩
      exact hVI hy)
  have hxImage : x ∈ (Subtype.val '' V : Set X) :=
    ⟨p, hCV mem_connectedComponent, rfl⟩
  apply hproper
  apply Subset.antisymm (subset_univ F)
  intro y _
  have hy : y ∈ (Subtype.val '' V : Set X) := by
    rw [hImage.eq_univ ⟨x, hxImage⟩]
    trivial
  rcases hy with ⟨z, _, rfl⟩
  exact z.2

/-- A proper closed subset of a continuum contains, through each of its points,
a compact connected subset that meets the frontier of the closed subset. -/
theorem exists_subcontinuum_meeting_frontier [CompactSpace X] [T2Space X] [ConnectedSpace X]
    {F : Set X} (hF : IsClosed F) (hproper : F ≠ univ) {x : X} (hx : x ∈ F) :
    ∃ K : Set X, IsCompact K ∧ IsConnected K ∧ x ∈ K ∧ K ⊆ F ∧
      (K ∩ frontier F).Nonempty := by
  have : CompactSpace F := isCompact_iff_compactSpace.mp hF.isCompact
  refine ⟨connectedComponentIn F x, ?_, isConnected_connectedComponentIn_iff.mpr hx,
    mem_connectedComponentIn hx, connectedComponentIn_subset F x,
    closed_component_meets_frontier hF hproper hx⟩
  rw [connectedComponentIn_eq_image hx]
  exact isClosed_connectedComponent.isCompact.image continuous_subtype_val

end BoundaryBumping
