# Contributing

Contributions should keep this repository generic, local, and easy to audit.

## Before opening a pull request

- Do not commit API keys, tokens, passwords, cookies, certificates, private keys, environment files, or keyring exports.
- Do not commit personal names, email addresses, home-directory paths, account handles, screenshots, browser data, or machine-specific commands.
- Do not add telemetry, analytics, network requests, account integrations, background services, or automatic application launchers.
- Keep `font.pixelSize` values as integers for Omarchy compatibility.
- Run `qmllint`, validate `manifest.json`, and review the complete diff.

Use placeholders in documentation and examples. If a change needs a credential or personal configuration, keep it outside this repository.
