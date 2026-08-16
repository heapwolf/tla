---- MODULE R04_RecFun ----
\* A recursive function definition is outside the subset.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
fact[n \in 0..3] == IF n = 0 THEN 1 ELSE n * fact[n - 1]
Init == x = fact[3]
Next == UNCHANGED x
====
