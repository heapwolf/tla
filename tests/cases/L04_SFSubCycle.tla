---- MODULE L04_SFSubCycle ----
\* M moves 0 <-> 1 <-> 2; G goes 2 -> 3 (the goal), enabled only at 2. WF(M), SF(G).
\* States awaiting x = 3: {0, 1, 2}, strongly connected; G is enabled in it (at 2) but never
\* taken, so it is unfair. But the subcycle 0 <-> 1 avoids 2: M is taken (WF(M) met), G is
\* disabled throughout (SF(G) met). So 0, 1, 0, 1, ... is fair and never reaches 3:
\* <>(x = 3) FAILS by a loop never visiting 2 (nor is 2 on the way: the behavior starts at 0).
\* EXPECT exit 13
\* EXPECT loop
\* EXPECT lacks x = 2
\* EXPECT lacks x = 3
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
M == \/ x = 0 /\ x' = 1
     \/ x = 1 /\ x' = 0
     \/ x = 1 /\ x' = 2
     \/ x = 2 /\ x' = 1
G == x = 2 /\ x' = 3
Next == M \/ G
Live == <>(x = 3)
Spec == Init /\ [][Next]_vars /\ WF_vars(M) /\ SF_vars(G)
====
