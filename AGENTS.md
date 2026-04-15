# AGENTS – Reglas pendientes y riesgos

Estas reglas deben considerarse al implementar el CV imprimible:

1) **Fuente concreta**
   - Definir una familia tipográfica explícita (la misma del sitio) para evitar inconsistencias.

2) **Tamaños exactos de headings**
   - Establecer un set fijo (ejemplo): h1 16pt, h2 14pt, body 10.75pt.

3) **Overflow de enlaces en sidebar**
   - Añadir control para enlaces largos: `word-break: break-word;` y `hyphens: auto;`.

4) **Validación multi-navegador de impresión**
   - Probar la salida de impresión en Chrome y Edge (motores distintos) para asegurar consistencia de paginado y cortes.

5) **Operación del servidor de desarrollo**
   - El servidor dev puede estar ya ejecutándose; no iniciarlo manualmente. Si se detiene, solicitar al usuario que lo reinicie.
   - Luego de cada cambio, debes buscar evidencia gráfica navegando a la ruta necesaria para verificar el resultado.

6) **Evidencia gráfica tras cambios**
   - Tras cada ajuste relevante, capturar evidencia visual (screenshot o print preview) de la ruta afectada para validar render e impresión.
