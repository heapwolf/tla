# tla: a model checker for a subset of TLA+, in Aela

tla checks every reachable state of a TLA+ spec, as TLC does, without Java: safety
invariants, and liveness properties under the SPECIFICATION's fairness. A spec is a TLA+
module plus a cfg in TLC's format; SANY and TLC read both unchanged. It began in aedb for
aedb's protocols (aedb's spec/) and is now standalone, used by models of the Aela runtime
(aela's docs/proposals/VERIFIED_RUNTIME.md), aedb, api (api/spec), and others.

```sh
aec build . --product tla               # or: aec src/main.ae -o tla
tla examples/TwoPhase.tla               # uses examples/TwoPhase.cfg; checks every state
tla Spec.tla -config Live.cfg           # another cfg, e.g. one with a PROPERTY
tla Spec.tla -simulate 10000 -depth 60 -seed 7   # random behaviors
aec test src                            # in-code tests: the examples, TLC's counts
tests/run.sh                            # test suite (tests/README.md)
```
