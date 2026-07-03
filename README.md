# dotfiles

Personal configuration, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a **stow package**. Its internal layout mirrors
`$HOME`, so stowing a package symlinks its files into the right place.

## Packages

| Package   | Symlinks to           |
| --------- | --------------------- |
| `nvim`    | `~/.config/nvim`      |
| `wezterm` | `~/.config/wezterm`   |
| `zsh`     | `~/.zshrc`            |

## Setup on a new machine

```sh
git clone git@github.com:brentibanez331/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew install stow
stow nvim wezterm zsh
```

After stowing, open Neovim once and run `:Lazy restore` to install the exact
plugin versions pinned in `nvim/.config/nvim/lazy-lock.json`.

## Adding a new config

1. Move the real file into a package, mirroring its path under `$HOME`
   (e.g. `~/.gitconfig` -> `git/.gitconfig`).
2. `stow git` to symlink it back.

## Removing / re-linking

- Unlink a package: `stow -D nvim`
- Re-link after changes: `stow -R nvim`
