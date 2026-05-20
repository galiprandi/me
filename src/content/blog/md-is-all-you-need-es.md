---
title: "MD Is All You Need"
description: "Explorando la transformación de la documentación técnica en la era de la IA: de manuales pasivos a contexto dinámico y estructurado para agentes autónomos."
pubDate: 2026-05-20T00:00:00-03:00
tags: ["AI", "Documentation", "Agents", "Engineering", "MD"]
lang: es
postSlug: md-is-all-you-need
---

En la era del desarrollo aumentado por Inteligencia Artificial, el software se escribe a una velocidad sin precedentes. Un equipo de ingenieros asistido por agentes autónomos puede generar hoy en una sola jornada laboral el mismo volumen de código que antes requería un mes de desarrollo manual. Esta aceleración exponencial ha expuesto la mayor línea de falla en la ingeniería de software moderna: **la documentación estática**.

> "La documentación suele ser ese lugar en el que las mentiras se acomodan, crecen y serán eventualmente promovidas a dogmas."

Cuando el código muta continuamente a través de pipelines automatizados, la documentación tradicional escrita a mano se convierte en ficción a las pocas horas de su creación. Si un agente autónomo intenta resolver un ticket basándose en especificaciones obsoletas, el sistema colapsa debido a alucinaciones o interpretaciones erróneas del comportamiento real del software.

Para que los agentes operen con máxima precisión, la documentación ya no puede concebirse como un manual de lectura pasiva para humanos. Debe transformarse en **variables de contexto dinámicas, estructuradas y de bajo consumo de tokens**, diseñadas específicamente como el mapa de navegación del modelo. La fricción de redactar ha desaparecido gracias a la IA; el desafío actual radica en la orquestación, validación y persistencia de la verdad técnica.

## La Pirámide Documental

Para resolver el problema de la consistencia a escala, la documentación de una organización orientada a agentes debe estructurarse en una arquitectura de tres capas bien definidas. Cada capa posee un propósito, un nivel de abstracción y un método de validación automatizado diferenciado.

```
       [ Capa 2: Corporativa ]      --> KMS, IDPs, Wikis (Procesos de Negocio)
      [ Capa 1: El Repositorio ]    --> Los 5 Fantásticos (Contexto Indexable)
     [ Capa 0: Comportamiento ]     --> Asserts y Tests (La Verdad Ejecutable)

```

### Capa 0: Comportamiento Duro (La Verdad Ejecutable)

La base de la pirámide está compuesta por las aserciones de los tests unitarios, de integración y *end-to-end* (E2E). Es la única documentación viva que no puede mentir: si el código cambia y contradice al test, la suite falla y el pipeline de integración continua (CI) se detiene. Representa la especificación técnica en su nivel más puro y determinista.

### Capa 1: El Repositorio (El Contexto Indexable)

Ubicada en la raíz de cada proyecto, esta capa está compuesta por **Los 5 Fantásticos**. Actúa como el manifiesto local del repositorio y opera de forma homóloga a un *Model Context Protocol* (MCP) local: expone información estructurada y jerárquica que el agente consume antes de ejecutar. A diferencia de las *skills*, que son unidades de capacidad y ejecución (como el `context-organizer` que procesa estos archivos), la Capa 1 es el propio contexto indexable. Su función es sintetizar el código de la Capa 0 en archivos `.md` estructurados jerárquicamente. Es el mapa de navegación optimizado que el agente consulta antes de examinar la lógica interna del sistema.

### Capa 2: Corporativa (Procesos Transversales)

La cima de la pirámide alberga los sistemas de gestión del conocimiento (KMS), portales internos de desarrollo (IDP) y wikis institucionales. Documenta procesos de negocio transversales, arquitecturas empresariales distribuidas, políticas de seguridad y metodologías de despliegue global. Se alimenta de forma asíncrona mediante pipelines de los datos consolidados en la Capa 1.

## El Principio del Boy Scout para Agentes Autónomos

La metodología de consistencia documental se rige por una regla absoluta e inquebrantable impuesta a todo modelo que interactúe con el repositorio: **El Principio del Boy Scout**.

No importa si un agente ha sido invocado para corregir un bug visual, optimizar una consulta de base de datos o añadir un nuevo endpoint; si durante la fase de análisis el modelo detecta un *gap* (brecha de información), una inconsistencia semántica o una contradicción entre los archivos de la Capa 1 y la ejecución real del código, **tiene la obligación imperativa de detenerse, corregir la documentación y cerrar la brecha** antes de proceder con su tarea principal.

Ningún Pull Request puede ser aprobado si el agente introduce código que desalinee el ecosistema de los 5 Fantásticos.

