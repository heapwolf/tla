---- MODULE S19_SymSubsets ----
\* S02 over three model values with SYMMETRY: subsets merge by size into 4 orbits
\* ({}, one, two, all), depth 4, generated 1 + 3 + 2 + 1 = 7 (one explored state per orbit).
\* EXPECT exit 0
\* EXPECT distinct 4
\* EXPECT depth 4
\* EXPECT generated 7
EXTENDS Naturals, TLC
CONSTANT E
VARIABLE S
Init == S = {}
Next == \E e \in E : e \notin S /\ S' = S \cup {e}
Sym == Permutations(E)
====
