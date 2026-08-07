# Preguntas secuenciales tipo test para Claude y Codex
Feature Branch: 003-preguntas-secuenciales-en-skills-claude-y-codex

Created: 2026-08-06

Status: Draft

Input: User description: "CLAUDE y AGENTS? El userAsqTool no existe para los casos de codex preguntar de una en una pregunta tipo test y no pasar a la siguiente hasta que haya terminado. Añadir el flujo como fallback en AGENTS.md, sin duplicar skills ni alterar el comportamiento de Claude.
Ej:   ¿Qué quieres hacer con la convención por defecto description: none en CLAUDE.md?

  A. Cambiar la plantilla y corregir la causa raíz
  B. No tocar la plantilla; solo corregir las páginas existentes
  C. Corregir las páginas existentes ahora y dejar el cambio de plantilla para otra feature
  D. No lo tengo claro todavía

  Responde A, B, C, D o tu propia respuesta."

## User Scenarios & Testing (mandatory)

### User Story 1 - Responder una pregunta de Codex antes de continuar (Priority: P1)

Como persona que usa una skill en Codex, quiero recibir las preguntas de decisión una por una y en formato tipo test para poder responder con claridad antes de que la skill avance.

Why this priority: El comportamiento solicitado corrige el caso principal identificado: en Codex no existe `userAsqTool`, por lo que debe usarse una herramienta nativa disponible y, si no existe, un flujo conversacional que impida continuar sin una respuesta.

Independent Test: Puede probarse ejecutando una skill que requiera varias decisiones en Codex y verificando que presenta solo una pregunta con opciones, espera la respuesta del usuario y solo entonces muestra la siguiente.

Acceptance Scenarios:

1. Given una skill ejecutándose en Codex que necesita una decisión del usuario, When llega al punto de preguntar, Then presenta una única pregunta tipo test con sus opciones y una instrucción para responder con la opción elegida.
2. Given una pregunta tipo test pendiente en Codex, When el usuario todavía no ha respondido, Then la skill no formula una pregunta posterior ni ejecuta pasos que dependan de esa respuesta.
3. Given el usuario responde la opción de la pregunta pendiente, When la respuesta se ha recibido, Then la skill procesa esa respuesta antes de continuar con la siguiente pregunta o paso aplicable.

### User Story 2 - Preservar el comportamiento actual de Claude (Priority: P2)

Como persona que usa las mismas skills en Claude, quiero que sus instrucciones de preguntas mantengan el comportamiento actual para que esta mejora destinada a Codex no altere mi flujo existente.

Why this priority: El usuario ha confirmado que Claude debe conservar el mismo comportamiento que tiene ahora; el nuevo enfoque secuencial solo corresponde a Codex.

Independent Test: Puede probarse comparando una skill que haga preguntas en Claude antes y después de implementar la feature y verificando que sus instrucciones y mecanismo de preguntas no cambian.

Acceptance Scenarios:

1. Given una skill que solicita decisiones y se ejecuta en Claude, When se implementa esta feature, Then conserva el comportamiento de preguntas que tenía antes de la implementación.
2. Given las instrucciones compartidas de una skill disponible en Claude y Codex, When se revisa `AGENTS.md`, Then el flujo secuencial de Codex se define sin duplicar la skill ni cambiar el comportamiento de preguntas de Claude.

### User Story 3 - Opciones de decisión claras (Priority: P3)

Como persona que responde una decisión de configuración, quiero ver alternativas concretas y una opción para indicar que aún no lo tengo claro, para no tener que redactar una respuesta libre cuando una elección basta.

Why this priority: El ejemplo aportado define el formato deseado de opciones A–D, admite respuestas libres y contempla explícitamente la falta de una decisión.

Independent Test: Puede probarse con una pregunta de ejemplo y comprobando que presenta alternativas A–D y permite responder con una de ellas o con texto libre.

Acceptance Scenarios:

1. Given una pregunta de decisión presentada como fallback conversacional en Codex, When se formula, Then ofrece alternativas identificables, como A–D, y permite responder con una de ellas o con texto libre.
2. Given una persona responde la opción D ("No lo tengo claro todavía"), When la respuesta se procesa, Then se registra un gap y el flujo puede continuar con la siguiente pregunta independiente.

## Edge Cases

- Las respuestas libres son válidas y deben procesarse como respuesta a la pregunta pendiente.
- Si el usuario elige la opción de no tenerlo claro, se registra un gap y el flujo solo puede continuar con preguntas o pasos independientes de esa decisión.
- Si una skill necesita preguntas independientes, debe seguir mostrando una sola pregunta pendiente cada vez; las preguntas condicionadas solo pueden formularse después de procesar la respuesta anterior.

## Requirements (mandatory)

### Functional Requirements

- FR-001: El `AGENTS.md` raíz MUST definir el flujo de preguntas secuenciales para todas las skills compartidas que necesiten información o una decisión en Codex, sin crear ni modificar variantes duplicadas de esas skills.
- FR-002: En Codex, las instrucciones MUST usar una herramienta nativa de preguntas cuando esté disponible y MUST usar mensajes conversacionales como fallback cuando no lo esté; en ambos casos MUST NOT requerir `userAsqTool`.
- FR-003: En Codex, una skill MUST presentar exactamente una pregunta pendiente cada vez y MUST procesar su respuesta antes de formular otra pregunta o avanzar a un paso dependiente de ella.
- FR-004: Una pregunta tipo test de Codex MUST incluir alternativas identificables y una instrucción explícita que permita responder con una alternativa —por ejemplo A, B, C o D— o con una respuesta propia.
- FR-005: Las respuestas libres MUST ser válidas y procesarse como respuesta a la pregunta pendiente.
- FR-006: Si el usuario selecciona una opción equivalente a "No lo tengo claro todavía", la skill MUST registrar un gap y solo podrá continuar con preguntas o pasos independientes de esa decisión.
- FR-007: Las skills compartidas y el comportamiento de preguntas de Claude MUST conservarse sin cambios funcionales antes de esta feature.
- FR-008: El texto sobre `description: none` en `CLAUDE.md` es únicamente un ejemplo ilustrativo del formato de fallback y MUST NOT incorporarse como pregunta obligatoria en una skill.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: En una ejecución de una skill con varias decisiones en Codex, se presenta como máximo una pregunta pendiente antes de recibir la respuesta del usuario.
- SC-002: Cuando haya una herramienta nativa de preguntas disponible en Codex, se utiliza; cuando no la haya, se usa el fallback conversacional sin referencias a `userAsqTool`.
- SC-003: Una revisión de una pregunta de ejemplo confirma que contiene alternativas identificables y permite responder con una opción o texto libre.
- SC-004: Una comprobación de regresión confirma que las skills compartidas y las instrucciones de preguntas de Claude no han cambiado funcionalmente, mientras que `AGENTS.md` define el flujo secuencial de Codex.

## Assumptions

- Las skills son compartidas entre Claude y Codex y no se duplicarán para esta feature.
- El `AGENTS.md` raíz es el único archivo de instrucciones que se modificará para definir el flujo específico de Codex.
- Claude mantiene su comportamiento actual; el alcance de cambio funcional de la feature se restringe a Codex.
