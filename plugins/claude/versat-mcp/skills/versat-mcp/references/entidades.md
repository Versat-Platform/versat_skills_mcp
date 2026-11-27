# Entidades BA31

## Elegir la herramienta

| Necesidad | Tool |
| --- | --- |
| Listar clientes, proveedores u otras entidades o buscar candidatos por nombre o CI | `versat_listar_entidades` |
| Encontrar entidades por número de RUC | `versat_buscar_entidades_por_ruc` |
| Resolver el identificador del RUC para un alta o una actualización | `versat_buscar_rucs` |
| Consultar el resumen, la dirección, los contactos u otros datos | `versat_consultar_entidad` |
| Descubrir los aspectos de negocio disponibles | `versat_listar_consultas_entidad` |
| Consultar una clase de detalle específica | `versat_consultar_detalle_entidad` |
| Crear o editar la entidad | `versat_agregar_entidad` o `versat_actualizar_entidad` |
| Crear o editar un detalle | `versat_agregar_detalle_entidad` o `versat_actualizar_detalle_entidad` |

## Listar y continuar

Traduce las palabras del usuario a los filtros de negocio. Para «liste os fornecedores ativos», usa `versat_listar_entidades` con `{"tipoEntidad":"Proveedor","estadoEntidad":"Activo","vistaResumida":true}`. Para «mostre meus clientes», usa `tipoEntidad=Cliente` y deja el estado abierto. Si el usuario dice «clientes do exterior», usa `Cliente Exterior`.

| Término que puede usar el usuario | Filtro `tipoEntidad` |
| --- | --- |
| Cliente, clientes | `Cliente` |
| Proveedor, provedor, fornecedor, fornecedores | `Proveedor` |
| Clientes do exterior, clientes del exterior | `Cliente Exterior` |
| Fornecedores do exterior, proveedores del exterior | `Proveedor Exterior` |
| Vendedores, bancos, transportadoras, funcionários | `Vendedor`, `Banco`, `Transportadora`, `Funcionario`, respectivamente |

El servidor acepta estas variantes y usa la clasificación canónica para la lectura. Cuando se pidan dos listados, solicita un tipo por llamada y conserva los filtros comunes. Si el usuario quiere entidades que tengan ambas clasificaciones, consulta una de ellas y revisa que `tipos` incluya la segunda en cada fila. Comunica el alcance si quedan páginas pendientes. Evita pedir aclaraciones cuando el tipo se desprende de la solicitud.


Ejemplo de listado resumido de clientes activos cuyo nombre contiene un término.

```json
{"nombre":"Comercial Norte","tipoEntidad":"Cliente","estadoEntidad":"Activo","pagina":0,"registrosPorPagina":20,"vistaResumida":true}
```

- Los criterios se combinan. `tipoEntidad` recibe un tipo completo. `Cliente` incluye un registro clasificado como `Cliente, Proveedor`. `Cliente Exterior` es una clasificación distinta. Los estados admitidos son `Activo`, `Inactivo` y `Prospecto`.
- En la vista resumida, lee `registros` para obtener identificador, nombre, tipos, estado y documento enmascarado cuando esté disponible. En búsquedas anteriores por `Descripcion_cb`, la respuesta flexible puede devolver `coincidencias` y `coincidenciaPrincipal`. La primera coincidencia orienta la selección. El total depende del alcance indicado.
- Continúa con `alcanceBusqueda.siguientePagina` cuando exista. Reenvía el mismo nombre, filtros, tamaño y `varianteNombre` si aparece. Las páginas 0 y 1 corresponden al mismo tramo inicial y avanzan a la página 2. Un tramo vacío puede tener continuación.
- Usa `ordenConsulta: "Recientes"` con los filtros y el tamaño. Omite `pagina` y `offset`. Revisa las páginas evaluadas y la verificación de recencia antes de afirmar que son los registros más recientes.
- Para llamadas nuevas, usa `pagina` y `registrosPorPagina`. Las existentes pueden conservar `limit` y `offset`. El desplazamiento debe ser múltiplo de `limit`, o de 100 si se omite `limit`.

Si una búsqueda por nombre sigue sin resolver la solicitud, usa un dato distintivo o un documento que el usuario pueda aportar. La búsqueda flexible considera nombres invertidos, puntuación y abreviaturas societarias. Si el alcance es parcial o una lectura falló, comunica esa situación y evita multiplicar consultas equivalentes.

## Buscar por documento

Para CI, envía el valor como texto para conservar sus ceros iniciales. Ejemplo para `versat_listar_entidades`.

```json
{"filtroCampo":"CI_uk","filtroValor":"00123456","vistaResumida":true}
```

Para RUC, invoca `versat_buscar_entidades_por_ruc` con el número tal como está registrado, incluidos los separadores y el dígito verificador cuando corresponda.

```json
{"ruc":"00123-4"}
```

La respuesta devuelve `candidatos` y `alcanceCompleto`. Usa el `entidadId` del candidato confirmado para el resumen o el detalle. Si necesitas el identificador del catálogo para escribir `Ruc_id`, consúltalo mediante `versat_buscar_rucs`. `Ruc_uk` es el número en el catálogo BA51 y `Ruc_id` es el vínculo que admite BA31.

## Consultar una entidad confirmada

Si la consulta devuelve `requiereSeleccion`, pide al usuario que confirme la entidad usando los nombres y los documentos enmascarados disponibles. Un único candidato en una muestra incompleta también puede requerir confirmación. Después, usa su identificador en `versat_consultar_entidad`.

```json
{"consulta":"contactos","filtroCampo":"id","filtroValor":"123"}
```

Usa `resumen` para los datos principales. También puedes pedir `direccion`, `contactos`, `timbrados`, `familiares`, `limites`, `garantias`, `codeudores`, `referencias`, `clt`, `regimen_especial` o `balance`. Si necesitas una clase específica como `Contacto`, llama a `versat_consultar_detalle_entidad` con `detalle`, `filtroCampo: "id"` y el identificador confirmado en `filtroValor`. El servidor vincula la lectura a esa entidad.

## Crear o actualizar

- **Alta.** Llama a `versat_agregar_entidad` sin `entidadJson` para ver los campos. Confirma si se usará RUC o CI si el usuario no lo indicó. Para RUC, resuelve `Ruc_id` con `versat_buscar_rucs`. Para CI, informa `CI_uk`. Si encuentras una entidad que podría ser la misma, confirma la intención de crear otro registro antes de escribir.
- **Tipo de persona.** Cuando se informe, usa `Persona` con `Física` o `Jurídica`. El servidor normaliza variantes y acepta `Persona_juridica_sn` como alias de entrada. `Si` se traduce a `Jurídica` y `No` a `Física`. Los valores contradictorios se rechazan.
- **Clasificación.** Informa `Entidad_tipo` en el alta. Para más de un tipo, usa una lista separada por comas, como `Cliente, Proveedor`. La tool publica las clasificaciones admitidas.
- **Actualización.** Usa `versat_actualizar_entidad` con el `id` confirmado y un `entidadJson` parcial con los campos solicitados. La misma normalización de persona se aplica al editar.
- **Detalles.** Invoca la tool de alta o actualización sin `detalleJson` para ver el contrato de la clase. Incluye `Entidad_id` cuando el contrato lo requiera. En una actualización, el argumento `id` identifica el detalle que se edita.

Sigue [Resultados y recuperación](resultados.md) para interpretar los errores. Si una escritura queda incierta, verifica qué ocurrió antes de repetirla. Para una lectura temporal, respeta la espera indicada cuando esté disponible.
