#!/bin/bash

# Define file paths
FW_FILE="alc287-yoga.fw"
CONF_FILE="lenovo-audio.conf"
FW_DEST="/lib/firmware/$FW_FILE"
CONF_DEST="/etc/modprobe.d/$CONF_FILE"

# Define user-space path
CONFIG_DIR="$HOME/.config"

echo "--- Lenovo Yoga Slim 7 14AKP10 Audio Fix ---"

# 1. System-Wide Fixes (Requires sudo)
echo "1. Applying Hardware/Kernel Fixes (Requires sudo)..."
sudo cp "$FW_FILE" "$FW_DEST"
sudo cp "$CONF_FILE" "$CONF_DEST"
sudo chmod 644 "$FW_DEST" "$CONF_DEST"

# 2. User-Space Restore (Does NOT require sudo for your own home dir)
echo "2. Restoring user audio configurations to $CONFIG_DIR..."

# Restore Pipewire folder if it exists in git
if [ -d "pipewire" ]; then
    cp -r pipewire "$CONFIG_DIR/"
    echo "   [✓] Pipewire configs restored."
fi

# Restore Pulse folder if it exists in git
if [ -d "pulse" ]; then
    cp -r pulse "$CONFIG_DIR/"
    echo "   [✓] Pulse/Device cache restored."
fi

# Restore pavucontrol.ini if it exists in git
if [ -f "pavucontrol.ini" ]; then
    cp pavucontrol.ini "$CONFIG_DIR/"
    echo "   [✓] pavucontrol settings restored."
fi

# 3. Boot Image Update
echo "3. Updating initramfs..."
if command -v dracut >/dev/null; then
    sudo dracut --force
elif command -v mkinitcpio >/dev/null; then
    sudo mkinitcpio -P
fi

echo "---"
echo "Fix Applied Successfully!"
echo "Please perform a FULL SHUTDOWN (not just restart) for the changes to take effect."
