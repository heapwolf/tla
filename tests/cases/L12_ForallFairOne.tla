---- MODULE L12_ForallFairOne ----
\* Three flags; Set(p) sets flag p. Goal: all set.
\* \A p \in {1} : WF(Set(p)): only Set(1) is fair. Once f[1] is set, no step is required:
\* stuttering with f[2] or f[3] unset is fair. Fails, stuttering.
\* EXPECT exit 13
\* EXPECT stutter
EXTENDS Naturals
CONSTANT P
VARIABLE f
vars == <<f>>
Init == f = [p \in P |-> FALSE]
Set(p) == f[p] = FALSE /\ f' = [f EXCEPT ![p] = TRUE]
Next == \E p \in P : Set(p)
Live == <>(\A p \in P : f[p])
Spec == Init /\ [][Next]_vars /\ \A p \in {1} : WF_vars(Set(p))
====
