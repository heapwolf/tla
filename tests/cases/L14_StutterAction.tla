---- MODULE L14_StutterAction ----
\* Idle only leaves x unchanged: <<Idle>>_x is never enabled, so WF(Idle) requires nothing
\* and staying at 0 forever is fair. Inc (0 -> 1) has no fairness. <>(x = 1) fails: the
\* initial state, stuttering. (A checker treating x' = x as enabling Idle would think
\* WF(Idle) excludes that behavior and wrongly say it holds.)
\* EXPECT exit 13
\* EXPECT stutter
\* EXPECT trace 1
\* EXPECT values x 0
EXTENDS Naturals
VARIABLE x
Init == x = 0
Idle == x' = x
Inc == x = 0 /\ x' = 1
Next == Idle \/ Inc
Live == <>(x = 1)
Spec == Init /\ [][Next]_x /\ WF_x(Idle)
====
