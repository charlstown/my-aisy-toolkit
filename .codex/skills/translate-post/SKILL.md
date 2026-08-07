---
name: translate-post
description: Translate published or publication-ready content while preserving meaning, structure, links, placeholders, and tone. Use when Codex needs to translate blog posts, Markdown articles, newsletters, landing-page copy, release notes, or social posts for another language or locale, especially when formatting and terminology consistency must survive the translation.
---

# Translate Post

Translate the user's content into the requested target language without flattening the original structure or voice.
Preserve formatting and identifiers exactly unless the user explicitly asks for broader localization or rewriting.

## Workflow

1. Identify the target language and locale.
If the user did not specify them and the choice is material, ask once before translating.

2. Inspect the source format before editing.
Preserve Markdown, HTML fragments, headings, bullets, numbering, tables, links, placeholders, variables, front matter keys, code fences, and inline code exactly as structure. Translate only the human-language content inside that structure unless the user asks otherwise.

3. Preserve intent before literal wording.
Prefer idiomatic phrasing in the target language when a literal translation sounds unnatural. Keep product names, trademarks, URLs, commands, and technical identifiers unchanged unless an official localized form is known from the repo or provided by the user.

4. Maintain terminology consistently.
Reuse the same translation for repeated domain terms across the whole artifact. If the repo contains a glossary or established wording, follow it.

5. Avoid accidental rewriting.
Do not add explanations, summaries, or stylistic improvements unless the user asked for adaptation, transcreation, SEO localization, or another editorial pass beyond translation.

## Output Rules

Return the translated artifact first, ready to use.

After the translation, add a short `Notes` section only when needed for one of these cases:

- a phrase was ambiguous in the source
- a locale choice materially changed wording
- a brand or terminology decision needed an assumption
- the source contained text that should probably stay untranslated

## Checks

Before finishing, verify:

- headings and list depth still match the source
- links, placeholders, and formatting tokens are unchanged
- repeated terminology is consistent
- the result reads naturally for the target audience

## Examples

- "Translate this blog post to neutral Spanish and keep the Markdown intact."
- "Localize this product announcement for Mexican Spanish, preserving links and CTA structure."
- "Translate these release notes to English, but keep commands, env vars, and code snippets unchanged."
