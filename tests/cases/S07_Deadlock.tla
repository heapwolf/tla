---- MODULE S07_Deadlock ----
\* x goes 0, 1, 2, then nothing is enabled: deadlock at 2, trace 0, 1, 2.
\* EXPECT exit 11
\* EXPECT has Deadlock reached
\* EXPECT trace 3
\* EXPECT values x 0 1 2
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == x < 2 /\ x' = x + 1
====
