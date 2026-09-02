# ADR-0004 — Llave de join entre ticket y monitoreo

| | |
| --- | --- |
| **Estado** | `Proposed` |
| **Fecha** | 2026-08-31 |
| **Dueño de la decisión** | Eduardo Jurado (técnica) |
| **Afecta a** | Slice 1 (trazabilidad), Slice 5 (dashboard), objetivo O1 |

## Contexto

Hoy no existe llave confiable entre un ticket de MEXCOMS y sus filas de performance en
`etl.mx__dataset.communications_monitoring`. La única liga es `template_name`, laxamente estandarizado.

**Restricción dura, verificada en código:** la tabla es **append-only y solo la escriben envíos reales** de
los canales. Ningún cambio de estado de ticket o solicitud escribe ahí.

⇒ **Cualquier join es necesariamente post-send.** No hay forma de escribir la liga en tiempo de guardrail.

### Lo que cambia el planteamiento

La PK verificada es `(template_name, communication_type, formatted_date)`, y el **form v2 ya captura los tres
componentes**:

| Componente PK | Campo del form v2 |
| --- | --- |
| `template_name` | Campo 6 / 10 / 14 — *Channel N Template Name* |
| `communication_type` | Campo 3 / 7 / 11 — *Channel N* |
| `formatted_date` | Campos 4-5 / 8-9 / 12-13 — *Start / End Date* por canal |

La llave **no falta en el diseño; falta validarla y normalizarla**. Eso reduce sustancialmente el costo de la
opción A.

## Opciones

### A — Vivir con reconciliación post-send sobre `template_name`

Estandarizar y normalizar `template_name` en el intake, y reconciliar después del envío.

- ➕ **No requiere cambios en sistemas de terceros** ni en los canales de envío.
- ➕ La captura ya existe en el form v2; solo falta validarla.
- ➕ Retrocompatible: aplica a datos históricos, así que da baseline medible desde el día uno.
- ➖ Sigue siendo texto abierto: el contrato es convención, no restricción del sistema.
- ➖ El match nunca será 100% si un equipo se equivoca al teclear.

### B — Introducir una llave dedicada (ej. ID de ticket propagado hasta el envío)

Que el ticket genere un identificador que viaje hasta la herramienta de envío y aterrice en la tabla.

- ➕ Match determinista y a prueba de errores de tecleo.
- ➖ Requiere cambios en `communication_handler`, en los datasets upstream y en
  `CommunicationsMonitoring.scala` — **atraviesa el no-objetivo del charter** de no rediseñar el pipeline.
- ➖ Depende de equipos que no controlamos.
- ➖ No es retroactiva: cero trazabilidad histórica.

### C — Híbrida

Reconciliación post-send ahora (A), y proponer la llave dedicada (B) como mejora de largo plazo con su
propio spec.

## Comparación

| | A — `template_name` | B — llave dedicada | C — híbrida |
| --- | --- | --- | --- |
| Esfuerzo | Bajo | **Alto** | Bajo ahora, alto después |
| Dependencias externas | Ninguna | **Varias** | Ninguna ahora |
| Precisión del match | Media-alta | **Total** | Media-alta → total |
| Aplica a histórico | ✅ | ❌ | ✅ |
| Respeta los no-objetivos | ✅ | ❌ | ✅ |

## Decisión

⬜ **Pendiente.** A resolver por Eduardo en la working session del 2026-09-03.

**Recomendación: opción C.** La reconciliación post-send es suficiente para desbloquear el dashboard y el
objetivo O1, no toca sistemas de terceros, y aplica retroactivamente. El baseline que produce el Slice 1 es
justamente la evidencia necesaria para argumentar si vale la pena la opción B: si la normalización rescata la
mayoría de los casos, B no se justifica; si el naming histórico resulta irrecuperable, B tiene su caso hecho
con datos.

## Consecuencias

- **Si A o C:** el contrato de naming de [SPEC-001](../specs/SPEC-001-template-name-traceability.md) es el
  entregable central, y la meta de O1 queda acotada por la calidad del naming histórico.
- **Si B:** el Slice 1 cambia de alcance por completo y pasa a depender de equipos externos — con lo que deja
  de ser el primer slice y la decisión **D8** del charter tendría que revisarse.

## Restricción a respetar en cualquier caso

`JourneyMomentCommunicationsMonitoring` filtra esta misma tabla con `template_name LIKE '%jm%'`. Cualquier
cambio de convención de naming debe verificarse contra ese dataset downstream antes de aplicarse
(regla `R-TPL-05`).
