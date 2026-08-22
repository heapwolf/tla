---- MODULE L02_CycleNoFair ----
\* L01 without fairness: stuttering at x = 0 forever is allowed and never reaches 2. Only
\* stuttering (at 0 or 1) shows it: no cycle avoids 2.
\* EXPECT exit 13
\* EXPECT has Error: Live:
\* EXPECT stutter
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x' = (x + 1) % 3
Live == []<>(x = 2)
Spec == Init /\ [][Next]_vars
====
