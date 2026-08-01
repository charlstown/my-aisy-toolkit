<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/logo-dark.png">
    <source media="(prefers-color-scheme: light)" srcset="assets/logo-light.png">
    <img alt="My AIsy Toolkit" src="assets/logo-light.png" width="320" height="160">
  </picture>
</p>

<p align="center">
  <strong>Pasa del vibe coding al Spec-Driven Development. Orquesta bucles agénticos con un catálogo de skills y subagentes listo para copiar y pegar, sin instalación.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-1.1-orange?style=for-the-badge" alt="Versión">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/skills-11-blue?style=flat-square" alt="Skills">
  <img src="https://img.shields.io/badge/agents-6-informational?style=flat-square" alt="Agentes">
  <img src="https://img.shields.io/badge/updated-2026--08--01-lightgrey?style=flat-square" alt="Actualizado">
</p>

<p align="center">
  🌐 <a href="README.md">English</a> · <strong>Español</strong>
</p>

<p align="center">
  My AIsy Toolkit reúne skills y subagentes listos para instalar en tu repositorio y empezar a desarrollar con Spec-Driven Development y bucles agénticos, compatible con Claude Code y Codex CLI en modo best-effort. Apunta tu agente a una URL (o pega un archivo), y cualquier repositorio obtiene el mismo catálogo de comandos y subagentes, listo para usar, sin librerías, sin gestores de paquetes, sin nada que instalar globalmente.
</p>

---

## ⚡ Instalación rápida

Desde dentro del repositorio que quieres configurar, pega esto en la conversación de tu agente:

```
Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md
```

Tu agente descarga el archivo, sigue los pasos que contiene y te cuenta qué instaló. No hay nada que descargar, ningún gestor de paquetes y ningún script que ejecutar. Los efectos secundarios se limitan a los archivos escritos dentro de `.claude/` y/o `.codex/` en tu repositorio. Nada más se toca.

---

### Instalación por terminal

¿Prefieres la terminal? Pásalo directamente como prompt al arrancar el agente:

```
claude "Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md"
```

```
codex "Fetch and follow the setup instructions at https://raw.githubusercontent.com/charlstown/my-aisy-toolkit/main/setup-ai.md"
```

## 📦 ¿Qué vas a encontrar aquí?

- **11 skills** que cubren todo el flujo dirigido por especificaciones, desde `/constitution` hasta `/clean-feature`
- **6 subagentes** para arquitectura, implementación, testing, UI y revisión
- **1 método de instalación**: una URL o un archivo pegado, nada que descargar
- **2 agentes de código IA** soportados: Claude Code (nativo) y Codex CLI (best-effort)

Y el catálogo sigue creciendo a medida que se añaden nuevas skills y agentes.

## 🔁 Cómo funciona

Apunta tu agente a la URL de instalación una sola vez, ese es el único paso de instalación. `/constitution` arranca las specs (product-spec, tech-spec, roadmap) y a partir de ahí cada feature pasa por el mismo ciclo cerrado: `/specify-feature` la acota, `/clarify-feature` cierra los huecos de decisión pendientes, `/plan-feature` la descompone, `/implement-feature` la construye y `/clean-feature` cierra el ciclo alineando de nuevo las specs antes de que empiece la siguiente feature.

<p align="center">
  <img src="assets/skill-cycle.svg" alt="La instalación alimenta un ciclo que se repite: constitution, specify-feature, plan-feature, implement-feature, clean-feature, y vuelta a constitution" width="720">
</p>

## 📚 Catálogo: perfil default

**Skills**

| Skill | Qué hace |
|-------|----------|
| `/constitution` | Encadena product-spec y tech-spec para arrancar las specs raíz de un proyecto. |
| `/product-spec` | Genera o actualiza `specs/product-spec.md` entrevistando al usuario. |
| `/tech-spec` | Genera o actualiza `specs/tech-spec.md` (el cómo técnico) a partir del product-spec. |
| `/roadmap` | Genera `specs/roadmap.md` a partir del product-spec y el tech-spec. |
| `/new-issue` | Abre un issue de bug o feature en GitHub, investigando o clarificando según el tipo. |
| `/specify-feature` | Detecta features a partir de varias fuentes (incluyendo issues abiertos de GitHub) y crea un `requirements.md` por cada una. |
| `/clarify-feature` | Cierra los huecos de decisión pendientes en uno o varios `requirements.md`. |
| `/grill-me` | Interrogatorio crítico de un documento para reducir huecos e inconsistencias. |
| `/plan-feature` | Genera `plan.md` a partir de un `requirements.md`, asignando tareas a subagentes. |
| `/implement-feature` | Orquesta la ejecución de uno o varios `plan.md` usando git worktrees. |
| `/clean-feature` | Alinea las specs raíz con el trabajo completado y cierra el issue asociado. |

**Agentes** (subagentes de Claude Code)

| Agente | Rol |
|--------|-----|
| `architect` | Descubrimiento, evaluación de alternativas y diseño de la solución antes de implementar. |
| `code-developer` | Implementa código de aplicación a partir de un plan ya definido. |
| `test-developer` | Escribe tests (no los ejecuta). |
| `tester` | Ejecuta los tests y verifica el comportamiento real de la aplicación. |
| `ui-developer` | Diseña e implementa pantallas completas (HTML/CSS/TS/React). |
| `judge` | Revisa el trabajo de otros agentes y emite un veredicto PASS / CHANGES_REQUESTED. |

> [!note] Codex CLI
> Codex CLI no tiene un equivalente nativo a los subagentes; en modo best-effort solo se traduce el catálogo de **skills** a `.codex/skills/`.

## 🗂️ Estructura del proyecto

Solo las piezas que le importan a alguien decidiendo si instalar o no:

```
my-aisy-toolkit/
├── ai-toolkit/
│   └── default/
│       ├── commands/    # 11 skills
│       └── agents/      # 6 subagentes
├── catalog.yaml
├── setup-ai.md
└── README.md
```

## 📝 Cosas a saber

**Reinstalar o actualizar.** Volver a ejecutar cualquiera de los dos métodos de instalación en un repositorio que ya tiene el kit trae la última versión del catálogo, añade las skills o agentes nuevos desde tu última instalación y actualiza los que hayan cambiado. No hay versionado semántico que rastrear. Siempre acabas en el catálogo actual.

**Parámetros**

| Parámetro | Tipo | Por defecto | Descripción |
|-------|------|---------|--------------|
| `profile` | string | `default` | Perfil del catálogo a instalar. Si hay más de uno disponible y no se especifica ninguno, tu agente pregunta cuál quieres. |
| `agent` | string | preguntado | Agente IA destino (`claude`, `codex`). Siempre se pregunta explícitamente, nunca se infiere de las carpetas que ya haya en tu repositorio. |

Los efectos secundarios se limitan a `.claude/` y/o `.codex/` en tu repositorio. El código de la aplicación y todo lo demás se deja intacto.

## 🤝 Código de conducta

Este proyecto sigue un [Código de conducta](CODE_OF_CONDUCT.md). Al participar, se espera que lo respetes.
