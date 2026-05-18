#!/usr/bin/env bash
# Run the full Zard vs Zod vs Yup benchmark comparison suite.
#
# Each block prints results in the same format (`📊 Name / Per op: X µs / Ops/sec: N`),
# so you can grep + paste into the README.
#
# - Dart: JIT (`dart run`), harness JIT, and AOT (`dart compile exe`).
# - Node: Zod, Yup (V8 JIT only).

set -e
cd "$(dirname "$0")"

bold() { printf "\n\033[1m=== %s ===\033[0m\n" "$1"; }

# --- Zard (Dart, manual Stopwatch — fast, casual numbers) ---
bold "Zard (Dart, JIT, Stopwatch)"
dart run zard_benchmark.dart

# --- Zard (Dart, benchmark_harness — auto-calibrated, canonical numbers) ---
bold "Zard (Dart, JIT, harness)"
dart run zard_harness_benchmark.dart

# --- Zard (Dart, AOT — closer to Flutter release builds) ---
bold "Zard (Dart, AOT, harness)"
OUT=$(mktemp)
dart compile exe zard_harness_benchmark.dart -o "$OUT" 2>&1 | tail -2
"$OUT"
rm -f "$OUT"

# --- Node deps ---
if [ ! -d node_modules ]; then
  bold "Installing Node deps for Zod / Yup benchmarks"
  npm install --silent
fi

bold "Zod (Node, V8)"
node zod_benchmark.js

bold "Yup (Node, V8)"
node yup_benchmark.js

bold "Done"
