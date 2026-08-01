# Plan — Versionado del repo (VERSION, CHANGELOG.md, git tags y badge en README)

Feature Branch: `feat/repo-versioning`

Requirements: `specs/002-versionado-del-repo-version-changelog-git-tags/requirements.md`

Created: 2026-08-01

## 1. Contexto encontrado (verificado en el repo)

Todo lo siguiente está comprobado leyendo los ficheros, no asumido:

| Hallazgo | Evidencia |
|---|---|
| No existe `VERSION` ni `CHANGELOG.md` en la raíz | `ls` de la raíz: solo `.gitignore`, `catalog.yaml`, `CODE_OF_CONDUCT.md`, `LICENSE`, `README.md`, `README-ES.md`, `setup-ai.md` |
| **No hay ningún git tag en el repo** | `git tag -l` devuelve vacío |
| `README.md` y `README-ES.md` ya tienen un badge de versión, pero **estático y con valor `1.1`** | línea 14 de ambos: `<img src="https://img.shields.io/badge/version-1.1-orange?style=for-the-badge" alt="Version">` |
| `catalog.yaml` **no** tiene ningún campo `version` (FR-003 ya se cumple) | `grep -n "version" catalog.yaml` → sin resultados |
| Ningún fichero de `ai-toolkit/` tiene `version` en frontmatter (FR-004 ya se cumple) | `grep -rn "^version:" ai-toolkit/` → sin resultados |
| `specs/tech-spec.md` contiene ADR-001…ADR-005 con formato fijo: `### ADR-00N: título` + `**Decision**` + `**Context**` + `**Consequences**` (bullets `(+)` / `(-)` y `Mitigation`) | `specs/tech-spec.md` líneas 166-221 |
| `specs/tech-spec.md` está escrito **en inglés** (igual que `product-spec.md` y `roadmap.md`) | todo el documento |
| ADR-005 termina en la línea 221; la sección siguiente es `## ⚠️ Known Limitations` (línea 223) | `specs/tech-spec.md` |
| `product-spec.md` declara explícitamente lo contrario de esta feature: *"no semantic versioning or release tags for now"* (línea 36) y *"How is the catalog versioned? → …no semantic versioning for now"* (línea 170) | `specs/product-spec.md` |
| `README.md` / `README-ES.md` línea 123 repiten esa idea: *"There's no semantic versioning to track"* / *"No hay versionado semántico que rastrear"* | ambos README |
| No hay tests automáticos ni CI en el repo | `tech-spec.md` § Testing Strategy y § Known Limitations |
| El plan lo consume `/implement-feature`: cada `##` es un batch, cada `- [ ]` una tarea, y hace **un commit al cerrar cada batch** | `ai-toolkit/default/commands/implement-feature.md` §4d |

**Comportamiento real de shields.io sin tags (verificado, no asumido).** Petición a `https://img.shields.io/github/v/tag/charlstown/my-aisy-toolkit.json` devuelve:

```json
{ "label": "tag", "message": "no tags found", "color": "red" }
```

Es decir: el badge **renderiza correctamente** (no rompe el README, confirma el Edge Case del requirements), pero muestra literalmente "no tags found" en rojo hasta que exista el primer tag.

**Conclusión de alcance real:** de los 9 FR, **FR-003, FR-004, FR-005 y FR-007 ya se cumplen hoy** y son requisitos de *no regresión* (verificación, no implementación). El trabajo efectivo son 5 ficheros: crear `VERSION`, crear `CHANGELOG.md`, editar `README.md`, editar `README-ES.md` y editar `specs/tech-spec.md`.

## 2. Decisiones (ADR-style)

### D-01 — `VERSION` sin prefijo `v`; los tags sí lo llevan (`vX.Y.Z`)

**Decisión:** el fichero contiene `0.1.0`; el tag correspondiente es `v0.1.0`.
**Alternativas descartadas:** `v0.1.0` en ambos sitios / tags sin `v`.
**Por qué:** FR-001 fija el valor `0.1.0` y FR-009 fija `git tag vX.Y.Z`, así que la asimetría viene del propio issue. Además el fichero queda como SemVer puro (legible por cualquier script futuro sin recortar el prefijo) y los tags siguen la convención habitual de git. **Esta asimetría debe quedar escrita en ADR-006** para que nadie la "arregle" más adelante.

### D-02 — Se **sustituye** el badge estático `version-1.1`, no se añade uno nuevo al lado

