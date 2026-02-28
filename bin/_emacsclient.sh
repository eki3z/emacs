#!/bin/sh

# library for emacsclient functionality

emacsclient::ensure_running() {
  if command -v emacs >/dev/null 2>&1 && command -v emacsclient >/dev/null 2>&1; then
    emacsclient -u -a "" -e "(server-running-p)" 2>/dev/null
  else
    echo "Error: emacs or emacsclient is not found."
    exit 1
  fi
}

# SEE https://www.emacswiki.org/emacs/EmacsPipe
emacsclient::pipe_detect() {
  if [ "$#" -eq 1 ] && [ "$1" = "-" ]; then
    mkdir -p /tmp/epipe
    EPIPE=$(mktemp "/tmp/epipe/$(date +%m%d-%H%M%S)-XXX")

    # remove ANSI color codes, SEE https://superuser.com/a/380778
    perl -pe 's/\e\[[0-9;]*[a-zA-Z]//g' | cat >"$EPIPE"
  fi
}

emacsclient::gui_frame_length() {
  emacsclient -q -e \
    "(length (seq-filter (lambda (f)
                      (and (frame-parameter f 'display)
                           (null (frame-parameter f 'parent-frame))))
                    (frame-list)))" 2>/dev/null
}

emacsclient::gui_open() {
  emacsclient::pipe_detect "$@"
  if [ "$#" -eq 0 ]; then
    emacsclient -u -e "(select-frame-set-input-focus (selected-frame))"
  else
    if [ -n "${EPIPE:-}" ]; then
      emacsclient -q -n "$EPIPE"
    else
      emacsclient -q -n "$@"
    fi
  fi
}

emacsclient::tui_open() {
  emacsclient::pipe_detect "$@"
  if [ -n "${EPIPE:-}" ]; then
    emacsclient -q -t "$EPIPE"
  else
    emacsclient -q -t "$@"
  fi
}

emacsclient::tui_eval() {
  emacsclient -q -t -e "$@"
}
