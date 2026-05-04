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

1. Consulta una pagina pequena para obtener `TotalPages`.
2. Consulta la ultima pagina.
3. Ordena por `Fecha`, `Fecha_doc` e `id` descendente.

## Crear recibo

1. Resuelve unidad, entidad, moneda, cuenta y zafra si aplica.
2. Si faltan campos, llama `versat_agregar_recibo_transaccion` sin JSON.
3. Usa `versat_agregar_recibo_transaccion_completo` cuando haya detalles.
4. Informa id creado y detalles creados.

## Resolucion de IDs

- Unidad: `versat_buscar_unidades`
- Entidad: `versat_listar_entidades`
- Moneda: `versat_buscar_monedas`
- Cuenta: `versat_buscar_cuentas`
- Condicion de pago: `versat_buscar_condiciones_pago`
- Zafra: `versat_buscar_zafras`

## Actualizar recibo

Usa `versat_actualizar_recibo_transaccion` con `id` y `reciboJson`.

No envies cambios parciales supuestos si no tienes el registro base. Para alterar un campo con seguridad, consulta primero el recibo actual, copia sus datos relevantes, cambia el campo pedido y envia el JSON.

## Procesar recibo

Usa `versat_procesar_recibos_transacciones`:

- `Aplicar`
- `Desaplicar`
- `Anular`

Incluye `motivo` para `Desaplicar` o `Anular` cuando el usuario lo informe.

## Detalles

Detalles AF51:

- `Financ_baja`
- `Financ_caja`
- `Financ_factura`

Consulta detalles con `Financ_id`.
