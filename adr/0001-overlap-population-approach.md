# ADR-0001 — Enfoque para el cálculo de overlap de poblaciones

| | |
| --- | --- |
| **Estado** | `Proposed` |
| **Fecha** | 2026-08-31 |
| **Dueño de la decisión** | Eduardo Jurado (técnica) |
| **Afecta a** | Slice 3 (validation engine) |

## Contexto

Uno de los guardrails centrales es evitar que un mismo cliente reciba comunicaciones traslapadas de campañas
distintas. Dos comms pueden aprobarse el mismo día si van a clientes distintos; si hay solapamiento
relevante, hace falta un umbral o criterio de aprobación.

**El problema duro:** la elegibilidad de clientes **cambia a diario**. La población objetivo de una campaña
calculada al momento de agendar no es la misma que recibirá la comm el día del envío.

Este es, por consenso de las tres reuniones, **el componente más complejo del proyecto**. Por eso la decisión
**D6** del charter lo saca de la ruta crítica: se trata como problema separado y posterior al flujo principal.

## Opciones

### A — Comparar poblaciones actuales directamente

Al momento de agendar, traer la población objetivo viva de cada comunicación y verificar el traslape contra
las ya agendadas.

- ➕ Simple de implementar; latencia baja.
- ➖ El overlap puede haber derivado para la fecha de envío, porque la elegibilidad cambia a diario.

### B — Re-ejecutar la segmentación al momento del check

Re-evaluar los criterios de elegibilidad justo antes de cada envío, para tener una foto fresca.

- ➕ La más precisa.
- ➖ Costo de cómputo y pipeline considerablemente mayor; agrega latencia al guardrail.
- ➖ Requiere que cada equipo exponga su lógica de segmentación de forma ejecutable — hoy no existe.

### C — Listas estáticas point-in-time

Congelar la población objetivo al momento de aprobar y validar el traslape contra esa lista congelada.

- ➕ Barata y **auditable**: queda registro exacto de contra qué se validó.
- ➖ Puede no detectar traslape real si la elegibilidad se mueve entre aprobación y envío.

## Comparación

| | A — Poblaciones vivas | B — Re-segmentar | C — Listas congeladas |
| --- | --- | --- | --- |
| Precisión | Media | Alta | Media-baja |
| Costo de cómputo | Bajo | **Alto** | Bajo |
| Latencia del guardrail | Baja | Alta | Baja |
| Auditabilidad | Media | Baja | **Alta** |
| Dependencia de otros equipos | Baja | **Alta** | Baja |

## Prior art

**Campaign Coalition Checker** — app de Streamlit en Databricks que recibía archivos CSV de customer IDs,
identificaba coincidencias entre campañas y mostraba gráficos.

- **Ya no está activa** y **nunca llegó a un repositorio**.
- Es efectivamente una implementación de la **opción C** (listas point-in-time vía CSV).
- Candidata a retomarse como MVP del análisis de overlap, escalarla y evaluarla.

⬜ *Pendiente:* localizar el código o al menos capturas/documentación antes de decidir si se retoma o se
reescribe.

## Enfoque propuesto para el spike

De la reunión del 2026-08-28: comparar primero campañas **por fechas** (barato, descarta la mayoría de los
pares), calcular las audiencias solo de las que se traslapan en el tiempo, y hacer el join para determinar el
**porcentaje de clientes compartidos**. Filtrar por fecha antes de calcular poblaciones es lo que hace el
problema tratable.

## Decisión

⬜ **Pendiente.** A resolver por Eduardo en la working session del 2026-09-03.

## Consecuencias

Afecta latencia del guardrail y costo de infraestructura. También determina si hace falta pedir a cada equipo
su lógica de segmentación (solo la opción B lo requiere), lo cual es una dependencia organizacional, no solo
técnica.

## Preguntas abiertas ligadas

- ¿Cuál es el **umbral** de overlap a partir del cual se rechaza o se escala a revisión manual? → dueña: Majo,
  [ADR-0003](./0003-guardrail-thresholds-ownership.md).
- ¿Las listas de clientes serán dinámicas o estáticas, y qué lógica o query puede aportar cada equipo?
