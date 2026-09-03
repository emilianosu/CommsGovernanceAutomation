# Inventario de fuentes

Todas las fuentes que alimentan los specs, con fecha de lectura. Regla 6 de
[`CONTRIBUTING.md`](../CONTRIBUTING.md): toda afirmación técnica en un spec apunta a una de estas.

Última actualización: **2026-09-02**

---

## 1. Jira

| Recurso | URL | Nota |
| --- | --- | --- |
| MXCE-1025 | <https://nubank.atlassian.net/browse/MXCE-1025> | Story *[AE] Comms governance automation Discovery*. ⚠️ Sin descripción (`null`), priority `Low`, status `Backlog`, 0 comentarios, 0 subtasks. Reporter: Maria Salinas · Assignee: Carlos Mendoza · Creado 2026-07-06 |
| MXCE-1260 | <https://nubank.atlassian.net/browse/MXCE-1260> | Epic padre *Comms Governance Optimization* (Backlog) |
| Board MXCE | <https://nubank.atlassian.net/jira/software/c/projects/MXCE/boards/30448> | Proyecto *[Core MX] Core Experience* |
| MEXCOMS | <https://nubank.atlassian.net/jira/servicedesk/projects/MEXCOMS/queues/custom/9010> | Service desk del intake actual. Estados: `To Do` → `In Review` → `Done` |
| Atlassian Support | <https://nubank.atlassian.net/servicedesk/customer/portal/1880> | Portal para *Update Existing Workflow* — **dependencia del Slice 2** |

## 2. Confluence

| Recurso | URL | Nota |
| --- | --- | --- |
| Spec-driven Development | <https://nubank.atlassian.net/wiki/spaces/CCFIN/pages/264998552244/Spec-driven+Development> | Metodología base. ⚠️ El plugin `spec-driven-dev` está hecho para microservicios Clojure con Diplomat — ver [`CONTRIBUTING.md`](../CONTRIBUTING.md) §"Por qué adaptado" |

## 3. Google Drive

**Carpeta del proyecto:** <https://drive.google.com/drive/folders/1CnWSNFK4i-Dkkk-rGu-wrKdyyGU8g2yw>

### Material de negocio en Drive

Tres documentos vivos, escritos **a mano para stakeholders** — no se derivan de los specs ni se generan con
un script. Están en lenguaje de proceso, sin jerga técnica, y su audiencia es Majo. Creados el
**2026-09-02**; los mantiene Emiliano.

