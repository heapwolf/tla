---- MODULE L07_QBeforeP ----
\* L06 (WF(Next)) with Q == x = 1: Q holds once, before P (x = 4), never after.
\* Awaiting Q after P: {4, 5}. {4} alone is unfair (Next enabled, untaken); 5 has no step,
\* so stuttering there is fair. Counterexample: 0..5, then stuttering.
\* EXPECT exit 13
\* EXPECT stutter
\* EXPECT trace 6
\* EXPECT values x 0 1 2 3 4 5
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x < 5 /\ x' = x + 1
Live == (x = 4) ~> (x = 1)
Spec == Init /\ [][Next]_vars /\ WF_vars(Next)
====
