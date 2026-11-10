# Productos y catálogos OB/BP

## Elegir recurso y resolver referencias

| Recurso | Uso y niveles |
|---|---|
| OB10 | Nombre comercial de producto |
| OB16 | Presentación |
| OB32 | Grupo → subgrupo → cuentas de stock, y costos del grupo |
| OB61 | Línea |
| OB65 | Restricción de línea; usuarios elegibles vinculados a la restricción |
| OB88 | Marca |
| OB89 | Principio activo |
| BP41 | Material y sus lotes |
| BP51 | Insumo, precios, equivalentes, costos, lotes, culturas y experiencias de aplicación |
| BP71 | Precio de producto |

Usa las tools de alta sin cuerpoJson para conocer campos obligatorios, opcionales, reservados, tipos y listas. La búsqueda `versat_buscar_productos_insumos` mantiene su contrato anterior. Para nombres comerciales, presentaciones, grupos, líneas, marcas y principios usa las búsquedas específicas de esos catálogos; para materiales, `versat_buscar_materiales`.

Las referencias auxiliares se consultan mediante `versat_buscar_medidas_productos`, `versat_buscar_culturas`, `versat_buscar_productos_elaborados`, `versat_buscar_fases_cultivo` y `versat_buscar_localizaciones_stock`. No ofrecen escritura en esta ampliación. Reutiliza monedas, tributaciones, cuentas, entidades y tipos de negociación cuando su contrato sea compatible. No adivines ids, tipos de proveedor o selecciones de negocio.

Son catálogos sin procesamiento de documentos. Producto_status admite Activo/Inactivo y no es Status. No intentes Aplicar/Desaplicar/Anular ni atribuyas la invisibilidad de Borradores a sus nuevos registros. No informes empresa/modelo, claves generadas, campos de integración o campos de lectura al escribir.

## Padres, precios y listas

Consulta la tool de tipos de detalle del recurso. Cada consulta/alta/edición de detalle exige el padre inmediato positivo. El subgrupo pertenece a su grupo OB32 y Stock_cuenta al subgrupo. Los lotes de un material BP41 pertenecen a ese material; los detalles BP51 pertenecen al insumo indicado. No reasignes padres ni aceptes JSON que los sustituya.

Precio tiene el mismo contrato en BP51 y BP71. Producto_id es vínculo fijo también cuando editas mediante BP71; no uses esa superficie para trasladar el precio a otro producto. No supongas una regla de unicidad de producto/tipo/moneda que no esté publicada.

Nivel_tecno admite Alto, Bajo y Mediano; Mostrar_desc_sn, Semilla_sn y Lotes_sn admiten Si/No; Tipo_calculo admite Mensual/Anual. No inventes rangos, costos, precios, impuestos, dosis o conversiones. Cero numérico no equivale a dato faltante. Los obligatorios adicionales de marcas, principios y cuentas de stock no están publicados: consulta el contrato y atiende exigencias útiles de Versat sin inventarlas.

## Cuentas elegibles de stock OB32

Para Cuenta_stock_id, Cuenta_costo_id, Cuenta_venta_id, Cuenta_dev_id, Cuenta_costo_exp_id y Cuenta_venta_exp_id de Stock_cuenta usa exclusivamente `versat_buscar_cuentas_stock`. Devuelve IDs y nombres de la selección completa de empresa/modelo autorizado y excluye cuentas de tipo Madre. nombre permite búsqueda local opcional. No sustituyas esta selección por la búsqueda genérica de cuentas ni inventes IDs.

Altas, ediciones y árboles completos verifican esas mismas cuentas; un parche conserva y valida las referencias efectivas omitidas. Una selección incompleta, incompatible o no verificable bloquea la escritura. Atiende cuenta_stock_no_habilitada y herramientaSugerida. La regla no amplía excepciones de cuentas compartidas.

## Usuarios elegibles de OB65

Resuelve Usuario_id de Linea_rest_usuario con `versat_buscar_usuarios_restriccion_linea`. Devuelve solo IDs y nombres elegibles de la empresa autorizada. Puedes informar nombre para buscar localmente; no admite filtros remotos ni elegir empresa/modelo. Si hay varias coincidencias pide la elección de negocio. No inventes IDs ni intentes obtener credenciales o datos internos.

El usuario a restringir se elige entre los devueltos por esa búsqueda y puede ser distinto del usuario autenticado del MCP. Esta regla sustituye la restricción anterior a la identidad numérica del actor. No uses un catálogo de usuarios alternativo para eludir la selección.

Altas, ediciones y árboles completos comprueban que Usuario_id sea positivo y pertenezca a la selección completa del contexto autorizado. Una selección incompleta, incompatible o sin el usuario elegido bloquea antes de escribir cualquier etapa. Atiende `usuario_restriccion_no_habilitado` y herramientaSugerida; conserva IDs confirmados y corrige la referencia del mismo registro, sin repetir árboles ni generar sustitutos.

## Altas completas y fallos

Prefiere `versat_agregar_grupo_producto_completo`, `versat_agregar_restriccion_linea_usuario_completo`, `versat_agregar_material_completo` o `versat_agregar_producto_insumo_completo` para cabecera con hijos. cabeceraJson es un objeto; detallesJson es un array opcional de objetos detalle/cuerpo/subdetalles opcionales. Omitido equivale a vacío y una cabecera sola es válida. Omite vínculos padre y claves generadas: el servidor inyecta ids confirmados por rama.

Se prevalida el árbol y sus referencias antes de escribir, con cincuenta nodos por defecto configurables entre dos y doscientos y presupuesto de lecturas compartido. Un límite o verificación incompleta no autoriza la escritura. Una falla conserva cabeceraId y etapas, sin cuerpos, rollback supuesto o reenvíos automáticos. Continúa solo lo pendiente si puedes verificar su pertenencia. Una etapa incierta exige conciliación antes de continuar; no repitas el árbol completo ni sustituyas el registro creado.

Las ediciones son parciales, no vacías y conservan omitidos. No conviertas un rechazo de referencia en un alta nueva. Sigue campoPendiente/herramientaSugerida cuando aparezcan y conserva los ids confirmados.

## Usuario de experiencias de aplicación BP51

Al agregar Experiencia_aplicacion informa Producto_id mediante el padre, Fecha y Obs. El MCP asigna internamente el usuario autenticado, también en el alta completa del insumo. No informes Usuario_ro_id, no elijas otro usuario ni uses el usuario seleccionado para una restricción OB65 como autor.

La identidad debe verificarse de forma única dentro de la empresa autorizada; si no puede verificarse, el MCP bloquea antes de escribir cualquier etapa. Atiende usuario_experiencia_no_verificable sin inventar IDs o repetir altas. Para editar, usa el id confirmado y un parche de campos editables: se conserva el usuario original y no puede reasignarse la autoría.
