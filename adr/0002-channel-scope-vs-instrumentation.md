# ADR-0002 — Alcance de canales del validation engine vs. instrumentación disponible

| | |
| --- | --- |
| **Estado** | `Proposed` |
| **Fecha** | 2026-08-31 |
| **Dueño de la decisión** | Maria Jose Salinas (negocio) + Eduardo Jurado (técnica) |
| **Afecta a** | Slice 3 (validation engine), Slice 5 (dashboard), objetivos O1 y O6 |

## Contexto

Hay una **asimetría estructural** entre lo que el governance cubre y lo que el sistema puede medir.

**Canales bajo governance** (*Mexico Comms Governance Process Sept 2025*):

| Grupo | Canales |
| --- | --- |
| In-App | Announcement · Now Dashboard\* · Highlight (Credit Card)\* · Highlight (Cuenta)\* · Discover More\* · Pop up |
| Direct | Push notification · Email · WhatsApp† · SMS† |
| App 1ª capa | Experiment proposal\* · Experiment roll out\* |

\* requiere aprobación adicional en `#homepage-support` · † requiere presupuesto aprobado

**Canales instrumentados** en `etl.mx__dataset.communications_monitoring` — **solo 3**:
email, push, announcement. Verificado en `CommunicationsMonitoring.scala`: sus inputs son exactamente
`nu-mx/dataset/{email,push,announcement}-communications`.

⇒ **7+ canales quedarían gobernados pero no medibles.**

## Opciones

### A — Gobernar solo los 3 instrumentados

- ➕ Todo lo que se gobierna se puede medir; guardrails verificables end-to-end.
- ➕ Alcance del Slice 3 mucho menor.
- ➖ El engine cubre una fracción del proceso real de Majo; el resto sigue manual.

### B — Gobernar los ~10 canales del forms

- ➕ Cobertura completa del proceso de governance; el engine sirve para todo lo que Majo revisa hoy.
- ➕ Las reglas de fechas, duración y approvers **no requieren instrumentación** para aplicarse — se validan
  contra lo que declara el ticket.
- ➖ 7+ canales sin forma de verificar cumplimiento después del envío.
- ➖ Alcance del Slice 3 considerablemente mayor.

### C — Gobernar 10, medir 3, documentando la asimetría

Variante de B que hace la brecha explícita en cada artefacto en lugar de dejarla implícita.

## Decisión

**Opción B, ejecutada como C:** el validation engine gobierna los ~10 canales del formulario, y la asimetría
se documenta explícitamente en lugar de esconderse.

*(Decisión **D9** del charter, 2026-08-31. Pendiente de ratificar con Majo y Eduardo el 2026-09-03.)*

## Consecuencias

1. **Los guardrails aplican a los ~10 canales.** Reglas de fechas, duración, approvers y cadencia se validan
   contra lo declarado en el ticket — no necesitan datos de envío.
2. **El join a monitoreo y el dashboard (O1, O6) cubren solo 3 canales.** Los criterios de aceptación de O1
   se acotan a email, push y announcement.
3. **Los 7+ canales restantes se marcan `governed, unmeasured`** en el charter y en el dashboard. Un canal
   sin datos debe verse como "sin instrumentación", **nunca** como "sin actividad" — confundir ambas cosas
   llevaría a conclusiones falsas sobre el uso de canales.
4. **Se acepta no poder verificar cumplimiento** en esos canales: si un equipo excede la duración aprobada en
   un Highlight, el sistema no lo detecta post-hoc.

## Camino de salida

Instrumentar canales adicionales requiere datasets upstream que hoy no existen. Extender
`CommunicationsMonitoring.scala` es un **no-objetivo del charter**, así que sería un proyecto aparte, con su
propio spec. La decisión **D5** ya contempla evaluar un cuarto canal más adelante.

⬜ *Pregunta para Majo:* de los 7 no instrumentados, ¿cuál aporta más valor si se instrumenta primero?
