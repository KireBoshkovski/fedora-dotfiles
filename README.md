# Lenovo Yoga Slim 7 14AKP10 Linux Audio Fix

This repository provides a possible fix for the quad-speaker audio issue on the **Lenovo Yoga Slim 7 14AKP10** (AMD Ryzen 7 8845HS / 14" OLED model) running Linux distributions like Fedora, Arch, or Ubuntu.

## The Problem
This laptop features a premium **4-speaker system** (2 Tweeters/Front + 2 Woofers/Rear) supported by Dolby Atmos. However, the Linux kernel (specifically the `snd_hda_intel` driver) fails to recognize the full speaker topology because:

1.  **Hidden Pins:** The BIOS/ACPI tables do not correctly report the Front Tweeter pins (Node 0x17) to the OS, leaving them in a `[N/A]` (Not Connected) state.
2.  **Subsystem ID Mismatch:** Standard kernel "quirks" for other Yoga models do not match the Subsystem ID of this specific model (`17aa:391a`).
3.  **Dual-Card Conflict:** The laptop has two audio controllers (AMD HDMI and Realtek ALC287). Standard configuration attempts often fail because they target the wrong controller.

**Result:** Out of the box, only the front speakers work, providing thin, low-volume audio.

## The Fix
This fix uses a **Firmware Patching** method to bypass the kernel's default detection:

1.  **`alc287-yoga.fw`**: A custom firmware patch that forces **Node 0x17** to be active and mapped as an Internal Speaker. This "physically" connects the front tweeters at the driver level.
2.  **`lenovo-audio.conf`**: A kernel module configuration that tells the driver to ignore the HDMI card (Card 0) and apply the custom patch specifically to the Realtek ALC287 (Card 1).
3.  **`install.sh`**: An automation script that copies the files, sets permissions, and updates the system's boot image (initramfs/dracut).

**`alc287-yoga.fw`** contents:

```bash
[Codec]
0x10ec0287 0x17aa391a 0

[Pincfg]
# Node 0x14 is your Bass/Woofer (already working, keeping it default)
0x14 0x90170110
# Node 0x17 is your Tweeter/Front (currently N/A, we force it ON)
0x17 0x90170111
```

**`lenovo-audio.conf`** contents:

```bash
options snd-hda-intel patch=,alc287-yoga.fw
```

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/KireBoshkovski/fedora-dotfiles.git
cd fedora-dotfiles
```
### 2. Run the installer

```bash
chmod +x install.sh
sudo ./install.sh
```

### 3. Full shutdown

IMPORTANT: After the script finishes, perform a complete Power Off (not just a restart). This ensures the Realtek chip is fully reset and loads the new pin mapping.

Also, Keep In mind that this fix may work solution may together with some other actions I did before hand while trying to fix the problem but I chose .
