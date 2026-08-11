---- MODULE S02_Subsets ----
\* S grows by one element of 1..3 per step (\E nondeterminism).
\* Hand count: every subset of 1..3 is reachable: 2^3 = 8 distinct states; the full set is
\* 3 steps away: depth 4. Generated: 1 + sum over subsets of (3 - |S|)
\*   = 1 + 1*3 + 3*2 + 3*1 + 1*0 = 13.
\* EXPECT exit 0
\* EXPECT distinct 8
\* EXPECT depth 4
\* EXPECT generated 13
EXTENDS Naturals
VARIABLE S
Init == S = {}
Next == \E e \in 1..3 : e \notin S /\ S' = S \cup {e}
====
