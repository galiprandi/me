# ADR.md

## ADR-001: Selector de idioma unificado en el nav del blog
- Fecha: 2026-05-20
- Estado: Accepted

### Contexto
El selector de idioma del blog tenía dos problemas:
1. En artículos individuales, el cambio de idioma redirigía al índice del blog en lugar de mantener el artículo actual
2. El selector no aparecía en el índice del blog, solo en los artículos
3. Había duplicidad: el selector aparecía tanto en el nav como en el main de los artículos

Esto creaba una experiencia de usuario inconsistente y confusa.

### Decisión
Ubicar el selector de idioma únicamente en el nav del BlogLayout, después del botón TL;DR, en todas las páginas del blog (índice y artículos). El componente LangSwitch maneja ambos casos:
- Con `slug` y `otherLang`: navega al mismo artículo en el otro idioma (`/me/blog/{slug}/{otherLang}`)
- Sin `slug`/`otherLang`: navega al índice del blog en el otro idioma (`/me/blog/{lang}`)

### Consecuencias
- (+) Experiencia de usuario consistente: el selector siempre está en la misma posición
- (+) El cambio de idioma mantiene el contexto (artículo o índice) según corresponda
- (+) Elimina duplicidad de componentes
- (+) Código más limpio: BlogLayout maneja la ubicación, LangSwitch solo la lógica de navegación
- (−) Requiere pasar `slug` y `otherLang` como props opcionales al BlogLayout desde las páginas de artículos
