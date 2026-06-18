# Versat MCP Skills

Skills e instrucciones para que agentes de IA usen correctamente el servidor MCP de Versat.

Este repositorio contiene solo material de apoyo para agentes. No contiene el servidor MCP, codigo de backend ni credenciales.

Este repositorio, en la rama `main`, es la fuente oficial para instalar y actualizar las skills de Versat. `skills-manifest.json` publica las versiones y rutas vigentes, y cada skill incluye un archivo `VERSION` para comparar la instalación local. No use forks o copias de terceros como fuente de actualización.

## Que hay en este repositorio

```text
skills-manifest.json
skills/
  versat-mcp/
    VERSION
    SKILL.md
    references/
      authentication.md
      entidades.md
      facturas.md
      recibos.md
```

La skill ayuda al agente a:

- Entender que tools usar para entidades, facturas y recibos.
- Resolver ids antes de crear registros.
- Elegir el tipo correcto de factura cuando el usuario no lo especifica.
- Consultar detalles sin exigir que el usuario conozca nombres tecnicos.
- Tratar errores de autenticacion y permisos de forma clara.
- Tratar indisponibilidades temporales sin confundirlas con ausencia de datos.
- Evitar escrituras inseguras o incompletas.

## Conceptos basicos

Para usar Versat MCP con un agente se configura el servidor y, opcionalmente, la skill:

- El servidor MCP: la conexion HTTP que permite al agente llamar las tools de Versat.
- La skill: instrucciones adicionales para que clientes compatibles usen esas tools con mejores criterios.

La URL del MCP y el token deben ser entregados por el administrador de Versat o por el equipo responsable de la implantacion.

Antes de instalar, confirme que tiene:

- URL HTTP del MCP de Versat.
- Token Versat valido para el usuario o empresa.
- Cliente/agente con soporte para servidores MCP HTTP remotos o un puente local compatible.
- Opcionalmente, soporte del cliente para skills o instrucciones reutilizables.

Ejemplo de URL:

```text
https://mcp-versat.azurewebsites.net/mcp
```

## Configurar el MCP

El MCP acepta dos formas de autenticacion. Use solo una.

Forma recomendada cuando el cliente permite headers manuales:

```text
Header: X-Versat-Mcp-Token
Valor: <TOKEN_VERSAT>
```

No agregue `Bearer` en este header.

Forma alternativa cuando el cliente tiene autenticacion Bearer nativa:

```text
Authorization: Bearer <TOKEN_VERSAT>
```

Si el cliente pide una "variable de ambiente del token", no coloque el token en ese campo. Coloque el nombre de una variable, por ejemplo:

```text
VERSAT_MCP_TOKEN
```

Y defina esa variable en el ambiente donde el agente ejecuta.

No coloque tokens reales en archivos del repositorio, prompts compartidos, logs ni capturas.

## Orden recomendado de configuracion

1. Configure el servidor MCP con URL y token.
2. Liste las tools del MCP y ejecute una consulta de solo lectura.
3. Si el cliente admite skills, instale opcionalmente `versat-mcp` desde este repositorio.
4. Reinicie el cliente/agente si no detecta la skill instalada o actualizada.
5. Solo después de validar lectura, habilite flujos de escritura como crear facturas, recibos o entidades.

## Instalar las Skills en Codex

1. Consulte `skills-manifest.json` y clone este repositorio oficial:

```bash
git clone https://github.com/Versat-Platform/versat_skills_mcp.git
```

2. Copie la skill para el directorio de skills de usuario de Codex:

```bash
mkdir -p ~/.agents/skills
cp -R versat_skills_mcp/skills/versat-mcp ~/.agents/skills/versat-mcp
```

Si ya existe una versión anterior, actualice primero el clon oficial y sustituya
la carpeta instalada mediante el mecanismo de actualización de su cliente. No
mezcle archivos de versiones diferentes.

