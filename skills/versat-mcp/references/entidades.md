# Entidades BA31

Usa estas reglas para clientes, proveedores, contactos, direcciones, timbrados, codeudores y otros detalles de BA31.

## Indice

- [Tools](#tools)
- [Patron rapido](#patron-rapido)
- [Busqueda por nombre](#busqueda-por-nombre)
- [Crear o actualizar entidad](#crear-o-actualizar-entidad)
- [Detalles tecnicos](#detalles-tecnicos)
- [Errores y ambiguedad](#errores-y-ambiguedad)

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

Para "dados da entidade X", primero busca candidatos:

```json
{"filtroCampo":"Descripcion_cb","filtroValor":"X","limit":10}
```

Si la coincidencia principal es clara y no hay ambiguedad razonable, consulta el aspecto pedido:

```json
{"consulta":"resumen","filtroCampo":"Descripcion_cb","filtroValor":"X","limit":10}
```

Para direccion/contactos/timbrados/codeudores:

```json
{"consulta":"contactos","filtroCampo":"Descripcion_cb","filtroValor":"Diego Silva","limit":10}
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

Flujo seguro para agentes:

1. Determina si el usuario quiere consultar, crear, actualizar o agregar un detalle.
2. Si hay nombre de entidad, busca candidatos antes de consultar detalles o escribir.
3. Si hay una unica coincidencia clara, continua con esa entidad.
4. Si hay varias coincidencias razonables, muestra opciones y pide confirmacion.
5. Si no hay coincidencias, repite con terminos distintivos antes de decir que no se encontro.
6. Para escribir, usa el `id` de la entidad confirmada y no el texto escrito por el usuario.

## Busqueda por nombre

Usa `Descripcion_cb` como campo principal:

```json
{"filtroCampo":"Descripcion_cb","filtroValor":"Ana","limit":10}
```

Si el usuario pide "liste todas", trae suficientes resultados para responder, pero evita cargas grandes sin necesidad. Si hay muchas coincidencias, resume y ofrece continuar.

Los nombres pueden estar invertidos o escritos con pequenas diferencias. Ejemplo: el usuario puede pedir `MATILDE RUIZ DIAZ ALCARAZ` y Versat puede tener `ALCARAZ, MATILDE RUIZ DIAS`. Usa igualmente `Descripcion_cb`; el MCP intenta variaciones y similitud de tokens antes de devolver "no encontrado".

Antes de concluir que no existe una entidad, aplica esta estrategia:

1. Busca primero el texto informado por el usuario con `Descripcion_cb` y un `limit` razonable.
2. Si no hay resultado o hay muchas coincidencias debiles, repite con el termino distintivo mas fuerte. Ejemplo: de `GIGANET S.A.` usa tambien `GIGANET`; de `LA SEMILLA - ESTANCIA` usa tambien `LA SEMILLA` y `ESTANCIA`.
3. Ignora diferencias de mayusculas, acentos, puntos, comas, guiones y espacios dobles al comparar candidatos.
4. Trata abreviaturas societarias como equivalentes: `S.A.`, `SA`, `SOCIEDAD ANONIMA`, `SOCIEDAD ANÓNIMA` y `SOCIEDADE ANONIMA`.
5. Para personas, prueba orden normal e invertido: `Nombre Apellido`, `Apellido, Nombre` y `Apellido Nombre`.
6. Si aparece una coincidencia clara por tokens significativos, usa esa entidad; si aparecen varias razonables, muestra opciones con nombre y documento si existe, y pide confirmacion.

Cuando `versat_listar_entidades` devuelva busqueda flexible, usa estos campos para decidir:

- `coincidenciaPrincipal`: candidato mejor ranqueado por el MCP.
- `coincidencias`: lista de candidatos para comparar si hay ambiguedad.
- `totalCoincidencias`: cantidad de candidatos encontrados.
- `criterioBusqueda="nombre_flexible"`: indica que el MCP ya intento variaciones de nombre, separadores, espacios y tokens.

Elige directamente solo cuando `coincidenciaPrincipal` sea claramente la entidad pedida. Si dos o mas candidatos tienen nombres parecidos o documentos distintos, pregunta cual usar antes de consultar detalles sensibles o escribir.

Ejemplos de busqueda flexible:

- Usuario: `GIGANET S.A.`; candidato valido: `GIGANET SOCIEDADE ANONIMA`.
- Usuario: `LA SEMILLA ESTANCIA`; candidato valido: `LA SEMILLA -  ESTANCIA`.
- Usuario: `MATILDE RUIZ DIAZ ALCARAZ`; candidato valido: `ALCARAZ, MATILDE RUIZ DIAS`.

Si hay multiples coincidencias para una accion que exige una entidad unica, pregunta cual usar antes de escribir o consultar detalles sensibles.

Pregunta de confirmacion recomendada:

```text
Encontré varias entidades posibles. ¿Cuál debo usar?
1. Nombre - documento si existe - id
2. Nombre - documento si existe - id
```

## Crear o actualizar entidad

Para crear una entidad:

1. Si faltan campos, llama `versat_agregar_entidad` sin `entidadJson`.
2. Antes de insertar, confirma si la entidad usará `RUC` o `CI` cuando el usuario no lo haya informado.
3. Si usa `RUC`, busca primero en BA51 con `versat_buscar_rucs` y envía el id encontrado como `Ruc_id`.
4. Si usa `CI`, envía el número en `CI_uk`.
5. Envia `entidadJson` con los nombres exactos de campos BA31.
6. Si la API rechaza, muestra el error y pregunta solo por el dato faltante o invalido.

No crees entidad si:

- No sabes si el documento debe ser RUC o CI.
- El usuario dio un nombre que coincide con una entidad existente y no confirmo que quiere crear una nueva.
- Faltan campos obligatorios del contrato de la tool.
- El `Ruc_id` requerido no fue resuelto por `versat_buscar_rucs`.

Para actualizar:

1. Busca o consulta la entidad actual para confirmar el `id`.
2. Usa `versat_actualizar_entidad` con `id` y `entidadJson`.
3. No cambies campos no solicitados si no tienes el registro base.
4. Si el cambio puede afectar datos sensibles, resume el cambio y pide confirmacion antes de ejecutar.

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

## Errores y ambiguedad

- Si la tool devuelve `reintentar=true`, espera y reintenta una vez; no digas que la entidad no existe.
- Si la API devuelve validacion de campo obligatorio, pregunta solo ese campo.
- Si una busqueda devuelve cero resultados con nombre largo, repite con el apellido, razon social principal o palabra mas distintiva.
- Si el usuario pide datos sensibles de una entidad ambigua, no muestres detalles de candidatos; pide elegir primero.
- Si el usuario pide "todos", limita la respuesta inicial y ofrece continuar para evitar respuestas enormes.
