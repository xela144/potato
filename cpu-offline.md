# env

Portable Linux user environment for Arch + Nix.

## Goal

Keep a setup that is easy to restore on a new laptop:

- dotfiles in git
- userland tools in Nix
- desktop apps split between Flatpak and pacman
- host/system stuff left to the distro

This repo is for:

- shell/editor/tool config
- Nix-managed user tools
- app install lists
- bootstrap scripts

This repo is not for:

- drivers
- system services
- GPU/audio/network stack
- browser profiles
- caches
- secrets

## Ownership model

Arch owns the host system.

Examples:

- sway
- seat/session setup
- xdg-desktop-portal
- audio
- bluetooth
- networking
- GPU drivers
- firmware
- login/session manager
- system daemons

Nix owns the userland.

Examples:

- git
- neovim
- tmux
- ripgrep
- fd
- jq
- direnv
- uv
- rust toolchain
- node/pnpm

Flatpak owns portable desktop apps.

Examples:

- Slack
- Discord
- Spotify
- Obsidian

pacman owns desktop apps that want tighter host integration.

Examples:

- KeePassXC
- nextcloud-client

AUR is a small escape hatch, not the default.

## Repo layout

```text
potato/
  flake.nix
  flake.lock
  nix/
    userland.nix
  config/
    nvim/
    sway/
    git/
    bash/
    tmux/
  apps/
    flatpak.txt
    arch-pacman.txt
    arch-aur.txt
  scripts/
    link.sh
  bootstrap/
    arch.sh
    ubuntu.sh
  .gitignore
  README.md
```

## What goes where

### `config/`

This is the source of truth for text config.

Examples:

- `config/nvim`
- `config/sway`
- `config/waybar`
- `config/git/.gitconfig`
- `config/bash/.bashrc`
- `config/tmux/tmux.conf`

These get linked into `~/.config` or `$HOME` by `scripts/link.sh`.

### `nix/userland.nix`

This is the list of userland tools installed through Nix.

### `apps/flatpak.txt`

Flatpak app IDs for portable GUI apps.

### `apps/arch-pacman.txt`

Arch-native apps that need better host integration.

### `apps/arch-aur.txt`

AUR-only apps. Keep this list small.

## Example package split

### Nix

- git
- neovim
- tmux
- ripgrep
- fd
- jq
- fzf
- bat
- eza
- direnv
- nix-direnv
- uv
- rustup
- nodejs
- pnpm

### Flatpak

- Slack
- Discord
- Brave if portability matters more than host integration

### pacman

- KeePassXC
- nextcloud-client
- Brave if you want it more native

## Example files

### `flake.nix`

```nix
{
  description = "Portable user environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.${system}.userland = pkgs.buildEnv {
      name = "userland";
      paths = import ./nix/userland.nix { inherit pkgs; };
    };
  };
}
```

### `nix/userland.nix`

```nix
{ pkgs }:
with pkgs; [
  git
  neovim
  tmux
  ripgrep
  fd
  jq
  fzf
  bat
  eza
  direnv
  nix-direnv
  uv
  rustup
  nodejs_22
  pnpm
  nil
]
```

### `apps/flatpak.txt`

```text
com.slack.Slack
com.discordapp.Discord
com.brave.Browser
```

### `apps/arch-pacman.txt`

```text
keepassxc
nextcloud-client
```

### `apps/arch-aur.txt`

```text
# brave-bin
```

### `scripts/link.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$HOME/.config"

ln -snf "$ROOT/config/nvim" "$HOME/.config/nvim"
ln -snf "$ROOT/config/sway" "$HOME/.config/sway"
ln -snf "$ROOT/config/waybar" "$HOME/.config/waybar"
ln -snf "$ROOT/config/tmux/tmux.conf" "$HOME/.tmux.conf"
ln -snf "$ROOT/config/bash/.bashrc" "$HOME/.zshrc"
ln -snf "$ROOT/config/git/.gitconfig" "$HOME/.gitconfig"
```

### `bootstrap/arch.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

sudo pacman -S --needed git curl flatpak

