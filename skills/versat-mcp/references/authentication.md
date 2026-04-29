# Autenticacion y acceso

El MCP HTTP espera:

```http
Authorization: Bearer <token-versat>
```

Tambien puede recibir el token con header propio:

```http
X-Versat-Mcp-Token: <token-versat>
```

El token recibido se reenvia a la API Versat. No lo imprimas en respuestas finales ni lo guardes en archivos del repositorio.

## Configuracion recomendada

Si el cliente MCP permite headers manuales, usa `X-Versat-Mcp-Token` con el token directo. No agregues `Bearer` en ese header.

Si el cliente MCP tiene autenticacion Bearer nativa, usa `Authorization: Bearer <token-versat>`.

Si el cliente pide "variable de ambiente del token", informa solo el nombre de la variable, por ejemplo `VERSAT_MCP_TOKEN`, y guarda el token real en esa variable de ambiente.

## Diagnostico rapido

`401` o `Auth required` desde MCP:

- El cliente MCP no envio `Authorization` ni `X-Versat-Mcp-Token`.
- Corrige la configuracion del servidor MCP en Codex/Azure/cliente.

`403` con `tipoError="acceso_mcp_denegado"`, `accesoMcp=false` o `debeDetenerse=true`:

- La validacion de acceso del MCP fue rechazada.
- Deten la operacion. No consultes ni modifiques datos.
- Responde claramente: el token o empresa no tiene acceso al MCP de Versat.

`401/403` desde API Versat sin `acceso_mcp_denegado`:

- El MCP recibio el Bearer, pero la API rechazo el token o permisos de negocio.
- Pide al usuario revisar/generar un token Versat valido.
- Si el cliente transforma el token Bearer, prueba `X-Versat-Mcp-Token` para enviar el token sin alteraciones.

## Regla para agentes

Cuando la tool indique falta de acceso MCP, no intentes resolver ids, buscar entidades ni repetir la misma llamada. La accion correcta es informar el bloqueo y pedir habilitacion de acceso MCP.
