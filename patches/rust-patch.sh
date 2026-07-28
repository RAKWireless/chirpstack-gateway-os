#!/bin/bash
# ConnectOS build-env patch: OpenWrt 'packages' feed, rust 1.90.0 host build.
#
# The 'packages' feed is a pinned REMOTE feed, so `feeds update` re-fetches and
# overwrites its Makefiles. Re-run this (via patches/apply.sh) after every
# `make init` / `make update`. Idempotent and arch-agnostic: it patches the feed
# Makefile *source*, so the fix applies to every target arch (a72/a76/...) and
# self-heals during the build — no per-failure build_dir surgery needed.
set -e
cd "$(dirname "$0")/.."
MK=openwrt/feeds/packages/lang/rust/Makefile
[ -f "$MK" ] || { echo "SKIP rust: $MK not found (run 'feeds install' first)"; exit 0; }

# (1) Build LLVM from source. rust-lang deletes old CI artifacts, so
#     download-ci-llvm=true 404s for any rust more than ~6 months old.
sed -i 's/--set=llvm.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' "$MK"

# (2) Restore the vendored Cargo.toml.orig files at Host/Compile time. OpenWrt's
#     patch step (scripts/patch-kernel.sh) runs `find -name '*.orig' -delete`,
#     wiping the ~1600 vendored crates' Cargo.toml.orig whose checksums cargo's
#     bootstrap requires -> "failed to open vendor/<crate>/Cargo.toml.orig".
if ! grep -qF 'vendor/*/Cargo.toml.orig' "$MK"; then
  python3 - "$MK" <<'PY'
import sys
p = sys.argv[1]; s = open(p).read()
old = 'define Host/Compile\n\t$(RUST_SCCACHE_VARS) \\\n'
new = ('# ConnectOS: restore vendored Cargo.toml.orig stripped by the patch step.\n'
       'define Host/Compile\n'
       '\t[ -e "$(HOST_BUILD_DIR)/vendor/serde-1.0.215/Cargo.toml.orig" ] || tar -C "$(HOST_BUILD_DIR)/.." -xJf "$(DL_DIR)/$(PKG_SOURCE)" --wildcards \'rustc-$(PKG_VERSION)-src/vendor/*/Cargo.toml.orig\'\n'
       '\t$(RUST_SCCACHE_VARS) \\\n')
assert s.count(old) == 1, f"Host/Compile anchor matched {s.count(old)} times"
open(p, "w").write(s.replace(old, new, 1))
PY
fi
echo "OK rust: download-ci-llvm=false + Cargo.toml.orig restore"
