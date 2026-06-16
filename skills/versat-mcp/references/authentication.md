# Autenticacion y acceso

El MCP HTTP espera:

```http
Authorization: Bearer <token-versat>
```

El mismo Bearer se reenvia a la API Versat. No lo imprimas en respuestas finales ni lo guardes en archivos del repositorio.

## Diagnostico rapido

`401` o `Auth required` desde MCP:

- El cliente MCP no envio `Authorization`.
- Corrige la configuracion del servidor MCP en Codex/Azure/cliente.

`403` con `tipoError="acceso_mcp_denegado"`, `accesoMcp=false` o `debeDetenerse=true`:

- `GetAccesoMCP` devolvio `AcessoMCP=false` o una validacion equivalente rechazada.
- Deten la operacion. No consultes ni modifiques datos.
- Responde claramente: el token o empresa no tiene acceso al MCP de Versat.

`401/403` desde API Versat sin `acceso_mcp_denegado`:

- El MCP recibio el Bearer, pero la API rechazo el token o permisos de negocio.
- Pide al usuario revisar/generar un token Versat valido.

## Regla para agentes

Cuando la tool indique falta de acceso MCP, no intentes resolver ids, buscar entidades ni repetir la misma llamada. La accion correcta es informar el bloqueo y pedir habilitacion de acceso MCP.
