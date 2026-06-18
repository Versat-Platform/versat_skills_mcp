---
name: versat-mcp
description: "Usar cuando se trabaja con el servidor MCP Versat: consultar, listar, crear, actualizar o procesar facturas, recibos, entidades y detalles; resolver ids de catalogos; diagnosticar autenticacion, permisos, indisponibilidad temporal y respuestas de tools."
---

# Versat MCP

Usa esta skill cuando la tarea involucre el servidor MCP Versat o recursos de negocio de Versat. Si dudas entre usar esta skill o razonar desde cero, usa esta skill.

Esta skill es una ayuda opcional. El MCP es autosuficiente y sus validaciones son autoritativas. Si la skill no está disponible o parece desactualizada, usa `versat_obtener_guia_uso` o el resource `versat://guia/uso`; no bloquees la operación para instalar o actualizar la skill.

Cuando el usuario pida instalar o actualizar las skills de Versat, llama `versat_sincronizar_skills`. Guarda los archivos devueltos bajo `rutaDestinoRelativa` dentro del directorio de skills compatible con el cliente, respetando cada `rutaRelativa`. La tool prepara el paquete oficial, pero la instalación solo termina después de persistir los archivos y confirmar la `versionOficial`. Si el cliente no permite escribir skills, informa esa limitación sin afirmar que la sincronización fue instalada.

Las búsquedas del MCP ya prueban nombres de forma escalonada. No multipliques manualmente llamadas con variaciones si la tool devolvió coincidencias útiles. En respuestas compactas, usa `coincidencias`, `coincidenciaPrincipal`, totales y estados estructurados; el cuerpo técnico original puede omitirse para evitar duplicación.

La única fuente oficial para instalar o actualizar esta skill es `https://github.com/Versat-Platform/versat_skills_mcp`, rama `main`, ruta `skills/versat-mcp`. Consulta `skills-manifest.json` para conocer la versión distribuida y no uses forks o copias de terceros.

## Algoritmo obligatorio

