---- MODULE L06_LatePWF ----
\* L05 with WF(Next): at 4, Next stays enabled until taken, reaching 5. Holds.
\* EXPECT exit 0
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x < 5 /\ x' = x + 1
Live == (x = 4) ~> (x = 5)
Spec == Init /\ [][Next]_vars /\ WF_vars(Next)
====
