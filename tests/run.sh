#!/bin/bash
# Runs each case in tests/cases against tla, then the differential test.
#   tests/run.sh                 (tla is $TLA, else build/tla, built if missing)
#   CASES='L*' tests/run.sh      only cases matching the glob; DIFF=0 skips differential.py
#   SEEDS='1 2 3' DIFFN=500      differential seeds, and cases per seed
# A case is Name.tla + Name.cfg; '\* EXPECT ...' lines in Name.tla give its expectations:
#   exit N | distinct N | generated N | depth N | trace N (states shown, not counting
#   stuttering) | loop [K] ("Back to state [K]:") | stutter ("State N: Stuttering") |
#   values VAR v1 v2 ... (VAR's values in the trace, in order) | has TEXT | lacks TEXT |
#   looplabel L (a loop step, counting the step back, is <L>) |
#   sfloop VAR V L (if a loop state has VAR = V, a loop step is <L>) |
#   args ARGS (extra arguments) | nocfg (run without -config).
here="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$here")"
if [ -z "$TLA" ]; then
    TLA="$root/build/tla"
    if [ ! -x "$TLA" ]; then
        (cd "$root" && aec build . --product tla) || { echo "FAIL build"; exit 1; }
    fi
fi
export TLA
shopt -s nullglob
# A lasso's loop: "label L" per step, "VAR = V" per state.
loop_of() {
    awk '/^Back to state [0-9]+:/ { k = $4 + 0; sub(/^[^<]*/, ""); back = $0 }
         /^State [0-9]+: </ { n = $2 + 0; l = $0; sub(/^[^<]*/, "", l); lab[n] = l }
         /^\/\\ / { v[n] = v[n] "\n" substr($0, 4) }
         END { if (!k) exit; for (i = k + 1; i <= n; i++) print "label " lab[i]; print "label " back
               for (i = k; i <= n; i++) printf "%s", v[i]; print "" }'
}
fails=0; total=0
for spec in "$here"/cases/${CASES:-*}.tla; do
    name="$(basename "$spec" .tla)"
    total=$((total + 1))
    args=(); cfgarg=(-config "$here/cases/$name.cfg")
    while IFS= read -r line; do
        set -- $line
        case "$1" in
            args) shift; args=("$@");;
            nocfg) cfgarg=();;
        esac
    done < <(sed -n 's/^\\\* EXPECT //p' "$spec")
    out="$("$TLA" "$spec" "${cfgarg[@]}" "${args[@]}" 2>&1)"; code=$?
    problems=""
    while IFS= read -r line; do
        set -f; set -- $line; set +f
        key="$1"; shift; rest="$*"
        case "$key" in
            exit) [ "$code" = "$1" ] || problems="$problems; exit $code, want $1";;
            distinct|generated)
                got="$(printf '%s\n' "$out" | sed -nE "s/^([0-9]+) states generated, ([0-9]+) distinct states found.*/\1 \2/p")"
                set -- $got
                if [ "$key" = distinct ]; then g="$2"; else g="$1"; fi
                want="$(printf '%s\n' "$line" | awk '{print $2}')"
                [ "$g" = "$want" ] || problems="$problems; $key ${g:-none}, want $want";;
            depth)
                g="$(printf '%s\n' "$out" | sed -nE 's/^The depth of the complete state graph search is ([0-9]+).*/\1/p')"
                [ "$g" = "$1" ] || problems="$problems; depth ${g:-none}, want $1";;
            trace)
                g="$(printf '%s\n' "$out" | grep -cE '^State [0-9]+: <')"
                [ "$g" = "$1" ] || problems="$problems; trace of $g states, want $1";;
            loop)
                if [ -n "$1" ]; then
                    printf '%s\n' "$out" | grep -qE "^Back to state $1:" || problems="$problems; no 'Back to state $1'"
                else
                    printf '%s\n' "$out" | grep -qE '^Back to state [0-9]+:' || problems="$problems; no loop"
                fi
                printf '%s\n' "$out" | grep -q 'Stuttering' && problems="$problems; stuttering, want a loop";;
