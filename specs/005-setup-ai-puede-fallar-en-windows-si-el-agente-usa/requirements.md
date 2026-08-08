# setup-ai puede fallar en Windows si el agente usa curl en vez del fetch nativo (CRYPT_E_NO_REVOCATION_CHECK)
Feature Branch: 005-setup-ai-puede-fallar-en-windows-si-el-agente-usa
Source Issue: https://github.com/charlstown/my-aisy-toolkit/issues/46

Created: 2026-08-07

Status: Draft

Input: User description: "## Descripción

`setup-ai.md` está diseñado para que el agente use su *native fetch tool* al hacer los `GET` de `catalog.yaml`, `setup-ai.md` y los ficheros de `commands/*.md` / `agents/*.md`. Sin embargo, las instrucciones no impiden ni advierten contra que el agente caiga a `curl` vía shell como fallback. En Windows, `curl` usa schannel y puede fallar durante el handshake TLS con `CRYPT_E_NO_REVOCATION_CHECK`, antes de recibir una respuesta HTTP. Como el Step 2 de `setup-ai.md` aborta la instalación ante un GET inalcanzable, este fallo puede detener toda la instalación con un error de bajo nivel. La instalación no debería depender del método de fetch elegido; si se usa un fallback por shell, el fallo debe ser reconocible y recuperable, o al menos explicado."

## User Scenarios & Testing (mandatory)

### User Story 1 - Instalar el kit en Windows sin depender de curl (Priority: P1)

Una persona en Windows pide a un agente instalar el kit siguiendo las instrucciones de `setup-ai.md`. El agente obtiene los recursos de instalación sin que la elección de `curl` como fallback provoque un fallo de handshake TLS que aborte toda la instalación.

Why this priority: La imposibilidad de completar la instalación bloquea por completo el uso del kit en entornos Windows afectados.

Independent Test: Se puede probar de forma independiente iniciando la instalación en Windows en un entorno donde `curl` falle con `CRYPT_E_NO_REVOCATION_CHECK` y verificando que la instalación no quede abortada únicamente por ese fallback.

Acceptance Scenarios:

1. Given un equipo Windows donde `curl` falla con `CRYPT_E_NO_REVOCATION_CHECK`, When un agente sigue las instrucciones de instalación, Then el flujo no debe abortarse silenciosamente por ese fallo de `curl`.
2. Given un agente que puede usar su herramienta nativa de fetch, When necesita recuperar los recursos remotos de instalación, Then las instrucciones deben orientar el flujo para no depender de `curl` vía shell.

### User Story 2 - Entender un fallo de fallback de shell (Priority: P2)

Una persona recibe un fallo al obtener un recurso durante la instalación en Windows. Si el proceso usa un fallback por shell y falla por la comprobación de revocación de schannel, recibe información que permita distinguir este caso de una caída del repositorio o de la red.

Why this priority: Un error de bajo nivel sin contexto impide identificar que el método de fetch, y no necesariamente el repositorio, causó el aborto.

Independent Test: Se puede probar provocando el fallo de handshake de `curl` en Windows y comprobando que el resultado sea reconocible y explicativo según el comportamiento que se defina.

Acceptance Scenarios:

1. Given un fallback por shell que falla antes de recibir una respuesta HTTP, When se detecta `CRYPT_E_NO_REVOCATION_CHECK`, Then el resultado debe ser reconocible como un fallo de método de fetch o de schannel y no presentarse como una respuesta HTTP del repositorio.

## Edge Cases

- Si el agente no dispone de una herramienta nativa de fetch, prueba secuencialmente los métodos alternativos compatibles disponibles.
- Ante un fallo de handshake TLS de `curl` en Windows antes de recibir una respuesta HTTP, el flujo prueba otros métodos antes de informar del error.
- Esta feature parte del mecanismo de fetch del issue #44, que ya está implementado y fusionado.

## Requirements (mandatory)

### Functional Requirements

- FR-001: Las instrucciones de `setup-ai.md` MUST usar la herramienta nativa de fetch del agente como primera opción para los GET de recursos remotos y, si falla, probar secuencialmente métodos alternativos compatibles antes de fallar.
- FR-002: El sistema MUST tratar el fallo `CRYPT_E_NO_REVOCATION_CHECK` de schannel durante un fallback de `curl` como un fallo previo a la respuesta HTTP.
- FR-003: Los usuarios MUST poder reconocer, mediante el resultado del flujo de instalación, que un fallo de `CRYPT_E_NO_REVOCATION_CHECK` está relacionado con el método de fetch o schannel y no con una respuesta HTTP del repositorio.
- FR-004: El sistema MUST recuperarse automáticamente de `CRYPT_E_NO_REVOCATION_CHECK` reintentando otros métodos de fetch y solo informar del error si ninguno completa la descarga.
- FR-005: Si el agente no dispone de una herramienta nativa de fetch, el sistema MUST probar secuencialmente los métodos alternativos compatibles disponibles y solo fallar tras agotarlos.

## Success Criteria (mandatory)

### Measurable Outcomes

- SC-001: En un entorno Windows que reproduzca `CRYPT_E_NO_REVOCATION_CHECK` con `curl`, la instalación no se aborta silenciosamente por ese fallo.
- SC-002: En ese escenario, el resultado distingue explícitamente un fallo de handshake TLS/fetch de una respuesta HTTP 4xx o 5xx.
- SC-003: Una persona puede identificar a partir del resultado de instalación que la causa está ligada al método de fetch o a schannel.
- SC-004: En las pruebas que simulen `CRYPT_E_NO_REVOCATION_CHECK`, el flujo completa la descarga con un método alternativo siempre que exista uno disponible y ninguna instalación se aborta en el primer fallo de fetch.

## Assumptions

- Las personas afectadas usan Windows 11 y pueden ejecutar un agente con acceso a herramientas de shell y/o fetch.
- El alcance se limita a las instrucciones y al flujo de instalación de `setup-ai.md`; no se presupone un cambio de configuración del sistema operativo o de la red de la persona.
- El fallo ocurre antes de completarse una petición HTTP cuando schannel no puede comprobar la revocación del certificado.
- El mecanismo de fetch del issue #44 ya está implementado y fusionado; esta feature se apoya en él para la secuencia de intentos y recuperación.
