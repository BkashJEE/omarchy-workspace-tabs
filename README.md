# Omarchy Workspace Tabs

A standalone Omarchy bar widget with seven compact, named workspace tabs and a matching dropdown menu for every tab.

## Features

- A ready-to-use Studio, Agents Lab, Social Media, Messages, Hermes OS, Git and Build layout
- Active, occupied, and empty visual states
- A matching dropdown for every tab with its purpose, live window count and focus action
- Live window counts for each workspace
- Quick access to three windows already open on a workspace
- No application launchers, background services, automatic window movement, or account integrations

## Requirements

- Omarchy with the Quickshell plugin bar

## Install

Copy this repository's HTTPS URL, then run:

```bash
omarchy plugin add https://github.com/BkashJEE/omarchy-workspace-tabs.git --enable --yes
```

If the widget is not placed automatically:

```bash
omarchy bar move community.workspace-tabs --section left
```

## Commands

```bash
omarchy-shell community.workspace-tabs open 4
omarchy-shell community.workspace-tabs status
omarchy-shell community.workspace-tabs close
```

## Customize

Change `workspaceOrder`, `workspaceLabels`, `workspaceSymbols`, or `workspaceDescriptions` near the top of `Workspaces.qml`. Keep every `font.pixelSize` value as an integer.

Every tab ships with the same safe dropdown behavior:

- show the workspace purpose
- show the current number of open windows
- focus the workspace
- activate one of its first three open windows

These menus use Hyprland's existing workspace metadata. They do not launch apps or require personal scripts.

## Privacy

The widget reads only the workspace and window metadata already exposed to Omarchy by Hyprland. It does not read application data, browser profiles, messages, cookies, tokens, credentials, or environment files.

## Security and scope

This plugin requires no API key, access token, password, account, network connection, environment variable, or configuration file. It does not start background services or send data anywhere.

Its only external command focuses a Hyprland workspace:

```text
hyprctl eval hl.dispatch(hl.dsp.focus(...))
```

The complete distributable source is `manifest.json`, `Workspaces.qml`, and `WorkspaceMenu.qml`. Review those files before installing. GitHub secret scanning and push protection are enabled for this repository.

See [SECURITY.md](SECURITY.md) for responsible disclosure and the repository's security boundaries.

## License

MIT
