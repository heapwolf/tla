---- MODULE L09_EventuallyInit ----
\* <>(x = 0) with x = 0 initially holds at once, without fairness (the behavior may then
\* go to 1 and stutter forever: <> needs Q once, from the initial states).
\* EXPECT exit 0
EXTENDS Naturals
VARIABLE x
vars == <<x>>
Init == x = 0
Next == x = 0 /\ x' = 1
Live == <>(x = 0)
Spec == Init /\ [][Next]_vars
====
