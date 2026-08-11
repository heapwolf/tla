---- MODULE S06_Doubling ----
\* x + 1 or 2 * x (x in 1..5). Breadth first, by steps: {0}, {1}, {2}, {3, 4}, {4, 5, 6, 8}.
\* 6 first appears at 4 steps, only as 3 * 2, and 3 only as 2 + 1: the unique shortest
\* behavior is 0, 1, 2, 3, 6 (5 states). Increment-first DFS would give 0..6 (7 states).
\* EXPECT exit 12
\* EXPECT has Invariant NotSix is violated
\* EXPECT trace 5
\* EXPECT values x 0 1 2 3 6
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == \/ x < 6 /\ x' = x + 1
        \/ x > 0 /\ x < 6 /\ x' = 2 * x
NotSix == x /= 6
====