## Los 5 Fantásticos: Arquitectura de la Capa 1

Cada uno de estos cinco archivos debe residir en la raíz del repositorio en formato Markdown (.md), el lenguaje nativo de los LLMs debido a su estructura jerárquica limpia y su alta densidad informativa por token.

### 1. README.md

#### Qué almacena
El mapa de ruta técnico, el propósito del negocio que resuelve el repositorio, el stack tecnológico preciso, las variables de entorno requeridas, los prerrequisitos del sistema y los comandos secuenciales de inicialización y despliegue local.

#### Para qué sirve
Garantizar el *onboarding* inmediato y determinista tanto de desarrolladores humanos como de agentes de software. Permite levantar el entorno de desarrollo simulado o de pruebas sin necesidad de inferir configuraciones.

#### Cómo se estructura y gestiona
 * **Owner:** Desarrollador Humano.
 * **Gatillo de Actualización:** Únicamente en la creación del repositorio o ante cambios estructurales en la infraestructura de desarrollo (ej: actualización de la versión del runtime de Node, migración de motor de base de datos local o adición de dependencias globales del sistema).

```markdown
# [Nombre del Repositorio]

## Propósito del Sistema
Breve descripción del dominio de negocio que resuelve este servicio.

## Stack Tecnológico
* Runtime / Lenguaje: Node.js v20+, TypeScript v5.
* Framework Principal: Fastify.
* Persistencia: PostgreSQL via Prisma ORM.

## Configuración del Entorno
Comandos exactos para replicar las variables de entorno (.env.example).

## Inicialización Local
1. `npm install`
2. `npm run db:migrate`
3. `npm run dev`
```

### 2. AGENTS.md

#### Qué almacena
El manual operativo interno para las Inteligencias Artificiales que manipulan el repositorio. Contiene el inventario de *skills* y herramientas disponibles, las políticas de seguridad en la ejecución de comandos, las restricciones de codificación locales y las **reglas de enrutamiento contextual** que indican explícitamente cuándo y bajo qué criterios se debe consultar y actualizar cada uno de los demás archivos Markdown del repositorio.

#### Para qué sirve
Actúa como el *system prompt* dinámico y acotado del proyecto. Evita que el agente asuma convenciones genéricas de la industria que entren en conflicto con las decisiones específicas de diseño y arquitectura del repositorio.

#### Cómo se estructura y gestiona
 * **Owner:** Co-owned (Humano + context-organizer). El humano define los límites éticos y operativos; el agente optimiza las instrucciones internas de las skills cuando detecta fricciones en la ejecución.
 * **Gatillo de Actualización:** Al añadir o modificar capacidades automáticas, herramientas de análisis de código o flujos de trabajo autónomos en el pipeline.

```markdown
# AGENTS.md - System Instructions

## Matriz de Consulta Documental
* Para entender restricciones de arquitectura antes de codificar: Consultar obligatoriamente `ADR.md`.
* Para asegurar la consistencia estética y reusabilidad de componentes visuales: Consultar y actualizar `DESIGN.md`.
* Para validar el impacto en la lógica de negocio existente: Consultar y sincronizar `BEHAVIOR.md`.

## Restricciones Operativas Locales
1. Prohibido el uso de librerías externas no listadas en package.json sin aprobación previa vía ADR.
2. Todo cambio de lógica debe incluir su respectivo test unitario que valide la regla de negocio.
3. El agente de CI ejecutará el parser de BEHAVIOR.md en cada pre-commit de forma mandatoria.
```

### 3. DESIGN.md

#### Qué almacena
Los lineamientos de diseño de interfaz de usuario (UI) y experiencia de usuario (UX) bajo la especificación estándar de Google Labs para design.md. Almacena los tokens de diseño (paletas cromáticas exactas, escalas tipográficas, espaciados), el catálogo de componentes web reutilizables consolidados en el proyecto, y los patrones para la gestión de estados visuales comunes (pantallas de carga, manejo de errores, listas vacías y criterios de accesibilidad WCAG).

#### Para qué sirve
Prevenir la fragmentación visual y la degradación de la UI. Cuando los agentes autónomos generan vistas o componentes frontend de forma masiva, tienden a inventar estilos ad-hoc si carecen de restricciones; este archivo los obliga a reutilizar la infraestructura de componentes existente y a mantener la consistencia estética de la aplicación.

#### Cómo se estructura y gestiona
 * **Owner:** El Agente de IA, inducido por la skill operativa definida en AGENTS.md.
 * **Gatillo de Actualización:** Autónomo y proactivo. Cada vez que el agente genera o refactoriza interfaces y detecta que un nuevo patrón visual o componente modular se repite y justifica su abstracción, lo documenta de inmediato para asegurar su reutilización futura.

