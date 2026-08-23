---- MODULE L05_LateP ----
\* x climbs 0..5 and stops. P (x = 4) holds only late; Q is x = 5. No fairness: the
\* behavior can stutter at 4 forever, after P, never Q. Only 4 awaits Q (5 is Q), so the
\* counterexample is 0, 1, 2, 3, 4, stuttering.
\* EXPECT exit 13
\* EXPECT stutter
\* EXPECT trace 5
\* EXPECT values x 0 1 2 3 4
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x < 5 /\ x' = x + 1
Live == (x = 4) ~> (x = 5)
Spec == Init /\ [][Next]_vars
====