| Documento | Para qué se abre |
| --- | --- |
| [Comms Governance — qué estamos construyendo y por qué](https://docs.google.com/document/d/1Gvh4pypg2KA6yrFF3fnriTEE_glhs06D8p7ZLm46Ukk/edit) | Contexto. Se manda antes de una sesión o se usa para explicar el proyecto a alguien nuevo |
| [Cómo cambia el proceso: hoy → mañana](https://docs.google.com/document/d/1VCrY2zg_ijye1X0zR_MX8_EiDIaa71XFCe89aB4XX1s/edit) | Se proyecta en pantalla. El recorrido de una solicitud, paso a paso |
| [Decisiones y acuerdos](https://docs.google.com/document/d/1Ny3G8DxTSfOxW5bETTQcsH1rEHySFJRbnh6KHwKq9Ho/edit) | Se abre *en* la reunión. Arriba lo que falta decidir; abajo la bitácora de lo acordado |

> **La relación con el repo es de traducción, no de copia** (decisión **D7** del charter). El repo es la
> fuente de verdad técnica; estos docs cuentan lo mismo en lenguaje de negocio y omiten a propósito reglas,
> rutas y nombres de dataset. Cuando una decisión se cierra, se registra en su ADR **y** en la bitácora del
> doc de decisiones. Majo puede comentar y editar: para eso están en Drive.
>
> Un intento anterior — cinco docs generados por script que transcribían los specs — se descartó el
> **2026-09-02**: era documentación de ingeniería con otro formato, inútil para la audiencia real.
> Sus URLs dejaron de servir.
>
> Los docs archivados el 2026-09-02 (*Spec v0*, *Technical Discovery (MXCE-1025)*, `discovery-doc.md` y las
> dos copias de *Spec v0*) citaban un `comms-governance-automation-context.md` "en la carpeta del proyecto"
> como fuente de verdad. **Ese archivo nunca existió** — ni en Drive ni en local. Este repo lo reemplaza.

### Documentos de proceso (de Majo)

| Documento | URL | Aporta |
| --- | --- | --- |
| Mexico Comms Governance Process Sept 2025 | <https://docs.google.com/document/d/15E1BrBs0e7gkUY-1oWse4IhMCJNa2CK7IY0RKyvlLoc> | Proceso vigente, canales aplicables, RACI, política, `R-REV-01`, cadencia semanal |
| Mex-Communication New form proposal | <https://docs.google.com/spreadsheets/d/16iSMFrYSXC16TZShZltYah1VsUp0yDYcq-MIJtcOjLE> | **Form v2, 26 campos.** Origen de `R-APR-01/02/03` y `R-CAD-01`; campos 6/10/14 = la join key |
| [Core XP] Communications governance (deck) | <https://docs.google.com/presentation/d/1O1rQUmFq9ZDord9LPgeytncbHWkwJ3NasLVO6940RH0> | Arquitectura de canales, slides 7-9 |
| MEX COMMUNICATIONS CALENDAR 2025 | <https://docs.google.com/spreadsheets/d/1tnf251e1JT3ufYsWFJYU4SPoJ31XhUb0nZ8Qz4c-lfA> | Calendario manual actual |
| MEX COMMS - JIRA IMPORT | <https://docs.google.com/spreadsheets/d/1ynfs5i6dM9TlbeN8RfBS_iT_zHij2dfhhZ-luyhIQNY> | Calendario automatizado |
| Sheet for automated calendar | <https://docs.google.com/spreadsheets/d/1a17bS847NTpm7yLgMT_y9VMNUL53csywTrNXvOi5d3k> | Insumo del Apps Script |
| BAU comms governance | <https://docs.google.com/document/d/1-qhXmJqgFkB52xtUPPOfHsll0s1wBRihWtnXBC45n3g> | Fuente del RACI |
| WIP - Building the foundations | <https://docs.google.com/document/d/1h99HgDt54l1OdSP8FMX3WW7yQgZnCM8pvguNrKyW6JA> | Visión de largo plazo |

## 4. Código (`nubank/itaipu`)

| Archivo | Aporta |
| --- | --- |
| [`CommunicationsMonitoring.scala`](https://github.com/nubank/itaipu/blob/master/subprojects/data-domains/mexico/src/main/scala/nu/data_domain/mexico/mx/core_experience/datasets/core_xp/communications_monitoring/CommunicationsMonitoring.scala) | `SubdomainOp` de la tabla. Owner `Squad.CoreMX`, `Country.MX`, visibility `Domain`, sharing `Private`. 3 inputs. Helper `safeRate` (denominador `0` ⇒ `0.0`) |
| [`JourneyMomentCommunicationsMonitoring.scala`](https://github.com/nubank/itaipu/blob/master/subprojects/data-domains/mexico/src/main/scala/nu/data_domain/mexico/mx/core_experience/datasets/purple_loop/journey_moment_monitoring/JourneyMomentCommunicationsMonitoring.scala) | Consumidor downstream: filtra `template_name LIKE '%jm%'`. ⚠️ Origen de la restricción `R-TPL-05` |

## 5. Databricks

| Recurso | Nota |
| --- | --- |
| `etl.mx__dataset.communications_monitoring` | **21 columnas**, verificado vía `DESCRIBE TABLE` el 2026-08-31. Schema en [`DISCOVERY`](../specs/DISCOVERY-MXCE-1025.md) §5.1 |
| [Notebook *Non-recurrent Monitoring*](https://nubank-e2-general.cloud.databricks.com/editor/notebooks/2219645164459186) (`2219645164459186`, VPN) | Leído 2026-09-01. Notebook parametrizado por widgets (`from_date`, `to_date`, `your_templates`, `your_comm_types`) que pivotea la tabla a matriz **template × métrica × día**, con métricas seleccionadas según el canal. Soporte: `@eduardoahumada`. Aporta la matriz métrica↔canal ([`DISCOVERY`](../specs/DISCOVERY-MXCE-1025.md) §5.1), confirma el grain, y origina los riesgos **R9** y **R10** |
| [Metadata en Free Willy](https://backoffice.nubank.com.br/free-willy/datasets/nu-mx/dataset/communications-monitoring/?section=columns) | El schema declarado devolvió vacío por MCP; se usó `DESCRIBE TABLE` como fuente autoritativa |

## 6. Slack

| Recurso | Aporta |
| --- | --- |
| Group DM del proyecto (`C0BPVBE5PCJ`) | Kickoff 2026-08-12: Majo comparte toda la documentación base y los next steps |
| [DM Eduardo — flujo de 5 pasos](https://nubank.enterprise.slack.com/archives/D0B7LRFRLJF/p1787872371758739) (2026-08-27) | El planteamiento original del proyecto en 5 pasos + "hacer un diagrama high level" |
| DM Eduardo (`D0B7LRFRLJF`) | Asignación de MXCE-1025, link a SDD, board de Jira, acuerdo de working session del jueves |
| `#mex-communications` | Canal del proceso vigente |
| `#homepage-support` | Aprobación adicional para canales de 1ª capa |

## 7. Transcripciones de reuniones (Glean)

| Fecha | Sesión | Decisiones que aporta |
| --- | --- | --- |
| 2026-08-25 | [a8fb1198…](https://app.glean.com/chat/a8fb1198a8a2419bbfb365362b1eb3aa) | Contexto inicial · **Campaign Coalition Checker** como prior art de overlap · idea del dashboard comunitario |
| 2026-08-27 | [ba92d55d…](https://app.glean.com/chat/ba92d55decc445cf96b9aa8a4e0779b1) | Kickoff. Decisiones **D1, D2, D3, D5** · guardrails · 3 enfoques de overlap |
| 2026-08-28 | [d569207f…](https://app.glean.com/chat/d569207f1c8a4fb09668d25e6dd96606) | Decisiones **D4, D6** · enfoque de overlap por fechas primero · diagramas como código |

## 8. Blockers abiertos

| Blocker | Detalle | Dueño |
| --- | --- | --- |
| ⬜ Atlassian Support | Ticket de *Update Existing Workflow* sin abrir (R3 + R4 + R5 deberían ir juntos) | Majo / Emiliano |
| ⬜ MXCE-1025 | Sin descripción ni criterios de aceptación | Emiliano |
| ⬜ Valores de negocio | `R-DUR-01`, `R-VOL-01`, `R-OVL-01` sin definir | Majo |
| ⬜ Jira → Databricks | Cómo se expone la data de Jira hacia Databricks, sin definir | Eduardo |
| ⬜ `communication_type` | Valores reales sin verificar — el MCP `databricks-sql` requiere autenticación | Emiliano |
