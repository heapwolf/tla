---- MODULE S18_NoSymOrbits ----
\* S17 without SYMMETRY: 3^3 = 27 distinct, depth 7, generated 1 + 27 * 3 = 82.
\* EXPECT exit 0
\* EXPECT distinct 27
\* EXPECT depth 7
\* EXPECT generated 82
EXTENDS Naturals, TLC
CONSTANT P
VARIABLE f
Init == f = [p \in P |-> 0]
Next == \E p \in P : f' = [f EXCEPT ![p] = (@ + 1) % 3]
====
