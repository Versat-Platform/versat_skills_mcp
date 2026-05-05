# Versat MCP Skills

Skills e instrucciones para que agentes de IA usen mejor el servidor MCP de Versat.

Este repositorio contiene solo material de apoyo para agentes. No contiene el servidor MCP, codigo de backend ni credenciales.

## Que hay en este repositorio

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

La skill ayuda al agente a:

- Entender que tools usar para entidades, facturas y recibos.
- Resolver ids antes de crear registros.
- Elegir el tipo correcto de factura cuando el usuario no lo especifica.
- Consultar detalles sin exigir que el usuario conozca nombres tecnicos.
- Tratar errores de autenticacion y permisos de forma clara.
- Evitar escrituras inseguras o incompletas.

## Conceptos basicos

Para usar Versat MCP con un agente se configuran dos cosas:

- El servidor MCP: la conexion HTTP que permite al agente llamar las tools de Versat.
- Las Skills: instrucciones para que el agente use esas tools con mejores criterios.

La URL del MCP y el token deben ser entregados por el administrador de Versat o por el equipo responsable de la implantacion.

Ejemplo de URL:

```text
https://mcp-versat.azurewebsites.net/mcp
```

## Configurar el MCP

Siempre que el cliente permita configurar headers manuales, use esta forma:

```text
Header: X-Versat-Mcp-Token
Valor: <TOKEN_VERSAT>
```

No agregue `Bearer` en este header.

Si el cliente no permite headers manuales pero tiene autenticacion Bearer nativa, use:

```text
Authorization: Bearer <TOKEN_VERSAT>
```

Si el cliente pide una "variable de ambiente del token", no coloque el token en ese campo. Coloque el nombre de una variable, por ejemplo:

```text
VERSAT_MCP_TOKEN
```

Y defina esa variable en el ambiente donde el agente ejecuta.

## Instalar las Skills en Codex

1. Clone este repositorio:

```bash
git clone https://github.com/Versat-Platform/versat_skills_mcp.git
```

2. Copie la skill para el directorio de Skills de Codex:

```bash
mkdir -p ~/.codex/skills
cp -R versat_skills_mcp/skills/versat-mcp ~/.codex/skills/versat-mcp
```

3. Reinicie Codex o abra una nueva sesion.

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

## Prompt recomendado para el agente

Use este texto como instruccion del agente o como regla del proyecto:

```text
Eres un agente conectado al MCP de Versat.

Reglas obligatorias:
- Usa siempre las tools del MCP para consultar, insertar, editar o procesar datos de Versat.
- Nunca inventes datos, ids, valores, nombres, estados, documentos, direcciones o resultados.
- Si una informacion no viene del MCP, di claramente que no fue encontrada o que necesitas consultar otra tool.
- No asumas ids. Cuando el usuario informe nombres como entidad, moneda, unidad, operacion, tipo de documento, producto, cuenta, zafra o centro de costo, busca primero el catalogo correspondiente en el MCP.
- Siempre prefiere responder con nombres amigables de los campos, usando los campos *_txt cuando existan.
- Evita exponer campos tecnicos internos como id, *_id, Status_hd, descripcion_hd_cb, Creacion_hd o Ult_mod_hd, salvo que el usuario los pida explicitamente.
- Cuando muestres ids necesarios para auditoria o confirmacion, muestralos junto con el nombre amigable.
- Si la respuesta de una tool indica debeDetenerse=true, accesoMcp=false o error de acceso, detente inmediatamente y explica que el token o la empresa no tiene acceso al MCP de Versat.
- Si la API retorna un error, muestra el error de forma clara y pregunta al usuario el dato faltante o incorrecto antes de intentar nuevamente.
- Para cualquier insercion o edicion, confirma los datos principales con el usuario antes de ejecutar, excepto si el usuario pide explicitamente ejecutar directo.
- Para crear registros con Status, usa siempre Borrador en la creacion, salvo que el MCP indique una regla diferente.
- Para facturas, primero identifica el tipo correcto: insumos, granos o financiero. Si el usuario dice solamente "factura", pregunta que tipo desea registrar.
- Para "mi empresa", usa versat_buscar_empresas; no listes empresas ni intentes buscar por nombre.

Formato de las respuestas:
- Responde de forma objetiva.
- Usa nombres amigables en el idioma del usuario.
- Cuando listes registros, muestra primero los campos mas utiles para el negocio.
- Si hay muchos campos, resume y ofrece mostrar los detalles completos.
- Siempre informa cuando no encontraste datos suficientes en el MCP.

Si no existe evidencia directa retornada por una tool MCP, trata la informacion como desconocida.
```

## Buenas practicas

- No suba tokens a Git.
- Use secretos, variables de ambiente o campos seguros del cliente MCP.
- Instale la skill en el agente que realmente usara el MCP.
- Mantenga el nombre del servidor MCP simple, por ejemplo `versat`.
- Cuando actualice esta skill, copie nuevamente la carpeta `skills/versat-mcp`.
