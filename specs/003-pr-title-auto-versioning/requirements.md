# Añadir GitHub Action de versionado automático por título de PR
Feature Branch: 003-pr-title-auto-versioning

Created: 2026-08-02

Status: Draft

Input: User description: "todos los issues abiertos"

## User Scenarios & Testing (mandatory)

### User Story 1 - Precheck de título de PR bloquea merges no conformes (Priority: P1)

Como mantenedor del repositorio, cuando alguien abre, edita o sincroniza una Pull Request, quiero que un workflow de GitHub Actions valide automáticamente que el título de la PR empiece por `release:`, `feature:`, `fix:` o `chore:` (sin distinguir mayúsculas/minúsculas), de modo que las PRs con títulos que no siguen la convención queden bloqueadas para mergear a `main`.

Why this priority: Es la pieza que garantiza que el cálculo de versión (User Story 2) siempre reciba un prefijo válido. Sin este precheck como required status check, el workflow de publicación de tag podría no saber qué incremento aplicar o aplicar uno incorrecto. Además, es el primer punto de contacto del desarrollador con la convención, por lo que debe funcionar antes de que exista cualquier lógica de tagging.

Independent Test: Puede probarse de forma aislada abriendo una PR de prueba con un título sin prefijo válido (p. ej. "actualiza el README") y verificando que el check de precheck falla y bloquea el merge; luego editando el título a uno con prefijo válido (p. ej. "fix: corrige el README") y verificando que el check pasa, sin necesidad de que exista todavía el workflow de publicación de tag.

Acceptance Scenarios:

1. Given una PR abierta con título "añadir nueva pantalla de login", When se ejecuta el workflow de precheck, Then el check falla porque el título no empieza por ninguno de los prefijos permitidos.
2. Given una PR abierta con título "FEATURE: añadir login con Google", When se ejecuta el workflow de precheck, Then el check pasa porque la validación no distingue mayúsculas/minúsculas.
3. Given una PR con título inválido cuyo check de precheck falló, When el autor edita el título a "fix: corregir crash al iniciar" y el workflow se vuelve a ejecutar (evento edited/synchronize), Then el check pasa y la PR queda desbloqueada para mergear (asumiendo el resto de checks requeridos también en verde).

### User Story 2 - Publicación automática de tag semver al mergear a main (Priority: P2)

Como mantenedor del repositorio, cuando una PR con título prefijado se mergea a `main`, quiero que un workflow calcule automáticamente la nueva versión semántica a partir del último git tag existente y el prefijo del título de la PR mergeada, y publique el nuevo tag `vX.Y.Z` en el repositorio, de modo que la versión del proyecto quede siempre sincronizada con el historial de merges sin intervención manual ni fichero `VERSION` que mantener.

Why this priority: Depende de que el título de la PR ya esté validado (User Story 1) para poder confiar en el prefijo al calcular el incremento. Es el valor final del feature (automatizar el versionado) pero requiere la validación previa para ser fiable.

Independent Test: Puede probarse de forma aislada simulando (o ejecutando contra un repo de prueba) el merge de una PR con título "feature: ..." partiendo de un tag existente `v0.3.1`, y verificando que se publica el tag `v0.4.0`; repitiendo con "fix: ..." se espera `v0.3.2`; con "release: ..." se espera `v1.0.0`; con "chore: ..." se espera que no se publique ningún tag nuevo.

Acceptance Scenarios:

1. Given el último tag del repositorio es `v0.3.1` y se mergea a `main` una PR titulada "feature: añadir login con Google", When se ejecuta el workflow de publicación de tag, Then se publica el tag `v0.4.0`.
2. Given el último tag del repositorio es `v0.3.1` y se mergea a `main` una PR titulada "fix: corregir crash al iniciar", When se ejecuta el workflow de publicación de tag, Then se publica el tag `v0.3.2`.
3. Given el último tag del repositorio es `v0.3.1` y se mergea a `main` una PR titulada "release: v2 API pública", When se ejecuta el workflow de publicación de tag, Then se publica el tag `v1.0.0`.
4. Given se mergea a `main` una PR titulada "chore: actualizar dependencias", When se ejecuta el workflow de publicación de tag, Then no se publica ningún tag nuevo.
5. Given el repositorio no tiene ningún tag previo y se mergea a `main` una PR titulada "feature: ..." o "fix: ...", When se ejecuta el workflow de publicación de tag, Then se publica el tag `v0.1.0`.
6. Given el repositorio no tiene ningún tag previo y se mergea a `main` una PR titulada "release: ...", When se ejecuta el workflow de publicación de tag, Then se publica el tag `v1.0.0`.

## Edge Cases

- Si una PR se mergea a `main` sin haber pasado por el precheck (p. ej. bypass de admin): no hay lógica adicional en el workflow de tag; se confía exclusivamente en el required status check de branch protection para evitar este caso.
- Si el título de la PR mergeada no tiene ningún prefijo válido en el momento del merge: el workflow de publicación de tag falla explícitamente (visible en Actions), sin publicar tag.
- Si se mergean varias PRs a `main` casi simultáneamente: el workflow de publicación de tag usa un `concurrency:` group para serializar sus ejecuciones y evitar condiciones de carrera.
- Tags que no siguen el formato `vX.Y.Z` (legacy, pre-release, etc.) se ignoran por completo al calcular "el último tag"; solo se consideran tags que cumplan estrictamente el formato `vX.Y.Z`.
- Si ya existe un tag con el nombre calculado (colisión, p. ej. por un tag creado manualmente): esto no debería ocurrir en el flujo normal; el workflow de publicación de tag falla explícitamente con un error y se detiene, sin sobrescribir el tag existente.

