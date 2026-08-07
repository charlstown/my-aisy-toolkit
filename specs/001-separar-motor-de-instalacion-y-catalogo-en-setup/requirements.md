# Separar motor de instalación y catálogo en setup-ai, y corregir bloqueo de preguntas e idioma
Feature Branch: 001-separar-motor-de-instalacion-y-catalogo-en-setup
Source Issue: https://github.com/charlstown/my-aisy-toolkit/issues/44

Created: 2026-08-05

Status: Draft

Input: User description: "issues gh"

## User Scenarios & Testing (mandatory)

### User Story 1 - Motor de instalación local, catálogo remoto declarativo (Priority: P1)

Como mantenedor de `my-aisy-toolkit`, quiero que `setup-ai.md` tenga la lógica de instalación (Steps 1-6: qué preguntar, cómo mapear rutas, cómo escribir ficheros, formato del wrap-up) embebida y versionada localmente en el comando/skill instalado, en vez de re-fetchear esas instrucciones desde GitHub en cada ejecución. Solo `catalog.yaml` y los ficheros de contenido individuales (`commands/*.md`, `agents/*.md`) deben fetchearse en runtime, porque son los que cambian con el tiempo.

Why this priority: Es el problema de raíz descrito en el issue — el patrón actual replica el antipatrón de `curl | bash` (sin pin de versión, riesgo de ejecución parcial si la red falla a mitad de instalación, imposibilidad de auditar de antemano qué va a correr). Los dos bugs de comportamiento (Story 2 y Story 3) se detectaron en el mismo fichero y se resuelven en el mismo cambio, pero la separación motor/catálogo es la motivación principal del issue.

Independent Test: Puede probarse ejecutando una instalación con `setup-ai` y verificando (p. ej. con captura de tráfico de red o logs de fetch) que la única actividad de red corresponde a `catalog.yaml` y a los ficheros de `commands/*.md` / `agents/*.md` que ese catálogo declara — no hay ningún fetch de las propias instrucciones de "cómo instalar" (Steps 1-6).

Acceptance Scenarios:

1. Given un usuario ejecuta el comando/skill `setup-ai` ya instalado localmente, When se ejecuta el proceso de instalación completo (Steps 1-6), Then ninguno de esos pasos requiere un fetch de red a GitHub para obtener sus propias instrucciones de instalación.
2. Given el comando/skill `setup-ai` en ejecución, When necesita conocer qué comandos/agentes están disponibles para instalar, Then hace fetch únicamente de `catalog.yaml` y de los ficheros de contenido individuales (`commands/*.md`, `agents/*.md`) que ese catálogo declara.
3. Given la plantilla del launcher global (Step 6) para Claude Code y Codex CLI, When se genera o actualiza, Then refleja la misma separación motor/catálogo (no replica el patrón de fetch autorreferencial).

### User Story 2 - Preguntas bloqueantes vía herramienta nativa (Priority: P2)

Como usuario que ejecuta `setup-ai`, quiero que las preguntas de Step 1 (y cualquier otra pregunta bloqueante equivalente) se hagan mediante la herramienta interactiva nativa del agente (`AskUserQuestion` en Claude Code, `ask_user_question` en Codex CLI), en vez de imprimirse como texto plano, para que el flujo realmente se detenga a esperar mi respuesta.

Why this priority: Es un bug de comportamiento funcional (las preguntas no bloquean de verdad), detectado durante el mismo trabajo que la Story 1 y localizado en el mismo fichero, pero es un defecto independiente y verificable por sí mismo.

Independent Test: Puede probarse ejecutando Step 1 de `setup-ai` en Claude Code y comprobando que se invoca la herramienta `AskUserQuestion` (no un simple print de texto) y que la ejecución se detiene hasta recibir respuesta del usuario.

Acceptance Scenarios:

1. Given el flujo de `setup-ai` llega a Step 1, When se presenta la pregunta al usuario, Then se invoca la herramienta nativa de preguntas interactivas de la plataforma del agente en vez de imprimir solo el texto de la pregunta.
2. Given cualquier otra pregunta bloqueante equivalente a la de Step 1 en el flujo, When se presenta al usuario, Then también instruye explícitamente el uso de dicha herramienta nativa.

### User Story 3 - Traducción de los bloques "word for word" al idioma de la conversación (Priority: P3)

Como usuario que ejecuta `setup-ai` en una conversación en un idioma distinto del inglés, quiero que los bloques de texto marcados "word for word" (estructura y opciones fijas) se traduzcan al idioma en el que se viene desarrollando la conversación, en vez de reproducirse literalmente en inglés, preservando la estructura y las opciones exactas.

Why this priority: Es el segundo bug de comportamiento detectado en el mismo fichero; tiene valor independiente (afecta a la experiencia del usuario en cualquier idioma) pero es de menor impacto funcional que el bloqueo real de las preguntas (Story 2), ya que hoy el texto sí se muestra, solo que en el idioma incorrecto.

