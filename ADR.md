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

## ADR-002: Abandonar multi-ruta por rol — CV único en `/`
- Fecha: 2026-07-27
- Estado: Accepted
- Supersedes: decisión implícita en README.md y PRODUCT.md (rutas `/em`, `/tl`, `/ext`)

### Contexto
El README y PRODUCT.md documentaban una arquitectura multi-ruta (`/em`, `/tl`, `/ext`) para "route the recruiter" según el rol para el que contrata. Estas rutas nunca se implementaron. El usuario decidió que no quiere ruteo por rol — mantener un único CV en `/` más `/blog` y `/portfolio`.

### Decisión
Abandonar la arquitectura multi-ruta. El sitio tiene tres superficies:
- `/` — CV único y completo
- `/blog` — blog técnico (es/en)
- `/portfolio` — proyectos y open source

No se crearán `/em`, `/tl`, ni `/ext`. El CV en `/` debe funcionar para cualquier recruiter sin necesidad de elegir un narrative.

### Consecuencias
- (+) Simplicidad: una sola narrative que debe ser fuerte por sí sola
- (+) Menor superficie de código y mantenimiento
- (+) El recruiter no necesita tomar decisiones antes de leer el CV
- (−) El CV debe ser igualmente convincente para roles de EM, TL y otros sin personalización
- (−) Se pierde el diferenciador de "route the recruiter" — requiere re-posicionar el producto
