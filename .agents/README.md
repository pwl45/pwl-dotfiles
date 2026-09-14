# Shared agent configuration

Home Manager links `rules/` into `~/.agents/rules` and `~/.claude/rules`, then concatenates the files into `~/.codex/AGENTS.md`. Run `hsf` after changing rules so Codex receives the updated aggregate.

Pi requires directory rules to opt into matching. Use `alwaysApply: true` for global rules or path-matching frontmatter for scoped rules:

```yaml
---
alwaysApply: true
---
```
