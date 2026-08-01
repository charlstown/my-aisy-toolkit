# Launcher global /setup-ai para reinstalar sin repetir el one-liner
Feature Branch: [001-launcher-global-setup-ai-para-reinstalar]

Created: 2026-08-01

Status: Draft

Input: User description: "todos los issues del repo"

## User Scenarios & Testing (mandatory)

### User Story 1 - Guardar el launcher global al finalizar la primera instalación (Priority: P1)

Un usuario instala por primera vez el kit en un repo siguiendo el one-liner del README, que apunta al fichero raíz `setup-ai.md`. Al terminar esa instalación, `setup-ai.md` le pregunta si además quiere guardar un launcher global `/setup-ai` para no tener que volver al README la próxima vez que quiera instalar el kit en otro repo.

Why this priority: Es el punto de entrada de todo el flujo descrito en el issue — sin esta pregunta al final de la primera instalación no existe forma de que el launcher global llegue a crearse, y el resto de la funcionalidad (reinstalar sin repetir el one-liner) depende de que este paso exista.

Independent Test: Ejecutar la instalación desde el one-liner del README en un repo limpio, comprobar que al finalizar `setup-ai.md` pregunta explícitamente si se desea guardar el comando global `/setup-ai`, y verificar el resultado tanto si el usuario acepta como si rechaza.

Acceptance Scenarios:

1. Given un usuario ejecuta el one-liner del README por primera vez en un repo, When la instalación del catálogo en `.claude/` o `.codex/` termina, Then `setup-ai.md` pregunta si el usuario quiere guardar un launcher global `/setup-ai`.
2. Given el usuario responde que sí a esa pregunta, When se procesa la respuesta, Then se escribe un fichero distinto —no una copia literal de `setup-ai.md`— en `~/.claude/commands/` (Claude Code) y en el directorio de comandos globales equivalente de Codex CLI.
3. Given el usuario responde que no, When se procesa la respuesta, Then no se escribe ningún fichero fuera del repo actual y la instalación del catálogo local se completa igualmente.

### User Story 2 - Reinstalar/instalar en un repo nuevo invocando el launcher global (Priority: P1)

Un usuario que ya tiene el launcher global `/setup-ai` instalado (de una sesión anterior) lo invoca desde un repo nuevo o desde el mismo repo para reinstalar. El launcher va directo a fetch la versión viva de `setup-ai.md` e instalar el catálogo en el repo activo, sin mostrar de nuevo la pregunta de "¿guardar el launcher global?".

Why this priority: Es el valor central que motiva el issue — evitar que el usuario tenga que volver al README y copiar el one-liner manualmente cada vez que quiere (re)instalar el kit en otro repo.

Independent Test: Con el launcher global ya instalado, invocar `/setup-ai` desde un repo distinto al de la instalación original y comprobar que el catálogo se instala/actualiza en ese repo sin que se repita la pregunta sobre guardar el launcher.

Acceptance Scenarios:

1. Given el launcher global `/setup-ai` ya está instalado en `~/.claude/commands/` (o equivalente en Codex CLI), When el usuario lo invoca desde cualquier repo, Then el flujo va directo a fetch de la versión viva de `setup-ai.md` e instala el catálogo en el repo activo.
2. Given el flujo se invoca desde el launcher global instalado, When se completa la instalación, Then no se repite la pregunta "¿guardar el launcher global?".

### User Story 3 - No repetir la pregunta si el launcher global ya existe (Priority: P2)

Un usuario que ya guardó el launcher global en una instalación anterior (en otro repo) vuelve a ejecutar el one-liner de `setup-ai.md` (por ejemplo, para instalar en un repo nuevo directamente desde el README en lugar de usar el launcher). Como el launcher global ya existe, `setup-ai.md` no debe volver a preguntar si se desea guardarlo.

Why this priority: Es una mejora de fricción sobre el flujo principal (evita una pregunta redundante), no bloquea el valor central de las Historias 1 y 2, pero está explícitamente listada como criterio de aceptación del issue.

Independent Test: Con el launcher global ya presente en el sistema, ejecutar de nuevo `setup-ai.md` (vía one-liner) en un repo distinto y comprobar que no aparece la pregunta sobre guardar el launcher global.

Acceptance Scenarios:

1. Given el launcher global `/setup-ai` ya existe en `~/.claude/commands/` o en el directorio equivalente de Codex CLI, When se ejecuta `setup-ai.md` de nuevo (vía one-liner) en cualquier repo, Then no se pregunta de nuevo si se desea guardar el launcher global.

## Edge Cases

- El issue no describe qué ocurre si el usuario tiene instalado Claude Code pero no Codex CLI (o viceversa): no se especifica si la pregunta/instalación del launcher se limita al agente detectado o se intenta para ambos. [NEEDS CLARIFICATION: comportamiento cuando solo uno de los dos agentes (Claude Code / Codex CLI) está presente en el entorno del usuario]
- El issue no especifica qué ocurre si el fichero global ya existe pero está desactualizado (versión antigua del propio launcher, no del catálogo) — [NEEDS CLARIFICATION: si el "ya existe, no preguntar de nuevo" also implica que nunca se sobreescribe/actualiza el propio fichero launcher, o si hay algún mecanismo de actualización del launcher en sí]
- No se especifica qué pasa si la escritura del fichero en `~/.claude/commands/` o el directorio equivalente de Codex CLI falla (permisos, disco, ruta inexistente). [NEEDS CLARIFICATION: manejo de errores al escribir el launcher global]
- No se especifica el comportamiento si el fetch de la versión viva de `setup-ai.md` falla al invocar el launcher global (sin conexión, URL caída, etc.). [NEEDS CLARIFICATION: manejo de errores de red/fetch al invocar el launcher global]

