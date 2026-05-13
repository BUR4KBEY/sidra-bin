# sidra-bin — AUR package

> An elegant Apple Music desktop client for Linux.  
> No frippery, just quality. A better class of Cider 🍎

Upstream: <https://github.com/wimpysworld/sidra>

---

## Why `-bin`?

Sidra depends on [CastLabs Electron](https://github.com/castlabs/electron-releases)
(`wvcus` variant) for Widevine DRM support on Linux. Standard Electron cannot
be substituted, and the build system requires Nix with flakes and EVS production
signing credentials. A source build inside a clean `makepkg` chroot is not
feasible, so this package installs the official pre-built AppImage from GitHub
Releases instead.

---

## Installation

```bash
# Using paru
paru -S sidra-bin

# Using yay
yay -S sidra-bin

# Manual
git clone https://aur.archlinux.org/sidra-bin.git
cd sidra-bin
makepkg -si
```

---

## Updating checksums after a new release

Before pushing a version bump, download the AppImages and update the
`sha256sums_*` arrays in the PKGBUILD:

```bash
curl -LO https://github.com/wimpysworld/sidra/releases/download/<VERSION>/Sidra-linux-x86_64.AppImage
sha256sum Sidra-linux-x86_64.AppImage
```

Then regenerate `.SRCINFO`:

```bash
makepkg --printsrcinfo > .SRCINFO
```

---

## What the package does

| Step | Detail |
|------|--------|
| Extract | Runs `Sidra-linux-<arch>.AppImage --appimage-extract` — no FUSE needed |
| Install app | Copies `squashfs-root/` → `/opt/sidra/` |
| Wrapper | `/usr/bin/sidra` → `exec /opt/sidra/sidra "$@"` |
| Desktop entry | Installs to `/usr/share/applications/sidra.desktop` |
| Icons | Installs hicolor icon theme entries from inside the AppImage |
| Sandbox | Sets `chrome-sandbox` setuid root (required by Chromium) |

---

## MPRIS / media controls

Sidra registers `org.mpris.MediaPlayer2.sidra` on the D-Bus session bus.
Any MPRIS-aware front-end (KDE, GNOME Shell, `playerctl`, GSConnect, …)
will see Sidra automatically once it is running — no extra configuration needed.

---

## Maintainer notes

- The AppImage artifact name deliberately omits the version
  (`Sidra-linux-x86_64.AppImage`, not `Sidra-0.3.3-linux-x86_64.AppImage`).
  This is set by `build.appImage.artifactName` in `package.json`.
- Bump `pkgver`, update `sha256sums_*`, regenerate `.SRCINFO`, push.
- License is [BlueOak-1.0.0](https://blueoakcouncil.org/license/1.0.0) —
  a permissive, OSI-approved license.