Independent Test: Puede probarse iniciando una conversación en español (o cualquier idioma no inglés) y verificando que los bloques "word for word" de Step 1 se presentan traducidos a ese idioma, conservando la misma estructura y las mismas opciones que la versión fuente en inglés.

Acceptance Scenarios:

1. Given una conversación que se ha desarrollado en español, When se llega a un bloque de texto marcado "word for word", Then dicho bloque se presenta traducido al español preservando estructura y opciones exactas.
2. Given no hay input ni histórico de conversación del que detectar idioma, When se llega a un bloque "word for word", Then se usa el inglés como idioma por defecto.

## Edge Cases

- Si la red falla durante el fetch de `catalog.yaml` o de un fichero de contenido individual (`commands/*.md`, `agents/*.md`), la instalación se aborta con un mensaje de error claro, sin escribir ningún fichero a medias (fail-safe): el motor local ya no depende de ese fetch para operar, pero un fetch fallido no debe dejar cambios parciales aplicados.
- Cuando el histórico contiene mensajes en más de un idioma, se usa siempre el idioma del mensaje más reciente del usuario, ignorando el resto del histórico.
- En Codex CLI, la herramienta nativa equivalente a `AskUserQuestion` es `ask_user_question` (tool nativo de Codex CLI para preguntas estructuradas bloqueantes, documentado en developers.openai.com/codex/).

## Requirements (mandatory)

### Functional Requirements

- FR-001: El comando/skill `setup-ai` instalado localmente MUST contener la lógica completa de instalación (Steps 1-6) embebida, sin re-fetchear sus propias instrucciones de instalación desde GitHub en cada ejecución.
- FR-002: En runtime, `setup-ai` MUST fetchear únicamente `catalog.yaml` y los ficheros de contenido (`commands/*.md`, `agents/*.md`) declarados en dicho catálogo.
- FR-003: Step 1 del flujo de `setup-ai` (y cualquier pregunta bloqueante equivalente) MUST instruir explícitamente invocar la herramienta nativa de preguntas interactivas disponible en la plataforma del agente (`AskUserQuestion` en Claude Code, `ask_user_question` en Codex CLI) en vez de imprimir el texto de la pregunta como texto plano.
- FR-004: Los bloques de texto marcados "word for word" MUST traducirse al idioma de la conversación, detectado siempre a partir del mensaje más reciente del usuario (incluso si el histórico contiene mensajes en varios idiomas), preservando la estructura y las opciones exactas del bloque fuente.
- FR-005: Cuando no haya input ni histórico de conversación del que detectar idioma, los bloques "word for word" MUST presentarse en inglés como idioma por defecto.
- FR-006: La plantilla del launcher global de Step 6, tanto para Claude Code como para Codex CLI, MUST actualizarse para reflejar la misma separación entre motor de instalación local y catálogo remoto declarativo.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: Durante una ejecución completa de `setup-ai` (Steps 1-6), no se produce ningún fetch de red hacia las propias instrucciones de instalación del comando/skill; los únicos fetches observados corresponden a `catalog.yaml` y a los ficheros de contenido (`commands/*.md`, `agents/*.md`) que ese catálogo declara.
- SC-002: En Claude Code, Step 1 (y cualquier pregunta bloqueante equivalente) invoca `AskUserQuestion` y la ejecución queda efectivamente detenida hasta recibir respuesta del usuario, en vez de continuar tras imprimir texto.
- SC-003: En una conversación desarrollada en un idioma distinto del inglés, los bloques "word for word" de Step 1 se muestran traducidos a ese idioma conservando estructura y opciones, y en inglés cuando no hay input ni histórico del que detectar idioma.
- SC-004: La plantilla del launcher global (Step 6) para Claude Code y Codex CLI ya no replica el patrón de fetch autorreferencial de las instrucciones de instalación.

## Assumptions

- La separación motor/catálogo se implementa embebiendo la lógica de instalación (Steps 1-6) directamente en el propio fichero `setup-ai.md` que se instala localmente en el repo destino; `catalog.yaml` y los ficheros de contenido (`commands/*.md`, `agents/*.md`) permanecen en el repositorio remoto de GitHub y se fetchean en runtime. La plantilla del launcher global (Step 6) se actualiza en consecuencia.
- `catalog.yaml` y los ficheros de contenido (`commands/*.md`, `agents/*.md`) continúan siendo remotos y fetcheados en runtime porque son los elementos que cambian con el tiempo; el resto de la lógica de instalación pasa a ser local.
- El pin de versión/tag de `catalog.yaml` queda fuera de alcance de este cambio y se difiere a un issue futuro; este cambio solo separa el motor (local) del catálogo (remoto), sin fijar versión del catálogo fetcheado desde `main`.
- La comparación con rustup, Homebrew y spec-kit (mencionada en el issue como contexto/justificación de la investigación comparativa) no impone un diseño técnico concreto sobre este repo, solo valida el patrón general de separación motor/catálogo.