**Decisión:** reemplazar in-situ la línea 14 de ambos README por el badge dinámico.
**Alternativas descartadas:** (a) mantener el estático y añadir el dinámico debajo; (b) mantener el estático corrigiendo su valor a `0.1.0`.
**Por qué:** hoy el badge estático dice `1.1` y `VERSION` va a decir `0.1.0` — dos fuentes de verdad que ya estarían en desacuerdo el día del merge. Un badge dinámico alimentado por los tags es exactamente lo que pide el issue (SC-003) y elimina un mantenimiento manual. Es el cambio de menor superficie: una línea por fichero, sin tocar la maquetación.

### D-03 — Se conservan los parámetros cosméticos del badge (`style`, `label`, `color`)

**Decisión:** URL final `https://img.shields.io/github/v/tag/charlstown/my-aisy-toolkit?style=for-the-badge&label=version&color=orange`.
**Alternativa descartada:** URL desnuda `https://img.shields.io/github/v/tag/charlstown/my-aisy-toolkit`.
**Por qué:** FR-006 restringe la *semántica* del badge (prohíbe `?sort=semver` y prohíbe migrar a `/github/v/release/`), no su presentación. Sin `style=for-the-badge` el badge héroe pierde el tamaño que se le acaba de dar a propósito (commit `a70fc6d`, "increase version badge size"), y sin `label=version` pasa a leerse "tag" en lugar de "version". Ningún parámetro altera qué tag se selecciona.
**Si el mantenedor prefiere leer FR-006 al pie de la letra:** usar la URL desnuda; es un cambio de un string y no afecta a ninguna otra tarea del plan.
*Nota de implementación:* dentro del HTML del README se escribe `&` tal cual (GitHub lo renderiza bien); `&amp;` también sería válido.

### D-04 — No se crea el tag `v0.1.0` dentro de esta feature

**Decisión:** la creación y push del tag queda como acción del mantenedor tras el merge (ver §6), no como tarea del plan.
**Alternativa descartada:** crear y pushear `v0.1.0` como última tarea.
**Por qué:** el requirements deja el tag fuera de los FR (solo pide *documentar* el paso, FR-009) y su Edge Case acepta explícitamente el estado sin tags. Además es una escritura en el remoto: la ejecuta el humano, y el catálogo de agentes disponible no incluye un rol `@human`, así que no debe ir como checkbox (un `- [ ]` sería despachado a un subagente por `/implement-feature`).
**Consecuencia asumida:** entre el merge y el primer tag, el badge héroe de ambos README leerá "version | no tags found". Es el comportamiento verificado en §1 y no rompe el renderizado.

### D-05 — `CHANGELOG.md` en inglés, con `[Unreleased]` y **sin** link-references de comparación

**Decisión:** idioma inglés (coherente con `README.md`, `product-spec.md`, `tech-spec.md` y `roadmap.md`); se incluye la sección `## [Unreleased]` vacía; **no** se añaden al pie los `[0.1.0]: https://github.com/.../compare/...`.
**Alternativas descartadas:** changelog bilingüe (duplica mantenimiento, y no existe `CHANGELOG-ES.md` en el issue); incluir link-refs de compare.
**Por qué:** `[Unreleased]` es parte del formato Keep a Changelog y da destino natural a las entradas entre releases, reforzando FR-009. Los link-refs de compare apuntarían a tags inexistentes → enlaces rotos el día del merge, justo el problema que D-04 ya asume una vez.

### D-06 — Los 3 pasos de release van en un bloque etiquetado **dentro** de ADR-006, después de `**Consequences**`

**Decisión:** ADR-006 mantiene la tríada `**Decision**` / `**Context**` / `**Consequences**` idéntica a ADR-001…005, y añade al final un bloque `**Release process (manual, 3 steps)**` con lista numerada.
**Alternativa descartada:** meter los 3 pasos como un bullet dentro de `**Consequences**`.
**Por qué:** SC-007 exige que los pasos sean "localizables"; enterrados en un bullet de consecuencias no lo son. El bloque extra respeta FR-008 ("mismo formato") porque no altera la estructura canónica del ADR, solo la extiende al final de esa entrada concreta.

### D-07 — La contradicción con `product-spec.md` se resuelve **dentro del Context de ADR-006**, no editando `product-spec.md`

**Decisión:** ADR-006 debe distinguir explícitamente dos planos: (a) *versionado de distribución del catálogo* — sin cambios, `setup-ai` siempre trae `main`, sin SemVer, tal como dice `product-spec.md`; (b) *versionado del repo* — nuevo, SemVer + tags, para visibilidad del mantenedor. No se tocan `product-spec.md` ni la línea 123 de los README en esta feature.
**Alternativa descartada:** matizar ya las líneas 36 y 170 de `product-spec.md`.
**Por qué:** el requirements no incluye `product-spec.md` entre los ficheros afectados (§ Key Entities) y el principio de no inventar alcance manda. Queda propuesto aparte en §5, y la skill `/clean-feature` audita `product-spec.md` después de cada plan completado, así que es el momento natural de decidirlo.

