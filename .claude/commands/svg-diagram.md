---
name: svg-diagram
description: Genera diagramas SVG precisos y editoriales (arquitectura, flujo, secuencia, ER, timeline, jerarquía, quadrant...) mediante una breve entrevista con el usuario, aplicando un sistema de diseño estricto (grid de 4px, paleta semántica de 1 solo acento, tipografía jerárquica, sin sombras ni degradados). Lee la sección **Design Tokens** de este mismo fichero para el sistema de diseño completo y la plantilla base. Presenta un boceto en texto plano antes de generar el SVG, lanza 1 ronda de AskUserQuestion (tema, densidad, acento) y escribe el fichero `.svg` final, ofreciendo embeberlo en la nota indicada con `![[archivo.svg]]`. Trigger cuando el usuario diga "diagrama SVG", "genera un diagrama", "dibuja la arquitectura", "diagrama de flujo/secuencia/ER", o invoque /svg-diagram.
---

# SVG Diagram Skill

## Filosofía

Diagramas editoriales, no "diagramas generados por IA". La señal de un diagrama mediocre es: sombras, degradados decorativos, demasiados colores compitiendo entre sí, texto sin jerarquía y coordenadas que no siguen ningún grid. Este skill evita eso de forma deliberada:

- **Restricción antes que decoración.** Cada nodo se gana su lugar; si sobra, se elimina.
- **Un solo acento.** El color de acento se reserva para 1-2 elementos que el lector debe encontrar primero. Todo lo demás vive en tonos neutros.
- **Grid de 4px, sin excepciones.** Toda coordenada, ancho, alto y separación es múltiplo de 4. Esto es lo que distingue un diagrama dibujado con intención de uno con aspecto genérico.
- **Nunca Mermaid.** Este skill dibuja SVG explícito con coordenadas propias; no delega el layout a un motor automático. La precisión del resultado depende de controlar cada coordenada a mano.
- **Adaptable a tema claro/oscuro.** El vault se lee en ambos temas; el SVG debe verse bien en los dos sin regenerar el fichero (ver plantilla base en la sección **Design Tokens**).

## Workflow

### 1. Leer contexto existente

Leer en paralelo (omitir los que no existan):

- La nota donde se insertará el diagrama, para extraer nombres reales de componentes, pasos o entidades
- `specs/tech-spec.md` / `specs/ui-spec.md` si existen, para reusar terminología y lenguaje visual ya establecido
- Cualquier `.svg` previo en la misma carpeta, para mantener consistencia entre diagramas del mismo proyecto

### 2. Identificar tipo de diagrama y ubicación

Si el usuario no lo especificó, preguntar en **una sola línea de texto** antes de continuar:

> "¿Qué diagrama necesitas? (arquitectura, flujo, secuencia, ER, timeline, jerarquía/organigrama, quadrant 2x2...) ¿Y dónde lo guardo? (ruta del fichero `.svg` y, si aplica, la nota donde embeberlo)"

Usar la tabla de la sección **Taxonomía** para identificar el tipo y sus convenciones de forma.

### 3. Reunir contenido

Extraer del contexto o preguntar por:
- La lista de nodos/pasos/entidades con su etiqueta
- Las relaciones entre ellos (qué conecta con qué y en qué dirección)
- Cualquier agrupación (capas, fases, contenedores)

Si el contenido ya quedó claro en el paso 1, no volver a preguntarlo.

### 4. Boceto en texto plano — ANTES de generar el SVG

Mostrar en texto plano (no en fichero) un esquema simple de nodos y conexiones, para validar la estructura antes de invertir en coordenadas SVG precisas. Ejemplo:

```
[Cliente] --> [API Gateway] --> [Servicio Auth]
                              --> [Servicio Pedidos] --> [Base de datos]
```

### 5. Ronda única de AskUserQuestion

Máximo 3 preguntas:

| Header | Foco |
|--------|------|
| **Tema** | ¿Claro, oscuro, o adaptable a ambos (recomendado)? |
| **Densidad** | ¿Vista general (pocos nodos, mucho aire) o completa (todos los detalles)? |
| **Acento** | ¿Qué 1-2 elementos deben destacar sobre el resto? |

Usar `preview` con el boceto ASCII del paso 4 adaptado a cada opción cuando ayude a comparar visualmente.

**No escribir el fichero todavía.**

### 6. Generar el SVG

Aplicar el sistema de diseño de la sección **Design Tokens**: grid de 4px, tokens de color semánticos, escala tipográfica, stroke y radios, orden z de conectores, marcador de flecha reutilizado. Partir de la plantilla base de esa sección en vez de escribir SVG desde cero.

### 7. Guardar y embeber

Escribir el fichero `.svg` en la ruta acordada. Si el usuario indicó una nota destino, añadir (o actualizar) la línea de embed:

```markdown
![[nombre-diagrama.svg]]
```

No sobrescribir contenido existente de la nota más allá de esa línea, salvo instrucción explícita.

### 8. Confirmar

Describir en 2-3 frases qué se generó y dónde, y ofrecer iterar (cambiar el acento, añadir un nodo, ajustar el tema) antes de dar la tarea por cerrada.

