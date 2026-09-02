# Comms Governance Automation (MX)

Automatización del governance de comunicaciones **no recurrentes** de Nu México:
intake estructurado → validación por guardrails → aprobación → publicación en calendario → monitoreo de performance.

- **Jira:** [MXCE-1025](https://nubank.atlassian.net/browse/MXCE-1025) (Story) · epic padre [MXCE-1260](https://nubank.atlassian.net/browse/MXCE-1260) *Comms Governance Optimization*
- **Board:** [MXCE / 30448](https://nubank.atlassian.net/jira/software/c/projects/MXCE/boards/30448)
- **Slack:** `#mex-communications` (proceso) · group DM del proyecto (Emiliano / Eduardo / Majo)
- **Drive (espejo para stakeholders):** [carpeta del proyecto](https://drive.google.com/drive/folders/1CnWSNFK4i-Dkkk-rGu-wrKdyyGU8g2yw)

## Equipo

| Persona | Rol | Gate |
| --- | --- | --- |
| Maria Jose Salinas (Majo) | Stakeholder principal · única persona que aprueba comms | Gate de negocio |
| Eduardo Jurado (Lalo) | Engineer de apoyo | Gate técnico |
| Emiliano Mendoza | Analytics Engineer (intern) · lleva el proyecto | — |

## Cómo se trabaja

Este proyecto sigue **Spec-Driven Development adaptado**: ningún PR sin un spec mergeado antes.
El loop, los gates y sus dueños están en [`CONTRIBUTING.md`](./CONTRIBUTING.md).

**La fuente de verdad de los specs es este repo.** Los Google Docs de la carpeta de Drive son una *vista*
para stakeholders; el mapeo doc ↔ spec está en [`docs/sources.md`](./docs/sources.md).

## Estructura

```text
specs/    SPEC-000 charter · DISCOVERY · PLAN · un SPEC-00N por slice · plantilla
adr/      Decisiones abiertas con opciones y trade-offs
diagrams/ Mermaid (.mmd) — as-is y to-be
sql/      Queries de reconciliación y baseline
docs/     Inventario de fuentes y blockers · material de sesiones
```

## Por dónde empezar

1. [`specs/SPEC-000-charter.md`](./specs/SPEC-000-charter.md) — objetivos, no-objetivos, decisiones cerradas, RACI.
2. [`specs/DISCOVERY-MXCE-1025.md`](./specs/DISCOVERY-MXCE-1025.md) — as-is, to-be, contrato de datos, blockers.
3. [`specs/PLAN-MXCE-1025.md`](./specs/PLAN-MXCE-1025.md) — secuencia de slices y milestones.
4. [`specs/SPEC-001-template-name-traceability.md`](./specs/SPEC-001-template-name-traceability.md) — el slice en curso.
5. [`adr/`](./adr/) — las 5 decisiones abiertas, con sus opciones y trade-offs. Es el insumo principal de la
   working session; [`docs/working-session-2026-09-03.md`](./docs/working-session-2026-09-03.md) las resume
   en formato decidible.

## Estado

| Slice | Estado |
| --- | --- |
| 1 — Trazabilidad (`template_name` como join key) | 📝 Spec en revisión |
| 2 — Intake (Slack Workflow → Jira MEXCOMS) | ⏸ No iniciado |
| 3 — Validation engine / guardrails | ⏸ No iniciado |
| 4 — Publicación en calendario | ⏸ No iniciado |
| 5 — Dashboard de performance | 🔍 Prior art identificado — [ADR-0005](./adr/0005-calendar-dashboard-tooling.md) |
| — Overlap de poblaciones (spike) | 🔬 [ADR-0001](./adr/0001-overlap-population-approach.md) en `Proposed` |
