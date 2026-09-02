# ADR-0003 — Valores de los umbrales de guardrails

| | |
| --- | --- |
| **Estado** | `Proposed` — bloqueado a la espera de definición de negocio |
| **Fecha** | 2026-08-31 |
| **Dueño de la decisión** | **Maria Jose Salinas** (negocio) |
| **Afecta a** | Slice 3 (validation engine) |

## Contexto

El validation engine necesita valores numéricos para aplicar sus reglas. Dos de ellos **no existen hoy en
ningún documento** — quedaron como preguntas abiertas en las reuniones del 2026-08-27 y 2026-08-28.

No son decisiones técnicas: son **política de negocio**. Un ingeniero no puede inventar cuántas comms al día
es aceptable que reciba un cliente; eso lo define quien responde por la experiencia.

## Reglas sin valor

| ID | Regla | Qué falta |
| --- | --- | --- |
| `R-DUR-01` | Duración máxima de una comm **por canal** | El número de días, por cada canal |
| `R-VOL-01` | Límite de comms que un cliente puede recibir **por canal y por periodo** | El número, y el periodo (¿día? ¿semana?) |
| `R-OVL-01` | Umbral de overlap a partir del cual se rechaza o se escala a revisión manual | El porcentaje de audiencia compartida |

Contexto útil: la política declarada en *Mexico Comms Governance Process Sept 2025* ya dice
*"limitar el número de comms que un cliente puede recibir de Nu **por día**"* — el periodo de `R-VOL-01`
probablemente sea diario, pero **el número nunca se escribió**.

## Reglas que sí tienen valor

Estas ya son deterministas y no dependen de este ADR — se pueden codificar tal cual:

| ID | Regla | Fuente |
| --- | --- | --- |
| `R-APR-01` | Canal = *In-App Announcement NPS* ⇒ approver **Core Analytics** | Form v2, hoja Workflow |
| `R-APR-02` | Lifecycle ∈ {`After`,`Both`} **y** canal ∈ {Now Dashboard, Highlight CC, Highlight Cuenta, Discover More} ⇒ **App Experience** | Form v2, hoja Workflow |
| `R-APR-03` | Lifecycle ∈ {`Before`,`Both`} **y** el mismo conjunto de canales ⇒ **Growth** | Form v2, hoja Workflow |
| `R-CAD-01` | Solicitud después del jueves 23:59 ⇒ ticket de **ESCALATION** | Form v2, Instructions |
| `R-REV-01` | Alcance >30% de clientes ⇒ 2 managers del squad; <30% ⇒ 1 manager de Content/Marketing | Governance Process Sept 2025 |

## Decisión

⬜ **Pendiente de Majo.** A cerrar en la working session del 2026-09-03.

## Principio de operación mientras tanto

> Una regla **sin dueño de dato no entra al engine**. Entra al spec como regla `Pendiente de dato`, con
> valor placeholder **declarado explícitamente**, y el slice avanza sin ella.

Esto evita dos fallas simétricas: bloquear todo el desarrollo esperando definiciones, e inventar umbrales que
después se aplican como si fueran política aprobada.

## Consecuencias

- El Slice 3 puede construirse con `R-APR-*`, `R-CAD-01` y `R-REV-01`, que ya están definidas.
- `R-DUR-01`, `R-VOL-01` y `R-OVL-01` se implementan como reglas **parametrizables**: la estructura se
  construye, el valor se inyecta por configuración cuando Majo lo defina.
- Los valores deben quedar en configuración, **no hardcodeados** — van a cambiar con la experiencia operativa.

## Sugerencia de método para definirlos

Los umbrales salen mejor de datos que de intuición. Una vez que el Slice 1 dé trazabilidad, se puede medir
cuántas comms recibe hoy un cliente típico por canal y periodo, y proponer un límite anclado a la realidad
observada en vez de a una estimación. **Esto no bloquea la decisión** — Majo puede fijar un valor provisional
ahora y refinarlo con datos después.
