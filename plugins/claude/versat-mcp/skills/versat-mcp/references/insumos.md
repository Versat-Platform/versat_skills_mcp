# Pedidos, cancelaciones, pagarés y comisiones de insumos

## Elegir el recurso

| Recurso | Uso y niveles |
|---|---|
| AI11 | Pedido → Pedido_producto → Pedido_producto_fidelizacion |
| AI15 | Cancelación de una línea de pedido, sin detalles publicados |
| AI81 | Pagaré de insumos con Pagare_entidad y Pagare_titulo |
| AI91 | Provisión de comisiones → Comision_vendedor → Comision_baja |

Cada recurso permite listar, agregar, actualizar y procesar mediante tools específicas. Consulta la tool de alta sin cuerpoJson para conocer todos los campos, referencias y enumeraciones. No inventes precios, cantidades, importes o fechas; los códigos no sustituyen ids.

## Referencias y detalles

Para AI11 usa `versat_buscar_tipos_pedido_insumos` por entidad, `versat_buscar_vendedores_pedido_insumos` para entidades activas de tipo Vendedor, `versat_buscar_condiciones_pago_pedido_insumos` por entidad/zafra y `versat_buscar_centros_costo_pedido_insumos` por actividad. Sin zafra, solo condiciones generales con zafra cero; con zafra, misma entidad y zafra. El centro puede ser general o de la actividad efectiva; sin actividad solo generales. No sustituyas estas selecciones por catálogos genéricos.

Para AI15 usa `versat_buscar_pedidos_cancelar_insumos` por unidad y `versat_buscar_productos_pedido_cancelar_insumos` por la misma unidad y pedido. Resuelve entidad y producto coherentes con esas selecciones y usa `versat_buscar_motivos_cancelacion_pedido`. Para fidelizaciones AI11 usa `versat_buscar_campanas_marketing`; la existencia de la campaña no demuestra por sí sola elegibilidad de cliente o producto. Los dos catálogos auxiliares solo ofrecen lectura.

AI81 resuelve Flujo_caja_id con `versat_buscar_titulos_pagare_insumos` usando entidadId, monedaId y zafraId opcional. Zafra omitida no restringe; cero no es un id válido. Usa el mismo contexto efectivo del pagaré. Si no puede verificarse la selección o su alcance completo, detén la escritura dependiente sin sustituir la selección ni adivinar ids. Tipo_codeudor admite Codeudor, Cónyuge o Representante Legal.

AI91 usa cuentas del modelo autorizado. Vend_ma admite Manualmente o Automaticamente; Generar_iva admite Sumar al valor, Incluido en el valor o Sin IVA. Comision_baja solo recibe Valor y Comision_vendedor_id; no informes referencias de origen de solo lectura ni calcules IVA/comisiones por conjetura.

Las tools `versat_obtener_tipos_detalle_pedido_insumos`, `versat_obtener_tipos_detalle_pagare_insumos` y `versat_obtener_tipos_detalle_provision_comisiones_insumos` describen cada clase. Al consultar, agregar o actualizar detalles informa detalle y padreId del padre inmediato: Pedido_id para productos; Pedido_producto_id para fidelizaciones; Pagare_id para entidades/títulos; Comision_prov_id para vendedores; Comision_vendedor_id para bajas. No reasignes padres ni uses el id propio del hijo como vínculo.

## Altas completas y recuperación

Prefiere `versat_agregar_pedido_insumos_completo`, `versat_agregar_pagare_insumos_completo` o `versat_agregar_provision_comisiones_insumos_completa` para crear un árbol. cabeceraJson contiene un objeto y detallesJson un array no vacío de objetos detalle/cuerpo/subdetalles opcionales. Omite padres y claves generadas: el servidor inyecta ids confirmados por rama. AI81 tiene detalles directos sin subdetalles. El máximo predeterminado es 50 nodos contando cabecera e hijos, configurable de 2 a 200; el presupuesto puede imponer un límite anterior.

Todas las altas con estado nacen en Borrador y nunca aplican automáticamente. Omite Status, empresa/modelo y claves generadas en actualizaciones; usa parches parciales no vacíos. Las transiciones Aplicar/Desaplicar/Anular usan sus tools de procesamiento con hasta cien ids positivos.

Conserva cabeceraId y etapas. No repitas un árbol parcial ni asumas rollback. Los borradores no son consultables hasta aplicar: consulta vacía no demuestra inexistencia. El alta completa usa ids confirmados sin releer padres nuevos; entre llamadas la continuación individual puede bloquearse cuando no pueda verificar pertenencia/contexto. `verificacion_registro_no_disponible` exige detenerse y conservar ids; un manifiesto reenviado no prueba permiso o estado actual. No apliques documentos incompletos para volverlos visibles. Una escritura incierta requiere conciliación autorizada antes de continuar; una desconexión puede impedir recibir el manifiesto y no hay diario duradero garantizado.

Los listados usan paginación acotada, sin Recientes u operadores inferidos. Una página vacía no demuestra ausencia global; un límite o error tampoco. Sigue siempre el contrato vigente y las señales de detención y espera. La preparación por historial de facturas/recibos no se extiende a estos recursos.

## Edición por id y cuentas compartidas AI91

Los parches escalares de cabecera se envían directamente con el id positivo confirmado, sin consultar previamente el Borrador. Usa un objeto parcial no vacío con campos editables; omite Status, contexto y claves generadas. El servidor valida acceso y tipos y conserva la autorización definitiva del registro en Versat. Un id conocido no sustituye autenticación. No repitas un parche incierto.

Cambiar referencias o editar detalles sigue exigiendo comprobar el registro efectivo y su pertenencia; esos caminos pueden bloquearse si el Borrador es invisible. No uses el parche escalar para cambiar vínculos ni apliques documentos incompletos para consultarlos.

En AI91, las cuentas de provisión y resultado pueden ser compartidas sin empresa únicamente si su modelo positivo coincide con el autorizado. Empresa distinta, modelo ausente o modelo ajeno bloquean la escritura. Esta excepción no se extiende a otros recursos o referencias y no permite informar empresa/modelo en el cuerpo.
