#!/bin/bash
# Starts the GitHub Actions self-hosted runner (foreground mode).
# The real run.sh ships inside the runner package downloaded from GitHub
# (Settings -> Actions -> Runners -> New self-hosted runner). This wrapper
# locates that package and delegates to it.
set -e

RUNNER_DIR="${RUNNER_DIR:-$HOME/actions-runner}"

if [ ! -x "$RUNNER_DIR/run.sh" ]; then
  echo "Runner package not found at $RUNNER_DIR."
  echo "Download it first (see day-42-runners.md), then re-run this script."
  exit 1
fi

cd "$RUNNER_DIR"
exec ./run.sh
