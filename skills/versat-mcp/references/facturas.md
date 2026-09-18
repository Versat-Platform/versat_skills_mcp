# Facturas

Usa estas reglas para listar, inspeccionar, crear, actualizar, duplicar o procesar facturas en Versat MCP.

Usa los filtros publicados por la tool específica del recurso. No deduzcas filtros nuevos de campos presentes en una respuesta ni consultes fuentes internas.

En pruebas de inserción autorizadas, aplica la factura al finalizar únicamente si la cabecera y todos sus detalles fueron creados correctamente. Fuera de esas pruebas, procesa solo si la solicitud del usuario incluye esa acción. No apliques altas parciales.

## Indice

- [Seleccion de tipo](#seleccion-de-tipo)
- [Mapa rapido](#mapa-rapido)
- [Registros recientes](#registros-recientes)
- [Consultar detalles](#consultar-detalles)
- [Crear o duplicar factura](#crear-o-duplicar-factura)
- [Alta guiada para usuario](#alta-guiada-para-usuario)
- [Actualizar factura](#actualizar-factura)
- [Procesar factura](#procesar-factura)
- [Resolucion de IDs](#resolucion-de-ids)
- [Errores y recuperacion](#errores-y-recuperacion)

## Seleccion de tipo

Si el usuario dice solo "crear/cadastrar una factura", no adivines. Llama:

- `versat_sugerir_tipo_factura`
- o `versat_listar_tipos_factura`

Si sigue ambiguo, pregunta si quiere factura `financiera`, de `insumos` o de `granos`.

No uses palabras sueltas como unica evidencia. Ejemplos:

- "producto", "insumo", "deposito" suelen indicar insumos, pero confirma si no es claro.
- "granos", "silo", "remision de granos" suele indicar granos.
- "cuenta", "cobro", "pago", "financiero" suele indicar financiero.

## Mapa rapido

`AF31` facturas financieras:

- listar: `versat_listar_facturas_financiero`
- agregar: `versat_agregar_factura_financiero`
- actualizar: `versat_actualizar_factura_financiero`
- agregar completa: `versat_agregar_factura_completa_financiero`
- detalle: `versat_consultar_detalle_factura_financiero`
- actualizar detalle: `versat_actualizar_detalle_factura_financiero`
- procesar: `versat_procesar_facturas_financiero`

`AI71` facturas de insumos:

- listar: `versat_listar_facturas_insumos`
- agregar: `versat_agregar_factura_insumos`
- actualizar: `versat_actualizar_factura_insumos`
- agregar completa: `versat_agregar_factura_completa_insumos`
- detalle: `versat_consultar_detalle_factura_insumos`
- actualizar detalle: `versat_actualizar_detalle_factura_insumos`
- procesar: `versat_procesar_facturas_insumos`
- productos facturados: detalle `Factura_producto`

`AG91` facturas de granos:

- listar: `versat_listar_facturas_granos`
- agregar: `versat_agregar_factura_granos`
- actualizar: `versat_actualizar_factura_granos`
- agregar completa: `versat_agregar_factura_completa_granos`
- detalle: `versat_consultar_detalle_factura_granos`
- actualizar detalle: `versat_actualizar_detalle_factura_granos`
- procesar: `versat_procesar_facturas_granos`

## Registros recientes

Sigue [Buscar los registros más recientes](resultados.md#buscar-los-registros-más-recientes): conserva filtros y tamaño de página al calcular la última página, y no interpretes metadatos nulos como cero. Ordenar una muestra no demuestra que contenga las últimas facturas del conjunto.

Cuando una factura sea compleja y necesites una referencia contable anterior, usa la tool automática del mismo recurso:

- AF31: `versat_buscar_ejemplos_contables_factura_financiero`
- AI71: `versat_buscar_ejemplos_contables_factura_insumos`
- AG91: `versat_buscar_ejemplos_contables_factura_granos`

Informa la operación ya resuelta y, cuando estén disponibles, tipo de documento, entidad y moneda. La tool localiza las páginas recientes y recupera clasificaciones con centros de costo. Usa esos datos solo como referencia: vuelve a resolver catálogos vigentes y no copies fechas, importes, números, timbrados ni estados.

## Consultar detalles

Para productos, cuotas, fletes, clasificaciones, bajas o remisiones de una factura, filtra por el id padre:

```json
{"detalle":"Factura_producto","filtroCampo":"Factura_id","filtroValor":"123","pagina":0,"registrosPorPagina":100}
```

Usa la tool de detalle del mismo recurso de la factura. No mezcles AI71, AF31 y AG91.

Usa solamente campos admitidos por el contrato de la cabecera o del detalle seleccionado. Las tools rechazan un `filtroCampo` inventado o perteneciente a otro recurso.

Los subdetalles se consultan con el mismo patrón: recurso de la cabecera y `detalle` con el nombre técnico del subdetalle. Para insertar o actualizar un subdetalle, primero debe existir el detalle padre y debes usar el id generado por ese detalle.

Subdetalles conocidos:

- AF31: `Factura_clasificacion_cc` y `Factura_clasificacion_deveng` bajo `Factura_clasificacion`.
- AG91: `Factura_clasificacion_cc` bajo `Factura_clasificacion`.
- AI71: `Factura_producto_lote` bajo `Factura_producto` y `Factura_clasificacion_cc` bajo `Factura_clasificacion`.

En clasificaciones contables, si Versat informa que una cuenta requiere centro de costo, inserta `Factura_clasificacion_cc` con el `Factura_clasificacion_id` correspondiente y reintenta solo después de corregir ese dato.

Para resolver `Centro_costo_id` de `Factura_clasificacion_cc`, usa la tool específica del recurso e informa la actividad de negocio de la clasificación padre:

- AF31: `versat_buscar_centros_costo_clasificacion_factura_financiero`
- AI71: `versat_buscar_centros_costo_clasificacion_factura_insumos`
- AG91: `versat_buscar_centros_costo_clasificacion_factura_granos`

El MCP incluye centros vinculados a esa actividad y centros generales sin actividad, siempre restringidos a la empresa autorizada. No pidas ni envíes `Empresa_id`.

## Crear o duplicar factura

1. Identifica el recurso.
2. Si faltan campos, llama la tool de agregar sin JSON para leer obligatorios/opcionales.
3. Resuelve IDs con catalogos antes de escribir.
4. Si hay detalles, prefiere la tool completa.
5. Para copias, toma la factura origen, elimina campos tecnicos (`id`, textos calculados, auditoria), cambia fechas y deja que el MCP fuerce `Status=Borrador`.
6. Si la tool rechaza la solicitud, informa solo el mensaje de negocio y pregunta por el campo necesario.

La cabecera y cada cuerpo de detalle deben ser objetos JSON completos. El servidor rechaza JSON inválido y campos obligatorios ausentes antes de crear la cabecera; corrige los campos listados y vuelve a intentar una sola vez con el cuerpo completo.

Checklist minimo antes de crear:

- Tipo de factura definido: financiera, insumos o granos.
- Tipo de documento resuelto.
- Operacion resuelta para el tipo de factura y empresa.
- Entidad unica confirmada.
- Unidad, moneda y fecha definidas.
- Numero de documento definido cuando aplique.
- Si se usara timbrado, tipo de documento resuelto antes de buscarlo.
- Detalles preparados cuando el usuario envio lineas, cuotas, productos, remisiones, fletes, retenciones o clasificaciones.

Cuando el usuario envie una factura para ser leida desde imagen, PDF o texto, no insertes solo la cabecera si el documento contiene lineas o datos relacionados. Extrae y propone tambien los detalles necesarios:

- Insumos: `Factura_producto` para productos/cantidades/precios; `Factura_cuota` para vencimientos; `Factura_flete` para flete; `Factura_clasificacion` para cuenta, unidad, actividad o centro de costo.
- Granos: `Factura_producto` para productos/granos; `Factura_remision` para remisiones; `Factura_cuota` para vencimientos; `Factura_flete` para flete; `Factura_clasificacion` para clasificación contable.
- Financiero: `Factura_clasificacion` para cuenta/clasificación; `Factura_cuota` para vencimientos; `Factura_baja` para bajas; `Factura_retencion` para retenciones; `Factura_flete` para flete.

Si hay cabecera y detalles, usa `versat_agregar_factura_completa_*`. La tool inyecta `Factura_id` automáticamente después de crear la cabecera.

Los contratos de factura exigen números JSON, ids enteros positivos, fechas ISO válidas y cadenas para textos. No envíes objetos o arreglos como valores escalares ni repitas campos con distinta capitalización. Ante `campos_factura_invalidos`, corrige los campos señalados. El servidor valida todo el árbol antes de crear la cabecera.

Las retenciones admiten `Factura_cuota` y `Factura_clasificacion` dentro de `subdetalles`; en AG91 también `Factura_remision`. El servidor inyecta `Factura_id` con el id generado por la retención. Una clasificación anidada puede incluir centros de costo y devengamientos cuando el recurso los admita. No uses el id de la factura principal para esos hijos. Para centros de costo, lotes o devengamientos, incluye cada subdetalle en la propiedad `subdetalles` del detalle padre; la tool crea primero el padre e inyecta también su id.

Si un producto de AI71 controla lote, crea primero `Factura_producto` y después `Factura_producto_lote` con el id del producto facturado. En el alta del subdetalle no envíes `Producto_lote_id`: Versat lo genera. Informa `Factura_producto_id`, `Producto_id`, `Lote_id` y `Cantidad`. El servidor rechaza `Producto_lote_id`, productos distintos del padre y cantidades cuya suma exceda la facturada. Comprueba también pertenencia al producto y depósito y el saldo informado; en altas individuales considera las asignaciones existentes. Ante `lote_factura_invalido`, corrige los datos señalados antes de volver a enviar.

Resuelve `Lote_id` con `versat_buscar_lotes_producto_factura_insumos`. Informa producto, depósito, fecha y las opciones Si/No para admitir lotes vencidos y lotes sin saldo. Con `incluirLotesSinSaldo=No`, la tool excluye lotes con saldo físico y contable cero; con `Si`, solo los incluye si su configuración permite mostrarlos sin saldo.

Si el usuario informa `Doc_num` o `Codigo_control_elec` con guiones, puntos o espacios, no pidas que lo corrija. El MCP normaliza esos campos antes de enviar a Versat y conserva solo dígitos.

## Alta guiada para usuario

Cuando el usuario quiera insertar una factura, no le pidas nombres técnicos como `Documento_tipo_id`, `Operacion_doc_id`, `Entidad_id` o `Moneda_id`. Haz preguntas de negocio y resuelve los IDs con tools.

Primero pregunta solo lo esencial:

1. Tipo de factura: financiera, insumos o granos, si todavía no está claro.
2. Fecha de movimiento y fecha del documento. Si el usuario dice "hoy", usa la fecha actual.
3. Tipo de documento por nombre, por ejemplo FACTURA, NOTA CREDITO o RECIBO.
4. Operación por nombre, pero después de resolver el tipo de documento busca operaciones pasando `documentoTipoId`.
5. Entidad por nombre, aplicando la estrategia de busqueda flexible de `references/entidades.md`.
6. Unidad por nombre.
7. Moneda por nombre.
8. Concepto u observación principal.
9. Número de documento, si el tipo de operación lo requiere o si el usuario lo tiene.
10. Condicion de pago, cuenta financiera, timbrado, ubicacion, deposito, zafra o proyecto solo si el contrato de la tool o la operacion lo exige.

Para facturas de insumos, pregunta además los productos como una lista simple: producto, cantidad, precio unitario, tributación si aplica y depósito si aplica. Después de resolver el depósito, el agente debe resolver `Producto_id` con `versat_buscar_productos_factura_insumos`, que devuelve los productos activos con stock válidos para `Factura_producto`.

Para facturas de granos, pregunta los datos específicos del flujo de granos solo si el contrato o la operación los exige. No inventes contrato, depósito, chapa, chofer ni transportadora.

Para facturas financieras, pregunta cuenta, clasificacion o cuotas solo si el usuario pidio esos detalles o el contrato de la tool los exige.

Si faltan muchos datos, no hagas una lista tecnica larga. Pide en bloques cortos: primero cabecera, luego detalles y despues los datos que la tool marque como obligatorios.

Ejemplo de pregunta por bloque:

```text
Para crear la factura necesito confirmar estos datos de cabecera: tipo de factura, fecha, entidad, moneda y número de documento. Después resolvemos productos/cuotas si corresponde.
```

## Actualizar factura

1. Identifica el recurso correcto: AF31, AI71 o AG91.
2. Consulta la factura actual antes de actualizar si el usuario pide cambiar solo un campo.
3. Usa la tool `versat_actualizar_factura_*` del mismo recurso, pasando `id` y `facturaJson`.
4. No mezcles recursos: una factura AI71 se actualiza solo con `versat_actualizar_factura_insumos`.
5. Omite `Status` de las actualizaciones de cabecera, detalle y subdetalle, incluso cuando sea nulo o Borrador. Su presencia provoca `status_factura_no_actualizable`; usa la tool de procesamiento para cambiar el estado.
6. Si la tool rechaza la solicitud, muestra solo el mensaje de negocio y pregunta por el dato faltante o invalido.

En actualización, `Doc_num` y `Codigo_control_elec` también son normalizados por el MCP para conservar solo dígitos.

## Procesar factura

Usa la tool `versat_procesar_facturas_*` del mismo recurso:

- `Aplicar`
- `Desaplicar`
- `Anular`

Reglas:

1. Confirma el recurso correcto antes de procesar.
2. Usa ids de facturas existentes, no numeros de documento sin resolver.
3. Para `Desaplicar` o `Anular`, incluye motivo si el usuario lo dio; si el motivo es obligatorio y falta, pregunta.
4. No cambies `Status` manualmente con update para aplicar, desaplicar o anular.
5. Si hay varios documentos con el mismo numero, pide confirmacion.
6. Si la respuesta incluye `accionRequerida`, `campoPendiente`, `herramientaSugerida` o `instruccionParaAgente`, corrige la misma factura en borrador y verifica el cambio antes de volver a procesarla.
7. Ante “Informe la Cuenta”, resuelve la cuenta con la tool específica del recurso, actualiza `Cuenta_id` en la cabecera existente y vuelve a aplicar solo después de verificarla.
8. Ante “Registre los detalles”, consulta los tipos y detalles del recurso, completa los detalles y subdetalles exigidos en el mismo borrador y vuelve a aplicar únicamente después de verificarlos. No crees otra factura para sustituirla.

## Resolucion de IDs

- Entidad: lee `references/entidades.md` y usa `versat_listar_entidades` con `Descripcion_cb`; no descartes coincidencias por espacios, puntuacion, orden de nombres o abreviaturas como `S.A.`.
- Direccion de entidad: `versat_consultar_entidad` con `consulta="direccion"`
- Tipo de documento: `versat_buscar_tipos_documento`
- Operación de cabecera AF31: `versat_buscar_operaciones_documento_factura_financiero`, informando el tipo de documento previamente resuelto.
- Operación de cabecera AG91: `versat_buscar_operaciones_documento_factura_granos`, informando el tipo de documento previamente resuelto.
- Operación de cabecera AI71: `versat_buscar_operaciones_documento_factura_insumos`, informando el tipo de documento previamente resuelto.
- Factura de referencia de cabecera AI71: `versat_buscar_facturas_referencia_insumos`, informando entidad y zafra. Use `zafraId=0` solo cuando no deba restringirse por zafra.
- Tipo de pedido de cabecera AI71: `versat_buscar_tipos_pedido_factura_insumos`, informando la entidad. La tool aplica internamente la empresa autorizada; no pidas `Empresa_id` al usuario.
- Producto facturado AI71: `versat_buscar_productos_factura_insumos`, informando el depósito. Use el resultado como `Producto_id` de `Factura_producto`; la búsqueda excluye productos inactivos.
- Tributación de producto facturado AI71: `versat_buscar_tributaciones_producto_factura_insumos`, informando el tipo de documento. Use el resultado como `Tributacion_id` de `Factura_producto`.
- Producto de pedido para facturar AI71: `versat_buscar_pedidos_producto_factura_insumos`, informando entidad, producto, zafra y si es devolución. La devolución se filtra localmente porque no es un filtro admitido por la consulta. Use `zafraId=0` para omitir el filtro de zafra.
- Centro de costo de producto facturado AI71: `versat_buscar_centros_costo_producto_factura_insumos`, informando la actividad de negocio. La tool aplica internamente la empresa autorizada; no pidas `Empresa_id` al usuario.
- Tributación de Fletes y Seguros AI71: `versat_buscar_tributaciones_flete_factura_insumos`, informando el tipo de documento.
- Centro de costo de Fletes y Seguros AI71: `versat_buscar_centros_costo_flete_factura_insumos`, informando la actividad de negocio. La tool aplica internamente la empresa autorizada.
- Cuenta de clasificación contable AI71: `versat_buscar_cuentas_clasificacion_factura_insumos`, informando moneda y operación. La tool usa `Moneda_id`; no envíe `Moneda_doc_id` ni sentido contable. Esta búsqueda es distinta de la cuenta de cabecera.
- Tributación de clasificación contable AI71: `versat_buscar_tributaciones_clasificacion_factura_insumos`, informando el tipo de documento. No use el catálogo general de tributaciones para este campo.
- Flujo de caja de baja de anticipos AI71: `versat_buscar_flujos_caja_baja_factura_insumos`, informando la entidad. No envíe el sentido del movimiento, porque esta búsqueda solo necesita la entidad. Use el resultado como `Flujo_caja_id` de `Factura_baja`.
- Factura de referencia de cabecera AG91: `versat_buscar_facturas_referencia_granos`, informando entidad y zafra. Use `zafraId=0` solo cuando la búsqueda no deba restringirse por zafra.
- Contrato de cabecera AG91: `versat_buscar_contratos_factura_granos`, informando entidad y zafra. Use `zafraId=0` solo cuando la búsqueda no deba restringirse por zafra.
- Cheque de cabecera AG91: `versat_buscar_cheques_factura_granos`. La consulta no requiere filtros adicionales.
- Producto facturado AG91: `versat_buscar_productos_factura_granos`, informando el depósito. Use el resultado como `Producto_id` de `Factura_producto`; la búsqueda excluye productos inactivos.
- Tributación de producto facturado AG91: `versat_buscar_tributaciones_producto_factura_granos`, informando el tipo de documento. Use el resultado como `Tributacion_id` de `Factura_producto`.
- Centro de costo de producto facturado AG91: `versat_buscar_centros_costo_producto_factura_granos`, informando la actividad de negocio. La tool aplica internamente la empresa autorizada; no pidas `Empresa_id` al usuario.
- Tributación de Fletes y Seguros AG91: `versat_buscar_tributaciones_flete_factura_granos`, informando el tipo de documento.
- Cuenta de clasificación contable AG91: `versat_buscar_cuentas_clasificacion_factura_granos`, informando moneda y operación. La tool usa `Moneda_id`; no envíe `Moneda_doc_id` ni sentido contable.
- Tributación de clasificación contable AG91: `versat_buscar_tributaciones_clasificacion_factura_granos`, informando el tipo de documento.
- Flujo de caja de baja de anticipos AG91: `versat_buscar_flujos_caja_baja_factura_granos`, informando la entidad. No envíe el sentido del movimiento, porque esta búsqueda solo necesita la entidad.
- Opción completa de remisión AG91: `versat_buscar_opciones_factura_granos_con_remision`, informando entidad y zafra. Usa juntos los ids de remisión, producto, depósito, operación y contrato de una misma opción; no mezcles resultados. La tool descarta contratos vinculados sin saldo de facturación.
- Remisión a liquidar AG91: `versat_buscar_remisiones_liquidar_factura_granos`, informando entidad y zafra, solo para consultas simples antes de resolver la combinación completa.
- Otras operaciones: `versat_buscar_operaciones_documento`
- Moneda: `versat_buscar_monedas`
- Tipo de cotizacion: `versat_buscar_tipos_cotizacion`
- Condicion de pago: `versat_buscar_condiciones_pago`
- Cuenta de cabecera AF31: `versat_buscar_cuentas_factura_financiero`, después de resolver moneda y operación. No envíe condición de pago ni sentido contable a esta consulta, ni use el catálogo general de cuentas para este campo.
- Cuenta de cabecera AG91: `versat_buscar_cuentas_factura_granos`, después de resolver moneda y operación. No envíe condición de pago ni sentido contable a esta consulta, ni use el catálogo general de cuentas para este campo.
- Cuenta de cabecera AI71: `versat_buscar_cuentas_factura_insumos`, después de resolver moneda y operación. No envíe condición de pago ni sentido contable a esta consulta, ni use el catálogo general de cuentas para este campo.
- Cuenta de clasificación contable AF31: `versat_buscar_cuentas_clasificacion_factura_financiero`, después de resolver moneda y operación. La tool usa `Moneda_id`; no envíe `Moneda_doc_id` ni sentido contable. Esta búsqueda es distinta de la cuenta de cabecera.
- Tributación de clasificación contable AF31: `versat_buscar_tributaciones_clasificacion_factura_financiero`, informando el tipo de documento previamente resuelto. No use el catálogo general de tributaciones para este campo.
- Tributación de Fletes y Seguros AF31: `versat_buscar_tributaciones_flete_factura_financiero`, informando el tipo de documento previamente resuelto. Use el resultado como `Tributacion_id` de `Factura_flete`.
- Flujo de caja de baja de anticipos AF31: `versat_buscar_flujos_caja_baja_factura_financiero`, informando la entidad. No envíe el sentido del movimiento, porque esta búsqueda solo necesita la entidad. Use el resultado como `Flujo_caja_id` de `Factura_baja`.
- Otras cuentas contables: `versat_buscar_cuentas`
- Unidad: `versat_buscar_unidades`
- Deposito: `versat_buscar_depositos`
- Timbrado general: `versat_buscar_timbrados` informando siempre `documentoTipoId`. Para las tools específicas de factura, la consulta requiere entidad y emisión cuando emite `El Parcero`, o tipo de documento, unidad y emisión cuando emite `La Empresa`. No uses un timbrado si no existe una coincidencia compatible.
- Zafra: `versat_buscar_zafras`
- Proyecto: `versat_buscar_proyectos`
- Tributacion: `versat_buscar_tipos_tributacion`
- Actividad de negocio: `versat_buscar_actividades_negocio`
- Centro de costo: `versat_buscar_centros_costo`
- Producto de insumo: `versat_buscar_productos_insumos`

Cuando haya varias coincidencias, elige solo si la coincidencia principal es evidente; si no, pregunta.

Para resolver la operación de cabecera, primero resuelve el tipo de documento. En AF31 llama `versat_buscar_operaciones_documento_factura_financiero`; en AG91 llama `versat_buscar_operaciones_documento_factura_granos`; en AI71 llama `versat_buscar_operaciones_documento_factura_insumos`. Informa `documentoTipoId` en cada caso. Para otros contextos sin tool específica, usa `versat_buscar_operaciones_documento` con el tipo de factura correspondiente. Usa el id retornado como `Operacion_doc_id` en el JSON, pero al responder al usuario muestra el nombre amigable de la operación, no el campo técnico.

No digas al usuario “tipoFactura=AI71” ni “campoTipoFactura=Factura_insumos_sn”. Traduce esa validación como “operación habilitada para facturas de insumos”, “operación habilitada para facturas de granos” o “operación habilitada para facturas financieras”.

## Errores y recuperacion

- Para clasificar errores y decidir un reintento, sigue [Resultados y recuperación](resultados.md). `reintentar=false` tiene prioridad y un código `servicio_versat_*` no basta para repetir una operación.
- Error por campo obligatorio: pregunta solo ese campo y vuelve a intentar con el JSON corregido.
- Error por operacion no habilitada: busca otra operacion valida para el mismo tipo de documento y tipo de factura; no inventes `Operacion_doc_id`.
- Error por falta de cotizacion del dia: usa `versat_buscar_cotizaciones_monedas` con la fecha del documento y el tipo de cotizacion. Si no existe, confirma `Compra` y `Venta` con el usuario y sugiere crearla con `versat_agregar_cotizacion_moneda`.
- Error por entidad ambigua: vuelve a `references/entidades.md` y pide confirmacion.
- Éxito parcial: conserva la cabecera, los detalles y subdetalles confirmados. Consulta los registros existentes y retoma únicamente lo faltante según [Recuperar una escritura por etapas](resultados.md#recuperar-una-escritura-por-etapas); no repitas la tool completa.
- Respuesta vacia al buscar recientes: revisa paginacion antes de decir que no hay facturas.
