#!/bin/bash
# krys314-mini-rasp-lxqt-v2.0.sh
# ======================================================
# Minimal LXQt/Openbox Environment for Raspberry Pi 5
# ======================================================
# Run on fresh Raspberry Pi OS Lite (64-bit) installation
# Sets up a lightweight X11 environment with full customization
# ======================================================

set -e  # Exit on error
clear -x

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#-------------------------------------------------------
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

#-------------------------------------------------------
print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

#-------------------------------------------------------
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

#-------------------------------------------------------
banner() {
    print_status " "
    print_status " $1 ......"
    print_status " "
}


#-------------------------------------------------------
banner "Check if running as root"
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. Run as normal user with sudo privileges."
    exit 1
fi

banner "    Starting Raspberry Pi 5 Minimal LXQt/Openbox Setup..."

# ======================================================
banner " 1. SYSTEM UPDATE"
# ======================================================
print_status "    Updating system packages..."
sudo apt update
sudo apt full-upgrade -y

# ======================================================
 banner "2. INSTALL X11 AND LXQT CORE"
# ======================================================
print_status "    Installing X11, Openbox, and LXQt..."
sudo apt install -y \
    xserver-xorg \
    xserver-xorg-core \
    xserver-xorg-input-libinput \
    xinit \
    xauth \
    x11-common \
    dbus \
    dbus-x11 \
    polkitd \
    openbox \
    lxqt-core \
    lxqt-panel \
    lxqt-config \
    lxqt-session \
    lxqt-qtplugin \
    lxqt-about \
    lightdm \
    lightdm-gtk-greeter \
    libgbm1 \
    libglx-mesa0 \
    libegl-mesa0 \
    xserver-xorg-video-modesetting \
    libgl1-mesa-dri

#sudo apt update
#sudo apt install xserver-xorg xinit xserver-xorg-video-modesetting libgl1-mesa-dri libegl-mesa0 libglx-mesa0


# ======================================================
banner " 3. INSTALL THEMES AND ICONS"
# ======================================================
print_status "    Installing themes and icons..."

# Install Arc Theme (includes Arc-Dark variant)
sudo apt install -y arc-theme

# Create symbolic links for Arc-Dark theme if needed
# The arc-theme package includes Arc-Dark, but we need to ensure it's available
if [ -d "/usr/share/themes/Arc-Dark" ]; then
    print_status "    Arc-Dark theme already installed"
else
    print_warning "Arc-Dark theme not found, creating symlink..."
    # If Arc-Dark doesn't exist but Arc does, create a symlink
    if [ -d "/usr/share/themes/Arc" ]; then
        sudo ln -s /usr/share/themes/Arc /usr/share/themes/Arc-Dark 2>/dev/null || true
    fi
fi

# Numix Icon Theme
sudo apt install -y numix-icon-theme numix-icon-theme-circle

# Additional GTK theme tools
sudo apt install -y lxappearance qt5ct

# ======================================================
banner " 4. INSTALL APPLICATIONS"
# ======================================================
print_status "    Installing applications..."

# Terminal and text editors
sudo apt install -y \
    xfce4-terminal \
    l3afpad \
    pcmanfm-qt

# Web browser (vimb - lightweight webkit browser)
sudo apt install -y vimb



# Raspberry Pi specific tools and kernel headers
sudo apt install -y\
    linux-headers-$(uname -r)
#    raspi-config \
#    raspi-utils-core

#    linux-headers-rpi-v8

# GPIO Libraries and Tools (modern - compatible with Pi 5)
#sudo apt install -y \
#    raspi-config \
#    raspi-utils \
#    python3-lgpio \
#    python3-gpiozero \
#    swig \
#    python3-dev \
#    rgpiod \
#    rgpio-tools

# System utilities
sudo apt install -y \
    fastfetch \
    flameshot \
    lximage-qt \
    qpdfview \
    network-manager \
    network-manager-gnome \
    dropbear

