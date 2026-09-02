# ADR-0005 — Tooling de calendario y dashboard

| | |
| --- | --- |
| **Estado** | `Proposed` |
| **Fecha** | 2026-08-31 |
| **Dueño de la decisión** | Maria Jose Salinas (negocio) + Eduardo Jurado (técnica) |
| **Afecta a** | Slice 4 (calendario), Slice 5 (dashboard) |

## Contexto

El charter deja explícitamente como **no-objetivo** *"elegir hoy el tooling definitivo de calendario y
dashboard"*. Este ADR mantiene la pregunta abierta con sus opciones, para cerrarla cuando los slices 4 y 5
estén cerca — no antes.

## Estado actual

**Calendario** — cadena frágil, es la falla **P2** del charter:

```text
Sheet "MEX COMMUNICATIONS CALENDAR 2025"  →  Apps Script  →  Google Calendar
                                              (sync parcial, propenso a error)
```

Artefactos vigentes: el Sheet actual · *MEX COMMS - JIRA IMPORT* (versión automatizada) ·
*Sheet for automated calendar* · un Google Calendar ya compartido con el equipo.

**Dashboard** — no hay uno publicado, pero el notebook de Databricks *Non-recurrent Monitoring*
(`2219645164459186`, dueño: Eduardo) **ya cubre buena parte de lo que se pide**. Revisado el 2026-09-01:

- Widgets de filtro por **rango de fechas, template y canal** — exactamente los tres ejes que pedía la
  reunión del 2026-08-25.
- Pivotea la tabla a matriz template × métrica × día, con las métricas correctas según el canal.
- Export a CSV y ordenamiento por columna desde la propia tabla de resultados.

⇒ **Lo que le falta no es filtrado.** Le faltan dos cosas: acceso para los squads consumidores, y la liga al
ticket — no tiene columna de squad, requester ni approver. Eso último es el Slice 1, no el 5.

## Lo que se pide del dashboard

De la reunión del 2026-08-25: un dashboard comunitario donde los squads **filtren por canal, fecha y
template** para consultar los rates de sus comunicaciones. Es decir: self-service, no un reporte que alguien
tenga que generar.

## Opciones — Calendario

| | Reusar el Apps Script | Google Calendar API directo | Otra herramienta |
| --- | --- | --- | --- |
| Esfuerzo | **Bajo** | Medio | Alto |
| Confiabilidad | Baja (es el problema actual) | **Alta** | Depende |
| Familiaridad del equipo | Alta | Media | Baja |
| Elimina el paso por Sheet | ❌ | ✅ | ✅ |

⚠️ Reusar el Apps Script conserva el punto de falla que **P2** justamente busca eliminar. Vale como puente,
difícilmente como destino.

## Opciones — Dashboard

| | Databricks dashboard | QuickSight | Extender el notebook actual |
| --- | --- | --- | --- |
| Self-service para squads | Media | **Alta** | Media — tiene filtros, pero exige correr un notebook |
| Cercanía a los datos | **Alta** (la tabla ya está ahí) | Media | **Alta** |
| Esfuerzo | Bajo | Medio | **El más bajo** — la query ya existe y funciona |
| Dueño / gate | Por asignar | Por asignar | **Eduardo** — el mismo del gate técnico |
| Requiere permisos para squads | Sí | Sí | Sí |
| Arrastra R9 / R10 | No | No | ⚠️ Sí, salvo que se corrijan |

> La calificación anterior de esta columna (`Self-service: Baja`, *"ya existe"*) se hizo sin ver el
> contenido del notebook y era incorrecta. Corregida el 2026-09-01.

## Decisión

⬜ **Pendiente.** Se cierra cuando los slices 4 y 5 estén por arrancar.

## Consideraciones para cuando se decida

1. **El dashboard depende del Slice 1.** Sin el join resuelto, puede mostrar performance por template pero no
   atribuirla al equipo solicitante — que es justamente lo que se quiere.
2. **Un rate en `0.0` es ambiguo.** El helper `safeRate` de `CommunicationsMonitoring.scala` devuelve `0.0`
   cuando el denominador es `0`, así que "cero clicks" y "cero enviados" se ven idénticos. Cualquier
   visualización debe mostrar `total_templates_sent` junto al rate, o inducirá a error.
   ⚠️ El notebook actual **no lo muestra** — solo lo usa para filtrar. Y su columna `Population` es
   `max(population)` sobre la ventana, cuando `population` es un total histórico según
   [DISCOVERY](../specs/DISCOVERY-MXCE-1025.md) §5.1: la etiqueta sugiere alcance de la ventana consultada
   y no lo es.

3. **El filtro de engagement cero (riesgo R9).** El notebook excluye todo template cuyo mejor rate en la
   ventana sea `0`. Cualquier dashboard que parta de esa query **hereda el sesgo** salvo que se quite
   explícitamente. Para governance hay que invertir el criterio: enviado-con-cero es una fila que debe verse,
   no una que deba ocultarse.
4. **Canales sin instrumentación.** Por [ADR-0002](./0002-channel-scope-vs-instrumentation.md), 7 canales no
   tienen datos. Deben verse como *"sin instrumentación"*, **nunca** como *"sin actividad"*.

5. **Acceso de los squads.** Nuestro acceso al notebook ya está resuelto, pero el de los squads consumidores
   no: cualquiera de las tres opciones lo requiere. Conviene preverlo temprano — es el tipo de permiso cuyo
   lead time no controlamos.

6. **Sensibilidad a mayúsculas (riesgo R10).** El notebook mezcla comparación case-insensitive en los filtros
   con comparación exacta en el unpivot. Antes de reutilizar su query hay que fijar un solo criterio, y eso
   depende de verificar los valores reales de `communication_type`.
