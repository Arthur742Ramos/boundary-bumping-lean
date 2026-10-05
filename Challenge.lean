/-
Copyright (c) 2026 Arthur Freitas Ramos, David Barros Hulak,
Ruy Jose Guerra Barretto de Queiroz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Arthur Freitas Ramos, David Barros Hulak, Ruy Jose Guerra Barretto de Queiroz
-/
module

public import Mathlib.Topology.Separation.Regular

/-!
# Boundary bumping: independent challenge statements

Two deliberate theorem holes. The complete proofs are in Solution.lean.
This module imports only Mathlib and can be renamed and compiled in isolation.
-/

@[expose] public section

open Set

namespace BoundaryBumping

variable {X : Type*} [TopologicalSpace X]

/-- Every component of a proper closed subset of a continuum meets its frontier. -/
theorem closed_component_meets_frontier [CompactSpace X] [T2Space X] [ConnectedSpace X]
    {F : Set X} (hF : IsClosed F) (hproper : F ≠ univ) {x : X} (hx : x ∈ F) :
    (connectedComponentIn F x ∩ frontier F).Nonempty := by
  sorry

/-- A subcontinuum through each point of the closed set meets its frontier. -/
theorem exists_subcontinuum_meeting_frontier [CompactSpace X] [T2Space X] [ConnectedSpace X]
    {F : Set X} (hF : IsClosed F) (hproper : F ≠ univ) {x : X} (hx : x ∈ F) :
    ∃ K : Set X, IsCompact K ∧ IsConnected K ∧ x ∈ K ∧ K ⊆ F ∧
      (K ∩ frontier F).Nonempty := by
  sorry

end BoundaryBumping
