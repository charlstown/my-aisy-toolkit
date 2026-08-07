# Plan: Preguntas secuenciales tipo test para Claude y Codex

Feature Branch: `003-preguntas-secuenciales-en-skills-claude-y-codex`
Requirements: `specs/003-preguntas-secuenciales-en-skills-claude-y-codex/requirements.md`

## Aclaraciones incorporadas

- El cambio cubre todas las skills distribuidas que realmente soliciten información o decisiones al usuario.
- Para Codex se usa interacción conversacional, una pregunta tipo test por turno. Una respuesta que no se entienda o no se relacione con las opciones permite pedir aclaración; no se establece una validación rígida de letras.
- Elegir “No lo tengo claro todavía” no detiene el flujo: la skill conserva la decisión como pendiente y continúa solo con los pasos que no dependan de resolverla.
- Claude conserva su mecanismo y comportamiento de preguntas actual.

## Tareas

- [ ] @architect · Inventariar los puntos de interacción y definir la política compartida: después de la migración de la feature 002, revisar todas las skills bajo `ai-toolkit/skills/` e identificar cuáles hacen preguntas y en qué pasos. Para cada una, anotar si la pregunta bloquea un paso dependiente o puede dejar un *gap* pendiente; definir una redacción condicional que mantenga el mecanismo actual de Claude y aplique el protocolo conversacional de Codex. Archivos afectados: `ai-toolkit/skills/*/SKILL.md` que pidan información. Dependencia: feature 002 completada. Comprobación: inventario completo de skills interrogativas y política aplicable sin cambiar las que no preguntan.

- [ ] @code-developer · Aplicar el flujo secuencial de Codex en las skills inventariadas: en cada `SKILL.md` afectado, instruir que Codex muestre exactamente una pregunta con alternativas identificables, la instrucción explícita de respuesta, espere la contestación antes de preguntar o ejecutar pasos dependientes, y procese la respuesta antes de continuar. Añadir el manejo acordado para entradas incomprensibles y decisiones pendientes, sin requerir ni mencionar `userAsqTool`. Mantener explícitamente intacto el flujo de Claude. Archivos afectados: los `ai-toolkit/skills/<nombre>/SKILL.md` del inventario. Dependencia: política de interacción. Comprobación: ninguna instrucción Codex formula preguntas en lote o avanza sobre una respuesta pendiente; Claude conserva sus instrucciones nativas.

- [ ] @code-developer · Incorporar el caso de `description: none`: localizar las skills que puedan plantear una decisión sobre la convención por defecto de `CLAUDE.md` e introducir el bloque de pregunta con las cuatro alternativas acordadas, etiquetadas A–D, y la frase exacta “Responde solo con A, B, C o D.”. Si la alternativa D se elige, registrar la decisión como pendiente y continuar sin aplicar un cambio que dependa de ella. Archivos afectados: skills identificadas en el inventario y, solo si ya era necesario para su comportamiento, la documentación de decisión correspondiente. Dependencia: política de interacción. Comprobación: revisión textual confirma las cuatro opciones y la frase exigida, sin convertir el ejemplo en una pregunta fuera de contexto.

- [ ] @tester · Validar el protocolo y la regresión de Claude: simular una skill con varias decisiones en Codex para comprobar la secuencia pregunta → respuesta procesada → siguiente paso, probar una respuesta incomprensible y la alternativa pendiente, y contrastar las instrucciones de Claude contra el comportamiento previo. Ejecutar búsquedas estáticas para asegurar que las instrucciones Codex no contienen `userAsqTool`. Archivos afectados: ninguno, salvo evidencia de pruebas si se acuerda guardarla. Dependencias: todas las tareas de implementación. Comprobación: se cumplen SC-001 a SC-004 y los escenarios de aceptación de las tres historias.

## Bloqueadores

- La feature 003 depende de la estructura única de skills de la feature 002. No debe editarse el catálogo distribuible antiguo: si 002 no está integrada, implementar primero su migración o adaptar esta tarea al árbol compartido resultante.
