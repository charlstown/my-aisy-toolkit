# Plan: Catálogos de skills compartidas y agentes nativos

Feature Branch: `002-catalogos-nativos-claude-codex`
Requirements: `specs/002-catalogos-nativos-claude-codex/requirements.md`

## Decisiones de ejecución

- Las 15 skills actuales (10 de `default`, 2 adicionales de `ui-ux` y 3 de `utils`) pasan a ser directorios bajo `ai-toolkit/skills/<nombre>/`, con un único `SKILL.md` y cualquier recurso propio que necesiten.
- Los seis agentes conservan dos artefactos nativos: Markdown para Claude y TOML para Codex. No se genera una variante desde la otra.
- El manifiesto declara rutas explícitas para skills y para cada conjunto de agentes. El instalador solo resuelve y copia esas rutas; no infiere archivos ni convierte contenido.

## Tareas

- [ ] @architect · Inventariar y fijar el mapa de migración: relacionar cada entrada de los perfiles `default`, `ui-ux` y del pack `utils` con su destino único `ai-toolkit/skills/<nombre>/SKILL.md`, y cada uno de los seis agentes con su par Claude/Codex. Diseñar la forma explícita de `catalog.yaml` que permita resolver skills, packs y agentes por destino sin listar directorios remotos. Archivos afectados: `catalog.yaml`, árbol actual `ai-toolkit/`, `.codex/agents/`. Dependencias: ninguna. Comprobación: cada selección actual queda mapeada una vez, sin rutas implícitas ni duplicados.

- [x] @code-developer · Migrar las skills distribuibles al catálogo compartido: crear `ai-toolkit/skills/` con una carpeta y `SKILL.md` por skill, trasladar los recursos que pertenezcan a cada una y retirar las copias distribuidas de `ai-toolkit/default/commands/`, `ai-toolkit/ui-ux/commands/` y `ai-toolkit/utils/commands/`. Adaptar solo lo imprescindible para que el mismo archivo sea válido para ambos destinos, sin cambiar su flujo funcional. Archivos afectados: árboles `ai-toolkit/skills/`, `ai-toolkit/default/`, `ai-toolkit/ui-ux/`, `ai-toolkit/utils/`. Dependencia: mapa de migración. Comprobación: hay una sola fuente por skill y cada ruta de skill del manifiesto apunta a `<nombre>/SKILL.md` existente.

- [x] @code-developer · Publicar los agentes nativos por destino: crear `ai-toolkit/agents/claude/` con los Markdown instalables y `ai-toolkit/agents/codex/` con los TOML instalables, preservando sus formatos nativos y documentando las diferencias deliberadas. Retirar del catálogo distribuible anterior las copias que crearían duplicidad. Archivos afectados: `ai-toolkit/agents/claude/`, `ai-toolkit/agents/codex/`, fuentes actuales de agentes bajo `ai-toolkit/default/` y `.codex/agents/`. Dependencia: mapa de migración. Comprobación: cada agente seleccionado existe como `.md` para Claude y `.toml` para Codex; ninguna ruta de agente cruza de destino.

- [x] @code-developer · Actualizar el manifiesto y el instalador para copia literal: modificar `catalog.yaml` y los pasos 2 a 5 de `setup-ai.md` para resolver únicamente las rutas declaradas, descargar cada artefacto y compararlo byte a byte con el destino. Escribir las skills en `.claude/skills/<nombre>/SKILL.md` o `.agents/skills/<nombre>/SKILL.md`, los agentes en `.claude/agents/*.md` o `.codex/agents/*.toml`, y mantener `aisy.` para utils. Eliminar todas las instrucciones de traducir, reinterpretar o buscar equivalencias semánticas, conservando selección explícita, reintentos y reglas create/overwrite/leave-alone. Archivos afectados: `catalog.yaml`, `setup-ai.md`. Dependencias: tareas de migración de skills y agentes. Comprobación: el instalador no menciona la traducción Codex y sus cuatro mapeos de destino son explícitos y literales.

- [ ] @code-developer · Alinear la documentación y la decisión arquitectónica: actualizar `README.md`, `README-ES.md`, `specs/product-spec.md`, `specs/tech-spec.md` (incluido el reemplazo de ADR-002), el README interno del catálogo y las referencias de estructura/rutas. Hacer de `AGENTS.md` la fuente de verdad de mantenimiento y dejar en `CLAUDE.md` únicamente la referencia a ella. Archivos afectados: `README.md`, `README-ES.md`, `specs/product-spec.md`, `specs/tech-spec.md`, documentación bajo `ai-toolkit/`, `AGENTS.md`, `CLAUDE.md`. Dependencia: estructura y manifiesto finales. Comprobación: una búsqueda no encuentra las rutas distribuidas antiguas ni la traducción durante la instalación, salvo referencias históricas justificadas en ADRs sustituidos.

- [ ] @tester · Verificar cobertura e instalación reproducible: revisar que `default`, `ui-ux` y `utils` resuelven todas sus skills compartidas para los dos agentes, y ejecutar una instalación de inspección en repositorios temporales para Claude y Codex. Confirmar selección explícita, prefijo `aisy.`, destinos nativos, reintento por archivo y comportamiento de actualización sin borrado de artefactos preexistentes. Archivos afectados: ninguno, salvo evidencia si se decide conservarla. Dependencias: todas las tareas anteriores. Comprobación: checklist de criterios de aceptación completo con rutas verificadas; cualquier limitación del entorno queda registrada.

## Bloqueadores

- Ninguno conocido. La validación en una instalación real de Codex continúa sujeta a la limitación ya documentada; la verificación debe distinguir esa limitación de la comprobación determinista de archivos.
