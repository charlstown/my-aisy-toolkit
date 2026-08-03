# Eliminar jerga interna (best-effort) del prompt de usuario en setup-ai
Feature Branch: 001-prompt-setup-ai-expone-best-effort-al-usuario
Source Issue: https://github.com/charlstown/my-aisy-toolkit/issues/36

Created: 2026-08-04

Status: Draft

Input: User description: "#36"

## User Scenarios & Testing (mandatory)

### User Story 1 - El usuario ve un prompt claro al elegir agente en Step 1 de setup-ai (Priority: P1)

Como usuario que ejecuta `setup-ai` para instalar el toolkit, cuando el agente me pregunta
para qué agente estoy configurando el proyecto, quiero ver únicamente opciones descritas en
lenguaje claro y orientado a usuario final, sin encontrarme con jerga interna del equipo del
proyecto (como la etiqueta "best-effort") que no me aporta información accionable sobre qué
esperar de esa opción.

Why this priority: Es el único defecto reportado en el issue y afecta directamente a la
primera interacción visible del flujo de instalación (`setup-ai.md`, Step 1). Es una
corrección de contenido de bajo riesgo pero con visibilidad alta, ya que la vería todo
usuario que instale el toolkit y elija la opción de Codex CLI.

Independent Test: Se puede probar de forma independiente ejecutando el flujo de `setup-ai`
(o revisando el texto literal definido en `setup-ai.md:71`) y verificando que el prompt del
Step 1 ya no contiene el término "best-effort" ni sinónimos técnicos internos equivalentes,
y que la opción 2 queda simplemente como "Codex CLI", sin ningún texto sustitutivo.

Acceptance Scenarios:

1. Given el flujo de instalación `setup-ai` en su Step 1 ("Ask what you're installing"),
   When el agente muestra el prompt con las opciones de agente a instalar, Then la opción
   correspondiente a Codex CLI no incluye la etiqueta "(best-effort support)" ni el término
   "best-effort".
2. Given la opción 2 del prompt del Step 1 ("Codex CLI (best-effort support)"), When se
   corrige el texto, Then la opción queda simplemente como "Codex CLI", sin añadir ningún
   texto sustitutivo ni advertencia adicional sobre el nivel de soporte — se asume que el
   soporte funcionará sin necesidad de comunicar matices en este prompt.
3. Given la documentación interna del proyecto (ADR-002, ADR-007, product-spec.md,
   tech-spec.md, roadmap.md), When se corrige el texto del prompt de Step 1, Then esos
   documentos internos no se modifican y siguen pudiendo usar libremente el término
   "best-effort".
4. Given las menciones narrativas a "best-effort" dentro de `setup-ai.md` fuera del Step 1
   (líneas 307, 328 y 546 — instrucciones dirigidas al agente, no prompts literales), When
   se corrige el texto del Step 1, Then esas menciones también se revisan y corrigen para
   que el agente no repita esa jerga interna si parafrasea o cita ese texto al usuario
   durante la instalación.

## Edge Cases

- ¿Qué ocurre si el usuario ya tiene memorizado o espera ver literalmente "best-effort"
  porque lo ha visto en otra documentación del proyecto (p. ej. un ADR)? El prompt de
  usuario no debe alinearse con esa jerga; se decidió no añadir ningún matiz alternativo en
  el prompt del Step 1, así que la opción queda simplemente como "Codex CLI".
- Las menciones narrativas a "best-effort" en `setup-ai.md` fuera del Step 1 (líneas 307,
  328 y 546) también entran en el alcance de esta corrección, aunque no son prompts
  literales, por si el agente las parafrasea o cita al usuario.

## Requirements (mandatory)

### Functional Requirements

- FR-001: El sistema DEBE eliminar el texto "(best-effort support)" (y cualquier sinónimo
  técnico interno equivalente) del prompt literal del Step 1 de `setup-ai.md` (línea 71 según
  el issue), que el agente muestra al usuario para preguntar qué agente va a instalar.
- FR-002: El sistema NO DEBE añadir ningún texto sustitutivo ni advertencia alternativa en
  la opción 2 del prompt del Step 1: tras eliminar "(best-effort support)", la opción queda
  simplemente como "Codex CLI", sin comunicar matices sobre el nivel de soporte en ese
  prompt.
- FR-003: El sistema NO DEBE modificar el uso del término "best-effort" en la documentación
  interna del proyecto (ADR-002, ADR-007, product-spec.md, tech-spec.md, roadmap.md), donde
  su uso es legítimo y se mantiene sin cambios.
- FR-004: El sistema DEBE revisar y corregir las menciones narrativas a "best-effort" en
  `setup-ai.md` fuera del Step 1 (líneas 307, 328 y 546 — instrucciones dirigidas al agente,
  no prompts literales), para que el agente no repita esa jerga interna si parafrasea o cita
  ese texto al usuario durante la instalación. No se han encontrado ocurrencias del patrón
  en ninguna otra skill o comando del catálogo; quedan fuera de alcance.

### Key Entities (include if feature involves data)

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: El texto literal del prompt del Step 1 de `setup-ai.md` (línea 71) no contiene la
  cadena "best-effort" tras aplicar la corrección, y la opción 2 queda como "Codex CLI" sin
  texto sustitutivo.
- SC-002: Las menciones narrativas a "best-effort" en `setup-ai.md` (líneas 307, 328 y 546)
  quedan revisadas y corregidas, sin afectar a la documentación interna del proyecto (ADRs,
  product-spec.md, tech-spec.md, roadmap.md, READMEs) ni a ninguna otra skill o comando del
  catálogo.

## Assumptions

- Se asume que el público objetivo de esta corrección es cualquier usuario final que ejecute
  el flujo de instalación `setup-ai`, no el equipo interno del proyecto.
- Se asume que el alcance de esta feature se limita a textos de cara al usuario dentro del
  flujo de `setup-ai.md`; no incluye una auditoría general de todo el repositorio en busca de
  otras skills o comandos que pudieran repetir el mismo patrón, salvo que se decida ampliar
  el alcance durante la clarificación.
- Se asume que la documentación interna del proyecto (ADR-002, ADR-007, product-spec.md,
  tech-spec.md, roadmap.md) queda fuera de alcance y no debe modificarse.
- Este bug depende únicamente de contenido de texto en `setup-ai.md`; no hay dependencia de
  comportamiento en runtime ni de otros servicios del sistema.
