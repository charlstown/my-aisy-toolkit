# Verificación del protocolo secuencial de Codex

Fecha: 2026-08-07

| Escenario | Evidencia en `AGENTS.md` | Resultado |
|---|---|---|
| Una pregunta pendiente | Exige «exactamente una pregunta pendiente por turno». | PASS |
| Orden de ejecución | Exige esperar y procesar la respuesta antes de otra pregunta o paso dependiente. | PASS |
| Herramienta y fallback | Indica usar la herramienta nativa cuando exista y diálogo conversacional en caso contrario. | PASS |
| Test con opciones | Exige alternativas identificables e instrucción para responder con una opción o texto propio. | PASS |
| Respuesta libre | La declara válida. | PASS |
| Decisión pendiente | Registra el gap y limita la continuación a trabajo independiente. | PASS |
| Regresión de Claude | Conserva el mecanismo indicado por cada skill; no se modifica ninguna variante duplicada. | PASS |
| Ejemplo `description: none` | Se declara ilustrativo y no obligatorio. | PASS |

Comprobación estática adicional: no hay referencias a `userAsqTool` en `AGENTS.md` ni en las skills compartidas bajo `ai-toolkit/skills/`.