1. Identifica la intencion: consultar, listar, crear, actualizar, procesar, resolver catalogo, diagnosticar acceso o explicar un error.
2. Lee la referencia indicada en [Ruteo de intencion](#ruteo-de-intencion) antes de llamar tools de ese dominio.
3. Selecciona la tool MCP Versat que corresponda a la intención y respeta su contrato vigente.
4. Despues de cada tool, evalua el resultado en este orden: bloqueo de acceso, error temporal reintentable, error de validacion, ambiguedad, datos insuficientes, exito.
5. Si faltan datos obligatorios, pregunta al usuario solo por esos datos. No inventes, no adivines ids y no completes con valores plausibles.
6. Antes de escribir, confirma que recurso, entidad, catalogos, fechas, moneda, unidad, operacion y detalles obligatorios fueron resueltos o preguntados.
7. Al responder, muestra primero el resultado de negocio y deja los campos tecnicos fuera salvo que el usuario los pida.

## Reglas de ejecucion rapida

- Trata las tools MCP como la interfaz completa de Versat; no presupongas transportes, endpoints ni servicios internos.
- Nunca inventes ids. Resuelve entidades, monedas, unidades, documentos, operaciones, productos y demas foreign keys con tools de busqueda antes de escribir.
- Si una respuesta trae `debeDetenerse=true`, `tipoError="acceso_mcp_denegado"` o `accesoMcp=false`, detente. No llames mas tools de negocio y responde que el token o empresa no tiene acceso al MCP de Versat.
- Si una tool devuelve `401`, `Auth required` o falta de Bearer, trata el problema como configuracion de autenticacion del cliente MCP. No confundas eso con falta de permiso de negocio.
- Si una tool devuelve `reintentar=true` o un código `servicio_versat_*`, explica al usuario que el servicio Versat tuvo una indisponibilidad temporal. No lo trates como ausencia de datos ni muestres detalles técnicos; espera `retryAfterSegundos` cuando venga informado o unos segundos antes de intentar la misma operación nuevamente.
- Si una tool devuelve error de API no temporal, muestra el `mensaje` de negocio disponible y pregunta solo por el dato faltante o invalido. No muestres `StackTrace`, `ExceptionType`, headers, tokens ni texto tecnico interno.
- Para consultas amplias, trae pocos registros primero. Usa mas registros solo cuando sea necesario para resolver ambiguedad o encontrar recientes.
- No reveles bearer tokens, secrets, headers sensibles ni cuerpos con credenciales.

## Interpretacion de resultados

- `EsExitoso=true`: resume datos de negocio. Si hay muchos campos, muestra los utiles y ofrece detalle.
- `debeDetenerse=true` o `accesoMcp=false`: no sigas. Explica bloqueo de acceso MCP.
- `reintentar=true`: informa falla temporal. No digas que no hay datos. Reintenta solo despues de esperar `retryAfterSegundos` o unos segundos.
- `CodigoEstado=400` o mensaje de validacion: corrige el JSON o pregunta el dato faltante. No repitas la misma llamada sin cambiar nada.
- Multiples coincidencias razonables: presenta 2 a 5 opciones con nombre y documento si existe; pide confirmacion antes de consultar detalles sensibles o escribir.
- Respuesta vacia: di que no se encontraron datos con ese criterio y ofrece ampliar busqueda; no concluyas que el registro no existe si solo usaste un filtro estrecho.

## Respuestas al usuario

- Responde siempre con nombres de negocio y nombres amigables. Usa campos `*_txt`, `Descripcion_cb`, `Nombre`, `Doc_num`, fechas y valores entendibles antes que nombres técnicos.
- No muestres campos técnicos internos como `tipoFactura`, `campoTipoFactura`, `Factura_insumos_sn`, `Factura_granos_sn`, `Factura_financiero_sn`, `Operacion_doc_id`, `Documento_tipo_id`, `Entidad_id`, `Moneda_id`, `Status_hd`, `descripcion_hd_cb`, `Creacion_hd` o `Ult_mod_hd`, salvo que el usuario pida detalles técnicos.
- Si necesitas mencionar una validación técnica, tradúcela a lenguaje de negocio. Ejemplo: en vez de “tipoFactura=AI71 y campoTipoFactura=Factura_insumos_sn”, responde “la operación fue validada como habilitada para facturas de insumos”.
- Cuando muestres un id por auditoría o confirmación, acompáñalo con el nombre amigable. Ejemplo: “Operación: COMPRAS IMPORTACION (id 1381)”.
- Si la tool devuelve datos técnicos junto con datos de negocio, resume primero lo relevante para el usuario y ofrece mostrar el detalle técnico solo si lo pide.

## Ruteo de intencion

- Datos, direccion, contactos, timbrados, codeudores o resumen de una persona/empresa: lee [references/entidades.md](references/entidades.md) y usa primero `versat_consultar_entidad`.
- Crear, duplicar, listar, procesar o inspeccionar facturas: lee [references/facturas.md](references/facturas.md).
- Crear, actualizar, listar, aplicar, desaplicar o anular recibos/transacciones: lee [references/recibos.md](references/recibos.md).
- Problemas de token, headers, Azure/Codex HTTP MCP o `GetAccesoMCP`: lee [references/authentication.md](references/authentication.md).

## Decisiones comunes

- Usuario pide algo ambiguo: pregunta una sola aclaracion concreta o usa una tool de sugerencia/listado si existe.
- Usuario dice "quiero cadastrar/criar uma fatura" sin tipo: llama `versat_sugerir_tipo_factura` o `versat_listar_tipos_factura`; si sigue ambiguo, pregunta si es `financiera`, `insumos` o `granos`.
- Usuario quiere insertar una factura: lee `references/facturas.md` y usa el flujo de alta guiada. Pregunta en lenguaje de negocio, no por nombres técnicos de campos; resuelve ids con tools.
- Usuario pide "ultima", "mais recente" o "ultimas": no uses `pagina=0` como reciente. Versat pagina de antiguo a nuevo. Usa `pagina=0` solo para obtener `infoPaginacion.totalPages`, luego pide `totalPages - 1` como ultima pagina y ordena por `Fecha` e `id` descendente.
- Usuario informa nombre de entidad: lee `references/entidades.md`, busca con `filtroCampo="Descripcion_cb"` y `filtroValor=<nombre>`. Normaliza mentalmente espacios, puntuacion y abreviaturas como `S.A.` antes de decidir que no existe. Si hay varias coincidencias fuertes, pregunta cual usar.
- Usuario busca una entidad por numero de RUC: nunca filtres BA31 por `Ruc_uk`. Usa `versat_buscar_rucs`, toma el `id` del RUC y llama `versat_listar_entidades` o `versat_consultar_entidad` con `filtroCampo="Ruc_id"`.
- Usuario crea una entidad: si no indicó documento, pregunta si usará `RUC` o `CI`. Para `RUC`, resuelve primero `Ruc_id` con `versat_buscar_rucs`; para `CI`, usa `CI_uk`.
- Usuario pide “mi empresa”, datos de la empresa o configuración OX01: usa `versat_buscar_empresas`. OX01 es solo lectura; el MCP usa el token y el `Empresa_id` autorizado por `GetAccesoMCP` como contexto, no como búsqueda libre por nombre.
- Para datos con `Modelo_id`, usa siempre las tools MCP normales. El MCP usa `Empresa_id` y `Modelo_id` devueltos por `GetAccesoMCP` para filtrar catálogos compatibles como cuentas, tributación y operaciones sin depender de que la API acepte `Modelo_id` como filtro remoto.
- Usuario pide detalles de una factura o recibo por id: usa la tool de detalle del mismo recurso y filtra por `Factura_id` o `Financ_id`.
- Usuario pide crear cabecera mas detalles: usa la tool completa/orquestadora del recurso cuando exista; evita crear manualmente cabecera y detalles separados.

## Escrituras seguras

Antes de escribir:

- Identifica el recurso correcto.
- Si faltan campos obligatorios, llama la tool de alta sin JSON para obtener el contrato de campos.
- Resuelve todas las foreign keys obligatorias con tools de catalogo.
- Construye JSON con nombres exactos de campos Versat.
- Para registros con `Status`, deja que el MCP fuerce `Borrador`; no intentes crear documentos como `Aplicado` o `Anulado`.
- Si el usuario mando imagen/PDF/texto con cabecera y lineas, usa la tool completa del recurso cuando exista.
- Si hay duda entre dos ids o dos operaciones, pregunta antes de escribir.

Despues de escribir:

- Informa ids creados y etapas completadas.
- Si hubo exito parcial, informa cabecera creada, detalles creados y etapa que fallo.
- Valida consultando el registro o detalle creado cuando sea util y barato.
- No reintentes a ciegas. Reintenta solo si corregiste un dato concreto indicado por la API o si la tool marcó la respuesta como temporal con `reintentar=true`.

## Prohibiciones criticas

- No presupongas ni expongas la arquitectura interna de Versat.
- No pedir ids tecnicos al usuario si existe una tool para buscarlos.
- No usar `pagina=0` como sinonimo de ultimo o reciente.
- No crear documentos como `Aplicado` o `Anulado`; crear en borrador y procesar con tool especifica.
- No modificar campos que el usuario no pidio cambiar.
- No continuar despues de un bloqueo de acceso MCP.
