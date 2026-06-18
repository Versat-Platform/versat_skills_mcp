# Autenticacion y acceso

El MCP HTTP acepta una de estas formas:

```http
X-Versat-Mcp-Token: <token-versat>
```

o:

```http
Authorization: Bearer <token-versat>
```

El token se procesa internamente por el MCP. No lo imprimas en respuestas finales ni lo guardes en archivos del repositorio.

Cuando el MCP esta detras de un proxy reverso, el proxy debe terminar TLS y enviar `X-Forwarded-Proto: https`. Una respuesta `426` indica que la solicitud llego por HTTP directo y debe repetirse por HTTPS, sin mostrar ni reutilizar el token en texto visible.

## Diagnostico rapido

`401` o `Auth required` desde MCP:

- El cliente MCP no envio `X-Versat-Mcp-Token` ni `Authorization: Bearer`.
- Corrige la configuracion del servidor MCP en Codex/Azure/cliente.
- No intentes resolver entidades, catalogos ni facturas hasta corregir el header.

`403` con `tipoError="acceso_mcp_denegado"`, `accesoMcp=false` o `debeDetenerse=true`:

- `GetAccesoMCP` devolvio `AcessoMCP=false` o una validacion equivalente rechazada.
- Deten la operacion. No consultes ni modifiques datos.
- Responde claramente: el token o empresa no tiene acceso al MCP de Versat.

`401/403` de una operación sin `acceso_mcp_denegado`:

- El MCP recibió el Bearer, pero la operación fue rechazada por autenticación o permisos de negocio.
- Pide al usuario revisar/generar un token Versat valido.

## Orden de decision

1. Si falta header o token, responde que el cliente MCP no envio credencial.
2. Si `accesoMcp=false` o `debeDetenerse=true`, responde bloqueo de acceso MCP y detente.
3. Si el error habla de permisos de negocio pero no de acceso MCP, informa que Versat rechazó la operación para ese token o permiso.
4. Si `reintentar=true`, tratalo como falla temporal, no como problema de permisos.
5. Si no puedes clasificar el error sin exponer detalle tecnico, responde que no fue posible validar el acceso y pide revisar configuracion o permisos.

## Respuesta segura

Usa mensajes simples:

- "No fue posible usar el MCP de Versat porque falta configurar el token de acceso."
- "El token o la empresa no tiene acceso habilitado al MCP de Versat."
- "Versat rechazó la autenticación o los permisos para esta operación."

No pegues headers, token parcial, stack trace, cuerpo tecnico completo, URLs con valores de filtros ni nombres o mensajes de excepciones.

## Regla para agentes

Cuando la tool indique falta de acceso MCP, no intentes resolver ids, buscar entidades ni repetir la misma llamada. La accion correcta es informar el bloqueo y pedir habilitacion de acceso MCP.
