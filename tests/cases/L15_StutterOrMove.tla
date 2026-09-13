---- MODULE L15_StutterOrMove ----
\* Act can stay (x' = x) or move 0 -> 1. Only the move is an <<Act>>_x step, so <<Act>>_x is
\* enabled at 0: WF(Act) forbids staying at 0 forever. <>(x = 1) holds.
\* (Counting the stay as an Act step would let 0 stutter forever: wrongly fail.)
\* EXPECT exit 0
EXTENDS Naturals
VARIABLE x
Init == x = 0
Act == x = 0 /\ (x' = x \/ x' = 1)
Next == Act
Live == <>(x = 1)
Spec == Init /\ [][Next]_x /\ WF_x(Act)
====
