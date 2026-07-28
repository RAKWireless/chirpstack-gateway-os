#!/bin/bash
# Apply all ConnectOS build-environment patches to the feeds.
#
# These fix upstream/time-bomb build breakages that this repo hits on every
# fresh checkout (see each script for the why). Run after `make init` /
# `make update`, before `make build`. Wired into the Makefile init/update
# targets so it is automatic; safe to run standalone (`make patches`) too.
# Every script is idempotent.
set -e
cd "$(dirname "$0")/.."
for p in rust-patch.sh chirpstack-patch.sh; do
  echo "== patches/$p =="
  bash "patches/$p"
done
echo "All ConnectOS build-env patches applied."
