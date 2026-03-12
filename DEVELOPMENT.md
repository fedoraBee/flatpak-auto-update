# Development Guide

This document provides instructions for developers who wish to modify, build, and test **Flatpak Auto Update** locally.

## 🛠 Project Standards

- **Idempotency:** The update script must handle "No updates available" gracefully by cleaning up its own pre-update snapshots.
- **Atomic Operations:** Every update attempt must be preceded by a Snapper `pre` snapshot and followed by a `post` snapshot only if changes occurred.
- **Reporting:** System status and update logs are delivered via local mail (`s-nail`/`mailx`).
- **Packaging:** All components are managed via the RPM spec file in `specs/`.

## 🏗 Architectural Overview

- **`scripts/`**: Contains the core logic (`flatpak-auto-update.sh`).
- **`systemd/`**: Defines the `oneshot` service and the `daily` timer.
- **`config/`**: Holds the environment-based configuration (`env.conf`).
- **`specs/`**: RPM packaging definition for deployment.

## 📦 Local Development & Packaging

To test changes locally, you can rebuild and reinstall the RPM package.

### Prerequisites
Ensure the RPM build tree exists:
```bash
mkdir -p ~/rpmbuild/{SOURCES,SPECS,RPMS,SRPMS,BUILD}
```

### Build & Install Workflow
1. **Sync sources to `rpmbuild`:**
   ```bash
   cp scripts/flatpak-auto-update.sh ~/rpmbuild/SOURCES/
   cp systemd/flatpak-auto-update.service ~/rpmbuild/SOURCES/
   cp systemd/flatpak-auto-update.timer ~/rpmbuild/SOURCES/
   cp config/env.conf ~/rpmbuild/SOURCES/
   cp README.md ~/rpmbuild/SOURCES/
   cp LICENSE ~/rpmbuild/SOURCES/
   cp specs/flatpak-auto-update.spec ~/rpmbuild/SPECS/
   ```

2. **Build the RPM:**
   ```bash
   rpmbuild -bb ~/rpmbuild/SPECS/flatpak-auto-update.spec
   ```

3. **(Re)install the package:**
   ```bash
   # Use 'reinstall' if the package is already on the system, otherwise 'install'
   sudo dnf reinstall ~/rpmbuild/RPMS/noarch/flatpak-auto-update-1.*.noarch.rpm
   ```

4. **Enable the systemd timer:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now flatpak-auto-update.timer
   ```

## ✅ Validation
- **Script Syntax:** `bash -n scripts/flatpak-auto-update.sh`
- **Service Files:** `systemd-analyze verify systemd/*` (where applicable)
- **RPM Lint:** `rpmlint specs/flatpak-auto-update.spec`
