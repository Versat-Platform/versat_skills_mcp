# Entidades BA31

Usa estas reglas para clientes, proveedores, contactos, direcciones, timbrados, codeudores y otros detalles de BA31.

## Tools

- `versat_consultar_entidad`: primera opcion para preguntas de negocio sobre una entidad.
- `versat_listar_entidades`: busqueda/listado general.
- `versat_agregar_entidad`: crea una entidad BA31. Si no envias JSON, devuelve campos obligatorios/opcionales.
- `versat_actualizar_entidad`: actualiza una entidad BA31 existente por `id`.
- `versat_buscar_rucs`: busca registros BA51 para obtener el `Ruc_id` usado por BA31.
- `versat_agregar_detalle_entidad`: crea un detalle BA31 como `Contacto`, `Entidad_ubicacion` o `Timbrado_entidad`.
- `versat_actualizar_detalle_entidad`: actualiza un detalle BA31 existente por `id` y `detalle`.
- `versat_consultar_detalle_entidad`: detalle tecnico cuando necesitas una clase especifica.
- `versat_listar_consultas_entidad`: descubre consultas de negocio disponibles.

## Patron rapido

Para "dados da entidade X":

```json
{"consulta":"resumen","filtroCampo":"Descripcion_cb","filtroValor":"X","limit":1}
```

Para direccion/contactos/timbrados/codeudores:

```json
{"consulta":"contactos","filtroCampo":"Descripcion_cb","filtroValor":"Diego Silva","limit":1}
```

Cambia `consulta` segun la necesidad:

- `resumen`
- `direccion`
- `contactos`
- `timbrados`
- `familiares`
- `limites`
- `garantias`
- `codeudores`
- `referencias`
- `clt`
- `regimen_especial`
- `balance`

## Busqueda por nombre

Usa `Descripcion_cb` como campo principal:

```json
{"filtroCampo":"Descripcion_cb","filtroValor":"Ana","limit":10}
```

Si el usuario pide "liste todas", trae suficientes resultados para responder, pero evita cargas grandes sin necesidad. Si hay muchas coincidencias, resume y ofrece continuar.

Los nombres pueden estar invertidos o escritos con pequenas diferencias. Ejemplo: el usuario puede pedir `MATILDE RUIZ DIAZ ALCARAZ` y Versat puede tener `ALCARAZ, MATILDE RUIZ DIAS`. Usa igualmente `Descripcion_cb`; el MCP intenta variaciones y similitud de tokens antes de devolver "no encontrado".

Si hay multiples coincidencias para una accion que exige una entidad unica, pregunta cual usar antes de escribir o consultar detalles sensibles.

## Crear o actualizar entidad

Para crear una entidad:

1. Si faltan campos, llama `versat_agregar_entidad` sin `entidadJson`.
2. Antes de insertar, confirma si la entidad usará `RUC` o `CI` cuando el usuario no lo haya informado.
3. Si usa `RUC`, busca primero en BA51 con `versat_buscar_rucs` y envía el id encontrado como `Ruc_id`.
4. Si usa `CI`, envía el número en `CI_uk`.
5. Envia `entidadJson` con los nombres exactos de campos BA31.
6. Si la API rechaza, muestra el error y pregunta solo por el dato faltante o invalido.

Para actualizar:

1. Busca o consulta la entidad actual para confirmar el `id`.
2. Usa `versat_actualizar_entidad` con `id` y `entidadJson`.
3. No cambies campos no solicitados si no tienes el registro base.

## Detalles tecnicos

No pidas al usuario conocer nombres tecnicos de detalles si existe una consulta de negocio. Cuando sea necesario usar detalle tecnico:

1. Busca la entidad.
2. Toma `id`.
3. Consulta el detalle filtrando por `Entidad_id`.

Para crear o actualizar detalles:

1. Si no sabes los campos, llama `versat_agregar_detalle_entidad` o `versat_actualizar_detalle_entidad` sin `detalleJson`.
2. Usa siempre una clase de detalle valida.
3. Incluye `Entidad_id` en el JSON del detalle cuando la clase lo requiera.
4. Para actualizar un detalle, usa el `id` del detalle, no el `id` de la entidad.

Detalles conocidos:

- `Contacto`
- `Entidad_ubicacion`
- `Entidad_familiar`
- `Entidad_limite`
- `Entidad_garantia`
- `Entidad_codeudor`
- `Cliente_referencia`
- `Timbrado_entidad`
- `Entidad_clt`
- `Entidad_reg_especial`
- `Entidad_balance`
