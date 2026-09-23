#!/usr/bin/env bash
#
# k314-mini-lgpio-setup-v1.5.sh
#
# Gets, Compiles and installs lgpio librairy for the minimal LXQt/Openbox desktop on a
# Raspberry Pi 5 (Raspberry Pi OS Lite 64-bit, Debian Trixie).
#
#     chmod +x k314-mini-lgpio-setup-v1.5.sh
#     ./k314-mini-lgpio-setup-v1.5.sh
#
# 
#

set -uo pipefail
clear -x

# ---------------------------------------------------------------------------
# Colors for output
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ---------------------------------------------------------------------------
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# ---------------------------------------------------------------------------
print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# ---------------------------------------------------------------------------
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ---------------------------------------------------------------------------
# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. Run as normal user with sudo privileges."
    exit 1
fi

# ---------------------------------------------------------------------------
# Globals
# ---------------------------------------------------------------------------
LOGFILE="$HOME/.k314-mini-lgpio-setup.log"
SKIPPED_PKGS=()
FAILED_STEPS=()

SKIP_SSH_SWAP="${SKIP_SSH_SWAP:-0}"
SKIP_PI_APPS="${SKIP_PI_APPS:-0}"
SKIP_TRIM="${SKIP_TRIM:-0}"
ASSUME_YES="${ASSUME_YES:-0}"


# ---------------------------------------------------------------------------
banner() {
    print_status " "
    print_status " $1"
    print_status " "
}
# ---------------------------------------------------------------------------
note_fail() {
    FAILED_STEPS+=("$1")
    print_error "$1"
}
# ---------------------------------------------------------------------------
confirm() {
    local prompt="$1"
    [ "$ASSUME_YES" = "1" ] && return 0
    [ -t 0 ] || return 0
    local reply=""
    read -r -p "$(echo -e "${YELLOW}[WARN]${NC} ${prompt} [Y/n] ")" reply
    case "$reply" in
        [nN]*) return 1 ;;
        *)     return 0 ;;
    esac
}

# ---------------------------------------------------------------------------
# True when apt has an installable candidate for the package.
pkg_available() {
    local cand
    cand="$(apt-cache policy -- "$1" 2>/dev/null | awk -F': ' '/Candidate:/{print $2; exit}')"
    [ -n "$cand" ] && [ "$cand" != "(none)" ]
}

# ---------------------------------------------------------------------------
# Install only packages that actually exist in the configured repositories.
# This is what keeps the run free of "Unable to locate package" failures.
apt_install() {
    local want=("$@") ok=() miss=() p
    for p in "${want[@]}"; do
        if pkg_available "$p"; then ok+=("$p"); else miss+=("$p"); fi
    done
    if [ "${#miss[@]}" -gt 0 ]; then
        print_warning "Not offered by this release, skipping: ${miss[*]}"
        SKIPPED_PKGS+=("${miss[@]}")
    fi
    if [ "${#ok[@]}" -eq 0 ]; then
        return 0
    fi
    print_status "apt-get install: ${ok[*]}"
    if ! sudo apt-get install -y --no-install-recommends "${ok[@]}" >>"$LOGFILE" 2>&1; then
        note_fail "apt-get install failed for: ${ok[*]} (see $LOGFILE)"
        return 1
    fi
    return 0
}

# ---------------------------------------------------------------------------
# Install the first package in the list that exists (for name changes across releases).
apt_install_first() {
    local p
    for p in "$@"; do
        if pkg_available "$p"; then
            apt_install "$p"
            return $?
        fi
    done
    print_warning "None of these packages exist here: $*"
    SKIPPED_PKGS+=("$*")
    return 1
}


printf ".\n.\n"
print_status "Configuration of [ LGPIO ] BEGIN..."
printf ".\n.\n"
# ===========================================================================
banner "01 - Install dependencies and pre-requisites"
# ===========================================================================
mkdir -p $HOME/.tmp
cd $HOME/.tmp

sudo apt update

# Normally the following are already installed ...
# They will be installed if not the case.
apt_install \
    build-essential \
    wget \
    unzip \
    swig \
    python3-setuptools 



# ===========================================================================
banner "02 - Download and extract the official source code repository"
# ===========================================================================
cd $HOME/.tmp

wget https://github.com/joan2937/lg/archive/master.zip


print_status "Installing LGPIO Master..."
PACKAGE="https://github.com/joan2937/lg/archive/master.zip"
if wget  "$PACKAGE" ; then
    print_status "    Download of $PACKAGE succesfull ...."
else
    note_fail    "    Download of $PACKAGE Failed ....."
    print_error  "    lgpio setup failed, please check wget source"
    exit 1

fi

unzip master.zip
cd lg-master

# ===========================================================================
banner "03 - Compile and install the C library"
# ===========================================================================
make
sudo make install

# ===========================================================================
banner "04 - Update the system library cache"
# ===========================================================================
sudo ldconfig

cd $HOME

print_status "---------------------------------------------------------------------------"
print_status " "
print_status " Setup finished successfully."
print_status " "
print_status " Configuration of [ LGPIO ] END..."
print_status " "
print_status "        Once installed, the header file (lgpio.h) will be placed "
print_status "        in /usr/local/include and the library binaries in /usr/local/lib."
print_status " "
print_status "        To compile your high-speed C project, always pass the -llgpio flag" 
print_status "        to your compiler so it links properly:"
print_status " "
print_status "        gcc -O3 my_gpio_project.c -o my_gpio_project -llgpio"
print_status "        (Note: Adding the -O3 flag instructs GCC to heavily optimize the "
print_status "        binary for execution speed.)"
print_status " "
print_status "---------------------------------------------------------------------------"

