---- MODULE L12_ForallFairAll ----
\* Three flags; Set(p) sets flag p. Goal: all set.
\* \A p \in P : WF(Set(p)): each Set(p) stays enabled until taken, so all get set. Holds.
\* EXPECT exit 0
EXTENDS Naturals
CONSTANT P
VARIABLE f
vars == <<f>>
Init == f = [p \in P |-> FALSE]
Set(p) == f[p] = FALSE /\ f' = [f EXCEPT ![p] = TRUE]
Next == \E p \in P : Set(p)
Live == <>(\A p \in P : f[p])
Spec == Init /\ [][Next]_vars /\ \A p \in P : WF_vars(Set(p))
====
