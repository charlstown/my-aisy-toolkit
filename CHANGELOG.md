# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-03

### Added

- `ui-ux` profile, an alternative catalog adding `ui-spec` and `clarify-uix`
  to the `default` skill set for teams that want a dedicated UI/UX design
  pass.
- Optional `utils` skill pack (`digest`, `grill-me`, `for-dummies`),
  installable on top of any profile via `catalog.yaml`'s `packs` section.

### Removed

- `grill-me` skill removed from the `default` profile catalog (10 skills now,
  down from 11); its source files (`ai-toolkit/default/commands/grill-me.md`,
  `.claude/commands/grill-me.md`) were deleted. Existing installs that already
  had `/grill-me` are unaffected — `setup-ai` never uninstalls skills a repo
  already has.

## [0.1.0] - 2026-08-01

### Added

- `default` profile catalog with 11 skills in `ai-toolkit/default/commands/`
  (`constitution`, `product-spec`, `tech-spec`, `roadmap`, `new-issue`,
  `specify-feature`, `clarify-feature`, `grill-me`, `plan-feature`,
  `implement-feature`, `clean-feature`) and 6 subagents in
  `ai-toolkit/default/agents/` (`architect`, `code-developer`,
  `test-developer`, `tester`, `ui-developer`, `judge`).
- `catalog.yaml` manifest listing the `default` profile's commands and agents.
- `setup-ai.md` installer for setting up the toolkit in a project.
- `README.md` and `README-ES.md` project documentation.
- Repository versioning: `VERSION` file, `CHANGELOG.md`, and a dynamic
  tag-based version badge.
