# Instrucciones del repositorio

## Versionado semántico automático

Este repositorio se versiona mediante tags de Git calculados a partir del título de las pull requests que se integran en `main` (ver issue #15). No existe fichero `VERSION`: el último tag de Git es la única fuente de verdad de la versión.

### Convención de título de PR (obligatoria)

Todo título de PR debe empezar por uno de estos prefijos (sin distinguir mayúsculas, estilo Conventional Commits):

| Prefijo | Efecto al integrar en `main` |
|---|---|
| `release: ...` | Incrementa la versión **major** (`vX.0.0`) |
| `feature: ...` | Incrementa la versión **minor** (`v0.X.0`) |
| `fix: ...` | Incrementa la versión **patch** (`v0.0.X`) |
| `chore: ...` | No publica ningún tag |

Un título sin uno de estos prefijos falla un check requerido y bloquea el merge de la PR.

### Reglas de versión inicial

Si el repositorio aún no tiene ningún tag:

- El primer `feature:` o `fix:` integrado genera `v0.1.0`.
- El primer `release:` integrado genera `v1.0.0`.

### Al crear una PR

Al titular una PR (manual o vía `gh pr create`), usa siempre uno de los cuatro prefijos anteriores acorde al tipo de cambio. No inventes otros prefijos.

### Push directo a `main` prohibido

Nunca hagas push directo a `main`. Todo cambio entra exclusivamente vía pull request, con título prefijado según la tabla anterior.

## Catálogos nativos de Claude Code y Codex

`ai-toolkit/skills/` es la única fuente distribuible de las skills equivalentes para Claude Code y Codex. No se duplican ni se traducen durante la instalación.

Los agentes, que sí son específicos de cada herramienta, se almacenan por separado en `ai-toolkit/agents/claude/` y `ai-toolkit/agents/codex/`.

- Cuando se añada, cambie o retire una skill distribuida, actualizar su único artefacto en `ai-toolkit/skills/` y sus rutas en `catalog.yaml`.
- Cuando cambie un agente, actualizar únicamente su variante nativa correspondiente y documentar cualquier diferencia deliberada entre agentes.
- Revisar en la PR que los perfiles `default`, `ui-ux` y el pack `utils` conservan la cobertura funcional acordada para ambos instaladores, sin crear copias de una misma skill.

## Preguntas de las skills compartidas

Claude Code conserva el mecanismo de preguntas indicado por cada skill. Para Codex, cuando una skill compartida necesite información o una decisión, usa su herramienta nativa de preguntas si está disponible; si no, usa el diálogo conversacional.

En Codex presenta exactamente una pregunta pendiente por turno, con alternativas identificables y una instrucción explícita para responder con una opción o con texto propio. Espera y procesa la respuesta antes de formular otra pregunta o ejecutar un paso dependiente. Las respuestas libres son válidas; si la persona expresa que aún no lo tiene claro, registra el gap y continúa únicamente con preguntas o pasos independientes de esa decisión.

El ejemplo `description: none` es solo ilustrativo: no debe convertirse en una pregunta obligatoria de ninguna skill fuera de su contexto.
