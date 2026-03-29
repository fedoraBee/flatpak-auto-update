Name:           flatpak-auto-update
Version:        1.0.3
Release:        1%{?dist}
Summary:        Automated Flatpak updates with optional snapshots and mail notifications
License:        GPL-3.0-or-later
BuildArch:      noarch
Requires:       flatpak, snapper, s-nail, systemd

%description
Automates Flatpak updates with pre/post Snapper snapshots and email alerts.
Includes integrated logic to avoid unnecessary snapshots, calculates update
counts for email subjects, and provides universal compatibility by 
automatically detecting Btrfs/Snapper support before execution.

%install
# 1. Create the system directories
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_unitdir}
mkdir -p %{buildroot}%{_sysconfdir}/flatpak-auto-update

# 2. Install functional files from SOURCES to BUILDROOT
install -p -m 755 %{_sourcedir}/flatpak-auto-update.sh %{buildroot}%{_bindir}/flatpak-auto-update
install -p -m 644 %{_sourcedir}/flatpak-auto-update.service %{buildroot}%{_unitdir}/
install -p -m 644 %{_sourcedir}/flatpak-auto-update.timer %{buildroot}%{_unitdir}/
install -p -m 644 %{_sourcedir}/env.conf %{buildroot}%{_sysconfdir}/flatpak-auto-update/env.conf

# 3. Copy documentation to current BUILD directory for %doc to find
cp %{_sourcedir}/README.md .
cp %{_sourcedir}/LICENSE .
cp %{_sourcedir}/CHANGELOG.md .
cp %{_sourcedir}/DEVELOPMENT.md .
cp %{_sourcedir}/CONTRIBUTING.md .

%files
# --- Binary & Systemd Units ---
%{_bindir}/flatpak-auto-update
%{_unitdir}/flatpak-auto-update.service
%{_unitdir}/flatpak-auto-update.timer

# --- Configuration ---
%dir %{_sysconfdir}/flatpak-auto-update
%config(noreplace) %{_sysconfdir}/flatpak-auto-update/env.conf

# --- Documentation & License ---
%license LICENSE
%doc README.md
%doc CHANGELOG.md
%doc DEVELOPMENT.md
%doc CONTRIBUTING.md

%changelog
* Sun Mar 29 2026 Alex <alex@localhost> - 1.0.3-1
- Added dynamic build-rpm.sh helper script to project root.
- Included DEVELOPMENT.md and CONTRIBUTING.md in package documentation.
- Standardized project structure for open-source contribution.
- Integrated filesystem safety check to automatically detect Snapper/Btrfs support.
- Improved error handling for non-Btrfs environments.
- Added CHANGELOG.md to the package documentation.

* Sun Mar 29 2026 Alex <alex@localhost> - 1.0.2-1
- Standardized configuration variables to UPPERCASE (EMAIL_TO, EMAIL_FROM).
- Optimized notification logic with late-binding variable evaluation.

* Sun Mar 29 2026 Alex <alex@localhost> - 1.0.1-1
- Fixed macro path resolution for LICENSE and README.
- Added dynamic package count to email subject line.