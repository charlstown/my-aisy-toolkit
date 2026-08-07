# Feature: Catálogos de skills compartidas y agentes nativos

> **Status:** Draft
> **Source:** Solicitud explícita del usuario, 2026-08-06; estado actual de `catalog.yaml`, `setup-ai.md`, `specs/product-spec.md` y `specs/tech-spec.md`.

## Contexto

El catálogo distribuible actual contiene archivos con forma de Claude Code. Cuando el destino es Codex, `setup-ai.md` pide al agente instalador que interprete y traduzca cada comando a un `SKILL.md`. Esa traducción no es determinista y está documentada como soporte best-effort.

Las skills de Claude Code y Codex son compatibles cuando se distribuyen como directorios con `SKILL.md`. La feature sustituye la traducción en instalación por una única copia distribuible de cada skill y reserva los catálogos separados únicamente para los agentes, cuyos formatos nativos difieren. El instalador selecciona el agente confirmado, descarga los artefactos declarados y los copia sin traducción.

## Alcance

- Crear un catálogo único de skills bajo `ai-toolkit/skills/`.
- Crear catálogos de agentes separados bajo `ai-toolkit/agents/claude/` y `ai-toolkit/agents/codex/`.
- Mantener perfiles `default` y `ui-ux`, y el pack opcional `utils`, mediante selecciones del catálogo compartido de skills.
- Adaptar `catalog.yaml`, `setup-ai.md` y la documentación que dependa de las rutas, el formato o la semántica de instalación actual.
- Eliminar del flujo de instalación cualquier traducción o reinterpretación de comandos Claude a skills de Codex.

## Fuera de alcance

- Añadir soporte para agentes distintos de Claude Code y Codex.
- Cambiar el flujo funcional de cada skill más allá de lo necesario para que su único `SKILL.md` funcione en ambos agentes objetivo.
- Cambiar la política de perfiles, de actualización desde `main`, de launcher global o de selección explícita del agente, salvo las referencias que deban actualizarse por la nueva estructura.
- Definir un generador, conversor o sincronización automática de agentes entre Claude y Codex.

## Historias de usuario

### US-001 — Instalar skills compatibles

Como persona que instala el toolkit para Claude Code o Codex, quiero recibir las mismas skills compatibles ya preparadas para que el resultado sea reproducible y no dependa de una traducción del agente instalador.

### US-002 — Mantener el catálogo

Como mantenedor, quiero que cada skill distribuible exista una sola vez en Git y que los agentes nativos se revisen por separado para reducir duplicidad y poder validar explícitamente las diferencias inevitables.

### US-003 — Elegir perfil y extras

Como persona que instala un perfil y utils opcionales, quiero que el manifiesto resuelva las skills compartidas y los agentes del destino correcto para conservar el comportamiento actual de perfiles y extras.

## Requisitos funcionales

- **FR-001 — Raíces distribuibles.** El repositorio MUST contener `ai-toolkit/skills/` como raíz única de las skills distribuibles y `ai-toolkit/agents/claude/` y `ai-toolkit/agents/codex/` como raíces de agentes nativos. Ninguna skill distribuible se duplicará por agente ni se traducirá durante la instalación.

- **FR-002 — Skills compartidas.** Cada skill MUST almacenarse una sola vez bajo `ai-toolkit/skills/<nombre>/SKILL.md`, con los recursos de su carpeta cuando sean necesarios. El mismo artefacto MUST poder copiarse literalmente a `.claude/skills/<nombre>/SKILL.md` y a `.agents/skills/<nombre>/SKILL.md`.

- **FR-003 — Agentes nativos.** Los agentes de Claude MUST almacenarse bajo `ai-toolkit/agents/claude/` en el formato Markdown nativo para copiarse a `.claude/agents/*.md`. Los agentes de Codex MUST almacenarse bajo `ai-toolkit/agents/codex/` como archivos `.toml` nativos para copiarse a `.codex/agents/*.toml`.

- **FR-004 — Cobertura funcional sin duplicidad.** Para cada skill distribuida por un perfil o por `utils`, el catálogo compartido MUST incluir una única variante compatible. Las diferencias de capacidades que solo afecten a agentes se expresarán en sus artefactos nativos y no se resolverán durante la instalación.

- **FR-005 — Manifiesto por perfil y artefacto.** `catalog.yaml` MUST declarar por perfil y pack opcional las rutas concretas de las skills compartidas, y por agente las rutas concretas de sus agentes nativos. El manifiesto seguirá siendo la única fuente para decidir qué se instala; el instalador no listará directorios remotos ni inferirá rutas por convenciones ocultas.

- **FR-006 — Copia literal para Claude.** Tras obtener las selecciones declaradas, `setup-ai.md` MUST descargar cada skill compartida y cada agente Claude aplicable, y escribirlos en sus destinos Claude correspondientes sin traducirlos, reformatearlos ni reinterpretarlos.

- **FR-007 — Copia literal para Codex.** Tras obtener las selecciones declaradas, `setup-ai.md` MUST descargar cada skill compartida y cada agente Codex aplicable, y escribirlos en sus destinos Codex correspondientes sin traducirlos, reformatearlos ni reinterpretarlos. En particular, el paso actual que presenta al agente como traductor de comandos Claude a `SKILL.md` MUST desaparecer.

