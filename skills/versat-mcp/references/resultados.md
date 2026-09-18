# Resultados, paginación y recuperación

Usa esta referencia ante errores, respuestas por etapas o búsquedas de registros recientes.

## Leer una respuesta

El contrato puede usar `EsExitoso`/`CodigoEstado` en resultados simples y `esExitoso`/`codigoEstado` en operaciones compuestas. Busca el código en `tipoError` o `codigoError`, según la respuesta. Revisa también `respuestaApi`, `factura`, `detalles` y `subdetalles` cuando existan: un resultado interno exitoso no convierte el resultado global en éxito total.

| Señal | Acción |
| --- | --- |
| `debeDetenerse=true` o `accesoMcp=false` | Detén las tools de negocio. Distingue el motivo mediante [Autenticación](authentication.md). `indeterminado` significa que no se pudo validar el acceso. |
| `401`, `Auth required` o `mcp_http_bearer_ausente_o_invalido` | Revisa la configuración de credenciales del cliente. No interpretes el fallo como ausencia de registros. |
| `resultado_escritura_incierto` o `resultadoIncierto=true` | La escritura pudo completarse; no se repite automáticamente. Consulta el registro y sus detalles para determinar qué se guardó antes de completar lo faltante. |
| `reintentar=false` | No repitas la misma llamada sin cambios. Si hay una corrección de negocio, aplícala al borrador existente y verifícala. |
| `servicio_versat_error_interno` sin corrección indicada | Conserva IDs y contexto de negocio para diagnóstico. No inventes un dato faltante ni lo trates como reintentable por su prefijo. |
| `reintentar=true` sin bloqueo | Espera `retryAfterSegundos` si es válido y positivo; en su ausencia, espera unos segundos. En consultas, haz un reintento y, si persiste el fallo, informa la indisponibilidad. En escrituras, aplica el flujo de recuperación de abajo. |
| `400`, `json_alta_invalido` o `campos_obligatorios_alta_faltantes`, `campos_factura_invalidos`, `lote_factura_invalido` o `status_factura_no_actualizable` | Corrige el parámetro o los campos señalados. Pregunta solo por información que no puedas resolver con los datos disponibles y catálogos. |
| `accionRequerida`, `campoPendiente`, `herramientaSugerida` | Sigue la corrección de negocio indicada, dentro de la acción autorizada. Comprueba el registro antes de volver a procesarlo. |
| Respuesta vacía exitosa | Informa que el criterio no encontró coincidencias. No concluyas inexistencia global con un filtro estrecho o una página aislada. |

Las señales de detención y `reintentar=false` tienen prioridad. Si falta `reintentar`, no lo supongas verdadero por el código HTTP o por un nombre `servicio_versat_*`. Un error interno tampoco implica que el usuario deba cambiar sus datos.

## Recuperar una escritura por etapas

1. Conserva el ID de cabecera, los IDs de detalles y subdetalles confirmados, sus resultados y la etapa fallida. No uses el ID de la cabecera donde corresponde el ID del detalle padre.
2. Si una etapa falla después de crear registros, consulta esos registros y compara lo existente con lo solicitado. No repitas la tool completa: podría crear otra cabecera y duplicar detalles.
3. Corrige el registro existente o crea únicamente los detalles que verificaste como faltantes. Si la respuesta no trajo el ID de una etapa exitosa, localiza el registro con sus datos de negocio; resuelve cualquier ambigüedad antes de escribir.
4. Si hubo timeout o pérdida de respuesta y no puedes determinar si la escritura se completó, informa que el resultado es incierto. No afirmes que falló sin crear datos ni envíes otra alta a ciegas.
5. Aplica o procesa solo cuando todas las etapas requeridas estén completas y esa acción esté autorizada. En un rechazo de procesamiento, corrige y verifica el mismo borrador antes de volver a aplicar.

Ejemplo: se crearon una factura, su clasificación y el primer centro de costo; falló el segundo centro. Conserva los tres IDs conocidos, consulta los centros de esa clasificación y agrega solo el faltante. No vuelvas a crear la factura o la clasificación.

## Buscar los registros más recientes

La paginación natural de Versat va de antiguo a nuevo. La numeración empieza en `0`: `pagina=1` es la segunda página y también contiene registros antiguos. Las búsquedas con página predeterminada comienzan en `0`; respeta una página explícita del usuario.

1. Elige filtros y un tamaño de página admitido por la tool. Consulta `pagina=0` para obtener `infoPaginacion` cuando no dispongas de ella.
2. Si `totalPages` es un entero positivo, consulta `totalPages - 1` con los mismos filtros y el mismo tamaño de página. Si cambias el tamaño, obtén nuevamente los metadatos antes de calcular la última página.
3. Para completar la cantidad pedida, recorre las páginas anteriores necesarias, elimina duplicados por ID y verifica fechas e IDs. Ordena según la fecha pertinente a la solicitud.
4. Si `totalPages` es cero, no solicites una página negativa. Si falta, es nulo o no es válido, no lo sustituyas por cero ni inventes la última página. Amplía la consulta solo mediante las opciones admitidas o informa que ordenaste únicamente los registros recuperados.

Ejemplo: `totalPages=8` con 25 registros por página implica `pagina=7` y tamaño 25. Cambiar el tamaño a 100 conservando `pagina=7` ya no identifica la misma parte del resultado.

Los campos de paginación nulos representan información no disponible; los registros devueltos pueden seguir siendo útiles. Para antecedentes contables, prefiere las tools `versat_buscar_ejemplos_contables_factura_*`, que recuperan referencias del recurso seleccionado.

El servidor expone `ultimaPagina`, `paginaAnterior` y `paginaSiguiente` cuando los metadatos lo permiten. En búsquedas de catálogos, revisa `paginasConsultadas`: conserva los filtros y tamaño de cada entrada y no sumes sus totales. Las búsquedas de cotizaciones y timbrados también exponen paginación; una página sin coincidencias no demuestra ausencia global ni justifica crear otro registro.

En ejemplos contables, revisa `alcanceBusqueda`: identifica páginas consultadas y evaluadas, si se verificaron páginas finales y si se alcanzó el límite de recorrido. Si faltan totales, los ejemplos son solo una muestra inicial. Ordenar por fecha/id dentro de esa muestra no garantiza las fechas más recientes de páginas pendientes. Un error al consultar páginas finales se conserva como error y no como una búsqueda vacía exitosa.

## Parámetros y límites del servidor

`filtrosJson` y `consultaJson` solo admiten `filtro_campo`, `filtro_valor`, `pagina` y `registros_por_pagina`. BA31 mantiene `limit`/`offset` como compatibilidad traducida. Use los argumentos específicos para ids y detalles; nunca sustituya recurso, vista ni contexto. Página desde cero, tamaño entre 1 y 1000 y nombre flexible de hasta 512 caracteres.

Ante `parametro_consulta_no_permitido`, `paginacion_invalida` o `campo_actualizacion_no_permitido`, corrija la entrada según el contrato. `respuesta_versat_demasiado_grande` requiere acotar filtros o reducir el tamaño de página. Una escritura con respuesta excesiva puede haberse completado: respete `resultado_escritura_incierto` y consulte antes de repetir.

Un 403 `mcp_origen_host_no_permitido` requiere revisar la configuración del cliente y del servidor. Ante 429 respete Retry-After; no rote credenciales para eludir límites.
