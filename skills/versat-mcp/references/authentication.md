# Autenticación y acceso

## Configurar la credencial

El MCP HTTP admite una de estas formas. Usa solo una por configuración:

```http
Authorization: Bearer <token-versat>
```

Si el cliente permite un encabezado personalizado, también puede enviar:

```http
X-Versat-Mcp-Token: <token-versat>
```

En el segundo encabezado, envía únicamente el token. Si el cliente pide el nombre de una variable de entorno, informa el nombre, no el valor secreto. Nunca pidas al usuario pegar credenciales en la conversación, ni las guardes en el repositorio o en ejemplos compartidos.

## Distinguir el motivo del bloqueo

| Respuesta | Interpretación y siguiente paso |
| --- | --- |
| `mcp_http_bearer_ausente_o_invalido`, `401` o `Auth required` del cliente | Falta una credencial utilizable o el cliente debe autenticarse. Revisa su configuración. |
| `tipoError=acceso_mcp_denegado` o `estadoValidacionMcp=denegado` | El acceso MCP está denegado. Detén la operación e informa que se necesita habilitación. |
| `estadoValidacionMcp=rechazado` | La autenticación no pudo validarse con esa credencial. Pide revisar su validez y permisos sin solicitar el secreto. |
| `estadoValidacionMcp=indeterminado`, por ejemplo `validacion_acceso_mcp_timeout` | No se pudo determinar el acceso. Detén las tools de negocio y comunica una falla de validación; no afirmes que la empresa carece de permiso. |
| `401/403` de una operación sin señal de denegación MCP | Puede ser autenticación o permiso para esa operación. Conserva el mensaje controlado y pide revisar el acceso correspondiente. |
| `426` | Usa la URL HTTPS del MCP. En una instalación con proxy, el administrador debe revisar TLS y las direcciones de proxies confiables. |

`debeDetenerse=true` o `accesoMcp=false` siempre bloquean la continuación de las tools de negocio, incluso si la causa es temporal. La frase al usuario debe reflejar el motivo concreto; no equipares una validación indeterminada con una denegación confirmada.

Para errores de disponibilidad sin bloqueo de acceso, aplica [Resultados y recuperación](resultados.md). Listar tools o leer la guía confirma descubrimiento, pero no prueba acceso a datos: una consulta exitosa como `versat_buscar_empresas` permite verificarlo sin escribir.

## Comunicar sin exponer credenciales

- Credencial ausente: “Falta configurar el token de acceso en el cliente MCP.”
- Acceso denegado: “El token o la empresa no tiene acceso habilitado al MCP de Versat.”
- Validación indeterminada: “No fue posible validar el acceso en este momento; la operación no puede continuar todavía.”

No copies headers de autenticación, tokens parciales, cuerpos técnicos, nombres de excepciones ni URLs con valores de filtros.
