# Recibos y transacciones AF51

En pruebas de inserción autorizadas, aplica el recibo al finalizar únicamente si la cabecera y todos sus detalles fueron creados correctamente. Fuera de esas pruebas, procesa solo si la solicitud incluye esa acción. No apliques altas parciales.

## Tools

- `versat_listar_recibos_transacciones`
- `versat_agregar_recibo_transaccion`
- `versat_agregar_recibo_transaccion_completo`
- `versat_actualizar_recibo_transaccion`
- `versat_procesar_recibos_transacciones`
- `versat_agregar_detalle_recibo_transaccion`
- `versat_actualizar_detalle_recibo_transaccion`
- `versat_consultar_detalle_recibo_transaccion`
- `versat_listar_detalles_recibos_transacciones`

## Recientes

Sigue [Buscar los registros más recientes](resultados.md#buscar-los-registros-más-recientes). Mantén filtros y tamaño de página; si falta un total válido, informa el alcance de los registros recuperados sin inventar la última página.

## Crear recibo

1. Resuelve unidad, entidad, moneda, cuenta y zafra si aplica. Para entidad, aplica la estrategia de busqueda flexible de `references/entidades.md`.
2. Si faltan campos, llama `versat_agregar_recibo_transaccion` sin JSON.
3. Usa `versat_agregar_recibo_transaccion_completo` cuando haya detalles.
4. Informa id creado y detalles creados.

La cabecera y cada cuerpo de detalle deben ser objetos JSON completos. El servidor valida sus campos obligatorios antes de escribir. Si devuelve `json_alta_invalido` o `campos_obligatorios_alta_faltantes`, corrige solo el cuerpo señalado y no reintentes sin cambios.

Checklist minimo antes de crear:

- Entidad unica confirmada.
- Unidad, moneda y fecha definidas.
- Cuenta o caja resuelta cuando el movimiento lo requiere.
- Valores y sentido del movimiento claros: entrada, salida, baja o factura vinculada.
- Detalles preparados si el comprobante contiene caja, baja o factura vinculada.

Cuando el usuario envie un recibo o comprobante para ser leido desde imagen, PDF o texto, no insertes solo la cabecera si el documento contiene detalles. Extrae y propone tambien:

- `Financ_caja`: movimiento de caja/cuenta, entrada o salida, moneda, condición, cuenta, cheque y valor.
- `Financ_caja_cuota`: cuota del movimiento de caja; se crea después de `Financ_caja` con el id devuelto por ese detalle.
- `Financ_baja`: baja o cancelación de títulos/flujo de caja, valor baja, descuento o interés.
- `Financ_factura`: factura/documento financiero vinculado al recibo.

`Financ_factura` crea la cabecera de una factura no provisionada. El id que devuelve el alta del detalle es su `Factura_id`. Antes de aplicar el recibo, usa ese id con `versat_agregar_detalle_factura_financiero` para crear `Factura_clasificacion`, `Factura_cuota` y cualquier otro detalle AF31 exigido por la operación, la cuenta o la condición de pago. Si una clasificación necesita centro de costo o devengamiento, crea después `Factura_clasificacion_cc` o `Factura_clasificacion_deveng` usando el id de la clasificación. No apliques la factura por separado: completa sus detalles y aplica solamente el AF51.

Si hay cabecera y detalles, usa `versat_agregar_recibo_transaccion_completo`. La tool inyecta `Financ_id` automáticamente después de crear la cabecera.

## Resolucion de IDs

- Unidad: `versat_buscar_unidades`
- Entidad: lee `references/entidades.md` y usa `versat_listar_entidades` con `Descripcion_cb`; no descartes coincidencias por espacios, puntuacion, orden de nombres o abreviaturas como `S.A.`.
- Moneda: `versat_buscar_monedas`
- Otras cuentas contables: `versat_buscar_cuentas`, solo cuando el contrato no indique una búsqueda específica.
- Condicion de pago: `versat_buscar_condiciones_pago`
- Zafra: `versat_buscar_zafras`
- Título o flujo de caja para `Financ_baja`: `versat_buscar_flujos_caja_baja_titulos_recibo`, informando la entidad del recibo o transacción. Use el resultado como `Flujo_caja_id`.
- Cuenta de movimiento de caja: `versat_buscar_cuentas_movimiento_caja_recibo`, informando solamente la moneda. No envíe el movimiento como filtro de esta consulta. Use el resultado como `Cuenta_id` de `Financ_caja`.
- Cheque de movimiento de caja: `versat_buscar_cheques_movimiento_caja_recibo`, sin filtros adicionales. Use el resultado como `Cheque_id` de `Financ_caja`.
- Centro de costo de movimiento de caja: `versat_buscar_centros_costo_movimiento_caja_recibo`, informando la actividad de negocio. La tool aplica internamente la empresa autorizada; no pida `Empresa_id` al usuario.

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

Si Versat exige un recibo de cobro o informa una diferencia entre Total debe y Total haber, no crees otro AF51. Consulta los detalles del recibo en borrador y corrige la cabecera, `Financ_baja`, `Financ_caja` o `Financ_caja_cuota` con `versat_actualizar_recibo_transaccion` y `versat_actualizar_detalle_recibo_transaccion`; aplica solo después de verificar que los totales están equilibrados.

## Detalles

Detalles AF51:

- `Financ_baja`
- `Financ_caja`
- `Financ_caja_cuota`
- `Financ_factura`

Consulta los detalles directos con `Financ_id`. Para `Financ_caja_cuota`, usa `Financ_caja_id` del movimiento de caja padre, no el ID del recibo.

Para agregar o consultar detalles:

1. Confirma el `id` del recibo/transaccion padre.
2. Usa el campo de relación del contrato: `Financ_id` para detalles directos o `Financ_caja_id` para sus cuotas.
3. Si no sabes campos del detalle, llama la tool sin JSON para obtener el contrato.
4. Si hay varias clases posibles, pregunta cual corresponde al comprobante.

Antes de aplicar, si la condición del movimiento de caja exige cuotas, crea `Financ_caja_cuota`. La suma y cantidad de cuotas deben corresponder al `Valor` y a la `Condicion_id` del `Financ_caja`.

Antes de aplicar un AF51 con `Financ_factura`, extrae el ID generado de cada `resultado.cuerpo` devuelto para ese detalle y úsalo como `Factura_id`. Completa la factura no provisionada con las tools de detalles AF31; no envíes el objeto de respuesta completo como ID. El recibo solo está listo para aplicar cuando esas facturas tienen sus clasificaciones, cuotas y subdetalles requeridos.

Usa solamente campos admitidos por el contrato de AF51 o del detalle seleccionado. La tool rechaza un `filtroCampo` inventado o perteneciente a otro recurso.

## Errores y recuperacion

- Clasifica las señales y los reintentos según [Resultados y recuperación](resultados.md). Un fallo temporal no demuestra ausencia de recibos ni que una escritura haya sido revertida.
- Error por campo obligatorio: pregunta solo ese dato.
- Error por entidad ambigua: resuelve entidad con la referencia de entidades antes de insistir.
- Éxito parcial: conserva los IDs conocidos, consulta cabecera y detalles y completa únicamente lo que falte en ese recibo. No repitas la tool completa ni apliques mientras falten cuotas o detalles de facturas no provisionadas.
- Si el usuario pide anular o desaplicar sin motivo y la tool lo exige, pregunta el motivo.
