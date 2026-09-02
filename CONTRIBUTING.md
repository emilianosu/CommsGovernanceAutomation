# Cómo se trabaja: SDD adaptado

## Por qué "adaptado"

La [página de SDD en Confluence](https://nubank.atlassian.net/wiki/spaces/CCFIN/pages/264998552244/Spec-driven+Development)
describe el plugin `spec-driven-dev`, cuyo FAQ dice explícitamente:

> *"Currently, the rules are tailored for Nubank's Clojure microservices following the Diplomat pattern."*

Sus fases de implementación y entrega ejecutan `lein lint-fix`, orden de capas Diplomat y tests `state-flow`.
**Este proyecto no tiene servicio Clojure.** Los stacks reales son:

| Bloque | Stack | Naturaleza |
| --- | --- | --- |
| Intake | Slack Workflow + Jira Service Management (`MEXCOMS`) | Configuración, no código |
| Guardrails | Por definir (Databricks/Python o Jira automation) | Código + reglas |
| Calendario | Google Apps Script + Google Calendar | JavaScript |
| Monitoreo | Itaipu (Scala `SubdomainOp`) + Databricks SQL | Código de datos |

Por eso adoptamos lo transferible de SDD — **el loop de fases, los gates humanos y el contrato de
artefactos** — y sustituimos la capa de reglas por las convenciones de cada stack.

## El loop, por slice

```text
DISCOVER  ──▶ evidencia + as-is + contrato de datos
              ╠═ Gate técnico: Eduardo
       │
SPEC      ──▶ specs/SPEC-00N-<slice>.md  (mini-spec con reglas verificables)
              ╠═ Gate de negocio: Majo  (solo si toca reglas o proceso)
       │
PLAN      ──▶ pasos ordenados, archivos afectados, criterios de aceptación
              ╠═ Gate técnico: Eduardo
       │
IMPLEMENT ──▶ código + tests + validación con datos reales
       │
DELIVER   ──▶ PR + actualización de MXCE-1025 + demo
```

## Reglas de operación

1. **Spec first, code second.** Ningún PR sin su `SPEC-00N` mergeado antes.

2. **Living spec.** `SPEC-000-charter.md` fija **solo decisiones caras de revertir** (canal de intake, modelo
   de aprobación, arquitectura). El detalle fino (lógica de matching, UI del dashboard, reglas exactas) vive
   en el mini-spec del slice, escrito *cuando se construye* ese slice. El charter se **enmienda**, no se
   reescribe.

3. **Dos gates, dueños distintos.** Eduardo = viabilidad técnica. Majo = reglas de negocio y proceso.
   No se mezclan: así el trabajo técnico no queda bloqueado esperando definiciones de negocio, ni al revés.

4. **Decisión abierta ⇒ ADR, no bloqueo.** Toda pregunta sin respuesta se registra como ADR en estado
   `Proposed`, con opciones y trade-offs, y el slice avanza **bajo un supuesto declarado por escrito**.
   Un slice nunca se detiene por una decisión pendiente; se detiene solo si el supuesto es inseguro.

5. **Diagramas como código.** Mermaid (`.mmd`) en `diagrams/`. Un diagrama es una afirmación sobre el sistema,
   así que se revisa como cualquier otra: vive junto al spec que ilustra, se versiona con él y entra al gate
   como un diff legible. Una imagen en una herramienta externa no cumple ninguna de las tres.

6. **Toda afirmación técnica lleva su fuente.** Cada hecho en un spec apunta a código, doc o transcripción.
   Sin afirmaciones huérfanas — es lo que separa un spec de una suposición.

## Reglas verificables

Toda regla de guardrail se escribe como **predicado testeable con ID estable**:

```text
R-APR-01 | Si algún canal = "In-App Announcement NPS"
         ⇒ approver group "Core Analytics" es requerido
         Fuente: Mex-Communication New Form Proposal, hoja Workflow
```

- IDs **estables y nunca reciclados** (si una regla muere, su ID queda retirado).
- Una regla **sin dueño de dato no entra al engine**: entra como ADR con valor placeholder declarado.
- Prefijos: `R-APR` approvers · `R-DUR` duración · `R-VOL` volumen · `R-CAD` cadencia · `R-REV` reviewers ·
  `R-OVL` overlap · `R-TPL` naming de templates.

## Convenciones de código y commits

- **Conventional commits:** `feat/fix/chore/docs(scope): description`.
  Scopes en uso: `specs`, `adr`, `sql`, `diagrams`, `intake`, `guardrails`, `calendar`, `monitoring`.
- **Itaipu / Scala** (si se toca `itaipu`): naming `{Country}{Domain}{TableName}Op`, `ref_date` como partition
  key, `sbt test` antes del PR, contratos de datos con estructura Archipelago.
- **Databricks SQL:** naming de 3 niveles (`catalog.schema.table`), `DESCRIBE TABLE` antes de agregar una
  tabla nueva, CTEs sobre subqueries anidadas, y comentar la intención de negocio en los `CASE WHEN`.
- **PRs:** formato Problem / Solution / Rationale.

## Plantilla de spec

Copiar [`specs/_TEMPLATE-spec.md`](./specs/_TEMPLATE-spec.md). Sus 9 secciones son **obligatorias**; un spec
incompleto no pasa el gate.
