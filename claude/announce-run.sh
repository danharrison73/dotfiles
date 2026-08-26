#!/usr/bin/env bash
#
# PreToolUse/Bash hook: print one line whenever Claude runs the PROGRAM, as
# opposed to the hundred greps, cats and git commands it also issues. Those are
# already visible in the transcript; the point here is a single, unmissable line
# for the thing that actually executes code.
#
# Reads the hook payload on stdin, prints {"systemMessage": ...} to show a line
# in the UI, or nothing at all when the command isn't a run.
set -uo pipefail

cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null | tr '\n' ' ')
[ -n "$cmd" ] || exit 0
cmd="${cmd%"${cmd##*[![:space:]]}"}"   # trim the trailing space tr left behind

# Anchored at the start of a command, not anywhere in the string -- otherwise
# `grep make Makefile` or `ls | wc` would announce themselves. A command starts
# at the beginning, after a pipe/&&/;/(, and may carry env assignments
# (DEBUG=1 make ...) or a path prefix (.venv/bin/python, ./run.py).
runner='(^|[|&;(] *)([A-Za-z_][A-Za-z0-9_]*=[^ ]* +)*([^ ]*/)?'
if   printf '%s' "$cmd" | grep -qE "${runner}make\b";        then verb='make'
elif printf '%s' "$cmd" | grep -qE "${runner}uv +run\b";     then verb='uv run'
elif printf '%s' "$cmd" | grep -qE "${runner}python3?\b";    then verb='python'
elif printf '%s' "$cmd" | grep -qE "${runner}pytest\b";      then verb='pytest'
elif printf '%s' "$cmd" | grep -qE "${runner}cargo +run\b";  then verb='cargo run'
elif printf '%s' "$cmd" | grep -qE "${runner}[^ ]*\.py\b";   then verb='script'
else exit 0
fi

# The command verbatim, capped: long enough for `make train BOOTSTRAPS=5`, short
# enough that it stays one line in a normal-width terminal.
short=$cmd
[ ${#short} -gt 110 ] && short="${short:0:107}..."

jq -n --arg v "$verb" --arg c "$short" '{systemMessage: ("▶ \($v): \($c)")}'
