#!/bin/bash
# ConnectOS build-env patch: local chirpstack-openwrt-feed.
#
# `make update` runs `git submodule update`, which resets this feed to its
# tracked commit. Re-run this (via patches/apply.sh) after every
# `make init` / `make update`. Idempotent.
set -e
cd "$(dirname "$0")/.."
FEED=feeds/chirpstack-openwrt-feed/chirpstack

# (1) chirpstack UI: with no lockfile, yarn resolves the latest
#     @testing-library/jest-dom (>=6.10.0 requires node>=22), but OpenWrt's host
#     node is 20.20.0. That dep is test-only and unused by `yarn build`, so skip
#     the engine check instead of forcing a host-node upgrade.
CS="$FEED/chirpstack/Makefile"
if [ -f "$CS" ]; then
  sed -i -e 's/yarn install &&/yarn install --ignore-engines \&\&/' \
         -e 's/yarn add @/yarn add --ignore-engines @/' "$CS"
  echo "OK chirpstack-ui: yarn --ignore-engines"
fi

# (2) chirpstack-rest-api: pin to 4.16.1. Newer releases pull
#     google.golang.org/grpc v1.78.0+ which needs Go 1.24, but OpenWrt 24.10
#     ships Go 1.23 with GOTOOLCHAIN=local.
API="$FEED/chirpstack-rest-api/Makefile"
if [ -f "$API" ]; then
  sed -i -e 's/^PKG_VERSION:=.*/PKG_VERSION:=4.16.1/' \
         -e 's/^PKG_HASH:=.*/PKG_HASH:=73d79e169c75ddb4bf939d93ef7319407621de2a4dd49e12a382fb4190691053/' "$API"
  echo "OK chirpstack-rest-api: pinned 4.16.1"
fi
