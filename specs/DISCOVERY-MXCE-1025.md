# DISCOVERY — MXCE-1025

| | |
| --- | --- |
| **Jira** | [MXCE-1025](https://nubank.atlassian.net/browse/MXCE-1025) — *[AE] Comms governance automation Discovery* (Story) |
| **Epic padre** | [MXCE-1260](https://nubank.atlassian.net/browse/MXCE-1260) — *Comms Governance Optimization* (Backlog) |
| **Proyecto** | MXCE — *[Core MX] Core Experience* |
| **Reporter** | Maria Salinas · **Assignee** Carlos (Emiliano) Mendoza |
| **Estado** | Draft for review · Gate técnico pendiente (Eduardo) |
| **Última actualización** | 2026-09-02 |

Fase read-only: consolida la evidencia que alimenta los specs. No propone implementación.
Inventario completo de fuentes con URLs: [`docs/sources.md`](../docs/sources.md).

---

## 1. Alcance del discovery

Automatizar el flujo de governance de comunicaciones **no recurrentes** en MX:
intake estructurado → validación por guardrails → aprobación (auto o manual) → publicación en calendario →
join con monitoreo de performance.

La entrega se parte en 4 bloques, MVP-first, endureciendo validaciones progresivamente:
**(1)** Slack workflow · **(2)** validation engine · **(3)** calendario · **(4)** link a Databricks/monitoring.

> Estos son los 4 bloques del *Technical Discovery* original. La secuencia de ejecución acordada después son
> **5 slices** —con trazabilidad primero, no intake (decisión **D8**)— en [`PLAN`](./PLAN-MXCE-1025.md) §1.
> Los bloques describen el alcance; los slices, el orden.

---

## 2. As-is: el proceso manual actual

### 2.1 Cadena de pasos

```text
Requester
  │ texto libre, sin estructura
  ▼
Ticket manual en MEXCOMS (Jira Service Management)
  │ copiado a mano
  ▼
Sheet "MEX COMMUNICATIONS CALENDAR 2025"
  │ Apps Script (sync parcial, propenso a error)
  ▼
Google Calendar

Aprobación: Majo, por Slack y juntas — sin registro estructurado

Canales (email / push / announcement) envían de forma independiente
  ▼
etl.mx__dataset.communications_monitoring   ← vía pipeline de Itaipu
  │ desconectado del ticket: la única liga es template_name, laxamente estandarizado
  ▼
(sin dashboard self-service)
```

### 2.2 Proceso vigente documentado

De *Mexico Comms Governance Process Sept 2025* (autoría de Majo, canal `#mex-communications`):

- **Cadencia:** los tickets se revisan y resuelven **cada viernes**; la conclusión se comunica en el thread
  de `#mex-communications`. El propio documento recomienda revisar cada mañana, porque *la mayoría de los
  equipos manda su ticket a última hora y, si no reciben respuesta, envían la comunicación sin autorización
  para cumplir su deadline.* ⚠️ Este es un síntoma directo del dolor que el proyecto ataca.
- **Deadline de intake:** jueves a medianoche, para asignar prioridad y confirmar fechas los viernes.
  Solicitudes fuera de ventana ⇒ ticket de **ESCALATION**.
- **Estados del ticket:** `To Do` (sin revisar) → `In Review` (Core XP revisando, puede pedir aclaraciones
  por Slack) → `Done` (dudas resueltas, fechas confirmadas, el requester puede ejecutar).
- **Regla de reviewers vigente:** si la comm alcanza **<30%** de clientes ⇒ indicar el manager de Content o
  Marketing que la revisó; si alcanza **>30%** ⇒ **dos** managers del squad.

### 2.3 Campos del formulario actual (11)

Squad · MEXCOM Channel · Desired Launch Date · End of comms date · Is Launch date Flexible? ·
Targeted Audience · Reviewers · Total Population · RFC link · Is this legally required? · Priority.

Debilidades reconocidas en el propio doc:

- **Fechas ambiguas por canal.** Announcement, Highlight, Pop up, Now Dashboard y Discover More se
  configuran **por periodo**; push y email tienen **fecha de envío única**. El formulario no distingue, y la
  recomendación actual es *"aclarar la fecha de cada canal con el Reporter en el thread de Slack"*.
- **`Priority` no se usa** para decidir, porque casi todos los equipos marcan high o medium.
- **`Squad` es texto abierto** ⇒ nombres inconsistentes, que rompen cualquier agregación por equipo.

### 2.4 Canales y comms bajo governance

**Canales aplicables — 12 ítems** (enumeración canónica en [`SPEC-000`](./SPEC-000-charter.md) §5):
In-App (Announcement, Now Dashboard\*, Highlight (Credit Card)\*, Highlight (Cuenta)\*, Discover More\*,
Pop up) · Direct (Push, Email, WhatsApp†, SMS†) · Modificaciones de 1ª capa de la app
(Experiment proposal\*, Experiment roll out\*).
\* requiere aprobación en `#homepage-support` · † requiere presupuesto.

**Comms aplicables:** BAU (cambio de contratos, bugs de producto, interrupción de servicio, retrasos en
transferencias, migraciones, repricing) · producto (ofertas por tiempo limitado, go-to-market, research) ·
experimentos (launch, awareness, cross/up-selling, retención).

**Comms NO aplicables:** transaccionales · seguridad y regulatorias · onboarding de 30 días ·
customer journey moment comms · customer delight / brand experience.

### 2.5 Política declarada

> *"Limitar el número de comms que un cliente puede recibir de Nu por día · mejorar la visibilidad de los
> equipos de ops sobre nuestras comms · incrementar el uso de espacios in-app, que tienen el mayor potencial
> de engagement pero están subutilizados."*

El primer punto es exactamente `R-VOL-01`, y **hoy no tiene valor numérico definido**.

---

## 3. To-be

```text
Requester → Slack Workflow (intake estructurado) → Jira Ticket (auto-creado)
   → Guardrails / Validation Engine
       ├─ pasa, sin overlap ni violación → Auto-aprobado
       └─ overlap o violación de regla   → Revisión manual de Majo (aprueba/rechaza)
   → Reflejar estado en Jira
   → si Aprobado → Calendario público
   → (post-send) join a communications_monitoring → Dashboard de performance
```

**Cambio respecto a los borradores previos:** el engine **ramifica**. Majo ya no es un gate obligatorio en
cada solicitud, solo en las que fallan la auto-aprobación. Conserva la propiedad de las reglas que el engine
codifica y responde por las excepciones. El RACI no cambia.

---

## 4. Detalle por bloque

### 4.1 Intake — Slack workflow

Reemplaza el intake manual y sin estructura. Debe auto-crear el ticket de Jira preservando la identidad de
quien solicita.

El **New Form Proposal (Communication Deployment Form v2, 2025)** ya resuelve buena parte de las debilidades
de §2.3. 26 campos; los relevantes para este proyecto:

| # | Campo | Tipo | Req. | Por qué importa |
| --- | --- | --- | --- | --- |
| 1 | Comms Description | Texto abierto | Sí | |
| 2 | Squad | Texto abierto | Sí | ⚠️ **sigue abierto** — no resuelve la inconsistencia de nombres (§2.3) |
| 3 / 7 / 11 | Channel 1 / 2 / 3 | Selección única | Sí / No / No | Máx. 3 canales por ticket; más ⇒ ticket adicional |
| 4-5 / 8-9 / 12-13 | Start Date / End Date **por canal** | Fecha | ↑ | ✅ **resuelve la ambigüedad de fechas** de §2.3 |
| **6 / 10 / 14** | **Template Name por canal** | Texto abierto | ↑ | ✅ **es la llave de join** — ver §5.3 |
| 16 | Total Population | Número | Sí | Insumo de `R-REV-01` y de overlap |
| 17-18 | Type of Population · Product Population | Selección única | No | Insumo de overlap |
| 19 | Is launch date flexible? | Selección única | Sí | Permite negociar fechas ante conflicto |
| 20 | Is this legally required? | Selección única | Sí | Prioriza sobre otras campañas |
| 21-22 | Comms Image · Comms Documentation | Link | Sí | Checks de contenido y branding |
| 23 | Punto del lifecycle (antes/después de los 30 días) | Selección única | Sí | **Determina el routing de approvers** |
| 24-26 | Reviewers de Legal · Content & Design · Ops | Selección múltiple | No | ⚠️ **opcionales** — ver riesgo R4 |

**Routing de approvers, ya determinista en el form v2** (hoja *Workflow*) — se puede codificar tal cual:

| Grupo | Condición | Miembros |
| --- | --- | --- |
| Core Analytics | Algún canal es *In-App Announcement NPS* | Adriano Merlo, Lizeth Larrea, Natali Jaramillo, Rafael Moreno |
| App Experience | Campo 23 ∈ {`After`, `Both`} **y** algún canal ∈ {Now Dashboard, Highlight (CC), Highlight (Cuenta), Discover More} | Ximena Puentes, Benjamin Lascari, Isis Sánchez |
| Growth | Campo 23 ∈ {`Before`, `Both`} **y** el mismo conjunto de canales | Jose Cobix, Sophie Siliceo |

⚠️ **Dependencia externa:** cambiar el formulario de MEXCOMS requiere un ticket en
[Atlassian Support, portal 1880](https://nubank.atlassian.net/servicedesk/customer/portal/1880)
(*Update Existing Workflow*). Lead time fuera de nuestro control ⇒ **bloquea el Slice 2**.

### 4.2 Validation engine — guardrails

Checks antes de que una solicitud pueda auto-aprobarse:

- Duración máxima por canal (`R-DUR-01`, **sin valor**).
- Checks obligatorios de Legal, Compliance, contenido y branding.
- Límites por cliente y por canal (`R-VOL-01`, **sin valor**) + lógica de overlap de poblaciones.

El **overlap es el componente más complejo**, porque la elegibilidad de clientes cambia a diario. Tres
enfoques candidatos, sin resolver — detalle y trade-offs en
[ADR-0001](../adr/0001-overlap-population-approach.md).

**Prior art:** *Campaign Coalition Checker* — app de Streamlit en Databricks que recibía CSVs de customer IDs,
identificaba coincidencias entre campañas y graficaba resultados. **Ya no está activa y nunca llegó a un
repositorio.** Candidata a retomarse como MVP del análisis de overlap.

### 4.3 Calendario

Al aprobar (auto o manual), publicar en el calendario público. El Apps Script existente es candidato a
reusar; la decisión de tooling definitivo está pendiente.

Artefactos vigentes: Sheet *MEX COMMUNICATIONS CALENDAR 2025* (actual) · *MEX COMMS - JIRA IMPORT*
(automatizado) · *Sheet for automated calendar* · un Google Calendar ya compartido por Majo.

### 4.4 Monitoreo — Databricks / Itaipu

**Verificado en código y contra la tabla real.**

`CommunicationsMonitoring` — [`CommunicationsMonitoring.scala`](https://github.com/nubank/itaipu/blob/master/subprojects/data-domains/mexico/src/main/scala/nu/data_domain/mexico/mx/core_experience/datasets/core_xp/communications_monitoring/CommunicationsMonitoring.scala)

| Propiedad | Valor |
| --- | --- |
| `subdomainOpName` | `communications-monitoring` |
| `namespace` | `Namespace.CountryDataset` |
| `country` / `ownerSquad` | `Country.MX` / `Squad.CoreMX` |
| `visibility` / `sharing` | `SparkOpVisibility.Domain` / `DatasetSharing.Private` |
| Tabla | `etl.mx__dataset.communications_monitoring` |

**Inputs (3 datasets upstream):**
`nu-mx/dataset/email-communications` · `nu-mx/dataset/push-communications` ·
`nu-mx/dataset/announcement-communications`

**Descripción declarada:** *"This dataset serves as a way to monitor via metrics, the different communication
templates we have across all campaigns and templates. It consumes email, push, and announcement
communications, to then compute different rates and metrics."*

Los rates se calculan con un helper `safeRate` que devuelve `0.0` cuando el denominador es `0`, redondeando a
4 decimales. ⚠️ **Implicación analítica:** un rate en `0.0` es ambiguo — puede significar "cero eventos" o
"cero enviados". No se puede distinguir sin mirar `total_templates_sent`.

**Consumo verificado:** el notebook *Non-recurrent Monitoring* une la tabla consigo misma por
`(template_name, communication_type, day)` tratándola como única. Es confirmación empírica **independiente**
del grain declarado en §5.1 y de la premisa central de [ADR-0004](../adr/0004-ticket-monitoring-join-key.md):
la PK se sostiene en uso real, no solo en la definición.

**Consumidor downstream:** `JourneyMomentCommunicationsMonitoring` filtra esta misma tabla por
`template_name LIKE '%jm%'` para aislar journey moments. ⚠️ Ese filtro es un **acoplamiento implícito al
naming de `template_name`**: cambiar la convención de nombres puede romperlo. A considerar en
[SPEC-001](./SPEC-001-template-name-traceability.md).

---

## 5. Contrato de datos

### 5.1 Schema verificado

`DESCRIBE TABLE etl.mx__dataset.communications_monitoring` — 21 columnas (ejecutado 2026-08-31):

| Columna | Tipo | PK | Significado |
| --- | --- | :--: | --- |
| `template_name` | `string` | ✅ | Nombre de la campaña o template **como está registrado en la herramienta `communication_handler`** |
| `communication_type` | `string` | ✅ | Tipo de comunicación (canal) |
| `formatted_date` | `date` | ✅ | Día usado para la agregación diaria |
| `total_templates_sent` | `int` | | Número diario de templates o campañas enviadas |
| `min_date_overall` | `date` | | Fecha más temprana del template en toda la historia |
| `max_date_overall` | `date` | | Fecha más tardía del template en toda la historia |
| `population` | `bigint` | | Clientes distintos que recibieron el template en toda la historia |
| `display_rate` / `_total` | `double` | | Announcement mostradas vs. total enviadas (diario / histórico) |
| `open_rate` / `_total` | `double` | | Emails abiertos vs. total enviados |
| `delivery_rate` / `_total` | `double` | | Email y push entregados vs. total enviados |
| `click_rate` / `_total` | `double` | | Email y push con click vs. total enviados |
| `click_primary_rate` / `_total` | `double` | | Click en botón primario de announcement vs. total enviadas |
| `dismiss_rate` / `_total` | `double` | | Push descartadas vs. total enviadas |
| `click_close_rate` / `_total` | `double` | | Click en botón de cierre de announcement vs. total enviadas |

**Grain:** una fila por `(template_name, communication_type, formatted_date)`.

#### Qué métrica aplica a qué canal

Las 14 columnas de rate **no son transversales**. El unpivot del
[notebook *Non-recurrent Monitoring*](../docs/sources.md) revela el mapeo real, más estrecho de lo que
sugieren las descripciones de columna:

| Canal | Métricas aplicables |
| --- | --- |
| `Email` | `delivery_rate` · `open_rate` · `click_rate` |
| `Push` | `delivery_rate` · `click_rate` · `dismiss_rate` |
| `Announcement` | `display_rate` · `click_primary_rate` · `click_close_rate` |

⚠️ **Para una fila dada, la mayoría de las columnas de rate no aplican.** Toda métrica de cobertura
—"% de comms con datos de performance"— debe evaluarse contra las 3 métricas del canal, no contra las 14
columnas: hacerlo contra las 14 daría siempre ~79% de nulos y sería una lectura falsa.

Notas de verificación:

- `population` es `bigint` en la tabla; el dataset derivado lo declara `IntegerType`. Discrepancia menor,
  sin impacto en el join.
- `DESCRIBE TABLE` no expone columna de partición (`ref_date` no aparece en la tabla publicada), a pesar de
  que la convención de Itaipu la usa como partition key.

### 5.2 Invariante

`communications_monitoring` es **append-only y se escribe únicamente cuando los canales envían de verdad**
(email, push, announcement). **Nunca** por cambios de estado de un ticket o solicitud.

⇒ **Todo join ticket ↔ monitoreo es necesariamente post-send.** No existe escritura en tiempo de guardrail.

### 5.3 El gap de trazabilidad, y por qué es más fácil de lo que parecía

La única liga entre un ticket y sus filas de monitoreo es `template_name`, laxamente estandarizado.

**Pero:** la PK de la tabla es `(template_name, communication_type, formatted_date)` **y el form v2 ya pide
`Channel N Template Name` por canal** (campos 6, 10, 14) junto con las fechas por canal (4-5, 8-9, 12-13).

⇒ Los tres componentes de la PK son capturables en el intake:

| Componente de la PK | Campo del form v2 |
| --- | --- |
| `template_name` | Campo 6 / 10 / 14 (Template Name por canal) |
| `communication_type` | Campo 3 / 7 / 11 (Channel) |
| `formatted_date` | Campos 4-5 / 8-9 / 12-13 (Start/End Date por canal) |

**La llave de join no falta en el diseño; falta validarla y normalizarla.** Eso convierte la trazabilidad en
el slice más barato del proyecto, y es la razón de la decisión **D8** del charter.

Sin resolver: el campo es **texto abierto**, así que la normalización (case, espacios, formato) y el mapeo
`Channel` → `communication_type` son trabajo real. Ver [SPEC-001](./SPEC-001-template-name-traceability.md).

---

## 6. Riesgos y dependencias

| ID | Riesgo | Impacto | Mitigación |
| --- | --- | --- | --- |
| R1 | Enfoque de overlap sin decidir | Afecta latencia del guardrail y costo de infra | [ADR-0001](../adr/0001-overlap-population-approach.md); no bloquea el flujo principal (D6) |
| R2 | `R-DUR-01` y `R-VOL-01` sin valor numérico | El engine no puede aplicarlas | [ADR-0003](../adr/0003-guardrail-thresholds-ownership.md); dueña: Majo |
| R3 | Cambiar el form de MEXCOMS depende de Atlassian Support | **Bloquea el Slice 2**, lead time externo | Slice 1 no lo requiere (D8); abrir el ticket en paralelo, temprano |
| R4 | Campos 24-26 (reviewers Legal/Content/Ops) son **opcionales** en el form v2 | Los checks obligatorios de Legal/Compliance no son exigibles con el form tal cual | Escalar a Majo: para hacerlos guardrail duro deben ser requeridos |
| R5 | `Squad` sigue siendo texto abierto en el form v2 | Persiste la inconsistencia de nombres (P1) — rompe agregación por equipo | Proponer campo de selección controlada en el mismo ticket de Atlassian Support de R3 |
| R6 | 7 canales gobernados sin instrumentación | Guardrails no verificables para esos canales | [ADR-0002](../adr/0002-channel-scope-vs-instrumentation.md); asimetría documentada en el charter §5 |
| R7 | `JourneyMomentCommunicationsMonitoring` filtra por `template_name LIKE '%jm%'` | Cambiar la convención de naming puede romper un dataset downstream | Verificar antes de proponer contrato de naming (SPEC-001) |
| R8 | `safeRate` devuelve `0.0` con denominador `0` | Un rate en `0.0` es ambiguo en el dashboard | Mostrar siempre junto a `total_templates_sent` |
| R9 | El notebook excluye templates enviados con engagement cero: `HAVING max(coalesce(metric_value, 0.0)) > 0` | Una comm que se envió y no tuvo resultado **desaparece de la vista sin aviso** — justo la señal que governance necesita ver | No heredar ese filtro en el dashboard; distinguir "sin envíos" de "enviado con cero" vía `total_templates_sent` |
| ~~R10~~ | ~~En el notebook el filtro de usuario es case-insensitive (`upper(...)`) pero el unpivot compara `communication_type = 'Email'` exacto~~ | **Cerrado 2026-09-02** — la columna tiene exactamente 3 valores (`Email`, `Push`, `Announcement`) sin ninguna variante de case, así que la inconsistencia no puede producir discrepancias | Verificado en [`sql/profile_communication_types.sql`](../sql/profile_communication_types.sql). Aun así, fijar un solo criterio de comparación en el dashboard |

**R9 es la contracara de R8.** Ante la ambigüedad del `0.0` de `safeRate`, el notebook resuelve
**descartando** la fila ambigua en lugar de desambiguarla. Para un visor de métricas es defendible; para
governance está al revés — una comm enviada con cero clicks es la fila más importante de la tabla.

## 7. Blockers abiertos

| Blocker | Detalle | Dueño |
| --- | --- | --- |
| **Atlassian Support** | Ticket para *Update Existing Workflow* en MEXCOMS aún no abierto (R3, R4, R5 deberían ir juntos) | Majo / Emiliano |
| **MXCE-1025** | El card no tiene descripción (`description = null`, priority `Low`, status `Backlog`, 0 comentarios, 0 subtasks) | Emiliano |
| **Valores de negocio** | `R-DUR-01` y `R-VOL-01` sin definir | Majo |
| ✅ **`communication_type`** | **Cerrado el 2026-09-02.** El acceso a `databricks-sql` quedó resuelto; la columna tiene 3 valores verificados. [SPEC-001](./SPEC-001-template-name-traceability.md) §4.1 y el riesgo R10 quedan cerrados | Emiliano |

## 8. Preguntas abiertas → ADR

Las 5 preguntas del *Technical Discovery* mapean 1:1 a un ADR. Ninguna queda sin dueño:

| Pregunta | ADR | Dueño de la decisión |
| --- | --- | --- |
| Enfoque de overlap de poblaciones | [ADR-0001](../adr/0001-overlap-population-approach.md) | Eduardo (técnica) |
| Alcance de canales vs. instrumentación | [ADR-0002](../adr/0002-channel-scope-vs-instrumentation.md) | Majo + Eduardo |
| Límite aceptable de comms por cliente y canal | [ADR-0003](../adr/0003-guardrail-thresholds-ownership.md) | Majo |
| ¿Llave mejor que `template_name`, o reconciliación post-send? | [ADR-0004](../adr/0004-ticket-monitoring-join-key.md) | Eduardo |
| Tooling de calendario y dashboard a largo plazo | [ADR-0005](../adr/0005-calendar-dashboard-tooling.md) | Majo + Eduardo |

El *"límite exacto de MVP entre los 4 bloques"* quedó resuelto por **D8** del charter (Slice 1 = trazabilidad).
