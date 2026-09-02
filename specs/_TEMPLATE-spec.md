# SPEC-00N — < nombre del slice >

| | |
| --- | --- |
| **Jira** | MXCE-XXXX |
| **Estado** | Draft · In review · Approved · Implemented · Superseded |
| **Última actualización** | YYYY-MM-DD |
| **Gate técnico** | Eduardo Jurado — ⬜ pendiente / ✅ aprobado |
| **Gate de negocio** | Maria Jose Salinas — ⬜ pendiente / ✅ aprobado / — no aplica |

> Las 9 secciones son **obligatorias**. Un spec incompleto no pasa el gate.
> Si una sección no aplica, escribir *"No aplica porque…"* — nunca borrarla.

---

## 1. Contexto

Qué dolor concreto ataca este slice. Enlazar al `DISCOVERY` en vez de repetirlo.

## 2. Objetivo medible

**Un solo objetivo**, con número. Si no se puede medir, no es un objetivo — es una intención.

| Métrica | Baseline | Meta | Cómo se mide |
| --- | --- | --- | --- |
| | | | |

## 3. Alcance / No-alcance

**Dentro:** …
**Fuera:** … *(y por qué — evita que se reabra la discusión después)*

## 4. Contrato de datos

Tablas, columnas, tipos, **grain** y PK. Naming de 3 niveles (`catalog.schema.table`).
`DESCRIBE TABLE` antes de dar por buena una tabla nueva; pegar el resultado verificado, no el asumido.

## 5. Reglas

Cada regla con **ID estable** y escrita como **predicado testeable**.

| ID | Regla | Fuente | Estado |
| --- | --- | --- | --- |
| `R-XXX-NN` | Si \<condición\> ⇒ \<consecuencia\> | doc / código / reunión | Activa · Pendiente de dato · Retirada |

Una regla sin dueño de dato **no entra al engine**: entra como ADR con valor placeholder declarado.

## 6. Criterios de aceptación

Comprobables **sin criterio humano**. "Funciona bien" no es un criterio; "el join resuelve ≥ X% de las filas
de la ventana Y" sí lo es.

- [ ] …

## 7. Plan de verificación

Cómo se prueba end-to-end: queries a correr, tests, validación con datos reales, quién revisa.

## 8. Riesgos y dependencias

Incluir dependencias externas **con su lead time** (ej. tickets a Atlassian Support).

| ID | Riesgo | Impacto | Mitigación |
| --- | --- | --- | --- |

## 9. Decisiones abiertas

Cada una apunta a un ADR. Ninguna queda sin dueño.

| Pregunta | ADR | Dueño | Supuesto mientras tanto |
| --- | --- | --- | --- |
