# Inventario de migración de identificadores `aisy.`

Los artefactos fuente conservan sus rutas declaradas en `catalog.yaml` y
`ai-toolkit/skills/<name>/SKILL.md`. El prefijo se aplica únicamente al
identificador y al directorio de destino instalado.

| Superficie | Fuente | Claude Code | Codex CLI |
|---|---|---|---|
| Skills de `default` y `ui-ux` | `profiles.*.skills` | `.claude/skills/aisy.<name>/SKILL.md` · `/aisy.<name>` | `.agents/skills/aisy.<name>/SKILL.md` · `aisy.<name>` |
| Pack `utils` | `packs.utils` | `.claude/skills/aisy.<name>/SKILL.md` · `/aisy.<name>` | `.agents/skills/aisy.<name>/SKILL.md` · `aisy.<name>` |
| Lanzador global | plantilla Claude/Codex de `setup-ai.md` | global `.claude/skills/aisy.setup-ai/SKILL.md` · `/aisy.setup-ai` | global `$CODEX_HOME/skills/aisy.setup-ai/SKILL.md` · `aisy.setup-ai` |

Las plantillas, `README.md`, `README-ES.md`, `ai-toolkit/README.md` y las
referencias cruzadas de las skills deben publicar estos identificadores. Las
instalaciones nuevas no crean aliases, redirecciones ni carpetas sin prefijo,
y `setup-ai` tampoco migra ni borra nombres históricos ya presentes: esa
limpieza queda bajo control de la persona usuaria.
