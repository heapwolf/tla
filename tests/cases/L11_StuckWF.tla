---- MODULE L11_StuckWF ----
\* A: 0 -> 1, C: 1 -> 0, B: 1 -> 2; 2 has no step. WF on all three. []<>(x = 0):
\* awaiting 0: {1, 2}. {1} is unfair (B and C enabled, untaken). {2}: nothing is enabled, so
\* stuttering there meets every WF: fails by 0, 1, 2, stuttering.
\* EXPECT exit 13
\* EXPECT stutter
\* EXPECT trace 3
\* EXPECT values x 0 1 2
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
A == x = 0 /\ x' = 1
B == x = 1 /\ x' = 2
C == x = 1 /\ x' = 0
Next == A \/ B \/ C
Live == []<>(x = 0)
Spec == Init /\ [][Next]_vars /\ WF_vars(A) /\ WF_vars(B) /\ WF_vars(C)
====
