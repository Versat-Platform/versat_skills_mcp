# Catalogos e ids auxiliares

Usa esta referencia para resolver ids antes de crear o actualizar documentos. No pidas al usuario un id tecnico cuando exista una tool que permita buscarlo por nombre.

## Tools habituales

- `versat_buscar_monedas`
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

1. Identifica el catalogo requerido por el contrato de la tool de negocio.
2. Busca por el nombre informado por el usuario.
3. Si existe una coincidencia clara, usa su id sin pedirlo al usuario.
4. Si hay varias coincidencias razonables, muestra de dos a cinco opciones con nombres amigables y pide confirmacion.
5. Si no hay coincidencias, informa el criterio usado y pide un dato distintivo; no inventes ids.

## Operaciones de documento

Para `versat_buscar_operaciones_documento`, primero resuelve el tipo de documento. Luego informa `documentoTipoId` y el tipo de factura correspondiente: `AI71`, `AG91` o `AF31`.

Presenta el resultado como una operacion habilitada para facturas financieras, de insumos o de granos. No expongas al usuario nombres tecnicos usados para validar esa compatibilidad.

## Empresa actual

Para consultas sobre "mi empresa", usa `versat_buscar_empresas`. La tool limita la consulta a la empresa autorizada; no la conviertas en una busqueda libre por nombre ni permitas elegir otra empresa.

`OX01` es solo lectura. No intentes crear, actualizar ni eliminar empresas.

## Catalogos dependientes del contexto

Usa las tools publicas normalmente para cuentas, tributacion, operaciones y otros catalogos dependientes de empresa o modelo. El MCP aplica internamente el contexto autorizado.