- **FR-008 — Destinos nativos preservados.** La instalación continuará escribiendo únicamente en las ubicaciones del agente confirmado dentro del repositorio destino: para Claude Code, `.claude/skills/<nombre>/SKILL.md` y `.claude/agents/*.md`; para Codex, `.agents/skills/<nombre>/SKILL.md` y `.codex/agents/*.toml`. La selección del agente seguirá siendo explícita y no se inferirá por carpetas existentes.

- **FR-009 — Utils compartidos.** La selección opcional de `utils` MUST resolver las skills del catálogo compartido y conservar el prefijo `aisy.` en su destino, tanto para Claude como para Codex.

- **FR-010 — Agentes por perfil.** Los agentes específicos de Claude y Codex MUST declararse e instalarse para los perfiles que los incluyan. Sus rutas procederán exclusivamente del catálogo de agentes nativo del agente confirmado.

- **FR-011 — Dependencias documentales.** Se MUST actualizar toda documentación y especificación afectada que describa rutas antiguas (`ai-toolkit/<profile>/commands`, `ai-toolkit/<profile>/agents`, `ai-toolkit/utils/commands`), la traducción en instalación o la duplicidad de skills por agente. Incluye como mínimo `README.md`, `README-ES.md`, `specs/product-spec.md`, `specs/tech-spec.md` y la documentación interna del catálogo.

- **FR-012 — Sustituir la decisión arquitectónica anterior.** La documentación técnica MUST retirar o reemplazar ADR-002, que decide traducir Codex durante la instalación, por una decisión que documente las skills compartidas y los agentes nativos separados.

- **FR-013 — Actualización e idempotencia.** Las reglas existentes de crear, sobrescribir si el contenido remoto cambió y dejar intacto si coincide MUST aplicarse comparando el artefacto descargado con el archivo del destino, sin ninguna comparación de equivalencia semántica derivada de una traducción. La actualización MUST añadir los nuevos artefactos en sus destinos nativos y solo podrá sobrescribir una skill ya instalada cuando coincida su nombre; no eliminará ni modificará los catálogos antiguos ni otros artefactos existentes en el repositorio destino.

- **FR-014 — Mantenimiento sin duplicidad.** `AGENTS.md` MUST ser la fuente de verdad de la regla de mantenimiento del catálogo. Cada cambio de una skill distribuible MUST realizarse una sola vez en `ai-toolkit/skills/`; cada cambio de agente MUST revisarse solo contra su variante nativa aplicable. La revisión de PR MUST comprobar que perfiles y `utils` conservan cobertura para ambos instaladores sin crear copias de una misma skill.

## Casos límite

- Una skill presente en `default` y reutilizada por `ui-ux` debe poder declararse en ambas selecciones desde la misma ruta compartida, sin traducción ni duplicación.
- Un fallo al descargar una skill compartida conserva la regla existente de reintentar una vez y omitir solo ese archivo; un fallo al descargar el manifiesto aborta sin escrituras.
- Una skill debe conservar su carpeta y su nombre `SKILL.md`; el manifiesto no puede reducirla a una ruta que pierda esta información.
- La instalación de un agente no debe descargar ni instalar los agentes nativos del otro, aunque ambas instalaciones resuelvan las mismas skills compartidas.
- El launcher global de Codex es un artefacto distinto de las skills del catálogo y no debe introducir una traducción al copiarse.
- Al migrar la distribución de este repositorio a las nuevas raíces, la instalación no debe eliminar ni migrar retrospectivamente los catálogos antiguos presentes en los repositorios destino.

## Criterios de aceptación

- [ ] Existe un árbol `ai-toolkit/skills/` con una única carpeta por skill y su `SKILL.md` instalable.
- [ ] Existen árboles `ai-toolkit/agents/claude/` y `ai-toolkit/agents/codex/` con los agentes Markdown y `.toml` instalables, respectivamente.
- [ ] Cada perfil y util ofrecido por el manifiesto tiene rutas válidas para skills compartidas y, cuando corresponda, agentes del destino elegido.
- [ ] Una instalación Codex descarga y copia únicamente skills compartidas y agentes Codex nativos; no contiene instrucciones de traducir, reinterpretar ni producir equivalencias semánticas.
- [ ] Una instalación Claude descarga y copia únicamente skills compartidas y agentes Claude nativos; no contiene instrucciones de traducir, reinterpretar ni producir equivalencias semánticas.
- [ ] Los destinos, prefijos `aisy.`, preguntas de selección, reintentos y reglas create/overwrite/leave-alone siguen funcionando según las especificaciones vigentes, salvo los cambios explícitos de esta feature.
- [ ] `catalog.yaml`, `setup-ai.md`, ambos README, ProductSpec, TechSpec y README interno del catálogo no contienen referencias contradictorias a los comandos antiguos, a la traducción Codex en tiempo de instalación ni a skills duplicadas por agente.
- [ ] `AGENTS.md` define la fuente única de skills y la separación de agentes nativos, y `CLAUDE.md` la referencia como fuente de verdad sin duplicarla.

## Suposiciones basadas en la solicitud

- El formato y contenido de cada `SKILL.md` distribuible son compatibles entre Claude Code y Codex.
- `utils` sigue siendo un pack opcional independiente de los perfiles.
- `ui-ux` sigue siendo una ampliación del perfil `default` en cuanto a selección de skills.
