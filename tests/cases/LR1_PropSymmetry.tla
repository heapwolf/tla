---- MODULE LR1_PropSymmetry ----
\* PROPERTY with SYMMETRY is refused (fairness isn't symmetric in general).
\* EXPECT exit 150
EXTENDS Naturals, TLC
CONSTANT P
VARIABLE S
vars == <<S>>
Init == S = {}
Next == \E e \in P : e \notin S /\ S' = S \cup {e}
Live == <>(S = P)
Spec == Init /\ [][Next]_vars /\ WF_vars(Next)
Sym == Permutations(P)
====