## Requirements (mandatory)

### Functional Requirements

- FR-001: El sistema DEBE ejecutar un workflow de GitHub Actions en los eventos `opened`, `edited` y `synchronize` de pull_request que valide el título de la PR.
- FR-002: El workflow de precheck DEBE validar que el título de la PR empiece por uno de los prefijos `release:`, `feature:`, `fix:` o `chore:`, sin distinguir mayúsculas/minúsculas.
- FR-003: El workflow de precheck DEBE fallar el check si el título no coincide con ninguno de los prefijos permitidos.
- FR-004: El check de precheck DEBE quedar documentado como required status check en la protección de la rama `main`, de modo que un check en fallo bloquee el merge.
- FR-005: El sistema DEBE ejecutar un workflow de publicación de tag al mergear una PR a `main` (disparado por push a `main` o por el evento pull_request `closed` con `merged=true`).
- FR-006: El workflow de publicación de tag DEBE leer el prefijo del título de la PR mergeada y el último git tag existente en el repositorio para calcular la nueva versión.
- FR-007: Un prefijo `release:` DEBE incrementar la versión major (`vX.0.0`).
- FR-008: Un prefijo `feature:` DEBE incrementar la versión minor (`v0.X.0`).
- FR-009: Un prefijo `fix:` DEBE incrementar la versión patch (`v0.0.X`).
- FR-010: Un prefijo `chore:` NO DEBE publicar ningún tag nuevo.
- FR-011: Si no existe ningún tag previo en el repositorio, el primer merge con prefijo `feature:` o `fix:` DEBE generar el tag `v0.1.0`.
- FR-012: Si no existe ningún tag previo en el repositorio, el primer merge con prefijo `release:` DEBE generar el tag `v1.0.0`.
- FR-013: El nuevo tag DEBE publicarse (push) automáticamente al repositorio en formato `vX.Y.Z`.
- FR-014: El fichero `VERSION` DEBE eliminarse del repositorio; el git tag es la única fuente de verdad de la versión.
- FR-015: El workflow de publicación de tag NO DEBE implementar lógica adicional de fallback ante un bypass del precheck; se confía exclusivamente en el required status check de branch protection sobre `main`.
- FR-016: Si el título de la PR mergeada no tiene un prefijo válido en el momento del merge, el workflow de publicación de tag DEBE fallar explícitamente, sin publicar ningún tag.
- FR-017: El workflow de publicación de tag DEBE usar un `concurrency:` group para serializar sus ejecuciones y evitar condiciones de carrera cuando se mergean varias PRs casi simultáneamente.
- FR-018: Al calcular "el último tag", el workflow DEBE ignorar cualquier tag que no cumpla estrictamente el formato `vX.Y.Z`.
- FR-019: El workflow de publicación de tag DEBE publicar únicamente el tag de git; NO DEBE crear un GitHub Release asociado.
- FR-020: El workflow de publicación de tag DEBE usar el `GITHUB_TOKEN` por defecto de Actions (con permisos de contenidos en escritura); no requiere un PAT adicional.
- FR-021: Si el tag calculado ya existe en el repositorio (colisión), el workflow de publicación de tag DEBE fallar explícitamente con un error y detenerse, sin sobrescribir el tag existente.

### Key Entities (include if feature involves data)

- Pull Request: entidad de GitHub cuyo atributo relevante es el título (usado para extraer el prefijo de versionado) y el estado de merge (`merged=true`) hacia `main`.
- Git Tag: entidad que representa la versión publicada del repositorio, en formato `vX.Y.Z`; es la única fuente de verdad de la versión (no existe fichero `VERSION`).
- Workflow de precheck: GitHub Action que se ejecuta en eventos de pull_request y actúa como required status check.
- Workflow de publicación de tag: GitHub Action que se ejecuta al mergear a `main`, calcula la nueva versión y publica el tag.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: El 100% de las PRs con título sin prefijo válido (`release:`/`feature:`/`fix:`/`chore:`, case-insensitive) quedan bloqueadas para mergear a `main` por el check de precheck.
- SC-002: El 100% de los merges a `main` de PRs con prefijo `release:`, `feature:` o `fix:` resultan en la publicación automática de un tag `vX.Y.Z` con el incremento correcto (major/minor/patch respectivamente), sin intervención manual.
- SC-003: El 100% de los merges a `main` de PRs con prefijo `chore:` no publican ningún tag nuevo.
- SC-004: El fichero `VERSION` no existe en el repositorio tras la implementación del feature.
- SC-005: Partiendo de un repositorio sin tags, el primer merge con `feature:` o `fix:` produce `v0.1.0`, y el primer merge con `release:` produce `v1.0.0`.

## Assumptions

- Se asume que los workflows se implementan como GitHub Actions estándar (YAML en `.github/workflows/`), dado que el issue los describe como "workflows de GitHub Actions".
- Se asume que el disparador de publicación de tag puede implementarse mediante push a `main` o mediante el evento `pull_request` con tipo `closed` y `merged=true`, tal como indica explícitamente el issue, sin que este determine cuál de las dos opciones (o si ambas) debe usarse.
- Se asume que la convención de prefijos y las reglas de versión inicial son exactamente las ya documentadas en `CLAUDE.md` del repositorio (release→major, feature→minor, fix→patch, chore→sin tag; primer `feature`/`fix`→`v0.1.0`, primer `release`→`v1.0.0`), consistentes con lo descrito en el issue.
