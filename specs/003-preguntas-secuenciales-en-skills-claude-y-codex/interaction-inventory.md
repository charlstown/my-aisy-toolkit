# Inventario de interacción

La inspección de `ai-toolkit/skills/*/SKILL.md` localizó preguntas en: `clarify-feature`, `clarify-uix`, `clean-feature`, `constitution`, `digest`, `for-dummies`, `grill-me`, `implement-feature`, `new-issue`, `plan-feature`, `product-spec`, `roadmap`, `specify-feature`, `tech-spec` y `ui-spec`.

Todas estas preguntas bloquean el paso que depende de la respuesta. Las decisiones que expresen «No lo tengo claro todavía» pueden conservarse como *gap* y solo permiten continuar con trabajo independiente.

La política no se duplica en cada skill: `AGENTS.md` define el fallback exclusivo de Codex. Claude conserva las instrucciones `AskUserQuestion` existentes en las skills. Esta centralización cumple la suposición y FR-001 de los requisitos de esta feature; el ejemplo de `description: none` permanece ilustrativo, por lo que no se añadió como pregunta fuera de contexto.
