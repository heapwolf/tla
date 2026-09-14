---- MODULE L18_LassoSFStep ----
\* A: 0 -> 1, 0 -> 2, 1 -> 0, 2 -> 1; G: 2 -> 0 only (enabled only at 2), SF(G).
\* []<>(x = 9) fails: e.g. 0 -> 2 -> 0 -> 2 ... takes G infinitely often. A counterexample
\* loop is either 0 <-> 1 (never at 2: G disabled throughout, fair) or passes 2, so G is
\* enabled infinitely often and must be taken: a loop through 2 with only A steps is unfair.
\* Checked ('sfloop x 2 G'): if a loop state has x = 2, a loop step is <G>.
\* EXPECT exit 13
\* EXPECT loop
\* EXPECT sfloop x 2 G
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
A == \/ x = 0 /\ x' = 1
     \/ x = 0 /\ x' = 2
     \/ x = 1 /\ x' = 0
     \/ x = 2 /\ x' = 1
G == x = 2 /\ x' = 0
Next == A \/ G
Live == []<>(x = 9)
Spec == Init /\ [][Next]_vars /\ SF_vars(G)
====
