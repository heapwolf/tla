---- MODULE R02_Lambda ----
\* LAMBDA (an operator as an argument) is outside the subset.
\* EXPECT exit 150
EXTENDS Naturals
VARIABLE x
Ap(F(_), v) == F(v)
Init == x = Ap(LAMBDA y : y + 1, 0)
Next == UNCHANGED x
====
