# portable opinionated toolchain and terminal organizer (potato)

## Philosophy

- Dotfiles in git
- Userland tools in Nix
- Desktop apps split between Flatpak and the system package manager
- Host/system config left to the distro

Distro owns the host: drivers, system services, audio, networking, GPU, login manager.

Nix owns the userland: CLI tools, editors, language toolchains — everything in `nix/userland.nix`.

Flatpak owns portable desktop apps: Slack, Discord, Spotify, Obsidian.

The system package manager owns apps that need tighter host integration: KeePassXC, nextcloud-client.

## Layout

```
potato/
  flake.nix          # Nix flake defining the userland package
  nix/
    userland.nix     # list of Nix-managed tools
  config/
    nvim/            # Neovim config
    ghostty/         # Ghostty terminal config
    tmux/            # tmux config
    bash/            # bashrc
    ssh/             # SSH client config
  apps/
    arch-pacman.txt  # pacman packages
  scripts/
    link.sh          # symlinks config into $HOME
    sync.sh
  bootstrap/
    arch.sh          # Arch Linux
    ubuntu.sh        # Ubuntu
    common.sh
```

## New machine setup

```bash
git clone https://github.com/xela144/potato.git ~/potato
cd ~/potato
./bootstrap/arch.sh   # or ubuntu.sh
```

That script:
1. Installs Nix (if missing)
2. Runs `nix profile install .#userland`
3. Runs `scripts/link.sh` to symlink dotfiles

## Day-to-day

Add a tool: add it to `nix/userland.nix`, then:

```bash
nix profile upgrade userland
```

Add a dotfile: drop it in `config/`, add a `ln -snf` line to `scripts/link.sh`, re-run link.sh.

tmux plugins: after first launch, hit `C-s I` to install plugins via tpm.

## Rules

- One source of truth per package — if it's in Nix, don't also install it via the system package manager.
- Track config, not state. No browser profiles, caches, tokens, or machine-specific state.
