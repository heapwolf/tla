---- MODULE R11_NoCfg ----
\* No R11_NoCfg.cfg (the runner passes only the spec): unreadable, exit 150.
\* EXPECT nocfg
\* EXPECT exit 150
VARIABLE x
Init == x = 0
Next == UNCHANGED x
====
