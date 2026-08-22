---- MODULE L01_CycleWF ----
\* x cycles 0 -> 1 -> 2 -> 0. Next is always enabled, so WF(Next) forces infinitely many
\* Next steps; every 3 consecutive ones pass 2: []<>(x = 2) holds.
\* EXPECT exit 0
\* EXPECT distinct 3
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x' = (x + 1) % 3
Live == []<>(x = 2)
Spec == Init /\ [][Next]_vars /\ WF_vars(Next)
====