## 3. Plan por batches

Orden por prioridad de historias: P1 → P2 → P3 → gate. Cada batch cierra con un commit (lo hace `/implement-feature`).

### Batch 1 — P1 · Versión explícita y visible (User Story 1)

- [ ] @code-developer · Crear el fichero VERSION: crear `VERSION` (sin extensión) en la raíz del repo `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\VERSION` con una única línea de texto plano `0.1.0` — sin prefijo `v`, sin comillas, sin BOM, sin comentarios, terminado en un salto de línea. El fichero no debe contener nada más. Cubre FR-001 y SC-001; ver decisión D-01.
- [ ] @code-developer · Sustituir el badge de versión en README.md: en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\README.md`, línea 14, reemplazar `<img src="https://img.shields.io/badge/version-1.1-orange?style=for-the-badge" alt="Version">` por `<img src="https://img.shields.io/github/v/tag/charlstown/my-aisy-toolkit?style=for-the-badge&label=version&color=orange" alt="Version">`. No tocar el `<p align="center">` que lo envuelve, ni el bloque de badges `skills` / `agents` / `updated` de las líneas 17-21, ni ninguna otra línea del fichero. Prohibido añadir `?sort=semver` o usar el endpoint `/github/v/release/`. Cubre FR-006 y SC-003; ver decisiones D-02 y D-03.
- [ ] @code-developer · Sustituir el badge de versión en README-ES.md: mismo cambio que la tarea anterior en `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\README-ES.md`, línea 14, con la **misma URL exacta** pero conservando el atributo original `alt="Versión"` (con tilde). No tocar nada más del fichero. Cubre FR-006 y SC-003.

### Batch 2 — P2 · Historial de cambios consultable (User Story 2)

- [ ] @code-developer · Crear CHANGELOG.md en formato Keep a Changelog: crear `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\CHANGELOG.md` en inglés, con (1) título `# Changelog`, (2) la cabecera estándar de Keep a Changelog con enlace a `https://keepachangelog.com/en/1.1.0/` y a `https://semver.org/spec/v2.0.0.html`, (3) una sección `## [Unreleased]` vacía, y (4) la entrada `## [0.1.0] - 2026-08-01` con un subapartado `### Added` que resuma el estado inicial del repo verificable en él: catálogo del perfil `default` con 11 skills en `ai-toolkit/default/commands/` y 6 subagentes en `ai-toolkit/default/agents/`, manifiesto `catalog.yaml`, instalador `setup-ai.md`, `README.md` y `README-ES.md`, y el propio versionado del repo (`VERSION`, `CHANGELOG.md`, badge dinámico de tag). La versión de la entrada debe coincidir exactamente con el contenido de `VERSION`. **No** añadir link-references de compare al pie (aún no existe ningún tag y quedarían rotos). Cubre FR-002, SC-002; ver decisión D-05.

### Batch 3 — P2 · Decisión y proceso de release documentados (User Story 3)

- [ ] @architect · Añadir ADR-006 con el proceso de release a tech-spec.md: editar `D:\00_WIP\2608_MyAIsyToolkit\my-aisy-toolkit\specs\tech-spec.md` insertando una entrada `### ADR-006:` **en inglés** (el documento entero está en inglés), justo después del final de ADR-005 (línea 221) y antes de `## ⚠️ Known Limitations` (línea 223). Debe replicar exactamente la estructura de ADR-001…ADR-005: `**Decision**`, `**Context**`, `**Consequences**` con bullets `(+)` / `(-)` y línea `Mitigation:`. Contenido obligatorio: (a) **Decision** — el repo adopta SemVer a nivel de repositorio mediante `VERSION` en la raíz, `CHANGELOG.md` en formato Keep a Changelog y git tags `vX.Y.Z`, con un badge dinámico de shields.io en ambos README; (b) **Context** — debe dejar explícita la distinción entre el versionado de *distribución del catálogo* (sin cambios: `setup-ai` siempre trae `main`, sin SemVer ni selección de versión, tal y como afirma `product-spec.md`) y el versionado *del repo* (nuevo, solo para visibilidad del mantenedor); mencionar las alternativas descartadas (campo `version` en `catalog.yaml` o en el frontmatter de cada skill/agent, y GitHub Releases + endpoint `/github/v/release/`, este último dejado como mejora futura); (c) **Consequences** — incluir como `(-)` la ausencia de validación automática de la coherencia entre `VERSION`, `CHANGELOG.md` y el último tag, con su `Mitigation:` apuntando al proceso manual descrito debajo, y como `(-)` que el badge muestra "no tags found" hasta que exista el primer tag; (d) la asimetría deliberada `VERSION` sin prefijo `v` / tags con `vX.Y.Z` (D-01). Cubre FR-008, SC-006 y la decisión D-07.
- [ ] @architect · Documentar los 3 pasos manuales de release dentro de ADR-006: al final de la entrada ADR-006 recién creada en `specs/tech-spec.md` — después de `**Consequences**` y todavía dentro de la sección `### ADR-006` — añadir un bloque etiquetado `**Release process (manual, 3 steps)**` con una lista numerada literal: 1) bump del valor en `VERSION`; 2) nueva entrada de versión en `CHANGELOG.md` moviendo lo acumulado en `[Unreleased]`; 3) `git tag vX.Y.Z && git push --tags`. El paso 3 debe indicar explícitamente que es el que alimenta el badge del README y el más fácil de olvidar. No se crea ningún `CONTRIBUTING.md` ni ningún otro fichero. Cubre FR-009 y SC-007; ver decisión D-06.

