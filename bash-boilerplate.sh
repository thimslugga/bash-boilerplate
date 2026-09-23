#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Script Constants
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_VERSION="0.1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME SCRIPT_VERSION SCRIPT_DIR

# Setup colors based on terminal capabilities
setup_colors() {
    declare -gA COLORS
    if [[ -t 1 ]] && command -v tput &> /dev/null && [[ $(tput colors) -ge 8 ]]; then
        COLORS[RED]="\033[0;31m"
        COLORS[GREEN]="\033[0;32m"
        COLORS[YELLOW]="\033[0;33m"
        COLORS[RESET]="\033[0m"
    else
        COLORS[RED]=""
        COLORS[GREEN]=""
        COLORS[YELLOW]=""
        COLORS[RESET]=""
    fi
}

# Print an informational message
print_info() {
    echo -e "${COLORS[GREEN]}[INFO]${COLORS[RESET]} $*"
}

# Print a warning message
print_warn() {
    echo -e "${COLORS[YELLOW]}[WARN]${COLORS[RESET]} $*"
}

# Print an error message (no exit)
print_error() {
    echo -e "${COLORS[RED]}[ERROR]${COLORS[RESET]} $*" >&2
}

# Print error and exit immediately
die() {
    print_error "$*"
    exit 1
}

# Ensure the script is run as root
require_root() {
    if [[ $EUID -ne 0 ]]; then
        die "This script must be run as root. Aborting."
    fi
}

# Check if a required command is available
require_command() {
    if ! command -v "$1" &> /dev/null; then
        die "Required command is not available: $1"
    fi
}

# Ensure a required environment variable is set
require_env() {
    if [[ -z "${!1:-}" ]]; then
        die "Required environment variable is not set: $1"
    fi
}

# Require a file to exist (exits if missing)
require_file() {
    if [[ ! -f "$1" ]]; then
        die "Required file not found: $1"
    fi
}

# Require a directory to exist (exits if missing)
require_dir() {
    if [[ ! -d "$1" ]]; then
        die "Required directory not found: $1"
    fi
}

# Ensure a directory exists, create it if missing
ensure_dir() {
    local dir_path="$1"
    if [[ ! -d "$dir_path" ]]; then
        print_info "Creating directory: $dir_path"
        mkdir -p "$dir_path"
    fi
}

# Ensure a file exists, create it if missing
ensure_file() {
    local file_path="$1"
    if [[ ! -f "$file_path" ]]; then
        print_info "Creating file: $file_path"
        touch "$file_path"
    fi
}

# Retry a command a set number of times
retry() {
    local max_attempts=3
    local count=0
    until "$@"; do
        count=$((count + 1))
        if [[ $count -ge $max_attempts ]]; then
            die "Command failed after $max_attempts attempts: $*"
        fi
        print_warn "Attempt $count/$max_attempts failed. Retrying..."
        sleep 2
    done
}

# Cleanup function for trap
cleanup() {
    if [[ -n "${TEMP_DIR:-}" ]] && [[ -d "${TEMP_DIR:-}" ]]; then
        print_info "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

# Create a temporary directory
make_temp_dir() {
    print_info "Creating temporary directory: $TEMP_DIR"
    TEMP_DIR=$(mktemp -d)
}

# Ensure only one instance of the script is running
setup_lockfile() {
    local LOCKFILE="/tmp/${SCRIPT_NAME}.lock"
    if [[ -e "$LOCKFILE" ]]; then
        die "Another instance is already running."
    fi
    trap 'rm -f "$LOCKFILE"; cleanup' EXIT
    touch "$LOCKFILE"
}

# Prompt the user for a Yes/No confirmation
confirm() {
    read -r -p "${1:-Are you sure?} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Display usage information
usage() {
    echo "$SCRIPT_NAME version $SCRIPT_VERSION"
    echo "Usage: $0 [-h] [-v]"
    echo ""
    echo "Options:"
    echo "  -h    Show this help message"
    echo "  -v    Enable verbose mode"
    exit 0
}

# Parse command-line arguments
parse_args() {
    VERBOSE=false
    while getopts "hv" opt; do
        case "$opt" in
            h) usage ;;
            v) VERBOSE=true ;;
            *) die "Invalid option passed to $0" ;;
        esac
    done
}

# Main function
main() {
    setup_colors

    # Set the trap to run the cleanup function on exit
    trap cleanup EXIT

    parse_args "$@"

    if [[ "$VERBOSE" == true ]]; then
        print_info "Verbose mode enabled."
    fi

    print_info "Script completed successfully."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
