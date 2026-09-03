# SPEC-000 — Charter

| | |
| --- | --- |
| **Jira** | [MXCE-1025](https://nubank.atlassian.net/browse/MXCE-1025) · epic [MXCE-1260](https://nubank.atlassian.net/browse/MXCE-1260) |
| **Estado** | Draft for review |
| **Última actualización** | 2026-09-02 |
| **Dueño** | Emiliano Mendoza (AE) |
| **Aprobación de negocio** | Maria Jose Salinas |
| **Aprobación técnica** | Eduardo Jurado |

> Este charter fija **solo decisiones caras de revertir**. El detalle fino vive en el mini-spec de cada slice.
> Se enmienda; no se reescribe. Ver [`CONTRIBUTING.md`](../CONTRIBUTING.md) regla 2.

---

## 1. Problema

El governance de comunicaciones no recurrentes de Nu MX es hoy **completamente manual y sin sistema que
conecte solicitud → aprobación → monitoreo**. Cuatro fallas concretas:

| # | Falla | Consecuencia |
| --- | --- | --- |
| P1 | Intake en texto libre, convertido a ticket a mano | Nombres de squad inconsistentes, fechas ambiguas por canal |
| P2 | Sync de calendario frágil (Sheet → Apps Script → Calendar) | Publicación parcial y propensa a error |
| P3 | Aprobaciones por Slack y juntas | Cero registro estructurado de quién aprobó qué y cuándo |
| P4 | Sin llave de join ticket ↔ monitoreo | Imposible atribuir performance al equipo solicitante |

Detalle y evidencia en [`DISCOVERY-MXCE-1025.md`](./DISCOVERY-MXCE-1025.md) §2.

---

## 2. Objetivos

| ID | Objetivo | Métrica de éxito |
| --- | --- | --- |
| **O1** | Cerrar el gap de trazabilidad ticket ↔ monitoreo | % de comms aprobadas cuyo `template_name` hace match en `communications_monitoring` · baseline `TBD` (ver [SPEC-001](./SPEC-001-template-name-traceability.md)) |
| **O2** | Intake estructurado | 0 campos libres en squad, canal y fechas; fecha inicio/fin **por canal** |
| **O3** | Aprobación auditable | 100% de decisiones con autor + timestamp en Jira; 0 aprobaciones que vivan solo en Slack |
| **O4** | Calendario confiable | Publicación automática al aprobar; 0 copiado manual al Sheet |
| **O5** | Reducir carga manual de Majo | Solicitudes que llegan a revisión manual / total — baja conforme maduran los guardrails |
| **O6** | Visibilidad para squads | Dashboard self-service filtrable por canal, fecha y template |

## 3. No-objetivos

Explícitos, para evitar deriva de alcance:

- **Rediseñar el pipeline de Itaipu** ni los datasets upstream
  (`nu-mx/dataset/{email,push,announcement}-communications`).
- **Comms recurrentes / journey-based** — ya cubiertas por `JourneyMomentCommunicationsMonitoring`.
- **Comms no aplicables** al governance (fuera del alcance del proceso de Majo): transaccionales,
  seguridad y requerimientos regulatorios, onboarding de 30 días, customer delight / brand experience.
- **Elegir hoy el tooling definitivo** de calendario y dashboard.
- **Sustituir el juicio de Majo** — el sistema refleja su decisión, no la reemplaza.
- **Optimizar el cálculo de overlap** — spike aparte, [ADR-0001](../adr/0001-overlap-population-approach.md).

---

## 4. Decisiones cerradas

Acordadas en el kickoff (2026-08-27) y la sesión de seguimiento (2026-08-28). Revertir cualquiera de estas
es caro: requiere enmienda a este charter con aprobación de ambos gates.

| ID | Decisión | Fecha |
| --- | --- | --- |
| **D1** | **Canal de intake:** un Slack workflow crea el ticket de Jira automáticamente, preservando la identidad de quien solicita | 2026-08-27 |
| **D2** | **Entrega por etapas:** primero un flujo end-to-end funcional; los guardrails y validaciones se endurecen después, contra datos reales del sistema | 2026-08-27 |
| **D3** | **Autoridad de aprobación:** Majo es la única persona que aprueba. El sistema sincroniza la decisión a Jira | 2026-08-27 |
| **D4** | **Aprobación con branching:** el engine auto-aprueba lo que pasa todas las reglas; solo enruta a revisión manual lo que tiene overlap o violación. Majo mantiene la propiedad de las reglas y responde por las excepciones | 2026-08-28 |
| **D5** | **Prioridad de monitoreo:** email, push y announcement primero (los 3 instrumentados); un cuarto canal se evalúa después | 2026-08-27 |
| **D6** | **Overlap como problema separado:** no bloquea el flujo principal | 2026-08-28 |
| **D7** | **Fuente de verdad de specs:** este repo Git. Drive no es una copia: aloja material de negocio escrito a mano para stakeholders, en lenguaje de proceso | 2026-08-31 |
| **D8** | **Primer slice:** trazabilidad vía `template_name`, no intake — no depende de terceros y desbloquea el dashboard | 2026-08-31 |
| **D9** | **Alcance de canales del validation engine:** los 12 ítems del form v2, no solo los 3 instrumentados (ver §5) | 2026-08-31 |

---

## 5. Alcance de canales, y su asimetría

**D9** establece que el validation engine gobierna todos los canales del formulario:

| Grupo | Ítems | # |
| --- | --- | :--: |
| In-App | Announcement · Now Dashboard\* · Highlight (Credit Card)\* · Highlight (Cuenta)\* · Discover More\* · Pop up | 6 |
| Direct | Push notification · Email · WhatsApp† · SMS† | 4 |
| App 1ª capa | Experiment proposal\* · Experiment roll out\* | 2 |
| **Total** | — | **12** |

\* requiere aprobación adicional en `#homepage-support` · † requiere presupuesto aprobado

**Pero `communications_monitoring` solo instrumenta 3** (Announcement, Push, Email). El desglose exacto:

```text
12 ítems bajo governance
  ├─ 3 instrumentados ............ Announcement · Push · Email
  ├─ 7 canales sin instrumentar .. Now Dashboard · Highlight (CC) · Highlight (Cuenta) ·
  │                                Discover More · Pop up · WhatsApp · SMS
  └─ 2 ítems de 1ª capa de app ... Experiment proposal · Experiment roll out
                                   ⬜ su clasificación como "canal" está abierta — ver D9
```

> ⚠️ **Consecuencia aceptada explícitamente:** **7 canales** quedan **gobernados pero no medibles**. Los
> guardrails aplican a los 12 ítems; el join a monitoreo y el dashboard (O1, O6) solo cubren los 3
> instrumentados. Registrado en [ADR-0002](../adr/0002-channel-scope-vs-instrumentation.md). Los criterios
> de aceptación de O1 se acotan a esos 3; el resto se marca *governed, unmeasured*.

⬜ **Pregunta abierta de `D9`, para la sesión del 2026-09-03:** *Experiment proposal* y *Experiment roll out*
son modificaciones de la 1ª capa de la app, no envíos de comunicación. Pasan por el mismo flujo de
aprobación, pero contarlos como "canales" es lo que hacía que este alcance se citara unas veces como 10 y
otras como 12. La respuesta la da Majo; hasta entonces se cuentan aparte.

---

## 6. RACI

Del proceso vigente (*Mexico Comms Governance Process Sept 2025*), sin cambios respecto al as-is:

| | Quién | Qué |
| --- | --- | --- |
| **R**esponsible | Equipo dueño de la comunicación (requester) | Definir mensaje y canales, ejecutar la comm (Purple Hub, template, población), seguir el proceso de aprobación |
| **A**ccountable | Requester + Maria Jose Salinas | Decisión final de aprobación y sus excepciones |
| **C**onsulted | Legal · Compliance | Implicaciones legales cuando aplique |
| **I**nformed | Core XP · Ops · PR (si aplica) | Preparar atención a cliente ante escenarios reactivos |

---

## 7. Arquitectura to-be

```text
Requester → Slack Workflow (intake estructurado) → Jira Ticket (auto-creado)
   → Guardrails / Validation Engine
       ├─ pasa todas las reglas, sin overlap  → Auto-aprobado
       └─ overlap o violación de regla        → Revisión manual de Majo (aprueba/rechaza)
   → Reflejar estado en Jira
   → si Aprobado → Calendario público
   → (post-send) join a communications_monitoring → Dashboard de performance
```

Diagramas: [`as-is.mmd`](../diagrams/as-is.mmd) · [`to-be.mmd`](../diagrams/to-be.mmd).

**Invariante de arquitectura:** `communications_monitoring` es **append-only y se escribe únicamente cuando
los canales envían de verdad**. Ningún cambio de estado de ticket o de solicitud escribe ahí. Por eso todo
join es necesariamente **post-send**.

---

## 8. Enmiendas

| Fecha | Cambio | Quién |
| --- | --- | --- |
| 2026-09-02 | Perfilado de `communications_monitoring` ([`sql/`](../sql/)): se retiran los riesgos `R10` y `S1-R3`/`S1-R6`, y el blocker de `communication_type`. Se abre **`R11`** — la llave de join es el par `(template_name, communication_type)`, no la columna sola | Emiliano Mendoza |