### Batch 4 — P3 · No regresión y verificación de criterios (User Story 4)

- [ ] @tester · Verificar la ausencia de campos version y la no regresión de la instalación: ejecutar y reportar el resultado de (a) `grep -n "version" catalog.yaml` → debe devolver 0 coincidencias (FR-003, SC-004); (b) `grep -rn "^version:" ai-toolkit/default/commands/ ai-toolkit/default/agents/` → 0 coincidencias, y además inspeccionar el frontmatter de los 11 comandos y los 6 agentes para confirmar que ninguno declara `version` con otra indentación o formato (FR-004, SC-005); (c) `git diff --stat main -- setup-ai.md catalog.yaml ai-toolkit/` → debe estar vacío, probando que ni el instalador ni el catálogo se han tocado (FR-005, FR-007). Si alguna comprobación falla, reportar el fichero y la línea exacta; no corregir nada.
- [ ] @tester · Verificar los criterios de éxito SC-001 a SC-007: comprobar uno a uno y reportar PASS/FAIL con evidencia: SC-001 `VERSION` existe en la raíz y su contenido es exactamente `0.1.0`; SC-002 `CHANGELOG.md` existe, sigue Keep a Changelog y su entrada de versión más alta es `0.1.0`, coincidiendo con `VERSION`; SC-003 `README.md` y `README-ES.md` contienen la URL `img.shields.io/github/v/tag/charlstown/my-aisy-toolkit`, ninguno conserva ya el badge estático `badge/version-1.1`, y ninguno incluye `sort=semver` ni `/github/v/release/`; SC-006 `specs/tech-spec.md` contiene `### ADR-006` con los bloques `**Decision**`, `**Context**` y `**Consequences**`; SC-007 los 3 pasos de release aparecen dentro de esa misma sección ADR-006. Comprobar también que ambos README siguen renderizando sin HTML roto en el bloque de badges.

### Batch 5 — Quality gate

- [ ] @judge · Quality gate de la feature: revisar de forma independiente los 5 ficheros tocados (`VERSION`, `CHANGELOG.md`, `README.md`, `README-ES.md`, `specs/tech-spec.md`) contra `specs/002-versionado-del-repo-version-changelog-git-tags/requirements.md`. Verificar en particular: coherencia del valor de versión entre `VERSION` y `CHANGELOG.md`; que la URL del badge es idéntica en ambos README; que ADR-006 mantiene el mismo formato que ADR-001…ADR-005 y está redactado en inglés como el resto del documento; que ADR-006 explicita la distinción entre versionado de distribución del catálogo y versionado del repo (evitando que quede una contradicción abierta con `product-spec.md` líneas 36 y 170); y que no se ha introducido ningún campo `version` en `catalog.yaml`, en el frontmatter del catálogo ni ningún cambio en `setup-ai.md`. Emitir PASS o CHANGES_REQUESTED con la lista concreta de correcciones.

## 4. Dependencias entre batches

```
Batch 1 (VERSION + badges)  ──►  Batch 2 (CHANGELOG debe citar el mismo 0.1.0)
        │                                   │
        └───────────────┬───────────────────┘
                        ▼
              Batch 3 (ADR-006 describe VERSION y CHANGELOG ya existentes)
                        ▼
              Batch 4 (verificación)  ──►  Batch 5 (quality gate)
```

