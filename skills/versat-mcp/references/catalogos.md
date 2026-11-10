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
2. Busca por el nombre informado por el usuario. Cuando la tool exponga `buscarPor`, usa Nombre o Codigo según el dato disponible; Auto respeta los campos propios del recurso. Cuentas, productos y monedas pueden admitir código; revisa el contrato. No conviertas códigos numéricos en ids.
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

Para consultas sobre "mi empresa", usa `versat_buscar_empresas`. La tool publica únicamente la empresa autorizada por el token y no envía empresa en la URL; no la conviertas en una busqueda libre por nombre ni permitas elegir otra empresa.

`OX01` es solo lectura. No intentes crear, actualizar ni eliminar empresas.

## Catalogos dependientes del contexto

Usa las tools publicas normalmente para cuentas, tributacion, operaciones y otros catalogos dependientes de empresa o modelo. El MCP aplica internamente el contexto autorizado.

## Cotizaciones de monedas

Si falta la cotización del día, consulta `versat_buscar_cotizaciones_monedas` con fecha y tipo. Resuelve el tipo con `versat_buscar_tipos_cotizacion`; si no existe cotización, pide los valores de compra y venta y propone `versat_agregar_cotizacion_moneda`. No inventes importes ni crees una cotización sin autorización.

Ante errores o resultados ambiguos, aplica [Resultados y recuperación](resultados.md). Si no se pudo validar empresa o modelo, no sustituyas el contexto autorizado por un ID elegido por el usuario.

## Alcance de las búsquedas

Las colecciones paginables usan página 0 y 100 registros por defecto, según configuración. Conserva filtros y tamaño al continuar. Solo entidades y RUCs usan variantes personales o societarias. Los demás catálogos evitan esa expansión.

Las selecciones específicas de documentos conservan sus parámetros de elegibilidad. Usa `pagina` y `registrosPorPagina` en las selecciones que los exponen. No agregues texto o parámetros ausentes del contrato, ni sustituyas sus resultados por un catálogo general. Revisa `alcanceBusqueda`: un límite o volumen excesivo requiere precisar la consulta, y una muestra vacía no demuestra inexistencia global.

## Recursos humanos

Para AR05, resuelve Centro_costo_id exclusivamente con `versat_buscar_centros_costo_contrato_trabajo`, según su actividad y contexto autorizado. Usa las tools de cargos, escalas y tipos de contrato para las otras referencias. Para AR11, operaciones y eventos se obtienen con `versat_buscar_operaciones_hoja_pago` y `versat_buscar_eventos_hoja_pago`; los eventos de una operación se consultan con `versat_listar_eventos_operacion_hoja_pago`. Consulta [Recursos humanos](recursos-humanos.md) para los vínculos entre hoja, funcionario y evento.

Los siete catálogos OR permiten también mantenimiento autorizado: profesiones OR51 y feriados OR65 completan eventos, operaciones, cargos, escalas y tipos de contrato. OR31, OR61 y OR65 incluyen detalles y altas completas con verificación del padre nuevo. Horarios y Dia_mes son strings sin máscara; OR65 se lista por año/id. Consulta [Recursos humanos](recursos-humanos.md) antes de crear o editar y conserva ids ante parciales.

En horarios OR61, Dia_semana admite varios días documentados separados por coma sin repetir. Las cuentas OX03 compartidas sin empresa se aceptan únicamente por modelo autorizado coincidente; una empresa ajena no nula sigue bloqueada.

## Referencias de documentos de insumos

Para AI15 usa `versat_buscar_motivos_cancelacion_pedido`; para fidelización AI11, `versat_buscar_campanas_marketing`. Son de solo lectura. Los títulos AI81 se resuelven con `versat_buscar_titulos_pagare_insumos` por entidad/moneda/zafra opcional; no uses una selección de recibos como sustituto. Consulta [Documentos de insumos](insumos.md).

## Productos y catálogos OB/BP

[Productos y catálogos](productos.md) describe la gestión OB10/OB16/OB32/OB61/OB65/OB88/OB89 y BP41/BP51/BP71, sus relaciones, listas y altas completas. Para materiales usa versat_buscar_materiales; la búsqueda BP51 anterior permanece. Usuario_id del detalle OB65 se resuelve con versat_buscar_usuarios_restriccion_linea entre usuarios elegibles de la empresa autorizada; la selección completa se valida antes de escribir. No se limita al usuario autenticado del MCP y no publica credenciales.
