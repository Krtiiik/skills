---
name: update
description: Update this plugin (krtiiik) to the latest version by refreshing its marketplace from GitHub first. Use when the user asks to update krtiiik, update these skills, or pull the latest skills.
---

Update the `krtiiik` plugin on this machine, nothing else.

1. **Refresh the marketplace.** Run `claude plugin marketplace update krtiiik-skills`. If it reports the marketplace is not found, stop and tell the user to run `/plugin marketplace add Krtiiik/skills`.
2. **Update the plugin.** Run `claude plugin update krtiiik@krtiiik-skills`. If it reports the plugin is not installed, stop and tell the user to run `/plugin install krtiiik@krtiiik-skills`.
3. **Report.** Say the version it went from and to, or that it was already current. An update only takes effect after Claude Code restarts, so tell the user to restart.
