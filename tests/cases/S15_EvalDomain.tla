---- MODULE S15_EvalDomain ----
\* f is defined on 1..2; the invariant applies it to x + 1, which is 3 at x = 2.
\* EXPECT exit 75
EXTENDS Naturals
VARIABLE x
f == [i \in 1..2 |-> i * 10]
Init == x = 0
Next == x < 2 /\ x' = x + 1
Inv == x = 0 \/ f[x + 1] > 0
====
