---- MODULE S03_MultiInit ----
\* Two initial states, 0 and 3; x climbs to 4.
\* Reachable: 0..4, 5 distinct. Shortest distances: 0:0 1:1 2:2 3:0 4:1, so depth 2 + 1 = 3
\* (5 if only 0 were initial). Generated: 2 initial + one successor from each of 0..3 = 6.
\* EXPECT exit 0
\* EXPECT distinct 5
\* EXPECT depth 3
\* EXPECT generated 6
EXTENDS Naturals
VARIABLE x
Init == x \in {0, 3}
Next == x < 4 /\ x' = x + 1
====
