---
name: versat-mcp
description: Usar cuando se trabaja con el servidor MCP Versat: consultar o crear facturas, recibos, entidades, detalles, resolver ids de catalogos, diagnosticar autenticacion, manejar errores de API y operar tools MCP Versat de forma segura y eficiente.
---

# Versat MCP

Usa esta skill cuando la tarea involucre el servidor MCP Versat o recursos de negocio de Versat.

## Reglas de ejecucion rapida

- Usa siempre las tools MCP; no llames directo a la API Versat salvo que el usuario pida modificar codigo o diagnosticar infraestructura.
- Nunca inventes ids. Resuelve entidades, monedas, unidades, documentos, operaciones, productos y demas foreign keys con tools de busqueda antes de escribir.
- Si una respuesta trae `debeDetenerse=true`, `tipoError="acceso_mcp_denegado"` o `accesoMcp=false`, detente. No llames mas tools de negocio y responde que el token o empresa no tiene acceso al MCP de Versat.
- Si una tool devuelve `401`, `Auth required` o falta de Bearer, trata el problema como configuracion de autenticacion del cliente MCP. No confundas eso con falta de permiso de negocio.
- Si una tool devuelve error de API, muestra el `mensaje`, `errorApi` o `cuerpo` relevante y pregunta solo por el dato faltante o invalido.
- Para consultas amplias, trae pocos registros primero. Usa mas registros solo cuando sea necesario para resolver ambiguedad o encontrar recientes.
- No reveles bearer tokens, secrets, headers sensibles ni cuerpos con credenciales.

## Ruteo de intencion

- Datos, direccion, contactos, timbrados, codeudores o resumen de una persona/empresa: lee [references/entidades.md](references/entidades.md) y usa primero `versat_consultar_entidad`.
- Crear, duplicar, listar, procesar o inspeccionar facturas: lee [references/facturas.md](references/facturas.md).
- Crear, actualizar, listar, aplicar, desaplicar o anular recibos/transacciones: lee [references/recibos.md](references/recibos.md).
- Problemas de token, headers, Azure/Codex HTTP MCP o acceso denegado: lee [references/authentication.md](references/authentication.md).

## Decisiones comunes

- Usuario dice "quiero cadastrar/criar uma fatura" sin tipo: llama `versat_sugerir_tipo_factura` o `versat_listar_tipos_factura`; si sigue ambiguo, pregunta si es `financiera`, `insumos` o `granos`.
- Usuario quiere insertar una factura: lee `references/facturas.md` y usa el flujo de alta guiada. Pregunta en lenguaje de negocio, no por nombres técnicos de campos; resuelve ids con tools.
- Usuario pide "ultima", "mais recente" o "ultimas": no uses `pagina=0` como reciente. Versat pagina de antiguo a nuevo. Consulta una pagina que devuelva `TotalPages`, luego pide la ultima pagina y ordena por `Fecha` e `id` descendente.
- Usuario informa nombre de entidad: busca con `filtroCampo="Descripcion_cb"` y `filtroValor=<nombre>`. Si hay varias coincidencias fuertes, pregunta cual usar.
- Usuario crea una entidad: si no indicó documento, pregunta si usará `RUC` o `CI`. Para `RUC`, resuelve primero `Ruc_id` con `versat_buscar_rucs`; para `CI`, usa `CI_uk`.
- Usuario pide datos de la empresa/configuración OX01: usa `versat_buscar_empresas`. OX01 es solo lectura en el MCP; no intentes crear ni actualizar empresas.
- Para datos con `Modelo_id`, usa siempre las tools MCP normales. El MCP usa `Empresa_id` y `Modelo_id` devueltos por `GetAccesoMCP` para filtrar automáticamente catálogos compatibles como cuentas, tributación y operaciones.
- Usuario pide detalles de una factura o recibo por id: usa la tool de detalle del mismo recurso y filtra por `Factura_id` o `Financ_id`.
- Usuario pide crear cabecera mas detalles: usa la tool completa/orquestadora del recurso cuando exista; evita crear manualmente cabecera y detalles separados.

## Escrituras seguras

Antes de escribir:

- Identifica el recurso correcto.
- Si faltan campos obligatorios, llama la tool de alta sin JSON para obtener el contrato de campos.
- Resuelve todas las foreign keys obligatorias con tools de catalogo.
- Construye JSON con nombres exactos de campos Versat.
- Para registros con `Status`, deja que el MCP fuerce `Borrador`; no intentes crear documentos como `Aplicado` o `Anulado`.

Despues de escribir:

- Informa ids creados y etapas completadas.
- Si hubo exito parcial, informa cabecera creada, detalles creados y etapa que fallo.
- Valida consultando el registro o detalle creado cuando sea util y barato.
- No reintentes a ciegas. Reintenta solo si corregiste un dato concreto indicado por la API.
