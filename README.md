# Versat MCP Skills

Skills para mejorar el uso del servidor MCP de Versat con agentes de IA.

Este repositorio no contiene el servidor MCP ni credenciales. Solo incluye instrucciones operativas para que el agente use mejor las tools expuestas por el MCP: entidades, facturas, recibos, autenticacion, paginacion, errores y flujos de escritura.

## Contenido

```text
skills/
  versat-mcp/
    SKILL.md
    references/
      authentication.md
      entidades.md
      facturas.md
      recibos.md
```

## Requisitos

- Servidor MCP Versat publicado o ejecutandose localmente.
- URL HTTP del MCP, por ejemplo `https://mcp-versat.azurewebsites.net/mcp`.
- Token Versat valido para la API y habilitado para MCP.

No publique tokens en este repositorio ni los incluya en archivos de configuracion versionados.

## Configuracion del MCP

El servidor MCP puede recibir el token de dos formas.

### Opcion recomendada: header propio

Use esta opcion cuando el cliente permita configurar headers manuales.

```http
X-Versat-Mcp-Token: <TOKEN_VERSAT>
```

No agregue `Bearer` en este header. Use el valor del token directamente.

### Opcion compatible: Authorization Bearer

Use esta opcion cuando el cliente soporte autenticacion Bearer nativa.

```http
Authorization: Bearer <TOKEN_VERSAT>
```

Si el cliente pide "variable de ambiente del bearer token", normalmente espera el nombre de una variable, no el token. En ese caso configure una variable como `VERSAT_MCP_TOKEN` y ponga el token real en el ambiente.

## Instalacion en Codex

Clone este repositorio:

```bash
git clone https://github.com/Versat-Platform/versat_skills_mcp.git
```

Copie la skill al directorio de Skills de Codex:

```bash
mkdir -p ~/.codex/skills
cp -R versat_skills_mcp/skills/versat-mcp ~/.codex/skills/versat-mcp
```

Configure el MCP HTTP en Codex:

```text
Nombre: mcp-versat-prod
URL: https://mcp-versat.azurewebsites.net/mcp
Header:
  X-Versat-Mcp-Token: <TOKEN_VERSAT>
```

Si prefiere usar variable de ambiente:

```bash
export VERSAT_MCP_TOKEN='<TOKEN_VERSAT>'
```

Y en Codex:

```text
Variable de ambiente de token del portador: VERSAT_MCP_TOKEN
```

## Instalacion en Claude Desktop

Claude Desktop no usa Skills de Codex directamente, pero puede aprovechar el contenido de `SKILL.md` como instrucciones del proyecto o del agente.

Para conectar el MCP por HTTP, agregue un servidor MCP remoto si su version de Claude Desktop lo soporta. Si solo soporta procesos locales, use un puente compatible con MCP remoto o ejecute el servidor MCP localmente.

Configuracion conceptual:

```json
{
  "mcpServers": {
    "versat": {
      "url": "https://mcp-versat.azurewebsites.net/mcp",
      "headers": {
        "X-Versat-Mcp-Token": "<TOKEN_VERSAT>"
      }
    }
  }
}
```

Luego agregue el contenido de `skills/versat-mcp/SKILL.md` a las instrucciones del proyecto o del agente.

## Instalacion en Cursor

Cursor puede usar servidores MCP desde su configuracion de MCP. Agregue el servidor remoto con la URL del MCP y el header del token.

Ejemplo conceptual:

```json
{
  "mcpServers": {
    "versat": {
      "url": "https://mcp-versat.azurewebsites.net/mcp",
      "headers": {
        "X-Versat-Mcp-Token": "<TOKEN_VERSAT>"
      }
    }
  }
}
```

Para la parte de Skills, copie el contenido de `SKILL.md` y las referencias relevantes en las reglas del proyecto, instrucciones personalizadas o memoria del agente.

## Instalacion en Windsurf

Configure el servidor MCP remoto en la configuracion de MCP de Windsurf:

```json
{
  "mcpServers": {
    "versat": {
      "url": "https://mcp-versat.azurewebsites.net/mcp",
      "headers": {
        "X-Versat-Mcp-Token": "<TOKEN_VERSAT>"
      }
    }
  }
}
```

Despues agregue el contenido de `skills/versat-mcp/SKILL.md` como reglas/instrucciones del workspace.

## Instalacion en VS Code

Si usa una extension o agente compatible con MCP, registre el servidor HTTP:

```json
{
  "servers": {
    "versat": {
      "url": "https://mcp-versat.azurewebsites.net/mcp",
      "headers": {
        "X-Versat-Mcp-Token": "<TOKEN_VERSAT>"
      }
    }
  }
}
```

La ubicacion exacta depende de la extension utilizada. Para mejorar el comportamiento del agente, agregue `SKILL.md` como instrucciones del workspace o como archivo de reglas del agente.

## Como usar la Skill

La skill indica al agente como:

- Resolver ids antes de crear registros.
- Elegir entre facturas financieras, de insumos o de granos.
- Consultar entidades y detalles sin pedir nombres tecnicos al usuario.
- Manejar paginacion de Versat, que devuelve registros de antiguo a nuevo.
- Detenerse correctamente cuando `GetAccesoMCP` deniega acceso.
- Crear registros en estado `Borrador` cuando el recurso tiene campo `Status`.

## Validacion rapida

Primero valide el token directamente contra la API Versat:

```bash
curl -i \
  -H "Authorization: Bearer <TOKEN_VERSAT>" \
  http://test.versat.com.py:8000/api/Polling/GetAccesoMCP
```

Resultados esperados:

- `200 true`: token valido y acceso MCP habilitado.
- `200 false`: token valido, pero sin acceso MCP habilitado.
- `401`: token invalido, transformado por el cliente o no aceptado por el ambiente.

Luego valide el MCP desde el agente listando tools o ejecutando una consulta simple, por ejemplo `versat_consultar_entidad`.

Si necesita probar el transporte HTTP con `curl`, envie una request JSON-RPC valida al endpoint MCP. La forma exacta puede variar segun el cliente y version del protocolo, por eso la prueba recomendada es desde el cliente MCP real.

Para diagnosticar headers sin exponer tokens, revise los logs del servidor:

```text
tokenFuente=x_versat_mcp_token
tokenLargo=64
```

El valor exacto de `tokenLargo` puede variar, pero debe coincidir con el token esperado y no con una version transformada por el cliente.

## Seguridad

- No suba tokens a Git.
- Prefiera variables de ambiente o secretos del proveedor.
- Si usa headers manuales en una UI, confirme que no queden versionados.
- Revise logs usando hash/tamano del token, nunca el token completo.
