#!/usr/bin/env bash

set -u

THRESHOLD="${THRESHOLD:-80}"
OUTPUT_DIR="${OUTPUT_DIR:-reports}"
REPORT_FILE="$OUTPUT_DIR/health-report-$(date +%Y%m%d%-%H%M%S).txt"

ERRORS=0
WARNINGS=0

if ! [[ "$THRESHOLD" =~ ^[0-9]+$ ]] || (( THRESHOLD < 1 || THRESHOLD > 100  )); then
	echo "Error: THRESHOLD must be an integer between 1 and 100." >&2
	exit 2
fi

mkdir -p "$OUTPUT_DIR" || {
	echo "Error: cannot create output directory: $OUTPUT_DIR" >&2
	exit 1
}

{
	echo "Linux Workstation Health Check"
	echo "Date: $(date --iso-8601=seconds 2>/dev/null || date)"
	echo "Hostname: $(hostname)"
	echo "Disk usage threshold: ${THRESHOLD}%"
	echo
	echo "== Filesystem usage =="

	df -P -x tmpfs -x devtmpfs | awk 'NR == 1 {print; next} {print}'
	echo
	echo "== Filesystems requiring attention =="

	while read -r filesystem size used available percentage mountpoint; do
		[[ "$percentage" =~ ^[0-9]+%$ ]] || continue
		usage="${percentage%\%}"

		if (( usage >= THRESHOLD )); then
			echo "WARNING: $mountpoint is ${usage}% full ($filesystem)"
			WARNINGS=$((WARNINGS + 1))
		fi
	done < <(df -P -x tmpfs -x devtmpfs | tail -n +2)

	echo
	echo "== Time synchronization =="

	if command -v timedatectl >/dev/null 2>&1; then
		timedatectl status 2>&1 || {
			echo "WARNING: unable to read timedatectl status."
			WARNINGS=$((WARNINGS + 1))
		}
	else
		echo "WARNING: timedatectl is not available."
		WARNINGS=$((WARNINGS + 1))
	fi

	echo
	echo "== Selected services =="

	if [[ -f config/services.conf ]]; then
		while IFS= read -r service || [[ -n "$service" ]]; do
			[[ -z "$service" || "$service" == \#* ]] && continue

			if command -v systemctl >/dev/null 2>&1; then
				if systemctl is-active --quiet "$service"; then
					echo "OK: $service is active."
				else
					echo "WARNING: $service is not active or its state cannot be checked."
					WARNINGS=$((WARNINGS + 1))
				fi
			else
				echo "WARNING: systemctl is not available; cannot check $service."
				WARNINGS=$((WARNINGS + 1))
			fi
		done < config/services.conf
	else
		echo "No service configuration found; skipping service checks."
	fi

	echo
	echo "== Summary =="
	echo "Warnings: $WARNINGS"
	echo "Errors: $ERRORS"
} | tee "$REPORT_FILE"

echo
echo "Report saved to: $REPORT_FILE"