# Notification and panel plugins
sudo apt install -y \
    lxqt-notificationd \
    pavucontrol-qt

# ======================================================
banner " 5. INSTALL PI-APPS (Raspberry Pi App Store)"
# ======================================================
print_status "    Installing Pi-Apps (Raspberry Pi App Store)..."

# Pi-Apps is not available as a Debian package - it must be installed via its official script
# Pi-Apps is the most popular app store for Raspberry Pi, with over 200 applications
# It is fully supported on Raspberry Pi OS 64-bit Bookworm (which this script targets)

#wget -qO- https://raw.githubusercontent.com/Botspot/pi-apps/master/install | bash

#print_status "    Pi-Apps installed successfully! You can run it with: pi-apps"

# ======================================================
banner " 6. INSTALL SUBLIME TEXT 3 (skipped)"
# ======================================================
#print_status "    Installing Sublime Text 3..."

# Install prerequisites for adding repositories securely
#sudo apt install -y gnupg2 wget

# Download the GPG key, de-armor it, and save it to the keyrings directory
#sudo mkdir -p /usr/share/keyrings
#wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | \
#    gpg --dearmor | \
#    sudo tee /usr/share/keyrings/sublimehq-archive-keyring.gpg > /dev/null

# Add the Sublime Text repository, explicitly pointing to the new keyring
#echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" | \
#    sudo tee /etc/apt/sources.list.d/sublime-text.list

# Update package list and install Sublime Text
#sudo apt update
#sudo apt install -y sublime-text

# ======================================================
banner " 7. INSTALL OH-MY-POSH AND NERD FONTS (ROBUST VERSION)"
# ======================================================
print_status "    Installing Oh-My-Posh and Nerd Fonts..."
sudo apt install -y curl unzip

# Install Oh-My-Posh with sudo to ensure system-wide availability
print_status "    Attempting to install Oh-My-Posh..."
sudo curl -s https://ohmyposh.dev/install.sh | sudo bash -s

#sudo -u "$TARGET_USER" bash -lc 'curl -s https://ohmyposh.dev/install.sh | bash -s'

BASHRC="$HOME/.bashrc"
grep -qxF 'export PATH=$PATH:$HOME/.local/bin' "$BASHRC" || \
  sudo echo 'export PATH=$PATH:$HOME/.local/bin' >> "$BASHRC"
grep -qxF 'eval "$(oh-my-posh init bash)"' "$BASHRC" || \
  sudo echo 'eval "$(oh-my-posh init bash)"' >> "$BASHRC"


# Download and install Ubuntu  Font
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

print_status "    Downloading Ubuntu Nerd Font..."
wget -qO- --show-progress -O "$FONT_DIR/UbuntuNerdFont.zip" \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Ubuntu.zip

# Extract font
print_status "    Extracting font...."
cd "$FONT_DIR"
unzip -q -o UbuntuNerdFont.zip
rm UbuntuNerdFont.zip
cd -

# Update font cache
print_status "    updating font cache...."
fc-cache -fv > /dev/null


# ======================================================
banner " 8. CONFIGURE OPENBOX (Square Windows with Arc-Dark)"
# ======================================================
print_status "    Configuring Openbox with square windows and Arc-Dark theme..."

mkdir -p ~/.config/openbox
if [ -f /etc/xdg/openbox/rc.xml ]; then
    cp /etc/xdg/openbox/rc.xml ~/.config/openbox/rc.xml
else
    # Create default rc.xml if not exists
    cat > ~/.config/openbox/rc.xml << 'EOF'
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

# ======================================================
banner " 9. CONFIGURE LXQT PANEL (Left Side with Widgets)"
# ======================================================
print_status "    Configuring LXQt panel..."

# Create panel configuration directory
mkdir -p ~/.config/lxqt

# Panel configuration with all required widgets
cat > ~/.config/lxqt/panel.conf << 'EOF'
[General]
theme=Arc-Dark
icon_theme=Numix

