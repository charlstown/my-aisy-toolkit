# Plan: Separar motor de instalación y catálogo en setup-ai, y corregir bloqueo de preguntas e idioma

Feature Branch: 001-separar-motor-de-instalacion-y-catalogo-en-setup
Source Issue: https://github.com/charlstown/my-aisy-toolkit/issues/44
Requirements: specs/001-separar-motor-de-instalacion-y-catalogo-en-setup/requirements.md

## Contexto de diseño (decisiones ya cerradas, no reabrir)

- El "motor" (lógica embebida de Steps 1-6) vive ÚNICAMENTE en el launcher global por máquina/agente
  (`~/.claude/commands/setup-ai.md` para Claude Code; `~/.codex/skills/setup-ai/SKILL.md`, fallback
  `~/.agents/skills/setup-ai/SKILL.md`, para Codex CLI). No hay copia por repo del motor.
- `catalog.yaml` y los ficheros individuales `commands/*.md` / `agents/*.md` permanecen remotos y se
  siguen fetcheando en cada instalación (Step 2 y Step 3 actuales no cambian en ese aspecto).
- El launcher se auto-actualiza solo cuando el usuario ejecuta explícitamente `/setup-ai` o
  `$setup-ai`: fetchea la última versión de `setup-ai.md` desde GitHub, la compara con su propia
  copia local embebida y se sobreescribe a sí mismo solo si difiere (mismo patrón
  create/overwrite/leave-alone que ya usa Step 4). No hay actualización automática ni en background.
- El primer bootstrap (one-liner del README, sin motor local previo) sigue requiriendo un único
  fetch inicial de `setup-ai.md` — es inevitable y no contradice FR-001.
- Fichero de trabajo: `setup-ai.md` (raíz del repo, 653 líneas). Referencias de línea usadas abajo
  son las del estado actual del fichero antes de estos cambios; pueden desplazarse tras cada edición
  — cada tarea debe releer el fichero antes de editar.

## Fase 1 — Diseño

- [ ] @architect · Diseñar el contenido embebido del motor y el algoritmo de auto-actualización del launcher: leer `setup-ai.md` completo (especialmente Step 6, líneas ~334-552, incluidas las dos plantillas literales del launcher en ~457-491 y ~509-543) y producir el texto candidato exacto en Markdown para: (1) las nuevas plantillas de `~/.claude/commands/setup-ai.md` y `~/.codex/skills/setup-ai/SKILL.md` que embeben Steps 1-6 completos en vez de solo apuntar a un fetch remoto; (2) el algoritmo de auto-actualización explícito (fetch de `setup-ai.md` desde GitHub → comparar contra la copia local embebida en el propio fichero del launcher → overwrite solo si difiere, patrón create/overwrite/leave-alone) incluyendo el caso de fallo de ese fetch — debe ser fail-safe: si el fetch de auto-actualización falla, el launcher sigue adelante con su lógica local ya embebida (no aborta la instalación) y lo reporta en el Wrap-up, análogo al tratamiento de fallo de escritura que ya usa Step 6 (D-07); (3) cómo se reescribe la rama actual "si llegaste aquí desde el launcher ya instalado, salta a Wrap up" (línea ~336), que deja de aplicarse tal cual porque el launcher ya no re-fetchea y re-sigue Steps 1-6 de un `setup-ai.md` remoto salvo para su propio auto-update; (4) los párrafos narrativos de Step 6 que rodean las plantillas (detección de candidatos ~340-456, mensajes "Heads up" ~368-398, oferta de guardar launcher ~417-443) ajustados a la nueva semántica. Debe distinguir explícitamente los bloques "word for word" dirigidos al usuario (traducibles, ver Fase 2) de los bloques de contenido de fichero marcados "byte-for-byte"/"word for word" que se escriben literalmente a disco y NUNCA se traducen ni reinterpretan (p. ej. la instrucción de la línea ~506 sobre la plantilla Codex). Entregar el texto listo para que @code-developer lo pegue, con referencias claras a qué sustituye.

## Fase 2 — Corrección de los dos bugs de comportamiento (independiente del diseño del launcher)

- [ ] @code-developer · Step 1: usar herramienta nativa de preguntas bloqueantes en vez de texto plano: reescribir Step 1 (líneas ~61-123 de `setup-ai.md`) para instruir explícitamente que la pregunta del agente objetivo, su reintento ("I still need to know…"), la pregunta de perfil y la pregunta de utils se presenten invocando la herramienta interactiva nativa de la plataforma en la que se ejecuta la instalación (`AskUserQuestion` en Claude Code, `ask_user_question` en Codex CLI) — no como un simple print de texto — y que la ejecución quede efectivamente bloqueada hasta recibir respuesta del usuario (FR-003, SC-002). No cambiar el contenido semántico de las preguntas ni sus opciones, solo el mecanismo de entrega. Cubrir también cualquier otra pregunta bloqueante equivalente que el fichero contenga fuera de Step 1.

