---- MODULE L13_StarveEach ----
\* A flips x while y = 0; B sets y to 1 (then nothing is enabled).
\* WF(A) /\ WF(B): B is enabled wherever y = 0, so it is taken. Holds.
\* EXPECT exit 0
EXTENDS Naturals
VARIABLES x, y
vars == <<x, y>>
Init == x = 0 /\ y = 0
A == y = 0 /\ x' = 1 - x /\ UNCHANGED y
B == y = 0 /\ y' = 1 /\ UNCHANGED x
Next == A \/ B
Live == <>(y = 1)
Spec == Init /\ [][Next]_vars /\ WF_vars(A) /\ WF_vars(B)
====