[panel0]
size=45
position=Left
show_desktop_icons=1
alignment=Center

# World Clock Widget
[widget1]
type=clock
config_show_seconds=1
config_show_date=1
config_timezone=America/New_York

# Volume Control
[widget2]
type=volume

# Network Manager
[widget3]
type=network

# Wi-Fi Control
[widget4]
type=wireless

# System Tray (includes update notifications)
[widget5]
type=tray

# System Update Notifier
[widget6]
type=updater
config_interval=3600

# Workspace Switcher
[widget7]
type=workspace

# Quick Launch (terminal, browser)
[widget8]
type=quicklaunch
config_items[0]=xfce4-terminal
config_items[1]=vimb
config_items[2]=pcmanfm-qt
EOF

# ======================================================
banner " 10. CONFIGURE LXQT SESSION"
# ======================================================
print_status "    Configuring LXQt session..."

# Create LXQt session config
mkdir -p ~/.config/lxqt-session

#cat > ~/.config/lxqt-session/session.conf << 'EOF'
#[General]
#window_manager=openbox
#leave_confirmation=false
#EOF

sudo tee ~/.config/lxqt-session/session.conf >/dev/null <<'EOF'
[General]
window_manager=openbox
leave_confirmation=false
EOF


# ======================================================
banner " 11. CONFIGURE LIGHTDM AND AUTOLOGIN"
# ======================================================
print_status "    Configuring LightDM..."

# Set LightDM as default display manager
sudo systemctl enable lightdm

# Configure LightDM for autologin
print_status "        Configuring LightDM for autologin"

sudo mkdir -p /etc/lightdm/lightdm.conf.d

sudo tee /etc/lightdm/lightdm.conf.d/99-autologin.conf  >/dev/null <<'EOF'
[Seat:*]
autologin-user=$(whoami)
autologin-user-timeout=0
EOF


#configure Rpi 5 video driver to enable startx 
print_status "        Configuring Rpi 5 video driver to enable startx"

sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/99-vc4.conf >/dev/null <<'EOF'
Section "OutputClass"
    Identifier "vc4"
    MatchDriver "vc4"
    Driver "modesetting"
    Option "PrimaryGPU" "true"
EndSection
EOF


# Configure LightDM GTK Greeter with Arc-Dark
print_status "    Configuring LightDM GTK Greeter with Arc-Dark"

sudo tee /etc/lightdm/lightdm-gtk-greeter.conf <<'EOF'
[greeter]
theme-name=Arc-Dark
icon-theme-name=Numix
font-name=Ubuntu Nerd Font 11
background=/usr/share/rpd-wallpaper/plain.png
EOF

# ======================================================
banner " 12. CONFIGURE GTK THEMES (Arc-Dark)"
# ======================================================
print_status "    Configuring GTK themes with Arc-Dark..."

# Create GTK3 configuration
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Arc-Dark
gtk-icon-theme-name=Numix
gtk-font-name=Ubuntu Nerd Font 11
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=0
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb
EOF

# Create GTK2 configuration
cat > ~/.gtkrc-2.0 << 'EOF'
gtk-theme-name="Arc-Dark"
gtk-icon-theme-name="Numix"
gtk-font-name="Ubuntu Nerd Font 11"
gtk-cursor-theme-name="Adwaita"
gtk-cursor-theme-size=24
style "user-font" {
    font_name="Ubuntu Nerd Font 11"
}
widget_class "*" style "user-font"
EOF

# ======================================================
banner " 13. CONFIGURE QT5 THEMES"
# ======================================================
print_status "    Configuring Qt5 theme..."

mkdir -p ~/.config/qt5ct
cat > ~/.config/qt5ct/qt5ct.conf << 'EOF'
[Appearance]
style=Fusion
color_scheme_path=/usr/share/qt5ct/colors/darker.conf
custom_palette=false

[Fonts]
fixed="Ubuntu Nerd Font,11,-1,5,50,0,0,0,0,0"
general="Ubuntu Nerd Font,11,-1,5,50,0,0,0,0,0"

