#!/usr/bin/env bash

set -uo pipefail

# Linux Workstation Health Check - automated tests
# Run from the project root with:
# bash tests/test-health-check.sh

SCRIPT="./health-check.sh"
TMP_DIR="$(mktemp -d)" || exit 2

PASSED=0
FAILED=0

find "$TMP_DIR" -maxdepth 3 -type f -print


pass() {
	printf 'PASS: %s\n' "$1"
	PASSED=$((PASSED + 1))
}

fail() {
	printf 'FAIL: %s\n' "$1"
	FAILED=$((FAILED + 1))
}

if [[ ! -f "$SCRIPT" ]]; then
	echo "Error: $SCRIPT not found."
	echo "Run this test from the project root directory."
	exit 2
fi

# Test 1: valid threshold
if THRESHOLD=90 OUTPUT_DIR="$TMP_DIR/reports" \
	bash "$SCRIPT" >"$TMP_DIR/valid.log" 2>&1; then
	pass "Accepts a valid threshold (90)"
else
	fail "Accepts a valid threshold (90)"
	cat "$TMP_DIR/valid.log"
fi

# Test 2: invalid threshold
if THRESHOLD=abc OUTPUT_DIR="$TMP_DIR/invalid-reports" \
	bash "$SCRIPT" >"$TMP_DIR/invalid.log" 2>&1; then
	fail "Rejects an invalid threshold (abc)"
else
	if grep -Fq "THRESHOLD must be an integer" "$TMP_DIR/invalid.log"; then
		pass "Rejects an invalid threshold (abc)"
	else
		fail "Rejects an invalid threshold with a clear error message"
		cat "$TMP_DIR/invalid.log"
	fi
fi

# Test 3: report generation
REPORT_FILE="$(sed -n 's/^Report saved to: //p' "$TMP_DIR/valid.log" | tail -n 1)"

if [[ -n "$REPORT_FILE" && -f "$REPORT_FILE" ]]; then
	pass "Generates a report file"
else
	fail "Generates a report file"
	echo "Diagnostic: reported path: ${REPORT_FILE:-<empty>}"
	echo "Diagnostic: files found in temporary directory:"
	find "$TMP_DIR" -maxdepth 3 -type 1 -print
fi

# Test 4: report contains expected sections
if [[ -n "$REPORT_FILE" && -f "$REPORT_FILE" ]]; then
	sections=(
		"Linux Workstation Health Check"
		"Filesystem usage"
		"Time synchronization"
		"Selected services"
		"Summary"
	)

	for section in "${sections[@]}"; do
		if grep -Fq -- "$section" "$REPORT_FILE"; then
			pass "Report contains section: $section"
		else
			fail "Report contains section: $section"
			echo "  Diagnostic: section not found in $REPORT_FILE"
		fi
	done
else
	fail "Cannot check report sections because no report was generated"
fi

# Final summary
echo
echo "=============================="
echo "Tests passed: $PASSED"
echo "Tests failed: $FAILED"
echo "=============================="

if (( FAILED > 0 )); then
	exit 1
fi

exit 0
