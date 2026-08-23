---- MODULE L08_Vacuous ----
\* x cycles 0..2; P (x = 7) is never reached: P ~> FALSE holds vacuously, without fairness.
\* EXPECT exit 0
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x' = (x + 1) % 3
Live == (x = 7) ~> FALSE
Spec == Init /\ [][Next]_vars
====
