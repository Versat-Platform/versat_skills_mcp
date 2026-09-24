# Versat MCP: plugin y skills

El plugin reúne la conexión al MCP de Versat y una skill opcional con instrucciones de negocio. El servidor MCP conserva sus validaciones y también puede utilizarse sin instalar el plugin o la skill.

Este repositorio, en la rama `main`, es la fuente oficial de distribución. [skills-manifest.json](skills-manifest.json) identifica versiones, rutas y hashes SHA-256; cada skill incluye `VERSION`. Una edición local no actualiza la versión publicada hasta incorporarse a la rama de distribución.

## Instalar el plugin de Versat

El plugin instala **la conexión al MCP y la skill oficial** en los clientes compatibles. Use el repositorio `Versat-Platform/versat_skills_mcp` como fuente. Antes de conectarse, entre al sistema Versat y genere su **Token Bearer**. Cuando aparezca la página de acceso, escriba su **usuario habitual de Versat** en Usuario y el **Token Bearer generado en Versat** en Contraseña. El plugin no guarda credenciales.

| Cliente | Instalación |
| --- | --- |
| Claude (web, Desktop o Cowork) | Abra **Customize → Plugins → + → Add marketplace → Add from a repository**. Indique `Versat-Platform/versat_skills_mcp`, abra el marketplace **Versat Platform** e instale **versat-mcp**. |
| Claude Code | Ejecute `/plugin marketplace add Versat-Platform/versat_skills_mcp` y después `/plugin install versat-mcp@versat-platform`. |
| Codex | Ejecute `codex plugin marketplace add Versat-Platform/versat_skills_mcp` y `codex plugin add versat-mcp@versat-platform`. También puede instalarlo desde el directorio de plugins tras agregar el marketplace. |
| VS Code con GitHub Copilot | Ejecute **Chat: Install Plugin From Source** e indique `https://github.com/Versat-Platform/versat_skills_mcp.git`. |
| Cursor | En un chat del agente, escriba `/add-plugin versat-mcp@https://github.com/Versat-Platform/versat_skills_mcp.git` y siga la instalación. |

En la ventana **Agregar marketplace de plugins** de Codex, escriba `Versat-Platform/versat_skills_mcp` en **Origen**, `main` en **Referencia de Git** y deje **Caminos dispersos** vacío. El plugin está en la raíz del repositorio; no use `plugins/codex`.

Si macOS muestra el error de licencia de Xcode al clonar, abra Terminal y ejecute `sudo xcodebuild -license` para revisar y aceptar la licencia antes de repetir la instalación. También puede usar los comandos de Codex de la tabla después de configurar las herramientas de línea de comandos de Apple.