- Las 3 tareas del **Batch 1** son independientes entre sí y podrían hacerse en cualquier orden.
- Las 2 tareas del **Batch 3** tocan la misma región del mismo fichero y son **estrictamente secuenciales**: la segunda edita el bloque creado por la primera.
- **Batch 4** exige que 1, 2 y 3 estén cerrados; **Batch 5** exige el 4.

## 5. Propuestas fuera del alcance (NO ejecutar en esta feature)

Detectadas durante el discovery. Requieren decisión explícita del mantenedor antes de convertirse en tareas:

1. **Matizar `product-spec.md` líneas 36 y 170**, que hoy afirman "no semantic versioning or release tags for now". Tras esta feature siguen siendo ciertas para la *distribución del catálogo*, pero falsas leídas como afirmación sobre el repo. Edición mínima sugerida: acotar la frase a la instalación del catálogo. La skill `/clean-feature` audita `product-spec.md` tras cada plan completado y es el momento natural para decidirlo.
2. **Matizar la línea 123 de `README.md` / `README-ES.md`** ("There's no semantic versioning to track" / "No hay versionado semántico que rastrear"), que queda tres pantallas por debajo de un badge SemVer. Misma acotación: la frase habla de la instalación, no del repo.
3. **Incluir el refresco de los badges manuales `skills-N`, `agents-N` y `updated-YYYY-MM-DD`** (líneas 17-21 de ambos README) como cuarto paso del proceso de release. Hoy también son estáticos y van a desincronizarse igual que el `version-1.1` que esta feature elimina.
4. **Validación automática de coherencia** entre `VERSION`, la última entrada de `CHANGELOG.md` y el último tag. El requirements lo declara explícitamente fuera de alcance; el repo además no tiene CI.

## 6. Acción del mantenedor tras el merge (no es una tarea del plan — ver D-04)

Una vez mergeada la rama en `main`, ejecutar manualmente para que el badge deje de mostrar "no tags found":

```
git tag v0.1.0
git push --tags
```

Es exactamente el paso 3 del proceso documentado en ADR-006. No requiere crear ninguna GitHub Release (fuera de alcance según el requirements).

## 7. Riesgos y desconocidos abiertos

| # | Riesgo / desconocido | Impacto | Mitigación / estado |
|---|---|---|---|
| R-01 | El badge mostrará "version \| no tags found" entre el merge y el primer tag — **verificado** contra la API de shields.io, no supuesto | Cosmético en la portada del repo | Ejecutar §6 inmediatamente tras el merge. El requirements lo acepta explícitamente en sus Edge Cases |
| R-02 | Contradicción documental viva con `product-spec.md` (líneas 36, 170) y con la línea 123 de ambos README | Confusión para un lector nuevo | ADR-006 debe explicitar la distinción (D-07, tarea del Batch 3). El texto de `product-spec.md` queda como propuesta §5.1 |
| R-03 | Los 3 pasos son manuales: en el primer release real es fácil bumpear `VERSION` y olvidar el tag | Badge desincronizado del `VERSION` | Documentación en ADR-006 (FR-009). Automatización explícitamente fuera de alcance (§5.4) |
| R-04 | `github/v/tag` **sin** `sort=semver` selecciona el tag más reciente por fecha, no el mayor SemVer. Si algún día se taggea fuera de orden (p. ej. un hotfix `v0.1.1` creado después de `v0.2.0`), el badge mostrará el tag equivocado | Bajo hoy (0 tags), creciente con el tiempo | FR-006 prohíbe `sort=semver` en esta feature. Anotar el riesgo en ADR-006 y revisitar si aparecen ramas de mantenimiento |
| R-05 | `/implement-feature` trabaja en un worktree aislado; las tareas del Batch 3 editan la misma región de `specs/tech-spec.md` de forma consecutiva | Conflicto o duplicación de ADR-006 si se paralelizan | Ejecutar el Batch 3 en orden estricto; no lanzar este plan en paralelo con `specs/001-launcher-global-setup-ai-para-reinstalar/` sin revisar solapes |
| U-01 | ¿Quiere el mantenedor que el tag `v0.1.0` se cree en el mismo momento del merge o más adelante? | Solo afecta a cuánto dura R-01 | No bloquea ninguna tarea del plan |
| U-02 | ¿Debe el `Version: v0.1` de las cabeceras de `product-spec.md`, `tech-spec.md` y `roadmap.md` seguir la numeración de `VERSION` (`0.1.0`) a partir de ahora? | Bajo; hoy son coherentes | Fuera de alcance; decidir en el primer bump real |
