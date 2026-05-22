---------------------------- MODULE TwoPhaseSym ----------------------------
\* TwoPhase with interchangeable resource managers: a SYMMETRY check.
EXTENDS TwoPhase, TLC

Perms == Permutations(RM)
=============================================================================