if [[ -s "$ROOT/apps/arch-pacman.txt" ]]; then
  mapfile -t PACMAN_PKGS < <(grep -vE '^\s*#|^\s*$' "$ROOT/apps/arch-pacman.txt")
  if [[ ${#PACMAN_PKGS[@]} -gt 0 ]]; then
    sudo pacman -S --needed "${PACMAN_PKGS[@]}"
  fi
fi

flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo

if [[ -s "$ROOT/apps/flatpak.txt" ]]; then
  mapfile -t FLATPAKS < <(grep -vE '^\s*#|^\s*$' "$ROOT/apps/flatpak.txt")
  if [[ ${#FLATPAKS[@]} -gt 0 ]]; then
    flatpak install -y --user flathub "${FLATPAKS[@]}"
  fi
fi

nix profile install "$ROOT#userland"
"$ROOT/scripts/link.sh"

echo "Done."
echo "AUR packages, if any, are listed in apps/arch-aur.txt"
```

## New laptop flow

1. Install Arch and host/system packages manually.
2. Install Nix.
3. Clone this repo.
4. Run the bootstrap script.

Example:

```bash
git clone https://github.com/YOUR_USER/env.git ~/src/env
cd ~/src/env
./bootstrap/arch.sh
```

That restores:

- userland tools from Nix
- desktop apps from Flatpak and pacman
- dotfiles via symlinks

## Kernel upgrade & reboot risk (Arch)

Arch's `linux` package is a single rolling package, not versioned like
Debian's `linux-image-*`. `pacman -Syu` replaces kernel files in place,
including deleting the old kernel's `/usr/lib/modules/<version>/` directory
immediately - before you've rebooted into the new kernel. Until you reboot,
the running kernel has no module directory, so anything not already loaded
(a USB driver, a new piece of hardware) can fail to load. This is what
happened to an SD card reader after a routine `upgrade.sh` run: the reader
kept enumerating and disconnecting because `usb_storage`/`uas` couldn't be
loaded for the running (already-upgraded-out-from-under) kernel.

Debian avoids this entirely: kernel packages are versioned and installed
side by side, so the running kernel's modules are never deleted out from
under it, and `update-grub` hooks run automatically on install/removal.
Arch does not do this by design (KISS, no per-package special casing) - the
accepted practice is "reboot immediately after a kernel upgrade," not a
tooling fix.

### What we chose to avoid

- `IgnorePkg = linux` in pacman.conf - rejected. Holding back the kernel
  from `-Syu` is a partial upgrade, which Arch explicitly discourages
  (packages can drift out of sync with their dependents). Don't fight
  Arch's model before understanding it.

### What's in place instead

- `needrestart` (`apps/arch-pacman.txt`) - installed via `sync.sh`. Wired
  into `upgrade.sh` after `pacman -Syu` to report whether a reboot (kernel
  changed) or just a service restart (a running daemon's library got
  replaced) is actually needed. Turns "did that upgrade break something"
  into an immediate answer instead of a surprise days later.

### Two different operations - don't conflate them

- `sync.sh` - installs/updates only the packages listed in
  `arch-pacman.txt`, via `pacman -S --needed`. Never touches the kernel,
  never a full system upgrade, no reboot risk. Use this to add one new
  package (e.g. `supercollider`).
- `upgrade.sh` - full `pacman -Syu`. The only sanctioned way to get a
  package's true latest version, but may bump the kernel. `needrestart`
  reports the outcome right after.

### Open questions - still reading up on these

Boot-chain pieces that determine whether a reboot actually succeeds, not
fully understood yet:

- `mkinitcpio` - regenerates the initramfs. Confirmed this runs
  automatically via a pacman hook on every kernel install/upgrade.
- `grub-mkconfig` - regenerates `/boot/grub/grub.cfg` (the actual boot
  menu). NOT triggered by any pacman hook - has to be run manually
  (`sudo grub-mkconfig -o /boot/grub/grub.cfg`) after anything that changes
  what should be bootable. This machine's `grub.cfg` was found to have no
  `vmlinuz` entries at all - unresolved, needs investigating before the
  next reboot.
- `grub-btrfs` + `snapper` - this machine's btrfs root already shows an
  "Arch Linux snapshots" submenu in `grub.cfg`, implying a snapshot-based
  rollback path exists if an upgrade breaks the system. Need to learn how
  this is actually configured and verify it works, rather than assume it
  does.

## Alternative considered: Debian + direnv + flakes

Not adopting this today. Revisit if Arch's upgrade/reboot fragility (see
above) gets costly enough that it stops being worth the time.

The idea: Debian stable (or testing, for fresher hardware support) as the
host OS, instead of Arch.

- Debian's kernel packages are versioned and installed side by side (see
  above) - the running kernel's modules are never deleted out from under
  it. This class of breakage structurally can't happen on Debian the way it
  did on Arch.
- Debian's staleness mostly hurts at the OS/kernel/system-library level
  (older hardware support), not at the project-dependency level. That part
  is handled per-project instead of by the OS:
  - `direnv` + a per-project `flake.nix`/`shell.nix`, `use flake` in
    `.envrc` - same reproducibility model already used for `potato`'s
    userland, just scoped to one project instead of the whole system.
  - Considered `devbox` (Jetify) as a friendlier wrapper around Nix for
    this - skip it. It just gives a JSON config instead of real Nix
    expressions, and `potato` already writes real Nix (`flake.nix`,
    `userland.nix`), so it would be one more tool for no real gain.
  - If Debian stable's kernel is too old for some piece of hardware:
    `linux-image-*-backports`, or run Debian testing instead of stable.
- Considered NixOS too - fully atomic, bootable generations, would solve
  the reboot-fragility problem even more thoroughly than Debian. Ruled out
  for now: too big a time investment (rewriting the whole host as
  `configuration.nix`, and `potato`'s "Arch owns the host" split would need
  to go away) for what is otherwise a "don't want to babysit the OS"
  problem.

## Future option: home-manager

Not adopted yet. Orthogonal to the OS decision above - works the same on
Arch, Debian, or NixOS, since it only manages the user environment, not the
host.

Would replace `nix profile add` + `scripts/link.sh` with one declarative
`home.nix`: package list, dotfile symlinking, and program configs all
applied via `home-manager switch` as an atomic, rollback-able generation.
If a config change breaks something, `home-manager rollback` undoes it -
same safety property as NixOS, but scoped to `~` instead of the whole
system.

Does not fix the Arch kernel/reboot brittleness described above - that's a
host-OS problem, and home-manager only ever touches the user environment.

## Rules

Track config, not state.

Good to track:

- shell config
- editor config
- sway config
- waybar config
- git config
- scripts

Do not track:

- browser profiles
- caches
- tokens
- machine-specific state
- app databases

Keep one source of truth per package.

Examples:

- if `git` comes from Nix, do not also install it via pacman
- if Discord comes from Flatpak, do not also install it via pacman


