---- MODULE L16_SFHolds ----
\* L04 without the 0 <-> 1 cycle: M is 0 -> 1, 1 -> 2, 2 -> 1; G 2 -> 3. WF(M), SF(G).
\* Awaiting: {0, 1, 2}. Candidate sets: {0} or {1} alone: M enabled, untaken (WF fails).
\* {1, 2}: G enabled at 2, never taken (SF fails); without 2: {1}, unfair. {2}: M and G
\* enabled, untaken. So no fair behavior avoids 3: holds.
\* EXPECT exit 0
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
M == \/ x = 0 /\ x' = 1
     \/ x = 1 /\ x' = 2
     \/ x = 2 /\ x' = 1
G == x = 2 /\ x' = 3
Next == M \/ G
Live == <>(x = 3)
Spec == Init /\ [][Next]_vars /\ WF_vars(M) /\ SF_vars(G)
====
