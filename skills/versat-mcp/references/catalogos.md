# Catalogos e ids auxiliares

Usa esta referencia para resolver ids antes de crear o actualizar documentos. No pidas al usuario un id tecnico cuando exista una tool que permita buscarlo por nombre.

## Tools habituales

- `versat_buscar_monedas`
- `versat_buscar_tipos_cotizacion`
- `versat_buscar_unidades`
- `versat_buscar_tipos_documento`
- `versat_buscar_operaciones_documento`
- `versat_buscar_condiciones_pago`
- `versat_buscar_cuentas`
- `versat_buscar_depositos`
- `versat_buscar_timbrados`
- `versat_buscar_zafras`
- `versat_buscar_proyectos`
- `versat_buscar_tipos_tributacion`
- `versat_buscar_actividades_negocio`
- `versat_buscar_centros_costo`
- `versat_buscar_productos_insumos`
- `versat_buscar_rucs`
- `versat_buscar_empresas`
- `versat_listar_tipos_factura`
- `versat_sugerir_tipo_factura`
- `versat_buscar_tipos_negociacion`

## Flujo seguro

1. Identifica el catálogo requerido por el contrato del campo y recurso. Usa su tool específica cuando exista; una cuenta válida en un catálogo general puede no servir para una cabecera, clasificación contable o movimiento de caja.
2. Busca por el nombre informado por el usuario.
3. Si existe una coincidencia clara, usa su id sin pedirlo al usuario.
4. Si hay varias coincidencias razonables, muestra de dos a cinco opciones con nombres amigables y pide confirmacion.
5. Si no hay coincidencias, informa el criterio usado y pide un dato distintivo; no inventes ids.

## Operaciones de documento

Para resolver la operación de la cabecera de una factura, primero resuelve el tipo de documento y usa la tool específica del recurso:

- AF31: `versat_buscar_operaciones_documento_factura_financiero`
- AG91: `versat_buscar_operaciones_documento_factura_granos`
- AI71: `versat_buscar_operaciones_documento_factura_insumos`

Usa `versat_buscar_operaciones_documento` únicamente en otros contextos sin una tool específica. En ese caso, informa `documentoTipoId` y el tipo de factura correspondiente: `AI71`, `AG91` o `AF31`.

Presenta el resultado como una operacion habilitada para facturas financieras, de insumos o de granos. No expongas al usuario nombres tecnicos usados para validar esa compatibilidad.

## Timbrados

Para `versat_buscar_timbrados`, el tipo de documento es obligatorio. Primero resuelve el tipo de documento y llama la tool informando `documentoTipoId`.

El MCP bloquea un timbrado solo si la consulta de expedidores publica una incompatibilidad para ese timbrado y tipo de documento. Si la consulta auxiliar no devuelve el timbrado, Versat valida el dato al crear la factura. Si falta `documentoTipoId`, no busques timbrados ni sugieras ids.

En las búsquedas específicas de timbrado por factura, informa únicamente el contexto de la emisión: para `El Parcero`, entidad y emisión; para `La Empresa`, tipo de documento, unidad y emisión.

## Empresa actual

Para consultas sobre "mi empresa", usa `versat_buscar_empresas`. La tool limita la consulta a la empresa autorizada; no la conviertas en una busqueda libre por nombre ni permitas elegir otra empresa.

`OX01` es solo lectura. No intentes crear, actualizar ni eliminar empresas.

## Catalogos dependientes del contexto

Usa las tools publicas normalmente para cuentas, tributacion, operaciones y otros catalogos dependientes de empresa o modelo. El MCP aplica internamente el contexto autorizado.

## Cotizaciones de monedas

Si falta la cotización del día, consulta `versat_buscar_cotizaciones_monedas` con fecha y tipo. Resuelve el tipo con `versat_buscar_tipos_cotizacion`; si no existe cotización, pide los valores de compra y venta y propone `versat_agregar_cotizacion_moneda`. No inventes importes ni crees una cotización sin autorización.

Ante errores o resultados ambiguos, aplica [Resultados y recuperación](resultados.md). Si no se pudo validar empresa o modelo, no sustituyas el contexto autorizado por un ID elegido por el usuario.
