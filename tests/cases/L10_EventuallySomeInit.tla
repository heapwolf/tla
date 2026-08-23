---- MODULE L10_EventuallySomeInit ----
\* L09 with x \in {0, 1} initially: from 1 (no step) x = 0 never holds. Fails: the single
\* initial state 1, stuttering.
\* EXPECT exit 13
\* EXPECT stutter
\* EXPECT trace 1
\* EXPECT values x 1
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x \in {0, 1}
Next == x = 0 /\ x' = 1
Live == <>(x = 0)
Spec == Init /\ [][Next]_vars /\ WF_vars(Next)
====
