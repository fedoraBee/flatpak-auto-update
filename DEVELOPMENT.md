# Development Guide

## 🏗 Build System (v1.0.3)
The project uses `build-rpm.sh` in the project root to handle the RPM lifecycle.

### Automated Build & Deploy
```bash
./build-rpm.sh --install --clean
```

### Manual Step-by-Step
1. **Sync Sources:**
   ```bash
   cp scripts/* systemd/* config/* *.md LICENSE ~/rpmbuild/SOURCES/
   cp specs/*.spec ~/rpmbuild/SPECS/
   ```
2. **Build:**
   ```bash
   rpmbuild -bb ~/rpmbuild/SPECS/flatpak-auto-update.spec
   ```
3. **Install:**
   ```bash
   sudo dnf install ~/rpmbuild/RPMS/noarch/flatpak-auto-update-1.0.3-1.*.noarch.rpm
   ```

## 🧪 Testing Universal Compatibility
Since v1.0.3, the script includes a **Filesystem Safety Check**. To test the logic without changing your actual hardware setup:

1. **Simulate a Missing Config:**
   Run the script while pointing to a non-existent Snapper configuration:
   ```bash
   sudo SNAPPER_CONFIG="invalid_test" /usr/bin/flatpak-auto-update
   ```
   *Expected: The script should output a WARNING, disable snapshots automatically, and proceed with the Flatpak update.*

2. **Manual Override:**
   Disable snapshots explicitly via your local configuration:
   ```bash
   # Edit /etc/flatpak-auto-update/env.conf
   ENABLE_SNAPSHOTS="no"
   ```

## ✅ Validation
The build script is designed to fail-fast (`set -e`). Before submitting changes, please verify:
- **Linting:** `shellcheck scripts/flatpak-auto-update.sh`
- **Spec Check:** `rpmlint specs/flatpak-auto-update.spec`
- **Integrity:** Ensure `CHANGELOG.md` version matches the `.spec` file.

---
*Maintained by fedoraBee - 2026*
