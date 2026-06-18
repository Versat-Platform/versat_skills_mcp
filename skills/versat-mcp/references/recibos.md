# Recibos y transacciones AF51

## Tools

- `versat_listar_recibos_transacciones`
- `versat_agregar_recibo_transaccion`
- `versat_agregar_recibo_transaccion_completo`
- `versat_actualizar_recibo_transaccion`
- `versat_procesar_recibos_transacciones`
- `versat_agregar_detalle_recibo_transaccion`
- `versat_consultar_detalle_recibo_transaccion`
- `versat_listar_detalles_recibos_transacciones`

## Recientes

Versat pagina de antiguo a nuevo. Para ultimos recibos:

1. Consulta `pagina=0` con pocos registros para obtener `infoPaginacion.totalPages`.
2. Calcula la ultima pagina como `max(infoPaginacion.totalPages - 1, 0)`.
3. Consulta esa ultima pagina.
4. Ordena por `Fecha`, `Fecha_doc` e `id` descendente.

Si la tool no devuelve paginacion, ordena los registros recibidos por fecha/id antes de responder. No asumas que el primer registro es el mas reciente.

## Crear recibo

1. Resuelve unidad, entidad, moneda, cuenta y zafra si aplica. Para entidad, aplica la estrategia de busqueda flexible de `references/entidades.md`.
2. Si faltan campos, llama `versat_agregar_recibo_transaccion` sin JSON.
3. Usa `versat_agregar_recibo_transaccion_completo` cuando haya detalles.
4. Informa id creado y detalles creados.

Checklist minimo antes de crear:

- Entidad unica confirmada.
- Unidad, moneda y fecha definidas.
- Cuenta o caja resuelta cuando el movimiento lo requiere.
- Valores y sentido del movimiento claros: entrada, salida, baja o factura vinculada.
- Detalles preparados si el comprobante contiene caja, baja o factura vinculada.

Cuando el usuario envie un recibo o comprobante para ser leido desde imagen, PDF o texto, no insertes solo la cabecera si el documento contiene detalles. Extrae y propone tambien:

- `Financ_caja`: movimiento de caja/cuenta, entrada o salida, moneda, condición, cuenta, cheque y valor.
- `Financ_baja`: baja o cancelación de títulos/flujo de caja, valor baja, descuento o interés.
- `Financ_factura`: factura/documento financiero vinculado al recibo.

Si hay cabecera y detalles, usa `versat_agregar_recibo_transaccion_completo`. La tool inyecta `Financ_id` automáticamente después de crear la cabecera.

## Resolucion de IDs

- Unidad: `versat_buscar_unidades`
- Entidad: lee `references/entidades.md` y usa `versat_listar_entidades` con `Descripcion_cb`; no descartes coincidencias por espacios, puntuacion, orden de nombres o abreviaturas como `S.A.`.
- Moneda: `versat_buscar_monedas`
- Cuenta: `versat_buscar_cuentas`
- Condicion de pago: `versat_buscar_condiciones_pago`
- Zafra: `versat_buscar_zafras`

## Actualizar recibo

Usa `versat_actualizar_recibo_transaccion` con `id` y `reciboJson`.

No envies cambios parciales supuestos si no tienes el registro base. Para alterar un campo con seguridad, consulta primero el recibo actual, copia sus datos relevantes, cambia el campo pedido y envia el JSON.

Si el usuario informa solo numero o entidad, busca candidatos y confirma el recibo exacto antes de actualizar.

## Procesar recibo

Usa `versat_procesar_recibos_transacciones`:

- `Aplicar`
- `Desaplicar`
- `Anular`

Incluye `motivo` para `Desaplicar` o `Anular` cuando el usuario lo informe.

No actualices `Status` manualmente para aplicar, desaplicar o anular. Usa siempre la tool de procesamiento.

## Detalles

Detalles AF51:

- `Financ_baja`
- `Financ_caja`
- `Financ_factura`

Consulta detalles con `Financ_id`.

Para agregar o consultar detalles:

1. Confirma el `id` del recibo/transaccion padre.
2. Usa `Financ_id` como filtro o relacion.
3. Si no sabes campos del detalle, llama la tool sin JSON para obtener el contrato.
4. Si hay varias clases posibles, pregunta cual corresponde al comprobante.

Usa solamente campos admitidos por el contrato de AF51 o del detalle seleccionado. La tool rechaza un `filtroCampo` inventado o perteneciente a otro recurso.

## Errores y recuperacion

- `reintentar=true`: informa falla temporal y no lo trates como ausencia de recibos.
- Error por campo obligatorio: pregunta solo ese dato.
- Error por entidad ambigua: resuelve entidad con la referencia de entidades antes de insistir.
- Exito parcial en tool completa: informa cabecera creada, detalles creados y etapa fallida; verifica antes de repetir.
- Si el usuario pide anular o desaplicar sin motivo y la tool lo exige, pregunta el motivo.