---

## Taxonomía de diagramas y convenciones de forma

| Tipo | Cuándo usarlo | Forma de los nodos | Notas |
|------|----------------|---------------------|-------|
| **Arquitectura de sistema** | Servicios, infraestructura, integraciones | Rects redondeados (`rx=8`) agrupados en contenedores (`rx=12`, borde discontinuo) | Leyenda de colores por capa (frontend/backend/datos/externo); flechas = llamadas de red |
| **Flujo / Proceso** | Lógica paso a paso, decisiones | Píldora (inicio/fin), rect redondeado (paso), rombo (decisión), paralelogramo (entrada/salida) | Una sola dirección de lectura (arriba-abajo o izquierda-derecha), nunca ambas a la vez |
| **Secuencia** | Interacción entre actores en el tiempo | Lifelines verticales + barras de activación; mensajes como flechas horizontales etiquetadas | El eje temporal siempre va de arriba a abajo |
| **Entidad-relación (ER)** | Modelo de datos | Tablas con cabecera + filas de campos (tipo en monospace) | Cardinalidad como etiqueta de texto (`1`, `N`) junto a la línea, no crow's-foot dibujado |
| **Timeline** | Hitos en el tiempo | Eje horizontal con marcas; hitos como punto + etiqueta alternando arriba/abajo | Fechas siempre en monospace |
| **Jerarquía / Organigrama / Árbol** | Estructura de niveles | Rects conectados por líneas ortogonales (nunca curvas) | Mismo nivel = misma fila del grid vertical |
| **Quadrant / 2x2** | Comparar dos ejes | Ejes con etiqueta en cada extremo, puntos o cajas dentro del cuadrante correspondiente | Los ejes son la única línea sin flecha |

Si el tipo pedido no está en la tabla, aplicar los principios generales de la sección **Filosofía** (restricción, grid de 4px, un solo acento) y elegir la forma de nodo más simple que represente el contenido.

---

## Design Tokens

Sistema de diseño completo para `/svg-diagram`. Se lee en el paso 6 del workflow (generación del SVG).

### Grid y espaciado

- Unidad base: **4px**. Toda coordenada x/y, ancho, alto y separación es múltiplo de 4.
- Padding del `viewBox`: 40px en los 4 lados respecto al contenido más extremo.
- Separación mínima vertical entre nodos: 40px (un conector o etiqueta puede vivir dentro de ese hueco, nunca superpuesto a un nodo).
- Separación mínima horizontal entre nodos: 32-48px según la densidad elegida en la ronda de preguntas.
- Leyenda: siempre fuera de cualquier contenedor/boundary, mínimo 20px por debajo del elemento más bajo del diagrama.

### Radios (`rx`)

| Elemento | rx |
|---|---|
| Chip / etiqueta pequeña | 4 |
| Nodo estándar | 8 |
| Contenedor / grupo interno | 12 |
| Contenedor exterior (región, boundary lógico) | 16-20 |

Nunca superar 20 salvo el propio fondo del lienzo.

### Trazo (stroke)

- Borde de nodo: 1-1.5px
- Grid de fondo (opcional, sutil): 0.5px
- Conectores: 1.5px, siempre con `fill="none"`
- Boundary/contenedor lógico: `stroke-dasharray="4,4"` (límite fino) o `"8,4"` (límite grueso/región)

### Tipografía

- Familia: `system-ui, sans-serif` para etiquetas de nodo; monospace para contenido técnico (rutas, tipos de campo, puertos, fechas)
- Escala: 16px (título del diagrama), 13px (etiqueta principal de nodo), 11px (subetiqueta), 9px (anotación/leyenda)
- Nunca todo en mayúsculas; negrita solo en la etiqueta principal de nodo
- Multilínea: usar `<tspan>` con `dy` múltiplo de 4 (12 o 16), nunca `foreignObject` (se renderiza de forma inconsistente al incrustar un SVG como imagen)

### Color: tokens semánticos, no valores repetidos a mano

Definir siempre en un bloque `<style>` dentro del propio SVG, con variables por tema. Esto permite que el mismo fichero se vea correcto en modo claro y oscuro dentro de Obsidian sin regenerar nada (el visor respeta `prefers-color-scheme` al renderizar el SVG como imagen incrustado).

```xml
<style>
  :root {
    --paper: #ffffff;
    --ink: #1e1e2a;
    --muted: #6b7280;
    --border: #d8dce3;
    --accent: #d9603b;
    --surface: #f5f6f8;
  }
  @media (prefers-color-scheme: dark) {
    :root {
      --paper: #14151c;
      --ink: #e8e9ee;
      --muted: #9aa0ac;
      --border: #33364a;
      --accent: #f0885a;
      --surface: #1c1e29;
    }
  }
  text { fill: var(--ink); font-family: system-ui, -apple-system, sans-serif; }
  .mono { font-family: 'SFMono-Regular', Menlo, monospace; }
  .muted { fill: var(--muted); }
  .node { fill: var(--surface); stroke: var(--border); stroke-width: 1.5; }
  .node-accent { fill: var(--surface); stroke: var(--accent); stroke-width: 1.5; }
  .edge { stroke: var(--muted); stroke-width: 1.5; fill: none; }
  .boundary { fill: none; stroke: var(--border); stroke-width: 1; stroke-dasharray: 4,4; }
</style>
```

