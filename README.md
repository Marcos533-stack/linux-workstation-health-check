# Linux Workstation Health Check

A lightweight Bash utility to check the basic health of a Linux workstation and generate a readable text report.

The project focuses on practical Linux administration, basic system diagnostics, shell scripting and technical documentation.

## Features

- **Filesystem usage:** displays filesystem capacity, used space, available space and usage percentage.
- **Configurable threshold:** identifies filesystems that exceed a specified usage threshold.
- **Time synchronization:** reports system time information and synchronization status.
- **Service checks:** checks selected services and reports warnings when a service is inactive or its state cannot be verified.
- **Text reports:** generates a report containing diagnostic information, warnings and a summary.
- **Automated tests:** validates threshold handling, report generation and the presence of expected report sections.

## Requirements

The project is intended for Linux systems with:

- Bash.
- Standard command-line utilities, including `df`, `grep` and other basic shell tools.
- `systemctl` and `timedatectl` for service and time-related checks, where available.

Some checks depend on the system's installed utilities and service manager. Results may vary across Linux distributions.

## Project structure

```text
linux-workstation-health-check/
├── health-check.sh
├── tests/
│   └── test-health-check.sh
├── examples/
│   └── sample-report.txt
└── README.md
```

The `examples/sample-report.txt` file is optional until a sanitized example report has been prepared.

## Installation

Clone the repository:

```bash
git clone <REPOSITORY_URL>
cd linux-workstation-health-check
```

Make the scripts executable:

```bash
chmod +x health-check.sh
chmod +x tests/test-health-check.sh
```

Replace `<REPOSITORY_URL>` with the URL of your public GitHub repository.

## Usage

Run the health check:

```bash
./health-check.sh
```

The script uses a default filesystem usage threshold unless another value is configured.

### Configure the threshold

The `THRESHOLD` environment variable controls the filesystem usage threshold.

For example, to use a threshold of 90%:

```bash
THRESHOLD=90 ./health-check.sh
```

An invalid threshold should be rejected with an error message.

### Configure the output directory

The `OUTPUT_DIR` environment variable specifies where the generated report is saved.

For example:

```bash
OUTPUT_DIR="./reports" ./health-check.sh
```

Both options can be used together:

```bash
THRESHOLD=90 OUTPUT_DIR="./reports" ./health-check.sh
```

The report filename includes a timestamp. The exact filename depends on the script's implementation.

## Example report

The report includes sections for:

- Filesystem usage.
- Filesystems requiring attention.
- Time synchronization.
- Selected services.
- Summary of warnings and errors.

A sanitized example report can be added to `examples/sample-report.txt`.

Example values should be fictitious. Do not publish hostnames, internal IP addresses, usernames, machine-specific paths or other sensitive system information.

## Automated tests

Run the test suite from the project root:

```bash
bash tests/test-health-check.sh
```

The tests currently check that:

1. A valid threshold is accepted.
2. An invalid threshold is rejected with a clear error message.
3. A report file is generated.
4. The report contains the expected main sections.

A successful run should finish with:

```text
Tests passed: 8
Tests failed: 0
```

The number of tests may change as the project evolves.

The current test suite validates basic behavior and report structure. It does not yet cover every possible filesystem, service-manager or time-synchronization failure.

## Limitations

- The tool provides basic diagnostics, not comprehensive system monitoring.
- A warning does not necessarily identify the root cause of a problem.
- Service checks depend on the services selected by the script and on the system's service manager.
- Time information depends on the available system utilities and time-synchronization configuration.
- Automated tests do not yet simulate all possible system states.
- Behavior may differ between Linux distributions.

## Security and privacy

The tool is intended to be run locally by the user.

Before publishing reports or test output, review them for hostnames, usernames, internal IP addresses, filesystem details and other potentially sensitive information.

Do not include credentials, private keys or configuration files from real systems.

## Future improvements

Potential improvements include:

- More comprehensive automated tests.
- Explicit handling of missing system utilities.
- More precise interpretation of time-synchronization status.
- Configurable service lists.
- Better handling of report-writing errors.
- Additional documentation and sanitized example reports.

## License

No license has been selected yet. Until a license is added, others should not assume that they have permission to reuse, modify or redistribute this project.

## Author

Developed as a personal project to practise Linux administration, Bash scripting, troubleshooting and technical documentation.
