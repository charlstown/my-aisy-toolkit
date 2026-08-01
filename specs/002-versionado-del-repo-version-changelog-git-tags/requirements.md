# Versionado del repo (VERSION, CHANGELOG.md, git tags y badge en README)
Feature Branch: [002-versionado-del-repo-version-changelog-git-tags]

Created: 2026-08-01

Status: Draft

Input: User description: "todos los issues del repo"

## User Scenarios & Testing (mandatory)

### User Story 1 - El mantenedor sabe en qué versión está el catálogo (Priority: P1)

Como mantenedor de `my-aisy-toolkit`, quiero que el repo tenga un número de versión SemVer explícito y visible (fichero `VERSION`, badge en el README) para saber en todo momento en qué versión del catálogo está el proyecto, sin tener que inspeccionar el historial de commits.

Why this priority: es el requisito base del que dependen el resto de historias — sin un fichero `VERSION` y un badge no hay "versionado" que documentar ni que comunicar.

Independent Test: clonar el repo, verificar que existe `VERSION` en la raíz con el valor `0.1.0`, y que el README (`README.md` y `README-ES.md`) renderiza un badge que apunta a `https://img.shields.io/github/v/tag/charlstown/my-aisy-toolkit`.

Acceptance Scenarios:

1. Given un checkout limpio del repo en `main`, When se abre el fichero `VERSION` en la raíz, Then contiene una sola línea de texto plano con el valor `0.1.0`.
2. Given el README (`README.md` o `README-ES.md`) renderizado en GitHub, When no existe todavía ningún git tag en el repo, Then el badge de shields.io se muestra igualmente (con el comportamiento por defecto de shields.io ante ausencia de tags, sin que esto rompa el renderizado del README).

### User Story 2 - El mantenedor y los colaboradores pueden consultar el historial de cambios (Priority: P2)

Como mantenedor o colaborador, quiero un `CHANGELOG.md` en formato Keep a Changelog para poder ver qué cambió entre versiones sin tener que leer todo el log de git.

Why this priority: depende de que exista el concepto de versión (User Story 1) pero es independiente en su verificación: el changelog puede existir y ser consultado aunque el badge aún no refleje ningún tag.

Independent Test: abrir `CHANGELOG.md` en la raíz y comprobar que sigue la estructura de Keep a Changelog (cabecera, formato de versión, fecha) y que contiene una entrada para `0.1.0`.

Acceptance Scenarios:

1. Given el fichero `CHANGELOG.md` en la raíz del repo, When se inspecciona su estructura, Then sigue el formato de [Keep a Changelog](https://keepachangelog.com/).
2. Given `CHANGELOG.md`, When se busca la entrada de la versión inicial, Then existe una entrada para `0.1.0` coherente con el valor del fichero `VERSION`.

### User Story 3 - El proceso de release queda documentado para no olvidar el paso del git tag (Priority: P2)

Como mantenedor, quiero que los 3 pasos manuales de cada release (bump de `VERSION`, entrada en `CHANGELOG.md`, y `git tag` + push) estén documentados, para no olvidar el paso del tag — que es el que realmente alimenta el badge del README y el más fácil de saltarse.

Why this priority: sin esta documentación, el resto del versionado (badge, changelog) puede quedar desincronizado en el primer release real tras el inicial.

Independent Test: localizar la documentación de los 3 pasos (en `tech-spec.md` o en `CONTRIBUTING.md` — ver DEFINITION GAP) y verificar que enumera explícitamente: 1) bump de `VERSION`, 2) nueva entrada en `CHANGELOG.md`, 3) `git tag vX.Y.Z && git push --tags`.

Acceptance Scenarios:

1. Given la documentación de proceso de release, When un mantenedor sigue los pasos descritos, Then el resultado incluye una nueva versión bumpeada en `VERSION`, una entrada nueva en `CHANGELOG.md` y un git tag `vX.Y.Z` pusheado al remoto.
2. Given la decisión de versionado a nivel de repo, When se consulta `specs/tech-spec.md`, Then existe una entrada **ADR-006** con el mismo formato que ADR-001 a ADR-005 explicando la decisión.

### User Story 4 - El versionado no afecta a la instalación ni a las skills/agents individuales (Priority: P3)

Como usuario final de `setup-ai` o como mantenedor de skills/agents individuales, quiero que este cambio no modifique el comportamiento de instalación (`setup-ai` sigue trayendo siempre `main`) ni introduzca campos `version` en `catalog.yaml` o en el frontmatter de skills/agents, para que la detección de cambios por contenido directo siga funcionando igual que antes.

Why this priority: es una historia de "no regresión" — de menor prioridad de implementación porque es, en esencia, verificar ausencia de cambios, pero es un criterio de aceptación explícito del issue.

Independent Test: revisar `catalog.yaml` y el frontmatter de todos los ficheros bajo `ai-toolkit/default/commands/*.md` y `ai-toolkit/default/agents/*.md` y confirmar que ninguno incluye un campo `version`.

Acceptance Scenarios:

1. Given `catalog.yaml`, When se inspecciona su contenido, Then no contiene ningún campo `version`.
2. Given cualquier fichero bajo `ai-toolkit/default/commands/*.md` o `ai-toolkit/default/agents/*.md`, When se inspecciona su frontmatter, Then no contiene ningún campo `version`.
3. Given el comportamiento actual de instalación de `setup-ai`, When se ejecuta tras este cambio, Then sigue trayendo siempre la versión de `main`, sin selección de versión por parte del usuario final.

## Edge Cases

