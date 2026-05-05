# Facturas

Usa estas reglas para listar, inspeccionar, crear, actualizar, duplicar o procesar facturas en Versat MCP.

## Seleccion de tipo

Si el usuario dice solo "crear/cadastrar una factura", no adivines. Llama:

- `versat_sugerir_tipo_factura`
- o `versat_listar_tipos_factura`

Si sigue ambiguo, pregunta si quiere factura `financiera`, de `insumos` o de `granos`.

## Mapa rapido

`AF31` facturas financieras:

- listar: `versat_listar_facturas_financiero`
- agregar: `versat_agregar_factura_financiero`
- actualizar: `versat_actualizar_factura_financiero`
- agregar completa: `versat_agregar_factura_completa_financiero`
- detalle: `versat_consultar_detalle_factura_financiero`
- procesar: `versat_procesar_facturas_financiero`

`AI71` facturas de insumos:

- listar: `versat_listar_facturas_insumos`
- agregar: `versat_agregar_factura_insumos`
- actualizar: `versat_actualizar_factura_insumos`
- agregar completa: `versat_agregar_factura_completa_insumos`
- detalle: `versat_consultar_detalle_factura_insumos`
- procesar: `versat_procesar_facturas_insumos`
- productos facturados: detalle `Factura_producto`

`AG91` facturas de granos:

- listar: `versat_listar_facturas_granos`
- agregar: `versat_agregar_factura_granos`
- actualizar: `versat_actualizar_factura_granos`
- agregar completa: `versat_agregar_factura_completa_granos`
- detalle: `versat_consultar_detalle_factura_granos`
- procesar: `versat_procesar_facturas_granos`

## Registros recientes

Versat pagina de antiguo a nuevo. No trates `pagina=0` como reciente.

Flujo recomendado:

1. Consulta con `pagina=1` y pocos registros para obtener `infoPaginacion.TotalPages`.
2. Consulta la ultima pagina (`TotalPages`) con un tamano suficiente.
3. Ordena items por `Fecha`, `Fecha_doc`, `Creacion_hd` o `id` descendente segun los campos disponibles.
4. Devuelve la cantidad pedida.

Si la tool no devuelve paginacion, ordena los items recibidos por fecha/id antes de responder.

## Consultar detalles

Para productos, cuotas, fletes, clasificaciones, bajas o remisiones de una factura, filtra por el id padre:

```json
{"detalle":"Factura_producto","filtroCampo":"Factura_id","filtroValor":"123","pagina":1,"registrosPorPagina":100}
```

Usa la tool de detalle del mismo recurso de la factura. No mezcles AI71, AF31 y AG91.

## Crear o duplicar factura

1. Identifica el recurso.
2. Si faltan campos, llama la tool de agregar sin JSON para leer obligatorios/opcionales.
3. Resuelve IDs con catalogos antes de escribir.
4. Si hay detalles, prefiere la tool completa.
5. Para copias, toma la factura origen, elimina campos tecnicos (`id`, textos calculados, auditoria), cambia fechas y deja que el MCP fuerce `Status=Borrador`.
6. Si la API rechaza, informa el error y pregunta solo por el campo necesario.

Cuando el usuario envie una factura para ser leida desde imagen, PDF o texto, no insertes solo la cabecera si el documento contiene lineas o datos relacionados. Extrae y propone tambien los detalles necesarios:

- Insumos: `Factura_producto` para productos/cantidades/precios; `Factura_cuota` para vencimientos; `Factura_flete` para flete; `Factura_clasificacion` para cuenta, unidad, actividad o centro de costo.
- Granos: `Factura_producto` para productos/granos; `Factura_remision` para remisiones; `Factura_cuota` para vencimientos; `Factura_flete` para flete; `Factura_clasificacion` para clasificación contable.
- Financiero: `Factura_clasificacion` para cuenta/clasificación; `Factura_cuota` para vencimientos; `Factura_baja` para bajas; `Factura_retencion` para retenciones; `Factura_flete` para flete.

Si hay cabecera y detalles, usa `versat_agregar_factura_completa_*`. La tool inyecta `Factura_id` automáticamente después de crear la cabecera.

