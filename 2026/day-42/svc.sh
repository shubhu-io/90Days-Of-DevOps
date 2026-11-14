#!/bin/bash
# Manages the self-hosted runner as a persistent service.
# Wraps the svc.sh shipped with the GitHub Actions runner package,
# which lives in $RUNNER_DIR (default $HOME/actions-runner).
set -e

RUNNER_DIR="${RUNNER_DIR:-$HOME/actions-runner}"

if [ ! -x "$RUNNER_DIR/svc.sh" ]; then
  echo "Runner package not found at $RUNNER_DIR."
  echo "Download it first (see day-42-runners.md), then re-run this script."
  exit 1
fi

cd "$RUNNER_DIR"
case "${1:-}" in
  install|start|stop|status|uninstall)
    exec sudo ./svc.sh "$1"
    ;;
  *)
    echo "Usage: $0 {install|start|stop|status|uninstall}"
    exit 1
    ;;
esac