## Requirements (mandatory)

### Functional Requirements

- FR-001: `setup-ai.md` (fichero raíz, entry point desde README/one-liner) MUST preguntar al usuario, al final de una instalación, si quiere guardar un comando/launcher global `/setup-ai`.
- FR-002: Si el usuario acepta, el sistema MUST escribir un fichero distinto —no una copia literal de `setup-ai.md`— en `~/.claude/commands/` para Claude Code.
- FR-003: Si el usuario acepta, el sistema MUST escribir el fichero equivalente en el directorio de comandos globales de usuario de Codex CLI.
- FR-004: El contenido del fichero launcher global MUST consistir únicamente en instrucciones que apuntan a fetch la versión viva de `setup-ai.md` en cada invocación, sin contenido estático embebido del catálogo, consistente con el principio "siempre la última versión" del product-spec.
- FR-005: Al invocar `/setup-ai` desde el comando global ya instalado, el sistema MUST ir directo a fetch + instalar el catálogo en el repo activo, sin repetir la pregunta de "¿guardar el launcher global?".
- FR-006: Si el comando/launcher global ya existe, `setup-ai.md` MUST NOT volver a preguntar si guardarlo en instalaciones/reinstalaciones posteriores.
- FR-007: `product-spec.md` y `tech-spec.md` MUST documentar la nueva arquitectura de dos ficheros (entry point desde README vs. launcher global instalado) y el soporte para ambos agentes (Claude Code y Codex CLI) desde el inicio.
- FR-008: El fichero raíz `setup-ai.md` MUST mantener su rol actual como entry point desde README/one-liner, sin cambios en esa función.
- FR-009: El sistema debe detectar si el fichero launcher global ya existe antes de decidir si mostrar la pregunta de FR-001. [NEEDS CLARIFICATION: el issue no detalla el mecanismo de detección — por ejemplo, comprobar la existencia del fichero en la ruta destino, un marcador de estado, u otro método]

### Key Entities (include if feature involves data)

- **Entry point (`setup-ai.md`, raíz del repo)**: fichero fuente que se fetch-ea desde el one-liner del README; instala el catálogo completo (skills/agents) en `.claude/` o `.codex/` del repo destino; al final de la instalación pregunta (condicionalmente) por el guardado del launcher global.
- **Launcher global (`/setup-ai` instalado)**: fichero distinto al entry point, ubicado en `~/.claude/commands/` (Claude Code) o en el directorio de comandos globales equivalente de Codex CLI; contiene solo instrucciones para fetch la versión viva de `setup-ai.md` y ejecutar la instalación directa en el repo activo, sin la pregunta de guardado.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: Tras completar una primera instalación vía one-liner, el 100% de las ejecuciones de `setup-ai.md` muestran la pregunta sobre guardar el launcher global (cuando este no existe aún).
- SC-002: Un usuario con el launcher global ya instalado puede instalar el catálogo en un repo nuevo invocando únicamente `/setup-ai`, sin visitar el README ni copiar el one-liner.
- SC-003: Invocar el launcher global instalado nunca vuelve a mostrar la pregunta "¿guardar el launcher global?" — el flujo va directo a fetch + instalación.
- SC-004: En repos donde el launcher global ya existe, ejecutar `setup-ai.md` de nuevo (vía one-liner) no muestra la pregunta de guardado.
- SC-005: `product-spec.md` y `tech-spec.md` reflejan la arquitectura de dos ficheros y el soporte dual (Claude Code + Codex CLI) descrita en el issue.

## Assumptions

- Se asume que "Claude Code" y "Codex CLI" son los dos únicos agentes objetivo mencionados en el issue; no se contemplan otros agentes.
- Se asume que la detección de "el launcher global ya existe" se basa en el propio sistema de ficheros (presencia del fichero en la ruta destino), dado que es el mecanismo más simple compatible con la descripción del issue, aunque el issue no lo confirma explícitamente (ver DEFINITION GAP).

## DEFINITION GAP

- [ ] Comportamiento cuando solo uno de los dos agentes (Claude Code / Codex CLI) está presente en el entorno del usuario: ¿se pregunta/instala solo para el agente detectado, o se intenta para ambos igualmente?
- [ ] Mecanismo exacto de detección de "el launcher global ya existe" (comprobación de fichero en ruta, marcador de estado, u otro) — el issue no lo especifica.
- [ ] Qué ocurre si el propio fichero launcher global queda desactualizado respecto a futuras versiones del mecanismo de fetch: ¿se sobreescribe/actualiza alguna vez, o "ya existe, no preguntar de nuevo" es definitivo?
- [ ] Manejo de errores al escribir el launcher global (permisos, disco, ruta inexistente) — no descrito en el issue.
- [ ] Manejo de errores si el fetch de la versión viva de `setup-ai.md` falla al invocar el launcher global (sin conexión, URL caída, etc.) — no descrito en el issue.
- [ ] Dependencia no confirmada: el issue menciona que la alternativa de usar el sistema nativo de plugins/marketplace de Claude Code fue "descartada (o pospuesta)" — no queda claro si esta decisión es definitiva o si podría revisarse en el futuro, lo cual podría afectar el diseño de la solución actual como "definitivo" vs. "provisional".
