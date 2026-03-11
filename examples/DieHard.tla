---------------------------- MODULE DieHard ----------------------------
\* Die Hard 3 water jugs: 3 and 5 gallon jugs; measure 4 gallons.
\* NotSolved fails; TLC's shortest counterexample has 7 states.
EXTENDS Naturals

VARIABLES small, big

TypeOK == /\ small \in 0..3
          /\ big   \in 0..5

Init == /\ big = 0
        /\ small = 0

FillSmall == /\ small' = 3
             /\ big' = big

FillBig == /\ big' = 5
           /\ small' = small

EmptySmall == /\ small' = 0
              /\ big' = big

EmptyBig == /\ big' = 0
            /\ small' = small

Min(m,n) == IF m < n THEN m ELSE n

SmallToBig == /\ big'   = Min(big + small, 5)
              /\ small' = small - (big' - big)

BigToSmall == /\ small' = Min(big + small, 3)
              /\ big'   = big - (small' - small)

Next == \/ FillSmall
        \/ FillBig
        \/ EmptySmall
        \/ EmptyBig
        \/ SmallToBig
        \/ BigToSmall

NotSolved == big /= 4
=============================================================================
