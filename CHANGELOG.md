# Changelog

What each release changes for the person running it. Write the notes for the next release
under `## Unreleased` as you go, in plain words, one bullet per change; `scripts/release`
refuses to cut a release without them, names the section after the version, and uses it as
the GitHub Release body. `lobsters-cli upgrade` shows every section between the installed
version and the one it is about to install, read from the signed tarball.

## Unreleased

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
