# Versat MCP Skills

Instrucciones opcionales para que agentes de IA usen las tools de Versat con criterios de negocio consistentes. El servidor MCP conserva sus validaciones y puede utilizarse sin instalar skills.

Este repositorio, en la rama `main`, es la fuente oficial de distribución. [skills-manifest.json](skills-manifest.json) identifica versiones, rutas y hashes SHA-256; cada skill incluye `VERSION`. Una edición local no actualiza la versión publicada hasta incorporarse a la rama de distribución.

## Conectar al MCP de Versat

Para usar Versat necesita **conectar el servidor MCP en su agente**. Después puede instalar esta skill para obtener orientación adicional. No necesita clonar este repositorio ni ejecutar el servidor en su computadora para conectarse a una instalación publicada.

### Datos que debe tener

Solicite al administrador de Versat la URL y un token con acceso MCP habilitado.

| Campo | Valor para los ejemplos |
| --- | --- |
| Nombre de la conexión | `versat` |
| Transporte | `Streamable HTTP` o `HTTP`, según el cliente |
| URL del servidor | `https://mcp-versat.azurewebsites.net/mcp` |
| Credencial | Su token de Versat, sin espacios adicionales ni el prefijo `Bearer` |
| Variable de entorno usada en esta guía | `VERSAT_MCP_TOKEN` |

Si el administrador le entrega otra URL, sustitúyala en los ejemplos. Conserve la ruta completa, incluido `/mcp`. El token de Versat no es la contraseña de su agente ni una clave de OpenAI o Anthropic.

El servidor admite `Authorization: Bearer <TOKEN_VERSAT>` o `X-Versat-Mcp-Token: <TOKEN_VERSAT>`. Use una sola forma por conexión. Los ejemplos usan marcadores o variables: sustituya `<TOKEN_VERSAT>` únicamente en su configuración privada, nunca en este repositorio o en el chat.

### Elija su cliente

