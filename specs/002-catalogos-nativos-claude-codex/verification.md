# Verificación de catálogo nativo

Fecha: 2026-08-07

| Comprobación | Resultado |
|---|---|
| Rutas declaradas por `catalog.yaml` | 27 rutas existentes. |
| Skills compartidas | 15 directorios, cada uno con `SKILL.md`. |
| Agentes nativos | 6 Markdown en `agents/claude` y 6 TOML en `agents/codex`. |
| Perfiles | `default` resuelve 10 skills; `ui-ux` reutiliza esas 10 y añade 2. |
| Utils | 3 skills compartidas con destino `aisy.<name>` para ambas plataformas. |
| Instalación literal | `setup-ai.md` declara los cuatro destinos nativos y create/overwrite/leave-alone por bytes. |
| Reintento | Cada descarga individual se reintenta una vez; el catálogo aborta sin escrituras si falla. |

La comprobación se hizo de forma estática porque el repositorio no contiene un ejecutable de instalación y Codex CLI no está disponible como entorno de integración real. La estructura y los destinos son deterministas y se validan directamente contra el manifiesto.
