#!/bin/bash
# First install of claude-team on a Mac, Ubuntu or Omarchy machine:
#
#   curl -fsSL https://raw.githubusercontent.com/Cloud-Lobsters/claude-team/main/install.sh | bash
#
# It installs Claude Code, gh and jq when they are missing, fetches the newest signed
# release of claude-team, verifies it, installs it under /usr/local (asks for your password),
# and runs `claude-team setup`. After this, updates come through `claude-team upgrade`;
# this script is never run again.
#
# Trust on first use: this script and the maintainer key it verifies against both come
# from GitHub in this one run. It prints the key's fingerprint; compare it with the one in
# the team onboarding note before you type your password.

set -eu
TOOLING_REPO="Cloud-Lobsters/claude-team"
SIGNER="release@cloudlobsters.com"
NAMESPACE="claude-team"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

say() { printf '\033[1m%s\033[0m\n' "$1"; }
die() { printf 'install: %s\n' "$1" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

case "$(uname -s)" in
  Darwin) os=mac ;;
  Linux)
    if has pacman; then os=arch; elif has apt-get; then os=debian; else die "Linux without apt or pacman is not supported"; fi ;;
  *) die "unsupported OS $(uname -s)" ;;
esac

say "1. Tools"
if ! has git; then
  case $os in mac) xcode-select --install 2>/dev/null; die "install the Xcode command line tools, then run this again" ;;
    debian) sudo apt-get install -y git ;; arch) sudo pacman -S --needed --noconfirm git ;; esac
fi
if ! has claude; then
  echo "  installing Claude Code"; curl -fsSL https://claude.ai/install.sh | bash
fi
if ! has gh; then
  echo "  installing GitHub CLI"
  case $os in
    mac)
      if ! has brew; then
        echo "  installing Homebrew first"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" </dev/tty
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
      fi
      brew install gh ;;
    debian)
      sudo mkdir -p -m 755 /etc/apt/keyrings
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
      sudo apt-get update -q && sudo apt-get install -y gh ;;
    arch) sudo pacman -S --needed --noconfirm github-cli ;;
  esac
fi
if ! has jq; then
  echo "  installing jq"
  case $os in mac) brew install jq ;; debian) sudo apt-get install -y jq ;; arch) sudo pacman -S --needed --noconfirm jq ;; esac
fi
has ssh-keygen || die "ssh-keygen is missing; it comes with OpenSSH"
echo "  git, Claude Code, gh, jq: ok"

say "2. GitHub"
if ! gh auth status >/dev/null 2>&1; then
  echo "  Sign in to GitHub, then run this install again:"
  echo "    gh auth login"
  exit 1
fi
echo "  signed in as $(gh api user --jq .login 2>/dev/null || echo '?')"

say "3. Newest claude-team release"
latest="$(GIT_TERMINAL_PROMPT=0 git ls-remote --tags --refs "https://github.com/$TOOLING_REPO" 'v[0-9]*' 2>/dev/null \
  | sed -n 's#.*refs/tags/v##p' | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)"
[ -n "$latest" ] || die "no releases found at github.com/$TOOLING_REPO"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
asset="claude-team-$latest.tar.gz"; base="https://github.com/$TOOLING_REPO/releases/download/v$latest"
for f in "$asset" SHA256SUMS SHA256SUMS.sig; do
  curl -fsSL --retry 2 -o "$tmp/$f" "$base/$f" \
    || gh release download "v$latest" --repo "$TOOLING_REPO" --pattern "$f" --dir "$tmp" \
    || die "could not download $f"
done
tar -xzf "$tmp/$asset" -C "$tmp"
tree="$tmp/claude-team-$latest"
signers="$tree/share/allowed_signers"
grep -qv '^#' "$signers" 2>/dev/null || die "the release carries no maintainer key; refusing to install"
ssh-keygen -Y verify -f "$signers" -I "$SIGNER" -n "$NAMESPACE" -s "$tmp/SHA256SUMS.sig" < "$tmp/SHA256SUMS" >/dev/null \
  || die "release v$latest is not signed by the key it ships. Refusing to install."
if has shasum; then (cd "$tmp" && shasum -a 256 -c SHA256SUMS >/dev/null); else (cd "$tmp" && sha256sum -c SHA256SUMS >/dev/null); fi \
  || die "checksum mismatch; refusing to install"
echo "  v$latest: signature and checksums ok"
echo "  Maintainer key fingerprint (compare with the onboarding note):"
grep -v '^#' "$signers" | awk '{for (i = 1; i <= NF; i++) if ($i ~ /^(ssh-|ecdsa-|sk-)/) {print $i" "$(i+1); break}}' \
  | while read -r type key; do echo "$type $key" | ssh-keygen -lf - 2>/dev/null | sed 's/^/    /'; done
echo

say "4. Install (asks for your password)"
sudo bash "$tree/bin/claude-team" install-files "$tree" </dev/tty

say "5. Set up this machine"
exec /usr/local/bin/claude-team setup </dev/tty
