---- MODULE S01_Grid ----
\* Two counters, x in 0..2 and y in 0..1, each incremented separately.
\* Hand count: every pair (x, y) is reachable: 3 * 2 = 6 distinct states.
\* Depth: the farthest state (2, 1) is 3 steps from (0, 0): 4 states on its shortest path.
\* Generated: 1 initial + one per enabled step: x's in the 4 states with x < 2, y's in the
\* 3 with y = 0: 1 + 4 + 3 = 8. (2, 1) has no successor: CHECK_DEADLOCK FALSE.
\* EXPECT exit 0
\* EXPECT distinct 6
\* EXPECT depth 4
\* EXPECT generated 8
EXTENDS Naturals
VARIABLES x, y
Init == x = 0 /\ y = 0
Next == \/ x < 2 /\ x' = x + 1 /\ UNCHANGED y
        \/ y < 1 /\ y' = y + 1 /\ UNCHANGED x
====
