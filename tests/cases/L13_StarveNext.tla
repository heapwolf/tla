---- MODULE L13_StarveNext ----
\* A flips x while y = 0; B sets y to 1 (then nothing is enabled).
\* WF(Next): doing A forever, (0,0) -> (1,0) -> (0,0) ..., takes Next steps (WF(Next) met)
\* and starves B (enabled throughout): <>(y = 1) fails by that loop.
\* EXPECT exit 13
\* EXPECT loop
\* EXPECT lacks y = 1
EXTENDS Naturals
VARIABLES x, y
vars == <<x, y>>
Init == x = 0 /\ y = 0
A == y = 0 /\ x' = 1 - x /\ UNCHANGED y
B == y = 0 /\ y' = 1 /\ UNCHANGED x
Next == A \/ B
Live == <>(y = 1)
Spec == Init /\ [][Next]_vars /\ WF_vars(Next)
====