Si el usuario informa `Doc_num` o `Codigo_control_elec` con guiones, puntos o espacios, no pidas que lo corrija. El MCP normaliza esos campos antes de enviar a Versat y conserva solo dígitos.

## Alta guiada para usuario

Cuando el usuario quiera insertar una factura, no le pidas nombres técnicos como `Documento_tipo_id`, `Operacion_doc_id`, `Entidad_id` o `Moneda_id`. Haz preguntas de negocio y resuelve los IDs con tools.

Primero pregunta solo lo esencial:

1. Tipo de factura: financiera, insumos o granos, si todavía no está claro.
2. Fecha de movimiento y fecha del documento. Si el usuario dice "hoy", usa la fecha actual.
3. Tipo de documento por nombre, por ejemplo FACTURA, NOTA CREDITO o RECIBO.
4. Operación por nombre, pero después de resolver el tipo de documento busca operaciones pasando `documentoTipoId`.
5. Entidad por nombre.
6. Unidad por nombre.
7. Moneda por nombre.
8. Concepto u observación principal.
9. Número de documento, si el tipo de operación lo requiere o si el usuario lo tiene.
10. Condición de pago, cuenta financiera, timbrado, ubicación, depósito, zafra o proyecto solo si la API, el contrato de la tool o la operación lo exige.

Para facturas de insumos, pregunta además los productos como una lista simple: producto, cantidad, precio unitario, tributación si aplica y depósito si aplica. El agente debe resolver `Producto_id` con `versat_buscar_productos_insumos`.

Para facturas de granos, pregunta los datos específicos del flujo de granos solo si el contrato o la operación los exige. No inventes contrato, depósito, chapa, chofer ni transportadora.

Para facturas financieras, pregunta cuenta, clasificación o cuotas solo si el usuario pidió esos detalles o la API los exige.

Si faltan muchos datos, no hagas una lista técnica larga. Pide en bloques cortos: primero cabecera, luego detalles, luego datos exigidos por la API tras el primer intento.

## Actualizar factura

1. Identifica el recurso correcto: AF31, AI71 o AG91.
2. Consulta la factura actual antes de actualizar si el usuario pide cambiar solo un campo.
3. Usa la tool `versat_actualizar_factura_*` del mismo recurso, pasando `id` y `facturaJson`.
4. No mezcles recursos: una factura AI71 se actualiza solo con `versat_actualizar_factura_insumos`.
5. No fuerces `Status=Borrador` en actualización; esa regla aplica solo al alta.
6. Si la API rechaza, muestra el error y pregunta solo por el dato faltante o inválido.

En actualización, `Doc_num` y `Codigo_control_elec` también son normalizados por el MCP para conservar solo dígitos.

## Resolucion de IDs

- Entidad: `versat_listar_entidades`
- Direccion de entidad: `versat_consultar_entidad` con `consulta="direccion"`
- Tipo de documento: `versat_buscar_tipos_documento`
- Operacion: `versat_buscar_operaciones_documento`
- Moneda: `versat_buscar_monedas`
- Condicion de pago: `versat_buscar_condiciones_pago`
- Cuenta: `versat_buscar_cuentas`
- Unidad: `versat_buscar_unidades`
- Deposito: `versat_buscar_depositos`
- Timbrado: `versat_buscar_timbrados`
- Zafra: `versat_buscar_zafras`
- Proyecto: `versat_buscar_proyectos`
- Tributacion: `versat_buscar_tipos_tributacion`
- Actividad de negocio: `versat_buscar_actividades_negocio`
- Centro de costo: `versat_buscar_centros_costo`
- Producto de insumo: `versat_buscar_productos_insumos`

Cuando haya varias coincidencias, elige solo si la coincidencia principal es evidente; si no, pregunta.

Para resolver `Operacion_doc_id` de una factura, primero resuelve `Documento_tipo_id` y después llama `versat_buscar_operaciones_documento` informando `documentoTipoId`. La tool debe consultar `OX56` con `detalle=Operacion_doc` y filtrar por `Documento_tipo_id`, para traer solo operaciones compatibles con ese tipo de documento.
