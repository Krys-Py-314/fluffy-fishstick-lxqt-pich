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
# ======================================================
banner "8. CONFIGURE OPENBOX (Square Windows with Arc-Dark)"
# ======================================================
print_status "Configuring Openbox with square windows and Arc-Dark theme..."

mkdir -p ~/.config/openbox
if [ -f /etc/xdg/openbox/rc.xml ]; then
    cp /etc/xdg/openbox/rc.xml ~/.config/openbox/rc.xml
else
    # Create default rc.xml if not exists
    sudo tee  ~/.config/openbox/rc.xml >/dev/null  << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <theme>
    <name>Arc-Dark</name>
    <titleLayout>NLIMC</titleLayout>
    <keepBorder>yes</keepBorder>
    <animateIconify>yes</animateIconify>
    <font place="ActiveWindow">
      <name>Ubuntu Nerd Font</name>
      <size>10</size>
      <weight>bold</weight>
      <slant>normal</slant>
    </font>
    <font place="InactiveWindow">
      <name>Ubuntu Nerd Font</name>
      <size>10</size>
      <weight>normal</weight>
      <slant>normal</slant>
    </font>
  </theme>
</openbox_config>
EOF
fi

# Remove rounded corners (set border radius to 0) for square windows
if grep -q "<borderRadius>" ~/.config/openbox/rc.xml; then
    sed -i 's/<borderRadius>.*<\/borderRadius>/<borderRadius>0<\/borderRadius>/g' ~/.config/openbox/rc.xml
else
    # Add border radius setting if it doesn't exist
    sed -i '/<theme>/a\    <borderRadius>0</borderRadius>' ~/.config/openbox/rc.xml
fi

# Set Arc-Dark theme (remove any existing theme name and add new one)
if grep -q "<name>" ~/.config/openbox/rc.xml; then
    sed -i 's|<name>.*</name>|<name>Arc-Dark</name>|g' ~/.config/openbox/rc.xml
else
    # If no theme name exists, add it
    sed -i '/<theme>/a\    <name>Arc-Dark</name>' ~/.config/openbox/rc.xml
fi