- ¿Qué ocurre con el badge de shields.io en el README si el repo todavía no tiene ningún git tag publicado en el momento del merge de esta feature? (El issue asume comportamiento por defecto de shields.io, pero no describe explícitamente el estado "sin tags".)
- ¿Cómo se resuelve una futura discrepancia entre el valor de `VERSION` y la última entrada de `CHANGELOG.md` si un mantenedor olvida uno de los 3 pasos manuales? El issue documenta el proceso pero no define ninguna validación automática.

## Requirements (mandatory)

### Functional Requirements

- FR-001: El sistema MUST incluir un fichero `VERSION` en la raíz del repo, en texto plano, con una sola línea, cuyo valor inicial sea `0.1.0`.
- FR-002: El sistema MUST incluir un fichero `CHANGELOG.md` en la raíz del repo, siguiendo el formato [Keep a Changelog](https://keepachangelog.com/), con una entrada inicial para la versión `0.1.0`.
- FR-003: `catalog.yaml` MUST permanecer sin ningún campo `version`, conservando su rol exclusivo de manifiesto de qué skills/agents entran en cada perfil (ADR-003).
- FR-004: Ninguna skill ni agent individual bajo `ai-toolkit/default/commands/*.md` ni `ai-toolkit/default/agents/*.md` MUST incluir un campo `version` en su frontmatter.
- FR-005: `setup-ai` MUST seguir detectando cambios comparando contenido directamente (remoto vs. local), sin introducir comparación por número de versión.
- FR-006: `README.md` y `README-ES.md` MUST incluir un badge dinámico apuntando a `https://img.shields.io/github/v/tag/charlstown/my-aisy-toolkit`, usando el comportamiento por defecto de shields.io (sin `?sort=semver` ni migración a `/github/v/release/` en esta feature).
- FR-007: El comportamiento de instalación de `setup-ai` MUST permanecer sin cambios: siempre trae `main`, sin selección de versión por parte del usuario final.
- FR-008: La decisión de versionado a nivel de repo MUST quedar documentada como **ADR-006** en `specs/tech-spec.md`, siguiendo el mismo formato que ADR-001 a ADR-005.
- FR-009: El sistema MUST documentar los 3 pasos manuales de cada release — bump de `VERSION`, nueva entrada en `CHANGELOG.md`, y creación + push del git tag correspondiente (`git tag vX.Y.Z && git push --tags`) — [NEEDS CLARIFICATION: el issue propone documentarlo "en tech-spec.md o en un CONTRIBUTING.md", presentando ambas opciones sin decidir cuál. Actualmente no existe ningún `CONTRIBUTING.md` en la raíz del repo. Debe decidirse si se añade esta documentación dentro de la propia entrada ADR-006 de tech-spec.md, en otra sección de tech-spec.md, o si se crea un `CONTRIBUTING.md` nuevo].

### Key Entities (include if feature involves data)

No aplica — esta feature no introduce entidades de datos persistentes; trabaja sobre ficheros de metadatos del propio repo (`VERSION`, `CHANGELOG.md`, `README.md`, `README-ES.md`, `specs/tech-spec.md`).

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: El fichero `VERSION` existe en la raíz del repo con el valor `0.1.0`.
- SC-002: El fichero `CHANGELOG.md` existe en la raíz, sigue el formato Keep a Changelog, y contiene una entrada para `0.1.0`.
- SC-003: `README.md` y `README-ES.md` muestran el badge de shields.io apuntando a `img.shields.io/github/v/tag/charlstown/my-aisy-toolkit`.
- SC-004: `catalog.yaml` no contiene ningún campo `version` (verificable por inspección/grep).
- SC-005: Ningún fichero bajo `ai-toolkit/default/` (skills o agents) contiene un campo `version` en su frontmatter (verificable por inspección/grep).
- SC-006: `specs/tech-spec.md` contiene una entrada ADR-006 sobre el versionado del repo, con el mismo formato que ADR-001 a ADR-005.
- SC-007: Los 3 pasos manuales de cada release quedan documentados de forma localizable por el mantenedor (bump `VERSION`, entrada en `CHANGELOG.md`, git tag + push).

## Assumptions

- El repo objetivo es `charlstown/my-aisy-toolkit` en GitHub (usado literalmente en la URL del badge).
- La rama base es `main` y la rama sugerida para el desarrollo es `feat/repo-versioning`, tal como indica el issue.
- El valor inicial `0.1.0` es coherente con la `Version: v0.1` ya declarada en `product-spec.md` / `tech-spec.md`, según lo indicado explícitamente en el issue.
- No se crean GitHub Releases como parte de esta feature; el issue menciona la migración a `/github/v/release/` únicamente como mejora futura posible, no como alcance actual.

## DEFINITION GAP

- [ ] Ubicación final de la documentación de los 3 pasos manuales de release: el issue propone "en `tech-spec.md` o en un `CONTRIBUTING.md`" sin decidir entre ambas opciones. No existe actualmente ningún `CONTRIBUTING.md` en la raíz del repo, por lo que elegir esa opción implicaría crear un fichero nuevo no descrito en ningún otro requisito del issue.
- [ ] Comportamiento del badge de shields.io antes de que exista el primer git tag publicado tras el merge de esta feature (el issue no describe el estado "repo sin tags", solo indica que se usa el comportamiento por defecto de shields.io).
- [ ] Contenido exacto que debe llevar la primera entrada de `CHANGELOG.md` para `0.1.0` más allá del formato Keep a Changelog (el issue no detalla qué categorías — Added/Changed/Fixed, etc. — ni qué elementos concretos del catálogo deben listarse en esa entrada inicial).
- [ ] Ubicación exacta del badge dentro de `README.md` / `README-ES.md` (junto a otros badges existentes, en la cabecera, etc.) — el issue no lo especifica.
