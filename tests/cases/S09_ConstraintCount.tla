---- MODULE S09_ConstraintCount ----
\* x + 1 forever, CONSTRAINT x < 3: 0, 1, 2 are explored; 3 is found (and checked) but not
\* explored: 4 distinct, depth 4, generated 1 + 3 = 4. 3 isn't a deadlock: it's unexplored
\* (and has a successor anyway). Deadlock checking stays on.
\* EXPECT exit 0
\* EXPECT distinct 4
\* EXPECT depth 4
\* EXPECT generated 4
EXTENDS Naturals
VARIABLE x
Init == x = 0
Next == x' = x + 1
Small == x < 3
====
