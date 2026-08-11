---- MODULE S04_MultiInitTrace ----
\* S03 with invariant x /= 4. The shortest behavior to x = 4 starts at initial state 3:
\* 3 -> 4, 2 states (from 0: 5).
\* EXPECT exit 12
\* EXPECT has Invariant NotFour is violated
\* EXPECT trace 2
\* EXPECT values x 3 4
EXTENDS Naturals
VARIABLE x
Init == x \in {0, 3}
Next == x < 4 /\ x' = x + 1
NotFour == x /= 4
====
