# Plan — Añadir el prefijo `aisy.` a todas las skills instaladas

## Batch 1 — Alcance y mapa de migración

- [x] @architect · Inventariar nombres y superficies publicadas: recorrer `catalog.yaml`, `ai-toolkit/skills/`, `setup-ai.md`, las plantillas de lanzador y la documentación para relacionar cada skill distribuible con su nombre fuente, destino instalado, comando de Claude Code y comando de Codex; dejar explícito que los directorios fuente no se renombran y que no habrá migración ni borrado de nombres históricos locales.

## Batch 2 — Registro e instalación con el nuevo identificador

- [ ] @code-developer · Prefijar destinos de skills de perfil: actualizar las instrucciones y ambos motores embebidos de `setup-ai.md` para derivar el destino instalado como `aisy.<name>` para cada artefacto declarado en `profiles.*.skills`, conservando la copia literal del contenido y la selección declarativa del catálogo.
- [ ] @code-developer · Unificar el pack utils con el esquema prefijado: ajustar las instrucciones de instalación para que perfiles y `packs.utils` usen el mismo cálculo de destino `aisy.<name>` en `.claude/skills/` y `.agents/skills/`, sin crear aliases, redirecciones ni operaciones sobre carpetas históricas sin prefijo.
- [ ] @code-developer · Renombrar el lanzador global: modificar las plantillas Claude y Codex, sus rutas de escritura, frontmatter, títulos, descripciones y autoactualización para publicar `aisy.setup-ai` y documentar su invocación nativa (`/aisy.setup-ai` en Claude y el identificador equivalente de skill en Codex), sin tocar ni eliminar lanzadores heredados.

## Batch 3 — Contenido y documentación coherentes

- [ ] @code-developer · Actualizar referencias invocables distribuidas: sustituir en cada `ai-toolkit/skills/*/SKILL.md` los comandos y referencias cruzadas a skills por sus formas `aisy.<skill-name>`, incluido `setup-ai`, preservando las reglas específicas de invocación de cada plataforma y sin duplicar las skills compartidas.
- [ ] @code-developer · Alinear documentación y especificaciones operativas: actualizar `README.md`, `README-ES.md`, `ai-toolkit/README.md`, `setup-ai.md` y los documentos de especificación que describen rutas o comandos instalados para que no anuncien skills distribuibles sin el prefijo; explicar que una instalación nueva no limpia nombres existentes.

## Batch 4 — Pruebas reproducibles

- [x] @test-developer · Añadir verificación estática del catálogo instalado: crear o ampliar pruebas/validaciones que, a partir de `catalog.yaml`, comprueben para ambos destinos que todas las skills de perfiles y utils se materializan exclusivamente bajo `aisy.<name>/SKILL.md`, que no se planifican destinos sin prefijo y que el contenido copiado sigue siendo literal.
- [x] @test-developer · Cubrir los lanzadores y las referencias públicas: comprobar que las plantillas globales publican `aisy.setup-ai`, que sus rutas y comandos documentados coinciden, y que las skills distribuidas y la documentación no contienen comandos invocables sin prefijo para las skills del catálogo.

## Batch 5 — Validación de instalación y revisión

- [blocked] @tester · Ejecutar la matriz de instalación aislada: en repositorios y hogares temporales, verificar perfiles `default` y `ui-ux` más `utils` para Claude Code y Codex, confirmar que cada skill resultante se detecta como `aisy.<name>`, probar el lanzador global `aisy.setup-ai` y confirmar que ninguna comprobación elimina nombres heredados.
  - Reason: los cambios requeridos de los batches 1–3 aún no existen en este worktree; la verificación estática devuelve 57 incumplimientos y no hay instalador actualizado que ejecutar de forma válida.
- [blocked] @judge · Revisar cumplimiento de la convención: auditar el diff y la evidencia contra FR-001 a FR-006 y SC-001 a SC-004, verificando cobertura funcional de `default`, `ui-ux` y `utils` en ambas plataformas, ausencia de compatibilidad implícita y consistencia entre catálogo, instalador, plantillas y documentación.
  - Reason: CHANGES_REQUESTED — faltan los cambios de los batches 1–3 y, por ello, no existe evidencia de una matriz de instalación aprobable.
