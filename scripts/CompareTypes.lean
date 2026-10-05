/-
Copyright (c) 2026 Arthur Freitas Ramos, David Barros Hulak,
Ruy Jose Guerra Barretto de Queiroz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
module

public import Lean

/-! Compare the two selected declaration types in separately imported environments. -/

@[expose] public section

open Lean

def main (args : List String) : IO Unit := do
  let [challengeModule] := args | throw <| IO.userError "Expected renamed challenge module"
  initSearchPath (← findSysroot)
  let challenge ← importModules #[{ module := challengeModule.toName }] {}
  let solution ← importModules #[{ module := `Solution }] {}
  for name in #[`BoundaryBumping.closed_component_meets_frontier,
      `BoundaryBumping.exists_subcontinuum_meeting_frontier] do
    let some a := challenge.find? name | throw <| IO.userError s!"Missing challenge: {name}"
    let some b := solution.find? name | throw <| IO.userError s!"Missing solution: {name}"
    unless a.type == b.type do
      throw <| IO.userError s!"Declaration type differs: {name}"
    IO.println s!"EXACT TYPE MATCH {name}"