Reservar `--accent` para 1-2 nodos como máximo (clase `.node-accent`). El resto usa `.node`.

### Conectores y flechas

Definir el marcador una sola vez y reutilizarlo:

```xml
<defs>
  <marker id="arrow" viewBox="0 0 8 8" refX="7" refY="4" markerWidth="8" markerHeight="8" orient="auto-start-reverse">
    <path d="M0,0 L8,4 L0,8 z" fill="var(--muted)"/>
  </marker>
</defs>
```

Aplicar con `marker-end="url(#arrow)"` en cada `<path>`/`<line>` de clase `.edge`.

**Orden de dibujo (z-order):** fondo/grid → conectores → contenedores/boundaries → nodos → texto. Así los nodos tapan el nacimiento de las flechas y el texto siempre queda encima.

Las líneas de conexión son rectas u ortogonales; evitar curvas Bézier decorativas salvo que el tipo de diagrama lo pida explícitamente (ej. loop/flywheel).

### Plantilla base

Punto de partida para cualquier diagrama nuevo. Ajustar `viewBox`, nodos y conectores al contenido real.

```xml
<svg viewBox="0 0 800 480" xmlns="http://www.w3.org/2000/svg">
  <style>
    :root {
      --paper: #ffffff; --ink: #1e1e2a; --muted: #6b7280;
      --border: #d8dce3; --accent: #d9603b; --surface: #f5f6f8;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --paper: #14151c; --ink: #e8e9ee; --muted: #9aa0ac;
        --border: #33364a; --accent: #f0885a; --surface: #1c1e29;
      }
    }
    text { fill: var(--ink); font-family: system-ui, sans-serif; }
    .mono { font-family: Menlo, monospace; }
    .muted { fill: var(--muted); }
    .node { fill: var(--surface); stroke: var(--border); stroke-width: 1.5; }
    .node-accent { fill: var(--surface); stroke: var(--accent); stroke-width: 1.5; }
    .edge { stroke: var(--muted); stroke-width: 1.5; fill: none; }
    .boundary { fill: none; stroke: var(--border); stroke-width: 1; stroke-dasharray: 4,4; }
  </style>
  <defs>
    <marker id="arrow" viewBox="0 0 8 8" refX="7" refY="4" markerWidth="8" markerHeight="8" orient="auto-start-reverse">
      <path d="M0,0 L8,4 L0,8 z" fill="var(--muted)"/>
    </marker>
  </defs>
  <rect width="800" height="480" fill="var(--paper)"/>

  <!-- conectores primero -->
  <path class="edge" d="M 160,80 L 160,140" marker-end="url(#arrow)"/>

  <!-- nodos despues -->
  <rect class="node" x="80" y="40" width="160" height="40" rx="8"/>
  <text x="160" y="64" text-anchor="middle" font-size="13" font-weight="600">Nodo A</text>

  <rect class="node-accent" x="80" y="140" width="160" height="40" rx="8"/>
  <text x="160" y="164" text-anchor="middle" font-size="13" font-weight="600">Nodo destacado</text>
</svg>
```

### Checklist antes de entregar

- [ ] Todas las coordenadas son múltiplos de 4
- [ ] Máximo 1-2 elementos con `--accent`
- [ ] Sin `filter`, sin `drop-shadow`, sin degradados
- [ ] `viewBox` ajustado al contenido + 40px de padding
- [ ] Conectores con `fill="none"` y marcador reutilizado
- [ ] Bloque `<style>` con `prefers-color-scheme` presente
- [ ] Leyenda (si existe) al menos 20px por debajo del elemento más bajo

---

## Constraints

- Nunca generar sintaxis Mermaid ni delegar el layout a un motor automático: todas las coordenadas se calculan y se escriben explícitamente.
- Ningún elemento usa sombra (`filter`/`drop-shadow`) ni degradado decorativo.
- Toda coordenada, ancho, alto y separación debe ser múltiplo de 4.
- Máximo 1-2 elementos con el color de acento; el resto en tokens neutros.
- El radio de esquina (`rx`) nunca supera 10-12px, salvo contenedores exteriores grandes (16-20px).
- Los conectores llevan `fill="none"`; el marcador de flecha se define una sola vez en `<defs>` y se reutiliza en todos.
- El SVG debe verse correctamente en tema claro y oscuro sin regenerar el fichero (variables CSS + `prefers-color-scheme`, ver sección **Design Tokens**).
- No escribir el fichero `.svg` antes de completar el boceto en texto (paso 4) y la ronda de preguntas (paso 5).
- Un solo diagrama por invocación; si el usuario pide varios, priorizar el primero y sugerir invocar `/svg-diagram` de nuevo para los demás.
- Si no se indica ruta de guardado, preguntarla explícitamente antes de escribir el fichero (no crear ficheros sin ubicación acordada).
