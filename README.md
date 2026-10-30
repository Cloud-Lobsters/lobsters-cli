# lobsters-cli

The Cloud Lobsters team setup for every team member's and contractor's machine: the Claude Code policy and rules that run at session start, the team MCP servers with keys from 1Password, the tools (gh, jq), a basecamp clone and the menu-bar icon. Installed once, updated only when a person says so. Mac, Ubuntu and Omarchy.

It is deliberately small: one CLI, one session hook, two JSON files. Everything that changes often (rules, skills, agents) lives in the private repo [claude-config-team](https://github.com/Cloud-Lobsters/claude-config-team) and is pulled as **text**; nothing pulled is ever executed. This repo is public: it holds no secrets, only `op://` pointers to items in your own 1Password vault.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Cloud-Lobsters/lobsters-cli/main/install.sh | bash
```

It installs Claude Code, `gh` and `jq` if they are missing, stops to ask you to `gh auth login` if you have not, downloads the newest release, checks its signature and checksums, prints the maintainer key fingerprint (compare it with the onboarding note), installs under `/usr/local` (asks for your password once) and runs `lobsters-cli setup`. Then start Claude Code, accept the one-time managed-hook dialog, and sign in to Ref with `/mcp`.

Before you start: the 1Password app signed in with **Integrate with 1Password CLI** on, and an item `claude-code-mcp` in your Employee vault with a `pm_authorization` field (`Bearer sk_live_…` from project.cloudlobsters.com/dashboard/preferences). `fireflies_authorization` too if you use Fireflies. Every repo's `scripts/op-env.sh` runs `op` as the team's shared read-only **service account** `dev-readers` (dev Environments only) when your OS keychain holds its token, so `pnpm dev` starts while 1Password is locked or from a phone; `setup` copies that token from the Engineering vault item `Service Account Auth Token: dev-readers` (1Password's default title when the token is saved) into the keychain, and `lobsters-cli token sync` refreshes it after a rotation. See basecamp `docs/50. standards/20. local-env.md`.

**Already on `claude-lobsters-cli`** (the name until v0.3.0, after `claude-team` until v0.2.0)? Run `claude-lobsters-cli upgrade` as usual. The release installs itself as `lobsters-cli`, takes the old files out and carries on; the old GitHub URLs redirect.

## Commands

| | |
|---|---|
| `lobsters-cli setup` | install or repair this machine: policy, rules clone, skills and agents, MCP servers, model defaults, status line, on a Mac the menu-bar icon (installs SwiftBar and starts it at login), and, for engineers, the team's shared `dev-readers` 1Password service-account token from the Engineering vault into the keychain (so dev servers start with 1Password locked; no vault, no token). Safe to run again. |
| `lobsters-cli check` | report only, change nothing |
| `lobsters-cli upgrade [X.Y.Z]` | fetch a release, verify it, show what changes, install it (asks for your password) |
| `lobsters-cli status` | refresh and print `~/.local/state/cloud-lobsters/status.json` |
| `lobsters-cli remove` | take the team setup out again |
| `lobsters-cli token sync` | engineers only: copy the team's shared `dev-readers` 1Password service-account token from the Engineering vault into your OS keychain (`setup` does this too when it can, and otherwise just says so). The vault is the only way in; `--shared` replaces a different token already in the keychain |
| `lobsters-cli token check` | try every cloned repo's dev Environment, and then every dev Environment the 1Password app lists (cloned or not), with the keychain token; lists the ones an admin must add to `dev-readers` |

## How it works

| Layer | Where | Changes when |
|---|---|---|
| **Policy**: permission allow/deny lists and the one `SessionStart` hook | `/Library/Application Support/ClaudeCode/managed-settings.d/cloud-lobsters.json` (Mac), `/etc/claude-code/managed-settings.d/cloud-lobsters.json` (Linux); the hook and CLI under `/usr/local`. Root-owned. | a person runs `lobsters-cli upgrade` and types their password |
| **Content**: `team/CLAUDE.md`, `skills/`, `agents/` from the private repo | read-only clone at `~/.local/share/cloud-lobsters/config`; `~/.claude/CLAUDE.md` imports the rules; skills and agents are symlinked into `~/.claude` (one of yours with the same name wins) | every session start, by the hook: `git pull --ff-only`, relink, one line saying who changed what |

The hook, `libexec/rules-sync`, pulls and links. It refuses to link any skill or agent whose frontmatter mentions hooks (the one place such a file could declare one), and names changed scripts in its note so you know what a skill might ask Claude to run. It also asks GitHub, at most every 30 minutes and read-only, whether a newer release exists, and writes `status.json` for the status line, SwiftBar (Mac) and Waybar (Omarchy; see `share/waybar/README.md`). The SwiftBar and Waybar plugins run `lobsters-cli status` on the same 30-minute clock, so a new release shows in the menu bar within about half an hour, with or without a Claude session.

MCP servers (`share/mcp-servers.json`) are added to your own user scope by `setup`, with keys read from 1Password at that moment. A change to the list reaches you on your next `upgrade`, never silently.

## Releases

Maintainers only. From a clean checkout of `main`:

```bash
scripts/release 1.3.0
```

First the notes: every release ships with release notes, and the script refuses to cut one without them. Write them in `CHANGELOG.md` under `## Unreleased` with each change (one bullet per change, for the person upgrading). The script shows the notes beside the commits since the last tag and asks you whether they match, then names the section after the version and leaves a fresh `## Unreleased` heading. Then it writes `VERSION`, commits, tags, builds the tarball from the tag, writes `SHA256SUMS`, signs it with your release key (one 1Password prompt), checks the signature against `share/allowed_signers`, pushes, and creates the GitHub Release with the notes as its body. `lobsters-cli upgrade` shows the notes for every version between the installed one and the new one, read from the signed tarball, before it asks to install. No CI, no secrets outside your 1Password.

Your release key is an SSH key in 1Password whose public half is in `share/allowed_signers`. Adding a maintainer is a commit that adds their line, shipped in a release signed by an existing key. Machines verify every release against the signers file they already have, so a new key cannot admit itself.

While machines are still moving over from `claude-lobsters-cli`, `scripts/release` also uploads the tarball under the old name and signs in the old namespace, so the old CLI's `upgrade` accepts it (the block is marked; delete it, and the old namespace in `share/allowed_signers`, once `lobsters-cli status` on every machine says 0.3.0 or later).

## Security model

- A push to this repo does nothing to any machine. Code reaches a machine only as a tagged, signed release that a person inspects (`upgrade` shows the policy diff) and installs with sudo.
- A push to the private content repo delivers text: rules, skill and agent prompts, and scripts a skill may ask Claude to run, which are named in the session note. It cannot run anything at session start, change permissions, add a hook, or add an MCP server.
- `upgrade` refuses an unsigned release, a release signed by a key not in the installed `allowed_signers`, a checksum mismatch, and (unless you name the version) a downgrade.
- First install is trust-on-first-use, like every installer: compare the printed key fingerprint with the onboarding note.
- **Accepted risk (2026-10-29):** `allowManagedHooksOnly` is not set. It would also have blocked a hook planted in a client repo's `.claude/settings.json` (runs once you trust that folder; one machine per person who opens it) and hooks from plugins people install themselves. It would also have broken everyone's own hooks, every repo's project hooks and all personal status lines, so it stays off on the assumption that the team does not install unknown plugins. Revisit after any repo-hook incident: `lobsters-cli statusline` already runs your own status line and appends the team segment, so turning it on is a one-line release.

## Layout

```
bin/lobsters-cli              the CLI
libexec/rules-sync            the SessionStart hook
share/managed-settings.json   the policy
share/mcp-servers.json        team MCP servers, with op:// pointers
share/allowed_signers         maintainer release keys
share/swiftbar/, share/waybar/ menu-bar readers of status.json
install.sh                    first install (curl | bash)
scripts/release               cut a release
CHANGELOG.md                  release notes; a release needs its section
```