- [ ] @code-developer · Traducir los bloques "word for word" dirigidos al usuario al idioma de la conversación: en cada bloque marcado "word for word" que se presenta al usuario (preguntas y mensajes de Step 1, líneas ~63-123, y los mensajes de usuario de Step 6, líneas ~368-435), añadir la instrucción explícita de detectar el idioma a partir del mensaje más reciente del usuario — ignorando el resto del histórico si hay mezcla de idiomas — y presentar el bloque traducido a ese idioma preservando exactamente estructura y opciones; usar inglés por defecto cuando no hay input ni histórico del que detectar idioma (FR-004, FR-005, SC-003). Excluir explícitamente de esta traducción los bloques de contenido de fichero marcados "byte-for-byte"/"word for word" que se escriben literalmente a disco (las plantillas del launcher en Step 4 y Step 6, incluida la instrucción de la línea ~506): esos deben seguir copiándose sin traducir ni reinterpretar, tal como ya indica el fichero.

## Fase 3 — Embeber el motor en el launcher y eliminar el fetch autorreferencial

- [ ] @code-developer · Reescribir las plantillas del launcher global (Step 6) para embeber Steps 1-6 en vez de apuntar a un fetch remoto: usando el texto producido por @architect en la Fase 1 (ya incorporando las correcciones de la Fase 2), sustituir las plantillas literales de `~/.claude/commands/setup-ai.md` (líneas ~457-491) y `~/.codex/skills/setup-ai/SKILL.md` (líneas ~509-543) — que hoy solo dicen "fetch this URL y sigue sus instrucciones" — por versiones que contienen embebida la lógica completa de Steps 1-6. Añadir a ambas plantillas la lógica de auto-actualización explícita descrita en la Fase 1 (fetch de `setup-ai.md` → comparar con la copia local embebida → overwrite solo si difiere, con fallback fail-safe si el fetch falla) (FR-001, FR-002, FR-006, SC-001, SC-004). Mantener intacto que Step 2 (fetch de `catalog.yaml`) y Step 3 (fetch de `commands/*.md` / `agents/*.md`) siguen siendo remotos sin caché (FR-002, edge case de fail-safe ante fallo de red en esos fetches).

- [ ] @code-developer · Actualizar los párrafos narrativos de Step 6 y el Wrap-up para reflejar el nuevo comportamiento del launcher: ajustar la detección de candidatos, los mensajes "Heads up" (~368-398), la oferta de guardar launcher (~417-443) y la sección Wrap-up (~587-627) para que ya no describan el launcher como un simple puntero que "fetches these same instructions fresh every time — nothing gets frozen or copied" (línea ~427) ni repliquen esa idea en otro texto — deben describir en su lugar el motor embebido y su auto-actualización create/overwrite/leave-alone. Revisar también el preámbulo "Instructions for the agent" (líneas ~48-60) y cualquier mención residual a "Do not fetch this file again" para dejar claro que: (a) el bootstrap inicial vía one-liner/copy-paste del README sigue requiriendo un único fetch de `setup-ai.md`; (b) el propio comando/skill `setup-ai` ya instalado sí puede re-fetchear `setup-ai.md` explícitamente como parte de su propio auto-update; (c) ningún otro comando/skill del kit dispara ese fetch en el uso diario (FR-001).

## Fase 4 — Verificación de calidad

- [ ] @judge · Revisar `setup-ai.md` completo contra `requirements.md`: verificar sistemáticamente cada requisito funcional (FR-001 a FR-006) y cada criterio de éxito (SC-001 a SC-004) contra el fichero final, comprobando en particular: (1) ningún texto describe ya un fetch autorreferencial de las propias instrucciones de instalación fuera del auto-update explícito y documentado del launcher; (2) Step 1 y toda pregunta bloqueante equivalente instruyen explícitamente `AskUserQuestion` / `ask_user_question`; (3) los bloques "word for word" dirigidos al usuario llevan la instrucción de traducción con inglés como idioma por defecto, y los bloques de contenido de fichero (byte-for-byte) permanecen intactos, sin instrucción de traducción; (4) las dos plantillas del launcher (Claude Code y Codex CLI) embeben Steps 1-6 completos y documentan la auto-actualización create/overwrite/leave-alone con su fallback fail-safe ante fetch fallido; (5) coherencia interna del fichero — numeración de pasos, referencias cruzadas entre steps, Wrap-up alineado con el nuevo comportamiento, sin referencias huérfanas a la lógica antigua — y de paso confirmar que el README y la estructura de `catalog.yaml` referenciados no quedan contradichos por el cambio. Emitir PASS o CHANGES_REQUESTED con la lista concreta de líneas/secciones a corregir.

- [ ] @code-developer · Aplicar los cambios solicitados por @judge (si CHANGES_REQUESTED) y solicitar una segunda pasada de revisión hasta obtener PASS.

### Critical Files for Implementation

- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\setup-ai.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\catalog.yaml
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\README.md
- D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\001-separar-motor-de-instalacion-y-catalogo-en-setup\requirements.md
