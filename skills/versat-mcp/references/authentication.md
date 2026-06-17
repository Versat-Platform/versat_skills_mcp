# Autenticacion y acceso

El MCP HTTP acepta una de estas formas:

```http
X-Versat-Mcp-Token: <token-versat>
```

o:

```http
Authorization: Bearer <token-versat>
```

El mismo token se reenvia a la API Versat como Bearer. No lo imprimas en respuestas finales ni lo guardes en archivos del repositorio.

## Diagnostico rapido

`401` o `Auth required` desde MCP:

- El cliente MCP no envio `X-Versat-Mcp-Token` ni `Authorization: Bearer`.
- Corrige la configuracion del servidor MCP en Codex/Azure/cliente.
- No intentes resolver entidades, catalogos ni facturas hasta corregir el header.

`403` con `tipoError="acceso_mcp_denegado"`, `accesoMcp=false` o `debeDetenerse=true`:

- `GetAccesoMCP` devolvio `AcessoMCP=false` o una validacion equivalente rechazada.
- Deten la operacion. No consultes ni modifiques datos.
- Responde claramente: el token o empresa no tiene acceso al MCP de Versat.

`401/403` desde API Versat sin `acceso_mcp_denegado`:

- El MCP recibio el Bearer, pero la API rechazo el token o permisos de negocio.
- Pide al usuario revisar/generar un token Versat valido.

## Orden de decision

1. Si falta header o token, responde que el cliente MCP no envio credencial.
2. Si `accesoMcp=false` o `debeDetenerse=true`, responde bloqueo de acceso MCP y detente.
3. Si el error habla de permisos de negocio pero no de acceso MCP, informa que la API Versat rechazo la operacion para ese token o permiso.
4. Si `reintentar=true`, tratalo como falla temporal, no como problema de permisos.
5. Si no puedes clasificar el error sin exponer detalle tecnico, responde que no fue posible validar el acceso y pide revisar configuracion o permisos.

## Respuesta segura

Usa mensajes simples:

- "No fue posible usar el MCP de Versat porque falta configurar el token de acceso."
- "El token o la empresa no tiene acceso habilitado al MCP de Versat."
- "La API Versat rechazo la autenticacion o permisos para esta operacion."

No pegues headers, token parcial, stack trace, cuerpo tecnico completo ni nombres de excepciones.

## Regla para agentes

Cuando la tool indique falta de acceso MCP, no intentes resolver ids, buscar entidades ni repetir la misma llamada. La accion correcta es informar el bloqueo y pedir habilitacion de acceso MCP.
