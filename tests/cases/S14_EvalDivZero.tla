---- MODULE S14_EvalDivZero ----
\* 0 -> 1 -> 2 by the first disjunct; at x = 2 the second's guard holds and its
\* x' = 6 \div (2 - x) divides by zero: evaluation error, exit 75.
\* EXPECT exit 75
EXTENDS Integers
VARIABLE x
Init == x = 0
Next == \/ x < 2 /\ x' = x + 1
        \/ x = 2 /\ x' = 6 \div (2 - x)
====
