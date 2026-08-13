---- MODULE S17_SymOrbits ----
\* Three processes (model values), each a counter mod 3; any one steps at a time.
\* All 27 f in [P -> 0..2] are reachable. Under permutations of P, an orbit is a multiset of
\* 3 values from {0, 1, 2}: C(3 + 2, 3) = 10 orbits.
\* Depth: counters only go up mod 3, so <<2,2,2>> needs 6 steps (its orbit is itself): 7.
\* Generated: 1 + 10 explored states * 3 successors = 31.
\* EXPECT exit 0
\* EXPECT distinct 10
\* EXPECT depth 7
\* EXPECT generated 31
EXTENDS Naturals, TLC
CONSTANT P
VARIABLE f
Init == f = [p \in P |-> 0]
Next == \E p \in P : f' = [f EXCEPT ![p] = (@ + 1) % 3]
Sym == Permutations(P)
====
