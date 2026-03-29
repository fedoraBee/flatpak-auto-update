# Flatpak Auto Update (Universal RPM Edition)

**Flatpak Auto Update** is a robust system utility for Fedora and RPM-based Linux distributions that orchestrates Flatpak package updates with atomic-like safety using Snapper snapshots and provides intelligent, dynamic email reporting.

---

## 🚀 Overview

This utility ensures your Flatpak environment remains current without manual overhead. By leveraging Btrfs snapshots, it creates a reliable "time machine" for your applications. Starting with v1.0.3, it features **Universal Compatibility**, allowing it to run safely on systems with or without Snapper/Btrfs support.

### Key Features
- **Atomic-like Safety:** Automatically pairs Snapper `pre` and `post` snapshots for every successful update session.
- **Universal Logic:** Automatically detects if Snapper/Btrfs is available; if not, it gracefully degrades to a safe "update-only" mode.
- **Smart Notifications:** Subject lines dynamically include package counts: `[hostname] flatpak-auto-update: 5 new upgrades have been installed.`.
- **Optimization-First:** Performs a zero-impact dry-run check to prevent unnecessary disk writes and snapshots.
- **Developer Tooling:** Includes a dynamic build helper for rapid RPM generation and testing.

---

## 🛠 Technical Logic Flow (v1.0.3)

1. **Safety Check:** The script verifies the Snapper configuration. If Btrfs or the specified config is missing, snapshots are disabled to prevent errors.
2. **Zero-Impact Check:** Executes `flatpak update --dry-run`. If the system is current, the script terminates.
3. **Pre-Update State:** A Snapper `pre` snapshot is generated (if enabled/supported).
4. **Automated Execution:** Updates are applied in non-interactive mode (`flatpak update -y`).
5. **Change Analysis:** The script parses the output to calculate exactly how many packages were modified.
6. **Conditional Finalization:**
   - **On Success:** A `post` snapshot is linked; a notification is sent with the dynamic package count.
   - **On Failure:** Any "orphan" `pre` snapshot is purged to save space, and a failure report is dispatched.

---

## 📥 Installation

### For Users
Install the latest stable RPM package:
```bash
sudo dnf install flatpak-auto-update-1.0.3-1.*.noarch.rpm
```

### For Developers (Build from Source)
The project includes a build helper `build-rpm.sh` in the project root to automate the RPM lifecycle.

**To Build Only:**
```bash
./build-rpm.sh
```

**To Build and Install Locally:**
```bash
./build-rpm.sh --install
```

---

## ⚙️ Usage

The utility is managed by a systemd timer for automated daily maintenance.

### Check the Schedule
To see the next scheduled execution:
```bash
systemctl list-timers flatpak-auto-update.timer
```

### Manual Trigger
To initiate an update cycle immediately:
```bash
sudo systemctl start flatpak-auto-update.service
```

---

## 🔧 Configuration

Settings are managed in `/etc/flatpak-auto-update/env.conf`.

```bash
# --- Core Identification ---
EMAIL_FROM="bot@$(hostname)"
EMAIL_TO="admin@example.com"

# --- Feature Toggles ---
ENABLE_EMAIL=yes
ENABLE_SNAPSHOTS=yes  # Set to "no" to force-disable snapshots

# --- Notification Customization ---
EMAIL_FROM_DISPLAY="Fedora Bot"
# Subject lines support $UPDATE_COUNT and $(hostname)
EMAIL_SUBJECT_SUCCESS="[$(hostname)] flatpak-auto-update: \$UPDATE_COUNT new upgrades have been installed."

# --- Advanced Provider Settings ---
SNAPPER_CONFIG="root"
```

---

## 📋 Dependencies & Compatibility

* **flatpak**: Application lifecycle management.
* **snapper**: Btrfs snapshot orchestration (Optional/Detected).
* **mailx/s-nail**: SMTP notification delivery.
* **systemd**: Service scheduling and logging.

*Compatible with Fedora, RHEL, and other modern RPM-based distributions.*

---
*License: GPL-3.0-or-later* *Maintained by fedoraBee - 2026*