[IconTheme]
name=Numix

[Interface]
activate_item_on_single_click=1
buttonbox_layout=0
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=@Invalid()
keyboard_scheme=2
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=@Invalid()
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[Palette]
active=@Invalid()
inactive=@Invalid()
disabled=@Invalid()
EOF

# ======================================================
banner " 14. SET RESOLUTION TO 1920x1080"
# ======================================================
print_status "    Setting resolution to 1920x1080..."

# Add to config.txt for Pi 5
#cat > /boot/firmware/config.txt << 'EOF'
## Force HDMI and set 1920x1080 resolution
#hdmi_force_hotplug=1
#hdmi_group=2
#hdmi_mode=82
#hdmi_drive=2
#EOF

sudo tee /boot/firmware/config.txt >/dev/null <<'EOF'
# Force HDMI and set 1920x1080 resolution
hdmi_force_hotplug=1
hdmi_group=2
hdmi_mode=82
hdmi_drive=2
EOF

# ======================================================
banner " 15. CREATE AUTOSTART CONFIGURATION"
# ======================================================
print_status "    Creating autostart configuration..."

cat > ~/.config/openbox/autostart << 'EOF'
#!/bin/bash

# Start LXQt session
lxqt-session &

# Set background color
feh --bg-solid "#2D2D2D" 2>/dev/null || true
EOF

chmod +x ~/.config/openbox/autostart

sudo mkdir -p /etc/X11/xorg.conf.d
sudo tee /etc/X11/xorg.conf.d/99-vc4.conf >/dev/null <<'EOF'
Section "OutputClass"
    Identifier "vc4"
    MatchDriver "vc4"
    Driver "modesetting"
    Option "PrimaryGPU" "true"
EndSection
EOF


# ======================================================
banner " 16. CREATE CUSTOM ENVIRONMENT VARIABLES"
# ======================================================
print_status "     Setting environment variables..."

sudo tee ~/.profile >/dev/null <<'EOF'
# Set QT theme
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=Fusion

# Set editor
export EDITOR=kate

# Set resolution
xrandr --output HDMI-1 --mode 1920x1080 2>/dev/null || true
EOF

# ======================================================
banner " 17. SET SYSTEM-WIDE FONT"
# ======================================================
print_status "    Setting system-wide font..."

sudo tee /etc/fonts/local.conf >/dev/null <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Ubuntu Nerd Font</family>
    </prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer>
      <family>Ubuntu Nerd Font</family>
    </prefer>
  </alias>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>Ubuntu Nerd Font</family>
    </prefer>
  </alias>
</fontconfig>
EOF

# ======================================================
banner " 18. FINAL CLEANUP"
# ======================================================
print_status "    Cleaning up..."

sudo apt install gldriver-test

# Development tools
sudo apt install  \
    gcc \
    g++ \
    make \
    git \
    curl \
   linux-headers-$(uname -r)

# Clean package cache
sudo apt clean

# Remove unnecessary packages
sudo apt autoremove -y

print_status "========== SETUP COMPLETE! =========="
print_status "The system will now reboot into your new LXQt/Openbox desktop."
print_status "Default credentials: $(whoami) / your password"
print_status ""
print_status "Features installed:"
print_status "  ✓ LXQt Desktop with Openbox (square windows)"
print_status "  ✓ Arc-Dark themes (GTK2/3 and Openbox)"
print_status "  ✓ Numix Icon Theme"
print_status "  ✓ Ubuntu Nerd Font (system-wide)"
print_status "  ✓ Oh-My-Posh with default theme (robust installation)"
print_status "  ✓ Left-side panel with clock, volume, network, wifi, update"
print_status "  ✓ All requested applications and development tools"
print_status "  ✓ Pi-Apps (Raspberry Pi App Store)"
print_status "  ✓ Resolution set to 1920x1080"
print_status ""