```markdown
# DESIGN.md - UI/UX Specifications (Google Labs Std)

## Tokens de Diseño Centralizados
* Primary Brand Color: `#0055FF` (usar variable CSS `--color-primary`)
* Background Surface: `#FFFFFF` / `#121212` (soporte nativo para Dark Mode)

## Catálogo de Componentes Consolidados
### [Button Component]
* Ubicación: `/src/components/ui/Button.tsx`
* Variantes permitidas: `primary`, `secondary`, `danger`.
* Restricciones: Debe incluir siempre la propiedad `aria-label` si el contenido es un icono.

## Gestión de Estados Globales
Toda vista de datos asíncrona debe implementar el componente `<SkeletonLoader />` durante la fase de fetching, mapeando los errores mediante el Error Boundary global `/src/components/errors/GlobalBoundary.tsx`.
```

### 4. BEHAVIOR.md

#### Qué almacena
La especificación funcional viva y detallada de las reglas de negocio del sistema, redactada en prosa estructurada utilizando lenguaje ubicuo. No describe la implementación técnica del código, sino el **comportamiento real observado y verificado** de la aplicación.

#### Para qué sirve
Optimizar drásticamente la ventana de contexto (*context window*) de los modelos de lenguaje. En lugar de forzar a un agente a leer e indexar miles de líneas de código fuente repartidas en decenas de archivos de testing (llenos de boilerplate, inicializaciones de *mocks*, inyecciones de dependencias y configuraciones de entornos de prueba) para deducir qué hace el sistema, el modelo lee un único archivo resumido que describe con total exactitud el comportamiento actual. Esto reduce el consumo de tokens en órdenes de magnitud y erradica las alucinaciones funcionales.

#### Cómo se estructura y gestiona
 * **Owner:** context-organizer (100% Automatizado e Inédito).
 * **Gatillo de Actualización:** En cada ejecución exitosa de la suite de pruebas automatizadas en los hooks de pre-commit o en el pipeline de CI/CD. Un script propietario extrae la salida estructurada de los bloques describe() e it(), y la IA pule la semántica jerárquicamente. No se permite la edición manual de este archivo.

```markdown
# BEHAVIOR.md - Living Specifications

## Módulo: Autenticación de Usuarios
* DEBE permitir el acceso al sistema cuando el usuario proporciona credenciales válidas y verificadas.
* NO DEBE permitir el acceso y debe retornar un código de error 401 si la contraseña es incorrecta.
* DEBE bloquear temporalmente la cuenta por un periodo de 15 minutos tras registrar 5 intentos fallidos consecutivos.

## Módulo: Procesamiento de Pagos
* DEBE despachar un evento de telemetría de tipo `order.paid` al bus de mensajería SQS inmediatamente después de que la pasarela de pago confirme la transacción de forma exitosa.
* DEBE revertir el stock de inventario reservado de forma atómica si la pasarela rechaza la tarjeta por fondos insuficientes.
```

### 5. ADR.md (Architecture Decision Records)

#### Qué almacena
El registro histórico, cronológico e inmutable de todas las decisiones de arquitectura de software, diseño técnico de datos e infraestructura que se han tomado en el proyecto, siguiendo el formato estándar de la industria (Contexto, Decisión, Consecuencias).

#### Para qué sirve
Preservar el contexto histórico del proyecto. Evita de manera contundente el "bucle de refactorización infinita" donde un agente autónomo, al analizar localmente una pieza de código compleja, propone una reestructuración técnica que el equipo humano ya debatió, probó y descartó meses atrás debido a restricciones operativas globales.

#### Cómo se estructura y gestiona
 * **Owner:** Desarrollador Humano (Tech Lead / Arquitecto de Software).
 * **Gatillo de Actualización:** Cada vez que se toma una decisión técnica irreversible, estructural o de alto impacto para el ecosistema de la aplicación.

```markdown
# ADR-004: Migración a Fastify en Capa de API

## Contexto
El servidor original basado en Express.js presenta problemas de latencia y un consumo de memoria elevado bajo cargas de procesamiento concurrentes que superan las 10,000 peticiones por segundo.

## Decisión
Migrar la capa de enrutamiento y middleware a Fastify debido a su rendimiento nativo optimizado y su esquema de validación JSON por esquema integrado que reduce el parsing manual.

