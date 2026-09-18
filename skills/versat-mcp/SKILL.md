---
name: versat-mcp
description: "Consultar y operar entidades, facturas, recibos y catálogos mediante las tools del MCP Versat; interpretar sus resultados y resolver problemas de acceso. Usar para tareas de negocio con Versat, no para desarrollo genérico del servidor."
---

# Versat MCP

Esta skill orienta el uso de las tools de Versat. El servidor es autosuficiente: prevalecen sus validaciones, el contrato vigente de cada tool y la guía de `versat_obtener_guia_uso`, también disponible como resource `versat://guia/uso` y prompt `versat_usar_mcp`. Una skill ausente o desactualizada no bloquea una tarea de negocio.

## Elegir el flujo

Lee solo la referencia necesaria para la tarea; combina referencias cuando el flujo lo requiera.

| Intención | Referencia y punto de entrada |
| --- | --- |
| Consultar o modificar clientes, proveedores y datos relacionados | [Entidades](references/entidades.md); `versat_consultar_entidad` para consultas de negocio |
| Crear, duplicar, actualizar o procesar facturas | [Facturas](references/facturas.md); distingue financiera AF31, insumos AI71 y granos AG91 |
| Crear, actualizar o procesar recibos y transacciones | [Recibos](references/recibos.md); AF51 y sus detalles |
| Resolver monedas, cuentas, operaciones, timbrados u otros IDs | [Catálogos](references/catalogos.md); prefiere la tool específica del campo y recurso |
| Interpretar errores, recuperar una creación parcial o buscar registros recientes | [Resultados y recuperación](references/resultados.md) |
| Resolver autenticación o bloqueo de acceso | [Autenticación](references/authentication.md) |

## Trabajar con la solicitud

1. Identifica la acción y el recurso. Si el tipo de factura sigue ambiguo después de consultar `versat_sugerir_tipo_factura` o `versat_listar_tipos_factura`, pregunta si es financiera, de insumos o de granos.
2. Resuelve los datos ya informados mediante búsquedas. Pide solo datos de negocio faltantes o una elección entre coincidencias razonables. Una autorización ya dada no exige otra confirmación para la misma acción.
3. Antes de escribir, consulta el contrato de campos. Muchas tools de alta lo devuelven sin JSON; comprueba esa posibilidad en la descripción vigente. Resuelve IDs mediante catálogos, sin inventarlos ni pedirlos al usuario cuando puedas buscarlos.
4. Envía un objeto JSON con los nombres exactos del contrato y una sola propiedad por campo. Para cabecera con detalles, prefiere la tool completa del recurso. Los registros con estado nacen en `Borrador`; aplicar, desaplicar y anular usan tools de procesamiento.
5. Evalúa el resultado global y cualquier resultado parcial antes de continuar. Informa qué se creó, qué falta y el estado verificado.

## Decisiones que cambian el flujo

- **Acceso bloqueado:** `debeDetenerse=true` o `accesoMcp=false` impiden continuar con tools de negocio. Usa `estadoValidacionMcp` y el código para distinguir acceso denegado, autenticación rechazada y validación indeterminada; no atribuyas falta de permiso a un timeout.
- **Escritura incierta:** `resultado_escritura_incierto` o `resultadoIncierto=true` exigen consultar lo creado antes de otra escritura. El servidor no repite automáticamente el envío y devuelve `reintentar=false`; no crees un sustituto ni repitas el alta completa.
- **Reintentos:** `reintentar=false` impide repetir la misma llamada sin cambios. El prefijo `servicio_versat_` por sí solo no significa fallo temporal. Con `reintentar=true`, espera el plazo indicado; en escrituras, verifica primero si hubo registros o cambios ya confirmados. Aplica [Resultados y recuperación](references/resultados.md).
- **Corrección indicada:** usa `accionRequerida`, `campoPendiente`, `herramientaSugerida` e `instruccionParaAgente` sobre el borrador existente. Verifica la corrección antes de repetir `Aplicar`; no crees un sustituto.
- **Búsquedas:** las tools ya intentan coincidencias flexibles. Usa `coincidencias`, `coincidenciaPrincipal` y totales; no multipliques variantes si hay resultados útiles. Pregunta únicamente cuando la ambigüedad afecte a la acción.
- **Recientes:** la página 0 contiene registros antiguos. Mantén filtros y tamaño de página al usar `totalPages`; si falta ese dato, no inventes la última página ni presentes una muestra como el conjunto completo.
- **RUC:** consulta `versat_buscar_rucs` y usa el ID devuelto como `Ruc_id` en BA31. `Ruc_uk` no es un filtro de entidades.
- **Mi empresa:** usa `versat_buscar_empresas`; OX01 es de solo lectura y corresponde exclusivamente a la empresa autorizada. No solicites otra empresa o modelo para sustituir ese contexto.

## Comunicar el resultado

Responde en el idioma del usuario con nombres, documentos, fechas, importes y estados. Acompaña los IDs útiles para auditoría o recuperación con su significado. No presentes una creación parcial como éxito total ni como una reversión completa.

Usa los mensajes de negocio controlados. Omite credenciales, headers sensibles, stack traces, valores de filtros en URLs y nombres o rutas de fuentes internas, incluso si aparecen en una respuesta técnica.

## Instalar o actualizar esta skill

La fuente oficial es [Versat MCP Skills](https://github.com/Versat-Platform/versat_skills_mcp), rama `main`, manifiesto `skills-manifest.json`, ruta `skills/versat-mcp`.

Cuando el usuario pida instalar o actualizar la versión distribuida, usa `versat_sincronizar_skills` e informa la versión local cuando esté disponible. Si devuelve archivos, persiste el paquete completo bajo `rutaDestinoRelativa` en el directorio de skills compatible con el cliente, respetando cada `rutaRelativa`. Comprueba la versión y los hashes suministrados. La descarga o preparación del paquete no equivale a una instalación; confirma `versionOficial` solo después de verificar los archivos escritos.

Si el cliente no permite escribir skills, informa esa limitación y continúa las tareas de negocio con la guía MCP. Mejorar el contenido fuente de la skill es una tarea de mantenimiento del repositorio oficial; no la confundas con instalar la versión publicada.
