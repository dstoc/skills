#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/bin" "$work/logs"

cat >"$work/bin/jev" <<'FAKE'
#!/usr/bin/env bash
set -euo pipefail
[[ ${1-} == ask && ${2-} == ignored && ${3-} == --state-file && -f ${4-} ]] || {
  printf 'bad jev invocation\n' >&2
  exit 8
}
printf 'called\n' >> "$FAKE_JEV_CALLS"
jq -c '{exit_code, stdout, stderr}' "$4" > "$FAKE_JEV_LAST_STATE"
if [[ ${FAKE_JEV_FAIL:-0} == 1 ]]; then
  exit 9
fi
printf 'jev_result=true\n'
FAKE
chmod +x "$work/bin/jev"
export PATH="$work/bin:$PATH"
export FAKE_JEV_CALLS="$work/calls" FAKE_JEV_LAST_STATE="$work/last_state.json"
export JEV_LOG_DIR="$work/logs"
wrapper="$root/scripts/jev-run"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
call_count() { if [[ -f $FAKE_JEV_CALLS ]]; then wc -l < "$FAKE_JEV_CALLS"; else printf '0\n'; fi; }
run() {
  : >"$work/stdout"; : >"$work/stderr"
  if "$wrapper" --noul 'Which failure?' -- "$@" >"$work/stdout" 2>"$work/stderr"; then
    rc=0
  else
    rc=$?
  fi
}

# Success never invokes Jev and preserves each stream independently.
run bash -c 'printf "success stdout\n"; printf "success stderr\n" >&2'
[[ $rc == 0 && $(cat "$work/stdout") == 'success stdout' ]] || fail 'success stdout'
grep -Fxq 'success stderr' "$work/stderr" || fail 'success stderr'
grep -Fxq 'exit_code=0' "$work/stderr" || fail 'success status'
[[ $(call_count) == 0 && -z $(find "$work/logs" -type f -print -quit) ]] || fail 'success invoked Jev or retained logs'
printf 'PASS: success preserves separate streams and skips Jev\n'

# Short failures replay separately and retain both source streams.
run bash -c 'printf "short stdout\n"; printf "short stderr\n" >&2; exit 17'
[[ $rc == 17 && $(cat "$work/stdout") == 'short stdout' ]] || fail 'short failure stdout'
grep -Fxq 'short stderr' "$work/stderr" || fail 'short failure stderr'
! grep -q 'short stderr' "$work/stdout" || fail 'stderr appeared on stdout'
! grep -q 'short stdout' "$work/stderr" || fail 'stdout appeared on stderr'
grep -Fxq 'jev_skipped=short_output' "$work/stderr" || fail 'short output not skipped'
[[ $(call_count) == 0 ]] || fail 'short failure invoked Jev'
stdout_log=$(sed -n 's/^stdout_log=//p' "$work/stderr" | head -1)
stderr_log=$(sed -n 's/^stderr_log=//p' "$work/stderr" | head -1)
[[ -f $stdout_log && -f $stderr_log ]] || fail 'separate logs not retained'
[[ $(cat "$stdout_log") == 'short stdout' && $(cat "$stderr_log") == 'short stderr' ]] || fail 'retained streams are incorrect'
printf 'PASS: short failure replays and preserves streams separately\n'

# Threshold is on combined bytes, not per-stream bytes.
run bash -c 'printf "%8190s" x; printf "y" >&2; exit 21'
[[ $rc == 21 && $(call_count) == 0 ]] || fail '8191 combined bytes must skip Jev'
printf 'PASS: below threshold skips Jev\n'

run bash -c 'printf "%4096s" x; printf "%4096s" y >&2; exit 22'
[[ $rc == 22 && $(call_count) == 1 ]] || fail '8192 combined bytes must invoke Jev once'
[[ $(cat "$work/stdout") == 'jev_result=true' ]] || fail 'Jev answer not forwarded'
! grep -q 'jev_result' "$work/stderr" || fail 'Jev answer appeared on stderr'
[[ $(jq -r '.exit_code' "$FAKE_JEV_LAST_STATE") == 22 ]] || fail 'JSON state missing exit code'
[[ $(jq -r '.stdout|length' "$FAKE_JEV_LAST_STATE") == 4096 ]] || fail 'JSON state stdout incorrect'
[[ $(jq -r '.stderr|length' "$FAKE_JEV_LAST_STATE") == 4096 ]] || fail 'JSON state stderr incorrect'
[[ $(jq -r '.stdout[-1:]' "$FAKE_JEV_LAST_STATE") == x ]] || fail 'stdout/stderr merged in state'
[[ $(jq -r '.stderr[-1:]' "$FAKE_JEV_LAST_STATE") == y ]] || fail 'stderr/stdout merged in state'
[[ $(wc -c < "$work/stderr") -lt 1024 ]] || fail 'raw command output leaked during Jev call'
printf 'PASS: threshold invokes Jev with distinct structured stdout/stderr\n'

export JEV_MIN_BYTES=16384
run bash -c 'printf "%9000s" x; exit 23'
[[ $rc == 23 && $(call_count) == 1 ]] || fail 'configurable threshold'
grep -Fxq 'jev_skipped=short_output' "$work/stderr" || fail 'threshold override not applied'
printf 'PASS: configurable threshold\n'

export JEV_MIN_BYTES=0
run bash -c 'exit 24'
[[ $rc == 24 && $(call_count) == 2 ]] || fail 'zero threshold did not force Jev'
[[ $(jq -r '.stdout|length' "$FAKE_JEV_LAST_STATE") == 0 && $(jq -r '.stderr|length' "$FAKE_JEV_LAST_STATE") == 0 ]] || fail 'empty streams not preserved'
printf 'PASS: zero threshold forces Jev with empty streams\n'

export FAKE_JEV_FAIL=1
run bash -c 'printf "%100s" x; exit 101'
[[ $rc == 101 && $(call_count) == 3 ]] || fail 'Jev error changed original exit code'
grep -q '^jev_error=1' "$work/stderr" || fail 'Jev error not reported'
printf 'PASS: Jev error preserves original exit code\n'

export JEV_MIN_BYTES=not-a-number
side_effect="$work/ran"
run bash -c 'touch "$1"' _ "$side_effect"
[[ $rc == 2 && ! -e $side_effect ]] || fail 'invalid threshold did not fail before command execution'
grep -q 'JEV_MIN_BYTES must be' "$work/stderr" || fail 'invalid threshold not reported'
printf 'PASS: invalid threshold rejected before command execution\n'
