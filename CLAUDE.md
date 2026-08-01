# CLAUDE.md

## Versionado semántico automático

Este repo versiona mediante tags de git, calculados automáticamente a partir del título de las Pull Requests que se mergean a `main` (ver issue #15). No existe fichero `VERSION`: el último git tag es la única fuente de verdad de la versión.

### Convención de título de PR (obligatoria)

Todo título de PR debe empezar por uno de estos prefijos (case-insensitive, estilo Conventional Commits):

| Prefijo | Efecto en el merge a `main` |
|---|---|
| `release: ...` | Incrementa la versión **major** (`vX.0.0`) |
| `feature: ...` | Incrementa la versión **minor** (`v0.X.0`) |
| `fix: ...` | Incrementa la versión **patch** (`v0.0.X`) |
| `chore: ...` | No publica ningún tag |

Un título sin ninguno de estos prefijos falla un check requerido y bloquea el merge de la PR.

### Reglas de versión inicial

Si el repositorio aún no tiene ningún tag:
- El primer `feature:` o `fix:` mergeado genera `v0.1.0`.
- El primer `release:` mergeado genera `v1.0.0`.

### Al crear una PR

Al titular una PR (manual o vía `gh pr create`), usa siempre uno de los cuatro prefijos anteriores acorde al tipo de cambio. No inventes otros prefijos.

### Push directo a `main` prohibido

Nunca hagas push directo a `main`. Todo cambio entra exclusivamente vía Pull Request, con título prefijado según la tabla anterior.