## Consecuencias
* Positivas: Reducción del 40% en el consumo de CPU en entornos de staging y tipado estricto de payloads de entrada/salida.
* Negativas: Requiere reescribir todos los middlewares de autenticación personalizados del ecosistema Express.
```

## El Motor de Automatización: context-organizer

La viabilidad operativa de esta metodología no descansa sobre la buena voluntad del desarrollador humano; se sostiene sobre la capacidad técnica de la skill **`context-organizer`**. Esta pieza de ingeniería es la encargada de cerrar el ciclo de retroalimentación viva dentro del repositorio, actuando bajo el siguiente flujo secuencial y determinista:

```
[Cambio de Código] ➔ [Reescritura Semántica de Tests Ambiguos (AI)] ➔ [Ejecución de Tests] ➔ [Extracción de Salida JSON] ➔ [Compilación Determinista de BEHAVIOR.md]
```

 1. **Extracción de la Verdad Empírica (Fuerza Bruta):** `context-organizer` invoca un script automatizado en el entorno local o en el pipeline de CI/CD que ejecuta la totalidad de la suite de pruebas utilizando un reporter estructurado (por ejemplo, JSON en `.context/test-results.json`). Solo el comportamiento que ha pasado exitosamente las aserciones técnicas es tomado en cuenta.
 2. **Optimización Semántica Proactiva:** Si el script detecta descripciones ambiguas (`it("should work")`, `it("test case 4")`), la skill entra en acción: analiza el assert, deduce la intención real y reescribe la descripción del test con semántica precisa (`should <verbo> <objeto> when <condición>`).
 3. **Compilación Documental Limpia:** Con las descripciones corregidas y la suite en verde, `context-organizer` compila de forma determinista la salida jerárquica y reescribe `BEHAVIOR.md` en la raíz del repositorio.

Este mecanismo asegura que el modelo recurra al código fuente estrictamente cuando requiere implementar un cambio funcional o reparar un fallo, pero **jamás para inferir el comportamiento general del sistema**. La verdad se encuentra indexada y sintetizada de antemano en la Capa 1, lista para el consumo óptimo del contexto de la IA.

### Instalación en tu repositorio

La skill se distribuye como un paquete portable, instalable en cualquier proyecto con un único comando:

```bash
npx skills add https://github.com/galiprandi/skills
```

El instalador detecta los agentes presentes en tu entorno (Cursor, Codex, Cline, GitHub Copilot, Gemini CLI, Warp, OpenCode, entre otros) y copia la skill a la ubicación correspondiente para que esté disponible de inmediato sin configuración adicional.

A partir de ese momento, `context-organizer` queda gobernando los 5 Fantásticos de tu repositorio: crea los archivos faltantes desde sus plantillas, mantiene `BEHAVIOR.md` sincronizado con la suite de tests vía hook de pre-commit, y se asegura de que cualquier agente que toque el código respete el Principio del Boy Scout antes de avanzar con su tarea.

## Cierre: el contexto como producto de ingeniería

La documentación dejó de ser un subproducto de la ingeniería para convertirse en **el primer ciudadano del repositorio**. En un ecosistema donde el código se escribe a velocidad de agente, lo escaso ya no son las líneas escritas, sino el contexto verificable que permite a esos agentes operar sin alucinar. La Pirámide Documental, los 5 Fantásticos y el Principio del Boy Scout son la arquitectura; `context-organizer` es el motor que la sostiene en producción. Instalalo, dejalo trabajar, y comprobá cómo el repositorio empieza a contar su propia verdad.

## Enlaces de Interés y Recursos Relacionados

 * **context-organizer Skill Framework:** [github.com/galiprandi/skills](https://github.com/galiprandi/skills?tab=readme-ov-file#readme) — Skill portable para gestión, curación autónoma de archivos estructurados `.md` y motor de refactor documental continuo. Instalable con `npx skills add`.
 * **Google Labs Code - design.md Standard:** [github.com/google-labs-code/design.md](https://github.com/google-labs-code/design.md) – Especificación oficial de la industria para el almacenamiento y la estructura de decisiones estéticas y de interfaces de usuario en el código fuente.
 * **Architecture Decision Records (ADR) Spec:** [github.com/joelparkerhenderson/architecture-decision-record](https://github.com/joelparkerhenderson/architecture-decision-record) – Plantillas y mejores prácticas para la implementación del formato de decisiones de arquitectura inmutables.
 * **Model Context Protocol (MCP):** [Documentación del protocolo abierto](https://modelcontextprotocol.io/) para la optimización de transferencia de contexto estructurado entre repositorios y modelos de lenguaje de gran tamaño.

> *Nota de Autoría:* El concepto operativo, el flujo de compilación y la lógica de inyección contextual de **BEHAVIOR.md** descritos en este artículo constituyen un desarrollo técnico e intelectual inédito creado específicamente para arquitecturas de software gobernadas por agentes de Inteligencia Artificial.
