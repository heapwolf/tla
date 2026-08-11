---- MODULE S05_ShortcutBFS ----
\* The first disjunct walks 0, 1, 2, 3, 4, 5; the second jumps 0 -> 5. DFS trying disjuncts
\* in order finds 5 after 6 states; the shortest behavior is 0, 5.
\* EXPECT exit 12
\* EXPECT has Invariant NotFive is violated
\* EXPECT trace 2
\* EXPECT values x 0 5
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == \/ x < 5 /\ x' = x + 1
        \/ x = 0 /\ x' = 5
NotFive == x /= 5
====
