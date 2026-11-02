# Changelog

What each release changes for the person running it. Write the notes for the next release
under `## Unreleased` as you go, in plain words, one bullet per change; `scripts/release`
refuses to cut a release without them, names the section after the version, and uses it as
the GitHub Release body. `lobsters-cli upgrade` shows every section between the installed
version and the one it is about to install, read from the signed tarball.

## Unreleased

- `lobsters-cli upgrade X.Y.Z` for the version already installed says so and stops, instead of fetching it and asking to install it again (`--force` reinstalls).

- `setup` signs you in to GitHub itself when you are not (device code to type at github.com/login/device), instead of stopping and telling you the command.

## 0.6.5 (2026-11-02)

- `orca-pair` on the hub finishes the job: it waits for the phone or laptop to pair, then starts your Orca server. No Ctrl-C, no systemctl. Re-running `hub add` for an existing account gives it the new script.

## 0.6.4 (2026-11-02)

- On a Mac, `setup` installs the Tailscale app (`brew install --cask tailscale-app`), not Homebrew's `tailscale` cask, which is now the CLI-only build and does not work as a laptop client; a machine that got that cask has it replaced.

## 0.6.3 (2026-11-02)

- A new hub account runs `lobsters-cli setup` by itself at its first logins, until it has completed once; the person only answers the GitHub prompt.

- `hub init` installs `gh` and `jq` for every account on the box (Omarchy ships `gh` as a per-user stub in the first account only).

## 0.6.2 (2026-11-02)

- `setup` puts your machine on the company tailnet: installs Tailscale if it is missing, signs you in with your Workspace account (or says the device is waiting for an admin's approval), and adds `ssh lobster`, which lands in your own account on the hub.

- `setup` in the retired shared account of a hub does nothing to it (it used to start that account's Orca server again); `hub init --retire` takes the unit out for good and remembers the account in `hub.conf`.

## 0.6.1 (2026-11-02)

- `hub add --sudo` writes a sudoers entry for the person (Omarchy's wheel group only carries a few fixed commands); `hub remove` takes it out.
- `setup` on a hub runs the Claude Code installer from a downloaded file and shows its last lines when it fails.
- `hub init --retire` also stops the AppImage's own Orca processes (they are not named `orca-ide serve`), and `hub add` warns when the port it picked is already taken.
- `lobsters-cli check` in a fresh hub account reports the missing Claude Code and GitHub login instead of stopping at the first one.
- `hub init` prints the working command for piping the dev-readers token in (`op item get … --reveal`; a colon is invalid in an `op://` reference). README too.

## 0.6.0 (2026-11-02)

- `lobsters-cli hub`: the shared agent box (the office Mac Pro "lobster"). `hub init` once, then `hub add name@cloudlobsters.com [--sudo]` gives a person their own Unix account, reached by Tailscale SSH under their own login, with their own Orca server on its own port and the shared dev-readers token in their home. `hub remove`, `hub list`, `hub check`, `hub tailnet EMAIL --approve` (approves their pending tailnet devices), `hub token` (secrets piped in from an admin's 1Password; never pasted).
- `setup` on a hub installs Claude Code into the home, sets your git name and email from your GitHub login, keeps the dev-readers token in a file (an ssh-only account has no keyring), enables your Orca server, and says what is left: the Claude login, pairing with `orca-pair`.
- The installer no longer asks for a password when the version it fetched is already under /usr/local, so a person without sudo on a shared machine can run the one-liner.

## 0.5.6 (2026-10-30)

- `scripts/release` shows the notes beside the commits since the last tag and asks whether they match, and leaves a fresh `## Unreleased` heading for the next change. A `CLAUDE.md` tells agents working on the repo to write the note with the change. With no terminal to ask on, the script stops before writing anything and says to run again with `--yes`.

## 0.5.5 (2026-10-30)

- `lobsters-cli upgrade` shows the release notes for every version it is about to skip over, before it asks to install.
- A release cannot be cut without notes: `scripts/release` refuses when this file has none for the version, and the GitHub Release carries them.

## 0.5.4 (2026-10-30)

- `lobsters-cli token check` also tries every dev Environment the 1Password app lists, not only the ones of cloned repos.

## 0.5.3 (2026-10-30)

- An MCP server whose command is a Mac path (the 1Password MCP) is found by name on PATH on Linux.

## 0.5.2 (2026-10-30)

- The shared `dev-readers` token is read by 1Password's default item title; a colon is invalid in an `op://` reference.
- README: the setup row no longer mentions pasting a token.

## 0.5.1 (2026-10-30)

- The Engineering vault is the only way to the `dev-readers` token; the paste path is gone.

## 0.5.0 (2026-10-30)

- `lobsters-cli token sync` copies the team's shared `dev-readers` 1Password service-account token from the Engineering vault into the keychain; `token check` lists the Environments it cannot read.
- `setup` only reports on the token; people without the Engineering vault need none.

## 0.4.1 (2026-10-30)

- The menu bar and status line notice a new release within 30 minutes, not at the next session (CLU031).

## 0.4.0 (2026-10-30)

- `setup` step 6 stores your 1Password service-account token in the OS keychain.

## 0.3.0 (2026-10-30)

- `claude-lobsters-cli` is now `lobsters-cli`: CLI, paths, repo and release assets. The old CLI's `upgrade` still accepts the release (CLU030).

## 0.2.1 (2026-10-29)

- Duncan's release key is in `allowed_signers`.
- `setup` installs SwiftBar on a Mac, so the menu-bar icon just appears (CLU026).

## 0.2.0 (2026-10-29)

- `claude-team` is now `claude-lobsters-cli`.
- A pixel lobster banner in `install.sh` and the CLI.

## 0.1.3 (2026-10-29)

- Status line: `🦞 <version>`, wrapped around your own status line.

## 0.1.2 (2026-10-29)

- `setup` remembers `CODE_DIR` after the first run and shows 1Password's own error when a key cannot be read.

## 0.1.1 (2026-10-29)

- `setup` honours `CODE_DIR` from the setup skills for the basecamp clone.

## 0.1.0 (2026-10-29)

- First release as `claude-team`: policy, rules clone, MCP servers, tools, basecamp and the menu-bar icon.
