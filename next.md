- This will be a best-effort translation of the Claude commands into Codex skill
  format, not a byte-for-byte copy. Evitar traducir codex tiene sus ficheros y claude los suyos.
- No se van a llamar commands se llamaran skills incluso para claude.
- Problema con los agentes de claude
- - Subagentes personalizados: van en .codex/agents/*.toml. La doc oficial dice que los agentes
    personalizados se definen como archivos TOML en ~/.codex/agents/ o .codex/agents/, uno por agente, con
    name, description y developer_instructions.
    Fuente: https://learn.chatgpt.com/docs/agent-configuration/subagents

-  repo/
    AGENTS.md
    .codex/
      agents/
        reviewer.toml
        translator.toml
      skills/
        translate-post/
          SKILL.md
        review-checklist/
          SKILL.md

- CLAUDE y AGENTS? El userAsqTool no existe para los casos de codex preguntar de una en una pregunta tipo test y no pasar a la siguiente hasta que haya terminado añadir a las skills
Ej:   ¿Qué quieres hacer con la convención por defecto description: none en CLAUDE.md?

  A. Cambiar la plantilla y corregir la causa raíz
  B. No tocar la plantilla; solo corregir las páginas existentes
  C. Corregir las páginas existentes ahora y dejar el cambio de plantilla para otra feature
  D. No lo tengo claro todavía

  Responde solo con A, B, C o D.