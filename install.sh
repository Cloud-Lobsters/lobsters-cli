#!/bin/bash
# First install of claude-lobsters-cli on a Mac, Ubuntu or Omarchy machine:
#
#   curl -fsSL https://raw.githubusercontent.com/Cloud-Lobsters/claude-lobsters-cli/main/install.sh | bash
#
# It installs Claude Code, gh and jq when they are missing, fetches the newest signed
# release of claude-lobsters-cli, verifies it, installs it under /usr/local (asks for your password),
# and runs `claude-lobsters-cli setup`. After this, updates come through `claude-lobsters-cli upgrade`;
# this script is never run again.
#
# Trust on first use: this script and the maintainer key it verifies against both come
# from GitHub in this one run. It prints the key's fingerprint; compare it with the one in
# the team onboarding note before you type your password.

set -eu
TOOLING_REPO="Cloud-Lobsters/claude-lobsters-cli"
SIGNER="release@cloudlobsters.com"
NAMESPACE="claude-lobsters-cli"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

say() { printf '\033[1m%s\033[0m\n' "$1"; }
die() { printf 'install: %s\n' "$1" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

# ---- banner: the lobster -------------------------------------------------------------
# One character per pixel, two pixel rows per terminal line (▀ ▄ half blocks), drawn in
# truecolor when the terminal says it has it and 256 colours otherwise. Three frames make
# the pincer snap once. This block is identical in install.sh and bin/claude-lobsters-cli (the
# installer runs before anything is on disk); scripts/release checks that it still is.
LOBSTER=(
  '......R...............R.................'
  '......R..............R..................'
  '.....R...............R..................'
  '.RRR.R..............R...................'
  'RRRHRRR.............R...................'
  'RRR.RRRR............R...................'
  'RR...RRRR.....HHRRRDRR..................'
  '.....RRRRR...RRRRRRDRRRR................'
  'RRR..RRRRR..RRKRRRDRRRRRRR..............'
  'RRRRRRRRRR..RRRRRRDRRRRRRRR.............'
  '.RRRRRRRRRRRRRRRRDRRRRRRRRRRD...........'
  '..RRRRRRRR.RRRRRRDRRRRRRRRRRDRR.........'
  '...RRRRRR..RRRRRRDRRRRRRRRRRDRRRD.......'
  '...........RRRRRRDRRRRRRRRRDRRRDRRR.....'
  '..........MRRRRRDRRRRRRRRRDRRDRRRRD.....'
  '.....RRRRRRDDMMMMMMMMMMMMMDRRDRRRRDRRR..'
  '....RRRR.RR..DRRDRRDRRDRRD.DMMRRDRRRRD..'
  '...RRR....RR..DR.DR.DR.DR...DMMRDRRRRDPP'
  '...RRR.........D..D..D..D....DMDRRRRDPPP'
  '....RRRRRR.....R..R..R..R.....DRRRDPPPP.'
  '......RRR.......D..D..D..D.....DRRPPPP..'
  '................................PPPPP...'
  '.................................PPP....'
)
# The other two frames as 'row:prefix' deltas: the prefix replaces the first columns of that row.
LOBSTER_OPEN=('0:.....R.................R' '1:.....R.................R' '2:.RR..R................R' '3:RRRR.R...............R' '5:.R.' '6:..' '17:...RRR....RR..RD.RD.RD.RD' '18:...RRR........D..D..D..D.' '19:....RRRRRR....R..R..R..R.' '20:......RRR......D..D..D..D......DRRPPPPP' '21:...............................PPPPPPP' '22:.................................PPPP')
LOBSTER_SHUT=('0:.......R.............R.' '1:.......R' '2:......R' '3:....' '4:.RRRH' '5:RRRR' '6:RRR' '7:.RR' '8:...' '9:....')
lobster_ink() { case $1 in R) INK=$LOB_R ;; M) INK=$LOB_M ;; D) INK=$LOB_D ;; H) INK=$LOB_H ;; P) INK=$LOB_P ;; K) INK=$LOB_K ;; *) INK='' ;; esac; }
# lobster_frame [row:prefix]...: FRAME[] gets the terminal lines of one frame.
lobster_frame() {
  local rows=("${LOBSTER[@]}") o n p top bot y x a b sgr ch last line
  for o in "$@"; do n=${o%%:*}; p=${o#*:}; rows[n]="$p${rows[n]:${#p}}"; done
  FRAME=()
  for ((y = 0; y < ${#rows[@]}; y += 2)); do
    top=${rows[y]}; bot=${rows[y+1]:-}; line=''; last=''
    for ((x = 0; x < ${#top}; x++)); do
      lobster_ink "${top:x:1}"; a=$INK; lobster_ink "${bot:x:1}"; b=$INK
      if [ -n "$a" ] && [ -n "$b" ]; then sgr="\033[38;$LOB_DEPTH;$a;48;$LOB_DEPTH;${b}m"; ch='▀'
      elif [ -n "$a" ]; then sgr="\033[0;38;$LOB_DEPTH;${a}m"; ch='▀'
      elif [ -n "$b" ]; then sgr="\033[0;38;$LOB_DEPTH;${b}m"; ch='▄'
      else sgr='\033[0m'; ch=' '; fi
      [ "$sgr" = "$last" ] || { line="$line$sgr"; last=$sgr; }
      line="$line$ch"
    done
    FRAME[${#FRAME[@]}]="$line\033[0m"
  done
}
# lobster_banner DETAIL TAGLINE: "Cloud Lobsters", "claude-lobsters-cli DETAIL" and TAGLINE beside the
# lobster (under it on a narrow terminal), animated once. Just the words when stdout is not a
# UTF-8 terminal, NO_COLOR is set or TERM is dumb. CLAUDE_LOBSTERS_CLI_NO_BANNER=1 prints nothing.
lobster_banner() {
  local detail="$1" tagline="$2" i n cols
  local -a text f0 f1 f2
  [ -z "${CLAUDE_LOBSTERS_CLI_NO_BANNER:-}" ] || return 0
  if [ ! -t 1 ] || [ -n "${NO_COLOR:-}" ] || [ "${TERM:-dumb}" = dumb ] \
     || ! { echo "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" | grep -qi 'utf-\{0,1\}8'; }; then
    printf '\nCloud Lobsters · claude-lobsters-cli%s · %s\n\n' "${detail:+ $detail}" "$tagline"; return 0
  fi
  case ${COLORTERM:-} in
    truecolor|24bit) LOB_DEPTH=2; LOB_R='227;57;43'; LOB_M='196;42;34'; LOB_D='140;22;22'; LOB_H='255;118;98'; LOB_P='242;150;140'; LOB_K='24;12;12' ;;
    *)               LOB_DEPTH=5; LOB_R=160; LOB_M=124; LOB_D=88; LOB_H=209; LOB_P=217; LOB_K=232 ;;
  esac
  text=("\033[1mCloud Lobsters\033[0m" "\033[38;$LOB_DEPTH;${LOB_R}mclaude-lobsters-cli\033[0m${detail:+ $detail}" "\033[2m$tagline\033[0m")
  lobster_frame;                      f0=("${FRAME[@]}")
  lobster_frame "${LOBSTER_OPEN[@]}"; f1=("${FRAME[@]}")
  lobster_frame "${LOBSTER_SHUT[@]}"; f2=("${FRAME[@]}")
  n=${#f0[@]}
  cols=$(tput cols 2>/dev/null || echo "${COLUMNS:-80}")
  if [ "${cols:-80}" -ge 80 ]; then
    for i in 0 1 2; do f0[i+4]="${f0[i+4]}   ${text[i]}"; f1[i+4]="${f1[i+4]}   ${text[i]}"; f2[i+4]="${f2[i+4]}   ${text[i]}"; done
  else
    for i in 0 1 2; do f0[n+i]=${text[i]}; f1[n+i]=${text[i]}; f2[n+i]=${text[i]}; done
    n=$((n + 3))
  fi
  echo; printf '%b\n' "${f0[@]}"
  for i in 1 0 2 0 1 2 0; do
    sleep 0.13; printf '\033[%dA' "$n"
    case $i in 0) printf '%b\n' "${f0[@]}" ;; 1) printf '%b\n' "${f1[@]}" ;; 2) printf '%b\n' "${f2[@]}" ;; esac
  done
  echo
}
# ---- end banner ----------------------------------------------------------------------

case "$(uname -s)" in
  Darwin) os=mac ;;
  Linux)
    if has pacman; then os=arch; elif has apt-get; then os=debian; else die "Linux without apt or pacman is not supported"; fi ;;
  *) die "unsupported OS $(uname -s)" ;;
esac

lobster_banner '' 'Claude Code for the whole team'
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

say "3. Newest claude-lobsters-cli release"
latest="$(GIT_TERMINAL_PROMPT=0 git ls-remote --tags --refs "https://github.com/$TOOLING_REPO" 'v[0-9]*' 2>/dev/null \
  | sed -n 's#.*refs/tags/v##p' | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)"
[ -n "$latest" ] || die "no releases found at github.com/$TOOLING_REPO"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
asset="claude-lobsters-cli-$latest.tar.gz"; base="https://github.com/$TOOLING_REPO/releases/download/v$latest"
for f in "$asset" SHA256SUMS SHA256SUMS.sig; do
  curl -fsSL --retry 2 -o "$tmp/$f" "$base/$f" \
    || gh release download "v$latest" --repo "$TOOLING_REPO" --pattern "$f" --dir "$tmp" \
    || die "could not download $f"
done
tar -xzf "$tmp/$asset" -C "$tmp"
tree="$tmp/claude-lobsters-cli-$latest"
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
sudo bash "$tree/bin/claude-lobsters-cli" install-files "$tree" </dev/tty

say "5. Set up this machine"
CLAUDE_LOBSTERS_CLI_NO_BANNER=1 exec /usr/local/bin/claude-lobsters-cli setup </dev/tty