| Cliente | Instrucciones |
| --- | --- |
| Codex: aplicación, CLI o extensión | [Conectar Codex](#codex) |
| Claude Code | [Conectar Claude Code](#claude-code) |
| Claude Desktop | [Conectar Claude Desktop mediante un puente local](#claude-desktop) |
| Claude web / Cowork | [Comprobar compatibilidad del conector remoto](#claude-web-y-cowork) |
| Cursor | [Conectar Cursor](#cursor) |
| VS Code con GitHub Copilot | [Conectar VS Code](#vs-code-con-github-copilot) |
| Windsurf / Cascade | [Conectar Windsurf](#windsurf-y-cascade) |
| Otro agente | [Datos para otros clientes](#otros-agentes) |

### Preparar la variable de entorno

Codex, Claude Code y los ejemplos de Cursor/Windsurf leen `VERSAT_MCP_TOKEN`. Su valor debe ser **solo el token**; los ejemplos agregan el encabezado cuando corresponde. Si un formulario pide el *nombre* de la variable, escriba `VERSAT_MCP_TOKEN`, no el secreto.

Para una sesión de terminal, puede introducir el token sin mostrarlo ni escribirlo como parte del comando:

**Bash, en Linux o macOS** — si usa zsh, abra `bash` antes de este bloque:

```bash
read -r -s -p "Token Versat: " VERSAT_MCP_TOKEN
export VERSAT_MCP_TOKEN
printf '\n'
```

**PowerShell, en Windows:**

```powershell
$versatCredencial = Read-Host "Token Versat" -AsSecureString
$env:VERSAT_MCP_TOKEN = [System.Net.NetworkCredential]::new("", $versatCredencial).Password
Remove-Variable versatCredencial
```

Inicie el agente desde esa misma terminal. Estas variables duran esa sesión; para uso permanente, utilice el entorno privado del usuario o el mecanismo de secretos de su cliente. Una aplicación ya abierta no recibe automáticamente cambios hechos en otra terminal. VS Code ofrece abajo una alternativa que pide el token al conectar; Claude Desktop tiene su propia configuración local.

## Codex

La aplicación de escritorio, la CLI y la extensión de Codex comparten la configuración del mismo host. Puede usar la interfaz o editar `~/.codex/config.toml`. [Documentación oficial de MCP en Codex](https://learn.chatgpt.com/docs/extend/mcp).

### Aplicación o extensión

1. Abra **Settings → MCP servers → Add server**; en la extensión, entre desde el menú de configuración.
2. Use el nombre `versat`, transporte **Streamable HTTP** y la URL de la tabla anterior.
3. Configure la autenticación por variable Bearer con el nombre `VERSAT_MCP_TOKEN`. Si su interfaz no muestra ese campo, guarde la entrada y edítela como se indica abajo.
4. Guarde y reinicie la conexión MCP o la extensión.

### Archivo de configuración

Agregue esta entrada a `~/.codex/config.toml`, conservando las demás configuraciones:

```toml
[mcp_servers.versat]
url = "https://mcp-versat.azurewebsites.net/mcp"
bearer_token_env_var = "VERSAT_MCP_TOKEN"
```

Si prefiere el encabezado personalizado, **sustituya** `bearer_token_env_var` por:

```toml
env_http_headers = { "X-Versat-Mcp-Token" = "VERSAT_MCP_TOKEN" }
```

Para escritorio o extensión que no hereden su entorno de terminal, configure el valor en el archivo privado `~/.codex/.env` y reinicie el cliente. [Entorno de escritorio y extensión](https://learn.chatgpt.com/docs/amazon-bedrock#desktop-app-and-ide-extension).

```dotenv
VERSAT_MCP_TOKEN=<TOKEN_VERSAT>
```

### CLI

Con la variable preparada, este comando registra la misma conexión:

```bash
codex mcp add versat --url https://mcp-versat.azurewebsites.net/mcp --bearer-token-env-var VERSAT_MCP_TOKEN
codex mcp list
```

En una sesión de Codex, `/mcp` muestra los servidores activos. Continúe con [Probar la conexión](#probar-la-conexion). El token estático de esta instalación no requiere `codex mcp login`, que inicia OAuth.

## Claude Code

Configure el servidor en el proyecto mediante `.mcp.json`. Claude Code admite `${VERSAT_MCP_TOKEN}` en los encabezados y permite revisar la conexión con `/mcp`. [Documentación oficial de Claude Code](https://code.claude.com/docs/en/mcp).

1. Prepare `VERSAT_MCP_TOKEN` en la terminal desde la que iniciará Claude Code.
2. En la raíz del proyecto, cree o complete `.mcp.json`:

```json
{
  "mcpServers": {
    "versat": {
      "type": "http",
      "url": "https://mcp-versat.azurewebsites.net/mcp",
      "headers": {
        "X-Versat-Mcp-Token": "${VERSAT_MCP_TOKEN}"
      }
    }
  }
}
```

3. Ejecute `claude` desde ese proyecto y acepte el servidor cuando el cliente solicite aprobar su configuración.
4. Use `/mcp` o `claude mcp list` y después [pruebe una consulta](#probar-la-conexion).

Para todos sus proyectos, puede registrar una entrada de usuario mediante esta alternativa en Bash. Las comillas simples conservan la referencia a la variable:

```bash
claude mcp add-json --scope user versat '{"type":"http","url":"https://mcp-versat.azurewebsites.net/mcp","headers":{"X-Versat-Mcp-Token":"${VERSAT_MCP_TOKEN}"}}'
```

Elija la configuración de proyecto o de usuario; evite dos entradas del mismo nombre con valores diferentes. Una variable sin definir no se reemplaza por un token válido.

## Claude Desktop

Para la instalación de Versat con token por encabezado, una opción es ejecutar un **puente local `mcp-remote`**, que conecta Claude Desktop con el servidor HTTPS. Es un paquete de terceros que se ejecuta en su computadora; no es una skill de Versat. [Documentación del paquete](https://github.com/punkpeye/mcp-remote).

1. Instale Node.js LTS con npm y compruebe `node --version` y `npx --version`.
2. En Claude Desktop, abra **Settings → Developer → Edit Config**. Las ubicaciones habituales son `~/Library/Application Support/Claude/claude_desktop_config.json` en macOS y `%APPDATA%\Claude\claude_desktop_config.json` en Windows. [Configuración local documentada por MCP](https://modelcontextprotocol.io/docs/develop/connect-local-servers).
3. Agregue `versat` dentro de `mcpServers`, conservando las demás entradas:

```json
{
  "mcpServers": {
    "versat": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp-versat.azurewebsites.net/mcp",
        "--header",
        "X-Versat-Mcp-Token:${VERSAT_MCP_TOKEN}"
      ],
      "env": {
        "VERSAT_MCP_TOKEN": "<TOKEN_VERSAT>"
      }
    }
  }
}
```

4. Sustituya el marcador por su token solo en ese archivo privado. La referencia `${VERSAT_MCP_TOKEN}` de `args` la resuelve el puente. `npx -y` descarga el paquete cuando hace falta.
5. Cierre completamente Claude Desktop, ábralo de nuevo y [pruebe la conexión](#probar-la-conexion).

Si no encuentra `npx`, revise la instalación y la ruta ejecutable disponible para Claude. No copie la entrada HTTP de Claude Code como si fuera una configuración de proceso local de Desktop.

## Claude web y Cowork

El flujo documentado de conectores remotos se configura en **Customize → Connectors → + → Add custom connector**, con la URL y, cuando corresponde, parámetros OAuth. Esas conexiones se originan desde la infraestructura de Anthropic. [Guía oficial de conectores remotos](https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp).

Esta instalación de Versat recibe un token por encabezado; el flujo descrito arriba no publica un inicio de sesión OAuth. Por eso **introducir únicamente la URL no completa la autenticación**. El token de Versat tampoco debe colocarse en un campo `OAuth Client Secret`.

Si su interfaz no permite enviar el Bearer o encabezado personalizado requerido, use Claude Code o la opción de Claude Desktop de esta guía. Para habilitar un conector web, el administrador debe proporcionar una integración con autenticación compatible. El puente local de Desktop no habilita por sí sola Claude web o Cowork.

## Cursor

Cursor admite MCP remoto con encabezados y variables `${env:NOMBRE}`. Cree `.cursor/mcp.json` en el proyecto o `~/.cursor/mcp.json` para uso personal global. [Documentación oficial de Cursor](https://cursor.com/docs/mcp).

1. Prepare `VERSAT_MCP_TOKEN` en el entorno que inicia Cursor.
2. Agregue esta entrada al archivo elegido:

```json
{
  "mcpServers": {
    "versat": {
      "url": "https://mcp-versat.azurewebsites.net/mcp",
      "headers": {
        "X-Versat-Mcp-Token": "${env:VERSAT_MCP_TOKEN}"
      }
    }
  }
}
```

3. Reinicie Cursor si cambió su entorno y habilite `versat` en la sección MCP del cliente.
4. Abra el chat del agente y [pruebe la conexión](#probar-la-conexion).

Para este servidor remoto, un `envFile` no sustituye la variable del entorno: esa opción de Cursor corresponde a procesos stdio. No use la sintaxis `${VERSAT_MCP_TOKEN}` de Claude Code en este bloque.

## VS Code con GitHub Copilot

Use `.vscode/mcp.json`. El ejemplo solicita el token mediante una entrada oculta y evita escribirlo dentro del JSON. VS Code utiliza la clave `servers`. [Formato oficial de configuración](https://code.visualstudio.com/docs/agents/reference/mcp-configuration).

```json
{
  "inputs": [
    {
      "id": "versat-token",
      "type": "promptString",
      "description": "Token Versat, sin el prefijo Bearer",
      "password": true
    }
  ],
  "servers": {
    "versat": {
      "type": "http",
      "url": "https://mcp-versat.azurewebsites.net/mcp",
      "headers": {
        "X-Versat-Mcp-Token": "${input:versat-token}"
      }
    }
  }
}
```

1. Guarde el archivo, abra **MCP: List Servers** en la paleta de comandos y seleccione `versat` para iniciarlo.
2. Introduzca el token cuando VS Code lo solicite y acepte la confianza del servidor cuando corresponda.
3. Habilite sus herramientas en el chat de Copilot y [pruebe la conexión](#probar-la-conexion).

Este ejemplo está orientado al agente integrado de Copilot. Una extensión de otro proveedor puede usar su propia configuración. [Administrar servidores MCP en VS Code](https://code.visualstudio.com/docs/agent-customization/mcp-servers).

## Windsurf y Cascade

Abra la configuración MCP de Cascade y edite `~/.codeium/windsurf/mcp_config.json`. El formato admite `serverUrl` y variables `${env:NOMBRE}`. La documentación actual de Cascade también se publica bajo Devin Desktop. [Documentación oficial de Cascade](https://docs.devin.ai/desktop/cascade/mcp).

```json
{
  "mcpServers": {
    "versat": {
      "serverUrl": "https://mcp-versat.azurewebsites.net/mcp",
      "headers": {
        "X-Versat-Mcp-Token": "${env:VERSAT_MCP_TOKEN}"
      }
    }
  }
}
```

Prepare la variable en el entorno del cliente, guarde y recargue los servidores MCP. Habilite las tools de Versat que necesite y [pruebe una consulta](#probar-la-conexion).

## Otros agentes

En el formulario de servidores MCP del cliente, informe:

| Campo del cliente | Qué escribir |
| --- | --- |
| Nombre | `versat` |
| Transporte | HTTP / Streamable HTTP |
| URL | La URL completa de su instalación, terminada en `/mcp` |
| Bearer token | Solo el token, cuando el formulario agrega `Bearer` automáticamente |
| Encabezado personalizado, como alternativa | Nombre `X-Versat-Mcp-Token`; valor igual al token |

Si solo admite procesos stdio locales, compruebe si acepta un puente como el de Claude Desktop. Si solo ofrece OAuth y no permite encabezados, necesita una integración compatible proporcionada por su administrador. Use el esquema de configuración documentado por ese cliente.

## Probar la conexion

En el chat del agente, pida primero:

```text
Usa el MCP versat para obtener su guía de uso.
Después consulta los datos de mi empresa autorizada. No crees ni modifiques registros.
```

El agente debe usar `versat_obtener_guia_uso` y `versat_buscar_empresas`. Una respuesta exitosa con los datos de la empresa confirma lectura autorizada. Listar tools o registrar una conexión solo confirma descubrimiento o configuración.

Después puede solicitar una consulta de negocio, por ejemplo:

```text
Busca la entidad por el nombre que te indicaré y muéstrame las coincidencias.
```

Si la conexión funciona, continúe con [Instalar o actualizar la skill](#instalar-o-actualizar-la-skill). La skill es opcional y no corrige un token inválido.

## Resolver problemas de conexion

| Problema | Qué revisar |
| --- | --- |
| `401`, `Auth required` o `mcp_http_bearer_ausente_o_invalido` | Que el cliente envíe el token, que la variable exista en su proceso y que no se haya escrito el nombre de la variable como valor del token |
| Variable no encontrada o token vacío | Nombre exacto `VERSAT_MCP_TOKEN`, sintaxis propia del cliente y reinicio después de configurar el entorno |
| Solicitud inesperada de OAuth | Verifique la configuración del Bearer o encabezado. El token de Versat no es un OAuth Client ID/Secret |
| `acceso_mcp_denegado` o estado `denegado` | El administrador debe revisar la habilitación MCP para esa credencial o empresa |
| Estado `indeterminado` | No pudo completarse la validación; no demuestra falta de permiso |
| `426` | Use HTTPS y solicite revisar el proxy de la instalación |
| Servidor configurado, pero sin tools | Revise que esté habilitado y aprobado en el cliente, la URL completa y posibles restricciones de su organización |
| `npx` no encontrado en Desktop | Revise Node.js/npm y la ruta del ejecutable que puede usar Claude |
| Timeout o `reintentar=true` | Espere el plazo indicado y revise conectividad; no repita escrituras con resultado incierto |

No envíe capturas con tokens ni copie cuerpos técnicos al reportar un problema. Para el comportamiento de negocio ante bloqueos o fallos, consulte [Autenticación](skills/versat-mcp/references/authentication.md) y [Resultados y recuperación](skills/versat-mcp/references/resultados.md).

## Contenido

La entrada [versat-mcp](skills/versat-mcp/SKILL.md) selecciona el flujo y carga solo las referencias pertinentes:

| Referencia | Cuándo usarla |
| --- | --- |
| [Entidades](skills/versat-mcp/references/entidades.md) | Personas, empresas, documentos y datos relacionados |
| [Facturas](skills/versat-mcp/references/facturas.md) | Insumos, granos y facturas financieras |
| [Recibos](skills/versat-mcp/references/recibos.md) | Recibos, movimientos de caja, cuotas y facturas vinculadas |
| [Catálogos](skills/versat-mcp/references/catalogos.md) | Resolver IDs compatibles con el campo y recurso |
| [Resultados y recuperación](skills/versat-mcp/references/resultados.md) | Errores, reintentos, creaciones parciales y paginación |
| [Autenticación](skills/versat-mcp/references/authentication.md) | Credenciales, denegación y validación de acceso indeterminada |

El contrato vigente de las tools y las validaciones del servidor prevalecen sobre la skill. Use `versat_obtener_guia_uso`, el resource `versat://guia/uso` o el prompt `versat_usar_mcp` para obtener la guía del servidor conectado.

## Instalar o actualizar la skill

### Mediante el MCP

Pida al agente instalar o actualizar la skill oficial de Versat. El flujo usa `versat_sincronizar_skills`:

1. Informa la versión local cuando esté disponible.
2. Revisa el resultado y, si devuelve un paquete, guarda todos sus archivos respetando `rutaDestinoRelativa` y `rutaRelativa` dentro del directorio de skills admitido por el cliente.
3. Verifica los hashes y que `VERSION` coincida con `versionOficial`.
4. Recarga las skills mediante el mecanismo del cliente cuando sea necesario.

La tool prepara el paquete oficial, pero no escribe archivos en el cliente. Solo confirme la instalación después de guardar y verificar los archivos.

Si el servidor conectado no expone `versat_sincronizar_skills`, compare directamente el archivo `VERSION` instalado con la versión publicada en `skills-manifest.json`. Si no puede leer la versión local, compare los hashes disponibles. Una diferencia se resuelve mediante el procedimiento del repositorio oficial descrito a continuación; la ausencia de la tool no convierte automáticamente la actualización de la skill en una actualización del servidor MCP.

### Desde el repositorio oficial

Clone la rama de distribución:

```bash
git clone --branch main https://github.com/Versat-Platform/versat_skills_mcp.git
```

Valide el paquete desde el clon; el script requiere Ruby y sus bibliotecas estándar:

```bash
ruby scripts/validar_distribucion.rb
```

Copie la carpeta completa `skills/versat-mcp` al directorio de skills compatible con su cliente. Conserve `SKILL.md`, `VERSION`, `agents/` y `references/`: copiar solo la entrada rompe las referencias. Para actualizar una instalación existente, use el mecanismo de sustitución del cliente y evite mezclar archivos de versiones distintas.

Si el cliente no admite skills, continúe con la guía MCP. No es necesario copiar instrucciones aisladas en prompts para habilitar las tools.

## Criterios operativos

- Resuelva entidades y catálogos mediante sus tools; pida solo los datos faltantes o elecciones ambiguas.
- Prefiera catálogos específicos para cuentas, operaciones y tributaciones de cada documento.
- Cree documentos en borrador y procese únicamente dentro de la acción autorizada.
- Distinga denegación confirmada de validación indeterminada. Ambas detienen las tools de negocio, pero requieren explicaciones diferentes.
- Decida reintentos por las señales estructuradas, no por el prefijo del código. Verifique escrituras con resultado parcial o incierto antes de repetir.
- Mantenga filtros y tamaño de página al localizar registros recientes; no presente una muestra como el conjunto completo.

## Mantener la distribución

1. Actualice la skill y solo las referencias afectadas, siguiendo las reglas y contratos vigentes del servidor.
2. Si cambia una orientación transversal, alinee también la guía MCP que comparten tool, resource y prompt.
3. Incremente `skills/versat-mcp/VERSION` y la versión de `skills-manifest.json`. Registre todo archivo distribuido y recalcule sus hashes SHA-256.
4. Ejecute `ruby scripts/validar_distribucion.rb` y `git diff --check`.
5. Sincronice desde este repositorio el espejo `skills/versat-mcp` del servidor y compare los archivos.

La validación comprueba estructura, versiones, archivos, enlaces locales y hashes; la revisión de los flujos debe comprobar además el significado de las instrucciones. Commit, push y publicación se realizan únicamente cuando estén autorizados.
