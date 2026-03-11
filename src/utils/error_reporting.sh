#!/usr/bin/env bash
# Centralized Error Reporting

report_error() {
    local error_code=$1
    local line_no=$2
    local bash_command=$3
    echo "ERROR: Failed executing '${bash_command}' at line ${line_no} with exit code ${error_code}" >&2
    # In a real environment with Sentry, we'd send the error here, e.g.:
    # sentry-cli send-event -m "Bash error: ${bash_command} failed at line ${line_no} with exit code ${error_code}"
}
