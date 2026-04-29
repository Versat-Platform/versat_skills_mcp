# Entidades BA31

Usa estas reglas para clientes, proveedores, contactos, direcciones, timbrados, codeudores y otros detalles de BA31.

## Tools

- `versat_consultar_entidad`: primera opcion para preguntas de negocio sobre una entidad.
- `versat_listar_entidades`: busqueda/listado general.
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

Si hay multiples coincidencias para una accion que exige una entidad unica, pregunta cual usar antes de escribir o consultar detalles sensibles.

## Detalles tecnicos

No pidas al usuario conocer nombres tecnicos de detalles si existe una consulta de negocio. Cuando sea necesario usar detalle tecnico:

1. Busca la entidad.
2. Toma `id`.
3. Consulta el detalle filtrando por `Entidad_id`.

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
