#!/bin/bash
# Mutation test of the harness: run.sh against a broken tla, one perturbation at a time;
# each must make run.sh fail. tla is untouched: a wrapper (TLA=wrapper) runs the real
# build/tla and perturbs its output and exit code.
#   tests/mutants.sh [mutant ...]       (default: all); DIFFN cases per differential seed
here="$(cd "$(dirname "$0")" && pwd)"
real="${TLA:-$here/../build/tla}"
[ -x "$real" ] || (cd "$here/.." && aec build . --product tla) || exit 1
tmp="$(mktemp -d /tmp/tla-mutants.XXXXXX)"
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/perturb.py" <<'PY'
import re, sys
mutant, code, out_path, live = sys.argv[1], int(sys.argv[2]), sys.argv[3], sys.argv[4] == "1"
lines = open(out_path).read().split("\n")
trace = [i for i, l in enumerate(lines) if l.startswith("/\\ ")]
def bump(i):                                   # change one value of a state: n -> n + 1
    lines[i] = re.sub(r"(-?\d+)$", lambda m: str(int(m.group(1)) + 1), lines[i]) \
        if re.search(r"\d+$", lines[i]) else lines[i] + "_x"
if mutant == "flip-live" and live:             # property verdicts flipped: 0 <-> 13
    code = {0: 13, 13: 0}.get(code, code)
elif mutant == "flip-safety" and not live:     # invariant verdicts flipped: 0 <-> 12
    code = {0: 12, 12: 0}.get(code, code)
elif mutant == "drop-back":                    # a lasso's "Back to state" line dropped
    lines = [l for l in lines if not l.startswith("Back to state")]
elif mutant == "back-off":                     # loop goes back to the wrong state
    lines = [re.sub(r"^Back to state (\d+):", lambda m: f"Back to state {int(m.group(1)) % 9 + 1}:", l) for l in lines]
elif mutant == "stutter-as-loop":              # stuttering shown as a loop to state 1
    lines = [re.sub(r"^State \d+: Stuttering$", "Back to state 1: <Next>", l) for l in lines]
elif mutant == "state-last" and trace:         # last trace state changed
    bump(trace[-1])
elif mutant == "state-first" and trace:        # first trace state changed
    bump(trace[0])
elif mutant == "drop-state":                   # last trace state dropped
    heads = [i for i, l in enumerate(lines) if re.match(r"State \d+: <", l)]
    if len(heads) > 1:
        j = heads[-1]
        k = j + 1
        while k < len(lines) and lines[k].startswith("/\\ "):
            k += 1
        del lines[j:k + 1]
elif mutant == "distinct":                     # one distinct state too many
    lines = [re.sub(r"(\d+) distinct states", lambda m: f"{int(m.group(1)) + 1} distinct states", l) for l in lines]
elif mutant == "depth":                        # depth off by one
    lines = [re.sub(r"search is (\d+)", lambda m: f"search is {int(m.group(1)) - 1}", l) for l in lines]
elif mutant == "liveness-off" and live and code in (0, 13):   # liveness unchecked: "holds"
    code = 0
    lines = ["Model checking completed. No error has been found."] + [l for l in lines if re.search(r"states generated|fingerprints|depth of", l)]
sys.stdout.write("\n".join(lines))
sys.exit(code)
PY
cat > "$tmp/tla" <<SH
#!/bin/bash
spec="\$1"; cfg="\${spec%.tla}.cfg"
args=("\$@")
for ((i = 0; i < \${#args[@]}; i++)); do [ "\${args[i]}" = -config ] && cfg="\${args[i+1]}"; done
live=0; grep -q '^PROPERTY' "\$cfg" 2>/dev/null && live=1
"$real" "\$@" > "$tmp/out.\$\$" 2>&1; code=\$?
python3 -I -B "$tmp/perturb.py" "\$MUTANT" "\$code" "$tmp/out.\$\$" "\$live"; c=\$?
rm -f "$tmp/out.\$\$"; exit \$c
SH
chmod +x "$tmp/tla"
mutants=("$@")
[ ${#mutants[@]} = 0 ] && mutants=(flip-live flip-safety drop-back back-off stutter-as-loop state-last state-first drop-state distinct depth liveness-off)
missed=0
# Baseline: what fails under the unperturbed wrapper (tla's own bugs). A mutant is caught
# when a case or differential seed fails that passes in the baseline.
run() { MUTANT=$1 TLA="$tmp/tla" SEEDS="${SEEDS:-1 2 3}" DIFFN="${DIFFN:-300}" "$here/run.sh" 2>&1 | grep '^FAIL' | sed -E 's/^FAIL differential seed ([0-9]+):.*/FAIL differential-seed-\1/; s/^FAIL ([A-Za-z0-9_-]+):.*/\1/; s/^FAIL //'; }
base="$(run none)"
echo "baseline (unperturbed wrapper) fails: $(printf '%s\n' "$base" | tr '\n' ' ')"
[ "$base" = "$(cd "$here" && TLA="$real" SEEDS="${SEEDS:-1 2 3}" DIFFN="${DIFFN:-300}" ./run.sh 2>&1 | grep '^FAIL' | sed -E 's/^FAIL differential seed ([0-9]+):.*/FAIL differential-seed-\1/; s/^FAIL ([A-Za-z0-9_-]+):.*/\1/; s/^FAIL //')" ] \
    || { echo "BROKEN: the unperturbed wrapper differs from tla itself"; exit 1; }
for m in "${mutants[@]}"; do
    new="$(comm -13 <(printf '%s\n' "$base" | sort) <(run $m | sort))"
    if [ -n "$new" ]; then
        live="$(printf '%s\n' "$new" | grep -c '^L')"
        safe="$(printf '%s\n' "$new" | grep -c '^[SR]')"
        diff="$(printf '%s\n' "$new" | grep -c '^differential')"
        echo "caught $m: newly failing: $live liveness case(s), $safe safety/refusal case(s), $diff differential seed(s)  [$(printf '%s\n' "$new" | head -4 | tr '\n' ' ')...]"
    else
        echo "MISSED $m"; missed=$((missed + 1))
    fi
done
[ $missed = 0 ] && echo "every mutant caught" || echo "$missed mutant(s) missed"
[ $missed = 0 ]
