# Plan — recuperación de fetch en `setup-ai`

## Batch 1 — Contrato del flujo

- [x] @architect · Delimitar la política de obtención remota: revisar `setup-ai.md`, sus dos plantillas embebidas y el mecanismo procedente de #44 para inventariar todos los GET (catálogo, artefactos y actualización del lanzador) y documentar en el plan de implementación una secuencia común: fetch nativo primero, fallbacks compatibles uno a uno y fallo únicamente tras agotarlos.

### Decisión de arquitectura — política común de GET

**Contexto verificado.** `setup-ai.md` describe el bootstrap que obtiene este documento, el GET del
catálogo en Step 2, los GET de cada ruta literal del catálogo en Step 3 y dos motores embebidos
(Claude y Codex). Ambos motores hacen además, antes de Step 1, un GET de `setup-ai.md` para extraer
y comparar únicamente su propia plantilla. El mecanismo de lanzador introducido después del flujo
de puntero de #44 conserva deliberadamente un motor local: que ese chequeo de actualización falle
no debe impedir la instalación de los artefactos del catálogo.

| Superficie | Recurso | Cuándo se agota la cadena | Consecuencia al agotarse |
| --- | --- | --- | --- |
| Bootstrap | `setup-ai.md` | Antes de que exista un motor que ejecutar | Informar que no se pudieron leer las instrucciones; no hay instalación ni escrituras del motor. |
| Catálogo | `catalog.yaml` | En Step 2, antes de cualquier escritura | Abortar la instalación sin escribir. |
| Artefacto | Cada ruta literal declarada en `profiles` o `packs.utils` | Al terminar una cadena completa; repetir una vez esa cadena completa | Tras la segunda cadena agotada, informar y omitir solo ese artefacto; continuar con los demás. |
| Autoactualización Claude | Plantilla Claude extraída de `setup-ai.md` | Una cadena completa antes de Step 1 | Registrar la causa real y continuar con el motor embebido. |
| Autoactualización Codex | Plantilla Codex extraída de `setup-ai.md` | Una cadena completa antes de Step 1 | Registrar la causa real y continuar con el motor embebido. |

**Política que implementará Batch 2.** Para *cada* GET de la tabla, intentar primero la herramienta
de fetch nativa del agente. Ante cualquier error de ese método, probar de forma secuencial —nunca en
paralelo— cada alternativa de descarga que sea compatible y esté disponible en el entorno. Cada
método recibe el mismo URL y se detiene la cadena en el primer resultado descargado correctamente.
No se prescribe un orden ni nombres de fallbacks de shell: la compatibilidad depende del agente y
del sistema, y `curl` no es un requisito ni una fuente de verdad. Solo tras no quedar un método
compatible sin intentar se aplica la consecuencia de la tabla. No usar caché, memoria, listado
remoto ni una ruta distinta de la declarada como sustituto de una descarga fallida.

Un `CRYPT_E_NO_REVOCATION_CHECK` emitido por `curl` es un error del método de fetch/schannel previo
a HTTP: se registra junto al método y su causa, se pasa al siguiente método y nunca se etiqueta como
respuesta 4xx/5xx. El mismo registro por método permite distinguir un error de transporte de una
respuesta HTTP real cuando finalmente se informe un agotamiento.

**Decisiones.**

- **Cadena completa por intento de artefacto** → descartado reintentar solo `curl` o ampliar el
  límite actual de artefactos → conserva el máximo actual de un reintento, pero hace que ambos
  intentos puedan recuperarse con cualquier método compatible.
- **Fallbacks definidos por capacidad, no una lista rígida de comandos** → descartado imponer
  `curl`/PowerShell o desactivar comprobaciones TLS → preserva el diseño sin dependencias y evita
  convertir un workaround específico de Windows en requisito o degradar la seguridad TLS.
- **El bootstrap adopta la prioridad de fetch nativo, pero no cambia la naturaleza de su fallo** →
  descartado tratarlo como un catálogo ya iniciado → el documento aún no está disponible para
  ejecutar su motor; por tanto solo puede explicar el agotamiento y no escribir ni instalar.
- **El update check de los launchers sigue siendo no bloqueante** → descartado abortar el motor local
  al agotar sus fallbacks → mantiene el contrato del mecanismo de #44/launcher embebido y ADR-007:
  la actualización del atajo no es fuente de las instrucciones activas.

## Batch 2 — Implementación y cobertura

- [x] @code-developer · Aplicar la política de reintentos en las instrucciones: actualizar `setup-ai.md` y las plantillas literales de Claude y Codex para exigir fetch nativo como primer intento para cada GET, probar métodos compatibles alternativos de forma secuencial tras cualquier error y conservar los límites actuales de escritura y de reintento de artefactos.
- [x] @code-developer · Diferenciar errores TLS de respuestas HTTP: añadir a las instrucciones y al wrap-up el tratamiento explícito de `CRYPT_E_NO_REVOCATION_CHECK` como fallo de fetch/schannel previo a HTTP, registrar cada método fallido y su causa, continuar con el siguiente método y explicar el diagnóstico solo cuando no quede ningún método capaz de descargar el recurso.
- [x] @test-developer · Añadir pruebas de contrato del instalador: crear cobertura automatizada proporcional al repositorio que compruebe, en el documento principal y en ambas plantillas, la prioridad de fetch nativo, la secuencia de fallbacks, el agotamiento antes de abortar y el texto de diagnóstico de `CRYPT_E_NO_REVOCATION_CHECK` sin clasificarlo como 4xx/5xx.

## Batch 3 — Verificación y cierre de calidad

- [blocked] @tester · Validar escenarios de recuperación: ejecutar la nueva cobertura y revisar el flujo como un agente en Windows, simulando que `curl` devuelve `CRYPT_E_NO_REVOCATION_CHECK` con un método alternativo disponible y sin él; confirmar respectivamente la continuidad de la descarga y el informe final inteligible tras agotar alternativas.
  - Reason: Cancelada por instrucción explícita del usuario; no ejecutar.
- [ ] @judge · Revisar consistencia y regresiones: comprobar que el cambio cubre todos los GET y las tres rutas de ejecución (bootstrap y ambos lanzadores), no convierte un fallo TLS en respuesta HTTP, no introduce escrituras fuera del alcance ni contradice el catálogo, y que las pruebas evidencian los criterios de aceptación.
