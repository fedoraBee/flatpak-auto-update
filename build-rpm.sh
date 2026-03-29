#!/bin/bash
set -e

# --- Environment Normalization ---
cd "$(dirname "$0")"

# --- Configuration & Flags ---
SPEC_FILE="specs/flatpak-auto-update.spec"
INSTALL_RPM=false
CLEAN_BUILD=false

# Check for flags
for arg in "$@"; do
    case $arg in
        --install) INSTALL_RPM=true ;;
        --clean)   CLEAN_BUILD=true ;;
    esac
done

# --- Dynamic Version Extraction ---
VERSION=$(grep -i '^Version:' "$SPEC_FILE" | awk '{print $2}')
RELEASE=$(grep -i '^Release:' "$SPEC_FILE" | awk '{print $2}' | sed 's/%{.*}//')

echo "🚀 Starting v${VERSION}-${RELEASE} Build..."

# 1. Pre-flight Check
REQUIRED_FILES=(
    "$SPEC_FILE"
    "scripts/flatpak-auto-update.sh"
    "systemd/flatpak-auto-update.service"
    "systemd/flatpak-auto-update.timer"
    "config/env.conf"
    "README.md"
    "LICENSE"
    "CHANGELOG.md"
    "DEVELOPMENT.md"
    "CONTRIBUTING.md"
)

echo "🔍 Checking dependencies in: $(pwd)"
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Error: Required file '$file' is missing!"
        exit 1
    fi
done

# 2. Ensure rpmbuild structure exists
mkdir -p ~/rpmbuild/{SOURCES,SPECS,RPMS,BUILD,SRPMS}

# 3. Sync sources to rpmbuild
cp scripts/flatpak-auto-update.sh ~/rpmbuild/SOURCES/
cp systemd/flatpak-auto-update.service ~/rpmbuild/SOURCES/
cp systemd/flatpak-auto-update.timer ~/rpmbuild/SOURCES/
cp config/env.conf ~/rpmbuild/SOURCES/
cp README.md ~/rpmbuild/SOURCES/
cp LICENSE ~/rpmbuild/SOURCES/
cp CHANGELOG.md ~/rpmbuild/SOURCES/
cp DEVELOPMENT.md ~/rpmbuild/SOURCES/
cp CONTRIBUTING.md ~/rpmbuild/SOURCES/
cp "$SPEC_FILE" ~/rpmbuild/SPECS/

# 4. Build the RPM
rpmbuild -bb ~/rpmbuild/SPECS/$(basename "$SPEC_FILE")

echo "📦 Build Complete: v${VERSION}-${RELEASE}"

# 5. Optional Install & Status Check
if [ "$INSTALL_RPM" = true ]; then
    echo "🔍 Checking installation status..."
    RPM_PATH=~/rpmbuild/RPMS/noarch/flatpak-auto-update-${VERSION}-${RELEASE}*.noarch.rpm
    
    if ls $RPM_PATH >/dev/null 2>&1; then
        sudo dnf install -y $RPM_PATH
        echo "✅ v${VERSION}-${RELEASE} Deployed Successfully!"
        
        echo "⚙️ Verifying systemd components..."
        sudo systemctl daemon-reload
        sudo systemctl enable --now flatpak-auto-update.timer
        
        if systemctl is-active --quiet flatpak-auto-update.timer; then
            echo "⏰ Timer is ACTIVE and scheduled."
        else
            echo "⚠️ Warning: Timer is installed but not active."
        fi
    else
        echo "❌ Error: RPM not found at $RPM_PATH"
        exit 1
    fi
fi

# 6. Optional Cleanup
if [ "$CLEAN_BUILD" = true ]; then
    echo "🧹 Cleaning up build artifacts..."
    # Remove sourced files from the central RPM sources folder
    rm -f ~/rpmbuild/SOURCES/flatpak-auto-update.sh
    rm -f ~/rpmbuild/SOURCES/flatpak-auto-update.service
    rm -f ~/rpmbuild/SOURCES/flatpak-auto-update.timer
    rm -f ~/rpmbuild/SOURCES/env.conf
    rm -f ~/rpmbuild/SOURCES/*.md
    rm -f ~/rpmbuild/SOURCES/LICENSE
    
    # Remove the temporary build directory
    rm -rf ~/rpmbuild/BUILD/flatpak-auto-update-${VERSION}*
    
    echo "✨ Workspace cleaned."
else
    echo "💡 Note: Build artifacts preserved in ~/rpmbuild/. Use --clean to purge."
fi

if [ "$INSTALL_RPM" = false ]; then
    echo "💡 To build and install, use: ./build-rpm.sh --install"
fi