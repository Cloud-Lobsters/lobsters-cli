# lobsters-cli

The team setup CLI. `README.md` says what it is, how a release reaches a machine and how to cut one.

## Every change ships with a release note

A change a person could notice (a command, a message, the policy, the hook, an MCP server, the installer) gets a bullet under `## Unreleased` in `CHANGELOG.md`, in the same commit. Write it for the person upgrading: what is different for them, in plain words, one bullet per change. The heading is always there; add the bullet beneath it.

`scripts/release` shows the notes next to every commit since the last tag and asks the maintainer whether they match, and refuses to release an empty section. A bullet written with the change is right; one written at release time, from the commit list, is a guess.

## Checked by the release script

- The lobster banner block is byte-identical in `install.sh` and `bin/lobsters-cli`.
- `main` is clean and in sync with origin; the release key is in `share/allowed_signers`.
