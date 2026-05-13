#!/usr/bin/env bash
set -euo pipefail

# Configuration
PKGNAME="sidra-bin"
UPSTREAM_REPO="wimpysworld/sidra"
PKGBUILD_FILE="PKGBUILD"

# Fetch latest version from GitHub API
echo "Checking for updates..."
LATEST_VERSION=$(curl -s "https://api.github.com/repos/${UPSTREAM_REPO}/releases/latest" | jq -r .tag_name | sed 's/^v//')

# Read current version from PKGBUILD
CURRENT_VERSION=$(grep -P '^pkgver=' "${PKGBUILD_FILE}" | cut -d= -f2)

echo "Current version: ${CURRENT_VERSION}"
echo "Latest version:  ${LATEST_VERSION}"

# if [[ "${LATEST_VERSION}" == "${CURRENT_VERSION}" ]]; then
#     echo "No update needed."
#     exit 0
# fi

echo "Updating to version ${LATEST_VERSION}..."

# Update PKGBUILD pkgver
sed -i "s/^pkgver=.*/pkgver=${LATEST_VERSION}/" "${PKGBUILD_FILE}"
# Reset pkgrel to 1
sed -i "s/^pkgrel=.*/pkgrel=3/" "${PKGBUILD_FILE}"

# Update checksums
# We use 'makepkg -g' to get the new checksums and 'sed' to update them in PKGBUILD
echo "Generating new checksums..."
NEW_SUMS=$(makepkg -g 2>/dev/null)
# Extract the array content
SUM_VALUES=$(echo "${NEW_SUMS}" | sed -n "s/^sha256sums_x86_64=('\(.*\)')/\1/p")

# Replace in PKGBUILD
sed -i "s/^sha256sums_x86_64=.*/sha256sums_x86_64=('${SUM_VALUES}')/" "${PKGBUILD_FILE}"

# Update .SRCINFO
echo "Updating .SRCINFO..."
makepkg --printsrcinfo > .SRCINFO

echo "Update complete!"
echo "New version: ${LATEST_VERSION}"
