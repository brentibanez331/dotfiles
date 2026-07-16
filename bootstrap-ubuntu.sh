#!/usr/bin/env bash
# bootstrap-ubuntu.sh -- install everything the nvim dotfiles need on Ubuntu.
# Target: Ubuntu 22.04 / 24.04, x86_64. For arm64, swap the arch strings noted inline.
# Safe to re-run.
set -euo pipefail

ARCH_NVIM="nvim-linux-x86_64"          # arm64: nvim-linux-arm64
ARCH_TS="tree-sitter-linux-x64"        # arm64: tree-sitter-linux-arm64

echo "==> [1/5] apt packages (git, stow, compiler, ripgrep, go, node)"
sudo apt-get update
sudo apt-get install -y \
  git stow build-essential curl unzip ripgrep \
  golang-go nodejs npm

echo "==> [2/5] Neovim 0.12 (apt's version is too old for Treesitter 'main')"
curl -fsSLo /tmp/nvim.tar.gz \
  "https://github.com/neovim/neovim/releases/download/stable/${ARCH_NVIM}.tar.gz"
sudo rm -rf "/opt/${ARCH_NVIM}"
sudo tar -C /opt -xzf /tmp/nvim.tar.gz
sudo ln -sf "/opt/${ARCH_NVIM}/bin/nvim" /usr/local/bin/nvim

echo "==> [3/5] tree-sitter CLI (Treesitter 'main' builds parsers with it)"
curl -fsSLo /tmp/ts.gz \
  "https://github.com/tree-sitter/tree-sitter/releases/latest/download/${ARCH_TS}.gz"
gunzip -f /tmp/ts.gz
sudo install -m755 /tmp/ts /usr/local/bin/tree-sitter

echo "==> [4/5] clone dotfiles + stow nvim"
# NOTE: the repo is private. This VPS needs GitHub access first -- either an SSH
# key added to your GitHub account, or clone over HTTPS with a token. See below.
if [ ! -d "$HOME/dotfiles" ]; then
  git clone git@github.com:brentibanez331/dotfiles.git "$HOME/dotfiles"
fi
cd "$HOME/dotfiles"
stow nvim

echo "==> [5/5] versions"
nvim --version | head -1
go version
node --version
tree-sitter --version

echo ""
echo "Done. Launch 'nvim' -- lazy.nvim installs plugins on first run,"
echo "and Mason will fetch gopls / ts_ls / lua_ls (Go + npm are now present)."