```bash
git -C versat_skills_mcp pull --ff-only origin main
```

3. Reinicie Codex o abra una nueva sesion para que cargue la skill actualizada.

4. Configure el servidor MCP en Codex:

```text
Nombre: versat
Tipo: HTTP con streaming
URL: https://mcp-versat.azurewebsites.net/mcp
Header:
  X-Versat-Mcp-Token: <TOKEN_VERSAT>
```

5. Verifique la conexion pidiendo al agente:

```text
Liste as tools do MCP versat
```

## Instalar en Claude Desktop

Claude Desktop puede usar servidores MCP, pero el soporte exacto para MCP remoto depende de la version instalada.

1. Abra la configuracion de MCP de Claude Desktop.

2. Agregue el servidor Versat con la URL HTTP:

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

3. Si su version de Claude Desktop no acepta MCP remoto por URL, use un puente local compatible con MCP remoto o ejecute el servidor MCP localmente.

4. Copie el contenido de `skills/versat-mcp/SKILL.md` en las instrucciones del proyecto o en las instrucciones personalizadas del agente.

5. Cuando el agente necesite mas detalle, agregue tambien los archivos de `skills/versat-mcp/references/`.

## Instalar en Cursor

1. Abra la configuracion de MCP de Cursor.

2. Agregue un servidor MCP remoto:

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

3. Agregue `skills/versat-mcp/SKILL.md` a las reglas del proyecto, instrucciones del agente o memoria del workspace.

4. Si trabaja frecuentemente con entidades, facturas o recibos, agregue tambien los archivos de `references/`.

## Instalar en Windsurf

1. Abra la configuracion de MCP de Windsurf.

2. Registre el servidor Versat:

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

3. Copie `skills/versat-mcp/SKILL.md` para las instrucciones del workspace.

4. Use los archivos de `references/` como documentacion adicional del agente.

## Instalar en VS Code

La instalacion en VS Code depende de la extension o agente utilizado. El patron general es:

1. Abra la configuracion MCP de la extension.

2. Agregue el servidor HTTP:

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

3. Agregue `skills/versat-mcp/SKILL.md` como instrucciones del workspace o reglas del agente.

4. Mantenga los archivos de `references/` disponibles para consultas de contexto.

## Si el cliente no soporta skills

La skill es opcional. Si el cliente no tiene ese mecanismo, use la tool
`versat_obtener_guia_uso` o el resource `versat://guia/uso`. El MCP conserva
las validaciones y reglas esenciales en el servidor.

## Como saber si quedo funcionando

Desde el agente, haga una prueba simple:

```text
Liste as tools do MCP versat
```

Despues pruebe una tool de solo lectura:

```text
Consulte os dados da entidade Batman usando o MCP versat
```

Si el agente lista tools y consigue ejecutar una consulta simple, la instalacion esta lista.

Diagnostico rapido si falla:

- `401`, `Auth required` o `mcp_http_bearer_ausente_o_invalido`: falta token o el header esta mal configurado. Use `X-Versat-Mcp-Token: <TOKEN>` o `Authorization: Bearer <TOKEN>`.
- `403`, `accesoMcp=false` o `debeDetenerse=true`: el token o la empresa no tiene acceso habilitado al MCP de Versat. No repita tools de negocio.
- `reintentar=true` o un código `servicio_versat_*`: el servicio Versat tuvo una indisponibilidad temporal. Espere `retryAfterSegundos` si viene informado y vuelva a intentar; no lo trate como ausencia de datos.
- Sin tools listadas: revise que el servidor MCP este configurado con la URL correcta y que el cliente soporte MCP HTTP remoto.

## Instrucciones para agentes

No duplique el contenido de la skill en prompts copiados. Instale la versión
indicada por `skills-manifest.json`. Si no puede instalarla, obtenga las
instrucciones vigentes mediante `versat_obtener_guia_uso` o
`versat://guia/uso`.
