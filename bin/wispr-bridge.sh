#!/usr/bin/env bash
# wispr-bridge — put Wispr Flow's dictation into the focused tmux pane, hands free.
#
# Why this exists. Flow cannot insert text into a terminal:
#   * its automatic insert after dictation sends NO keystroke at all (verified
#     with `cat -v`: zero bytes, while manual typing in the same capture came
#     through). It writes through a Windows text-control API, and a GPU-rendered
#     terminal is not an edit control, so the write goes nowhere.
#   * its paste shortcuts fare no better through WSL.
# What Flow DOES do, reliably, is put the transcript on the Windows clipboard --
# and then restore the previous contents ~455ms later (measured by polling at
# 60ms: set at 18:31:58.171, reverted at 18:31:58.626). That set-then-restore is
# both the reason every paste-based approach loses the race, and a signature no
# ordinary copy produces. This watches for it and does the paste itself.
#
# Detection: on each clipboard change, if the value returns to what it was two
# changes ago within REVERT_MS, the value in between was a Flow transcript.
# A normal copy persists, so it never matches and is never pasted.
#
# One long-lived PowerShell process does the polling. Spawning powershell.exe per
# check would cost more than the whole 455ms window.

set -uo pipefail

POLL_MS=${POLL_MS:-50}      # clipboard sample interval
TMUX_SOCK=${TMUX_SOCK:-}    # tmux -L socket to paste into; empty = the default server
REVERT_MS=${REVERT_MS:-1500} # how long a value may stand and still count as Flow's

command -v powershell.exe >/dev/null || { echo "wispr-bridge: powershell.exe not on PATH" >&2; exit 1; }
command -v tmux >/dev/null           || { echo "wispr-bridge: tmux not on PATH" >&2; exit 1; }

# Emits "<unix_ms> <base64>" per clipboard change. base64 keeps multi-line
# transcripts on one line, and survives quoting on both sides.
# One line on purpose. powershell.exe -Command with a MULTI-LINE string silently
# executes nothing -- no output, no error -- so the whole script has to be
# semicolon-separated on a single line. (-EncodedCommand is the other way.)
PS='$last = Get-Clipboard -Raw;'
PS+=' while ($true) {'
PS+=' $c = Get-Clipboard -Raw;'
PS+=' if ($null -eq $c) { $c = "" };'
PS+=' if ($c -ne $last) {'
PS+=' $b = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($c));'
# The inner parens are required: inside a method call the comma binds to the
# method's argument list, so `-f a, b` reaches the format string as ONE argument
# and PowerShell throws "Index ... must be less than the size of the argument list".
PS+=' [Console]::Out.WriteLine(("{0} {1}" -f [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds(), $b));'
PS+=' [Console]::Out.Flush();'
PS+=' $last = $c };'
PS+=" Start-Sleep -Milliseconds $POLL_MS }"

# v2/v1 are the two previous clipboard values; t1 is when v1 appeared.
v2=""; v1=""; t1=0
# No `tr -d '\r'` in this pipeline, tempting as it is: tr block-buffers when its
# output is not a terminal, so lines would sit in its buffer instead of reaching
# the loop -- the events arrive, just minutes late. PowerShell writes CRLF, so
# the CR is stripped per-field below instead; left on, `base64 -d` fails and
# every event is silently skipped.
powershell.exe -NoProfile -Command "$PS" 2>/dev/null | while read -r ms b64; do
  b64=${b64%$'\r'}
  ms=${ms%$'\r'}
  text=$(printf '%s' "$b64" | base64 -d 2>/dev/null) || continue
  if [ -n "$v1" ] && [ "$text" = "$v2" ] && [ $((ms - t1)) -le "$REVERT_MS" ]; then
    # v1 stood briefly and the clipboard snapped back: Flow's transcript.
    # -p sends it as a bracketed paste, so the receiving program treats it as
    # pasted text rather than typing -- no accidental submit on an embedded \n.
    if [ -n "$TMUX_SOCK" ]; then set -- -L "$TMUX_SOCK"; else set --; fi
    printf '%s' "$v1" | tmux "$@" load-buffer - && tmux "$@" paste-buffer -p
    printf 'wispr-bridge: pasted %d chars\n' "${#v1}" >&2
    v2=""; v1=""; t1=0
    continue
  fi
  v2="$v1"; v1="$text"; t1="$ms"
done
