---- MODULE LR4_PropSimulate ----
\* PROPERTY with -simulate is refused: only exhaustive search checks liveness.
\* EXPECT args -simulate 10 -depth 10 -seed 1
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x' = (x + 1) % 3
Live == []<>(x = 2)
Spec == Init /\ [][Next]_vars /\ WF_vars(Next)
====
