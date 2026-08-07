# Native agent artifacts

`claude/` contains the Markdown agents installed in `.claude/agents/`.
`codex/` contains the TOML agents installed in `.codex/agents/`.

The deliberate difference is their native file format and the platform-specific fields each format supports. They are maintained independently; neither is generated from, translated from, or a fallback for the other.