Después de instalar, conecte **versat** cuando el cliente solicite autenticación y pruebe una consulta de lectura en [Probar la conexión](#probar-la-conexion). Si su cliente no admite plugins, siga [Conectar al MCP de Versat](#conectar-al-mcp-de-versat) y, si desea, [instale la skill](#instalar-o-actualizar-la-skill) por separado. Si ya configuró el MCP y la skill manualmente, evite registrar una segunda conexión `versat` al instalar el plugin.

La instalación por plugin requiere que el servidor MCP tenga OAuth habilitado y que el cliente admita autenticación OAuth para servidores remotos. Si su instalación usa otra URL del MCP, utilice la [conexión manual](#conectar-al-mcp-de-versat) con la dirección entregada por su administrador. Consulte las guías de [Claude](https://support.claude.com/en/articles/13837440-use-plugins-in-claude), [Claude Code](https://code.claude.com/docs/en/plugin-marketplaces), [Codex](https://developers.openai.com/plugins/build/plugins) y [VS Code](https://code.visualstudio.com/docs/agent-customization/agent-plugins) si cambió la interfaz de instalación.

## Conectar al MCP de Versat

Antes de conectar, entre al **sistema Versat con su usuario habitual** y genere allí un **Token Bearer**. Necesita ese token tanto para OAuth como para la conexión Bearer directa. Solicite al administrador la URL del MCP y la habilitación de acceso MCP si aún no los tiene. En los ejemplos se usa `https://mcp-versat.azurewebsites.net/mcp`; si le entregaron otra URL, use esa. No necesita instalar esta skill para conectar.

**La forma más fácil es OAuth, cuando está habilitado en la instalación:** agregue la URL en su cliente y pulse **Conectar**. En la página de Versat complete:

| Campo | Qué escribir |
| --- | --- |
| Usuario | El mismo usuario con el que inicia sesión en el sistema Versat |
| Contraseña / Token Bearer | El Token Bearer que generó en el sistema Versat; no es la contraseña con la que entra al sistema |

Si el token empieza por `Bearer `, también puede pegarlo completo. No introduzca el token en los campos *OAuth Client ID* o *Client Secret*. El cliente recibe una credencial del MCP; las operaciones en Versat siguen usando únicamente su token Bearer de Versat.

### Claude: web, Desktop y Cowork

1. Abra **Customize → Connectors → + → Add custom connector**.
2. Ponga el nombre `versat` y la URL del MCP. Deje vacíos los ajustes OAuth avanzados.
3. Pulse **Add** y después **Connect**. Complete la página de Versat con su usuario y token.
4. Active el conector en la conversación desde **+ → Connectors**.

En planes Team o Enterprise, el propietario de la organización debe agregar primero el conector en **Organization settings → Connectors**; cada persona pulsa después **Connect** con su propia credencial. [Instrucciones oficiales de Claude](https://support.claude.com/en/articles/11175166-get-started-with-custom-connectors-using-remote-mcp).

### Claude Code

En una terminal, registre el servidor una vez:

```bash
claude mcp add --transport http versat --scope user https://mcp-versat.azurewebsites.net/mcp
```

Abra Claude Code, ejecute `/mcp`, seleccione `versat` y autentíquese en la página de Versat. [Instrucciones oficiales de Claude Code](https://code.claude.com/docs/en/mcp).

### Codex

En la aplicación o extensión, abra **Settings → MCP servers → Add server**, escriba `versat`, elija **Streamable HTTP** e indique la URL. Guarde y seleccione **Authenticate** cuando aparezca.

En la CLI puede hacer lo mismo con:

```bash
codex mcp add versat --url https://mcp-versat.azurewebsites.net/mcp
codex mcp login versat
```

Complete la página de Versat con su usuario y token. [Instrucciones oficiales de Codex](https://learn.chatgpt.com/docs/extend/mcp).

No abra `/authorize` directamente en el navegador. Si aparece `{"error":"invalid_request"}` en esa dirección, vuelva al cliente y seleccione **Authenticate** para que Codex genere un enlace de acceso completo.

### Cursor

Abra `~/.cursor/mcp.json` para usarlo en todos sus proyectos, o `.cursor/mcp.json` dentro de un proyecto. Agregue:

```json
{
  "mcpServers": {
    "versat": {
      "url": "https://mcp-versat.azurewebsites.net/mcp"
    }
  }
}
```

Habilite `versat` en la configuración MCP de Cursor y siga la autenticación que muestre el cliente. Si su versión no ofrece inicio OAuth, use [conexión manual con token](#conexion-manual-con-token). [Instrucciones oficiales de Cursor](https://prod.cursor.com/help/customization/mcp).

### VS Code con GitHub Copilot

Abra la paleta de comandos y ejecute **MCP: Add Server**. Elija **HTTP**, escriba la URL del MCP, asígnele el nombre `versat` y elija configuración **Global** para usarla en todos sus proyectos. Inicie el servidor desde **MCP: List Servers** y complete la autenticación cuando VS Code abra el navegador.

También puede abrir **MCP: Open User Configuration** o editar `.vscode/mcp.json` en un proyecto y agregar el servidor bajo `servers`, sin encabezados. [Instrucciones oficiales de VS Code](https://code.visualstudio.com/docs/agent-customization/mcp-servers).

### Windsurf y Cascade

En Cascade, abra **⋯ → MCPs → Open MCP config file** y agregue esta entrada a `mcpServers`:

```json
{
  "mcpServers": {
    "versat": {
      "serverUrl": "https://mcp-versat.azurewebsites.net/mcp"
    }
  }
}
```

Guarde y conecte mediante OAuth si aparece esa opción. Si su versión solo admite encabezados, use [conexión manual con token](#conexion-manual-con-token). [Instrucciones oficiales de Cascade](https://docs.devin.ai/desktop/cascade/mcp).

### Conexión manual con token

Use este método solo cuando su cliente no pueda completar OAuth. Primero genere el Token Bearer en el sistema Versat. Configure un servidor **HTTP / Streamable HTTP** con la URL del MCP y **una** de estas credenciales:

| Campo que ofrece el cliente | Valor |
| --- | --- |
| Bearer token | Su token de Versat, sin la palabra `Bearer` |
| Encabezado personalizado | Nombre `X-Versat-Mcp-Token`; valor: su token de Versat sin `Bearer` |

Guarde el token en el almacén privado de credenciales del cliente. No lo pegue en chats, archivos compartidos ni en este repositorio. En VS Code, puede usar una entrada `promptString` con `password: true`; en otros clientes, siga su mecanismo privado de secretos. [Referencia de configuración de VS Code](https://code.visualstudio.com/docs/agents/reference/mcp-configuration).

### Otros clientes

Seleccione transporte **HTTP / Streamable HTTP**, nombre `versat` y la URL completa terminada en `/mcp`. Si aparece una pantalla de inicio de sesión, use su usuario y token de Versat. Si no existe OAuth, siga la [conexión manual](#conexion-manual-con-token).

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
| `401`, `Auth required` o `mcp_http_bearer_ausente_o_invalido` | Pulse **Connect / Authenticate** en el cliente. Si usa conexión manual, revise que el token esté configurado en el cliente. |
| OAuth expirado o servidor reiniciado | Conecte de nuevo y complete la página de Versat. |
| El formulario rechaza el acceso | Compruebe que escribió su usuario de Versat y el token de esa misma cuenta. |
| `acceso_mcp_denegado` o estado `denegado` | El administrador debe revisar la habilitación MCP para esa credencial o empresa |
| Estado `indeterminado` | No pudo completarse la validación; no demuestra falta de permiso |
| `426` | Use HTTPS y solicite revisar el proxy de la instalación |
| Servidor configurado, pero sin tools | Revise que esté habilitado y aprobado en el cliente, la URL completa y posibles restricciones de su organización |
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

Si instaló el plugin, la skill ya está incluida. Siga estos pasos solo para instalarla de forma independiente.

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
3. Incremente `skills/versat-mcp/VERSION`, la versión de `skills-manifest.json` y la de los manifiestos del plugin. Registre todo archivo de la skill distribuido y recalcule sus hashes SHA-256.
4. Ejecute `ruby scripts/validar_distribucion.rb` y `git diff --check`.
5. Sincronice desde este repositorio el espejo `skills/versat-mcp` del servidor y compare los archivos.

La validación comprueba estructura, versiones, archivos, enlaces locales y hashes; la revisión de los flujos debe comprobar además el significado de las instrucciones. Commit, push y publicación se realizan únicamente cuando estén autorizados.
