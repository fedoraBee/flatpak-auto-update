# Contributing to Flatpak Auto Update

First off, thank you for considering contributing! Projects like this thrive on community feedback and improvements.

## 📜 Code of Conduct
By participating in this project, you agree to maintain a professional and respectful environment. Please report any issues or suggested improvements via GitHub Issues.

## 🛠 Development Workflow

### 1. Fork and Clone
Fork the repository and clone it to your local Fedora/RPM-based machine.

### 2. Environment Setup
Ensure you have the necessary development tools installed:
```bash
sudo dnf install fedora-packager rpm-build shellcheck rpmlint
```

### 3. Making Changes
- **Branching:** Create a feature branch for your changes (e.g., `feat/your-feature`).
- **Standards:** We use `set -euo pipefail` in all scripts. Ensure your code is idempotent and handles non-Btrfs/non-Snapper environments gracefully.
- **Variables:** Use **UPPERCASE** for all environment variables in `env.conf` and the main script.

### 4. Testing Your Changes
The project root includes a build helper `build-rpm.sh` to make testing easy. This script automates the sync, build, and optional installation process.

```bash
chmod +x build-rpm.sh

# To build only:
./build-rpm.sh

# To build, install locally, and clean up build artifacts:
./build-rpm.sh --install --clean
```

### 5. Version Management & Changelog
When contributing a fix or feature, please ensure the metadata is updated:
- **RPM Spec:** Increment the `Release` number (or `Version` if applicable) in `specs/flatpak-auto-update.spec`.
- **CHANGELOG.md:** Add a brief note under the current version or a new version header. Ensure the date and version match the Spec file exactly.
- **RPM Changelog:** Add a matching entry to the `%changelog` section at the bottom of the Spec file.

### 6. Validation
Before submitting a Pull Request, please run:
- **Linting:** `shellcheck scripts/flatpak-auto-update.sh`
- **Spec Check:** `rpmlint specs/flatpak-auto-update.spec`

## 📬 Submitting a Pull Request
1. **Commit:** Use descriptive commit messages (e.g., `fix: resolve s-nail pathing on secondary distros`).
2. **Push:** Push to your fork and submit a Pull Request to the `main` branch.

## ⚖️ License
By contributing, you agree that your contributions will be licensed under the **GPL-3.0-or-later** license.
