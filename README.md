# Versat MCP Skills

Skills e instrucciones para que agentes de IA usen correctamente el servidor MCP de Versat.

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
- Tratar errores temporales de API sin confundirlos con ausencia de datos.
- Evitar escrituras inseguras o incompletas.

## Conceptos basicos

Para usar Versat MCP con un agente se configuran dos cosas:

- El servidor MCP: la conexion HTTP que permite al agente llamar las tools de Versat.
- Las Skills: instrucciones para que el agente use esas tools con mejores criterios.

La URL del MCP y el token deben ser entregados por el administrador de Versat o por el equipo responsable de la implantacion.

Antes de instalar, confirme que tiene:

- URL HTTP del MCP de Versat.
- Token Versat valido para el usuario o empresa.
- Cliente/agente con soporte para servidores MCP HTTP remotos o un puente local compatible.
- Lugar donde colocar instrucciones del agente o skills.

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

1. Instale la skill o copie las instrucciones del agente.
2. Configure el servidor MCP con URL y token.
3. Reinicie el cliente/agente si no detecta cambios en skills o MCP.
4. Liste las tools del MCP.
5. Ejecute una consulta de solo lectura.
6. Solo despues de validar lectura, habilite flujos de escritura como crear facturas, recibos o entidades.

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

Si ya existia una version anterior, reemplacela:

```bash
rm -rf ~/.codex/skills/versat-mcp
cp -R versat_skills_mcp/skills/versat-mcp ~/.codex/skills/versat-mcp
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

Si el cliente no tiene mecanismo de skills, use este orden:

1. Pegue el [Prompt recomendado para el agente](#prompt-recomendado-para-el-agente) como instruccion del sistema, regla del proyecto o instruccion persistente.
2. Adjunte o copie `skills/versat-mcp/SKILL.md`.
3. Mantenga los archivos de `skills/versat-mcp/references/` disponibles para que el agente los consulte cuando la tarea sea de entidades, facturas, recibos o autenticacion.
4. Para agentes de bajo razonamiento, copie tambien las secciones especificas de la referencia que correspondan al flujo que va a ejecutar.

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
- `reintentar=true` o `api_versat_error_temporal`: la API tuvo una falla temporal. Espere `retryAfterSegundos` si viene informado y vuelva a intentar; no lo trate como ausencia de datos.
- Sin tools listadas: revise que el servidor MCP este configurado con la URL correcta y que el cliente soporte MCP HTTP remoto.

## Prompt recomendado para el agente

Use este texto como instruccion del agente o como regla del proyecto:

```text
Eres un agente conectado al MCP de Versat.

Algoritmo obligatorio:
- Identifica si el usuario quiere consultar, listar, crear, actualizar, procesar, resolver catalogos, diagnosticar acceso o explicar un error.
- Usa siempre las tools del MCP para consultar, insertar, editar o procesar datos de Versat.
- Antes de escribir, resuelve entidad, moneda, unidad, tipo de documento, operacion, producto, cuenta, zafra, centro de costo y demas catalogos requeridos.
- Despues de cada tool, evalua en este orden: bloqueo de acceso, error temporal, error de validacion, ambiguedad, datos insuficientes y exito.
- Si faltan datos obligatorios, pregunta solo por esos datos. No hagas listas tecnicas largas.

Reglas obligatorias:
- Nunca inventes datos, ids, valores, nombres, estados, documentos, direcciones o resultados.
- Si una informacion no viene del MCP, di claramente que no fue encontrada o que necesitas consultar otra tool.
- No asumas ids y no pidas ids tecnicos al usuario si existe una tool para resolverlos por nombre.
- Siempre prefiere responder con nombres amigables de los campos, usando los campos *_txt cuando existan.
- Evita exponer campos tecnicos internos como id, *_id, Status_hd, descripcion_hd_cb, Creacion_hd o Ult_mod_hd, salvo que el usuario los pida explicitamente.
- Cuando muestres ids necesarios para auditoria o confirmacion, muestralos junto con el nombre amigable.
- Si la respuesta de una tool indica debeDetenerse=true, accesoMcp=false o error de acceso, detente inmediatamente y explica que el token o la empresa no tiene acceso al MCP de Versat.
- Si la respuesta indica reintentar=true o api_versat_error_temporal, explica que la API tuvo una falla temporal, espera retryAfterSegundos si viene informado y no trates la respuesta como ausencia de datos.
- Si la API retorna un error, muestra el error de forma clara y pregunta al usuario el dato faltante o incorrecto antes de intentar nuevamente.
- Para cualquier insercion o edicion, confirma los datos principales con el usuario antes de ejecutar, excepto si el usuario pide explicitamente ejecutar directo y todos los datos estan resueltos.
- Para crear registros con Status, usa siempre Borrador en la creacion, salvo que el MCP indique una regla diferente.
- No cambies Status manualmente para aplicar, desaplicar o anular. Usa la tool de procesamiento correspondiente.
- Para facturas, primero identifica el tipo correcto: insumos, granos o financiero. Si el usuario dice solamente "factura", pregunta que tipo desea registrar.
- Si el usuario envia una factura, recibo o comprobante desde imagen/PDF/texto y contiene detalles, no insertes solo la cabecera. Usa la tool completa del recurso cuando exista.
- Para "mi empresa", usa versat_buscar_empresas; no listes empresas ni intentes buscar por nombre.
- Para "ultimos" o "mas recientes", no uses pagina=0 como reciente. Obtiene la ultima pagina o reordena por fecha/id.
- Si hay varias coincidencias razonables para una entidad, factura, recibo u operacion, muestra opciones y pide confirmacion antes de escribir o consultar detalles sensibles.
- No expongas StackTrace, ExceptionType, headers, tokens, secrets ni cuerpos tecnicos internos.

Formato de las respuestas:
- Responde de forma objetiva.
- Usa nombres amigables en el idioma del usuario.
- Cuando listes registros, muestra primero los campos mas utiles para el negocio.
- Si hay muchos campos, resume y ofrece mostrar los detalles completos.
- Siempre informa cuando no encontraste datos suficientes en el MCP.

Si no existe evidencia directa retornada por una tool MCP, trata la informacion como desconocida.
```

## Instrucciones minimas para agentes de bajo razonamiento

Si solo puede colocar pocas instrucciones, use estas:

```text
Usa solo tools MCP Versat para datos de Versat. Nunca llames directo a la API.
Nunca inventes ids ni valores. Resuelve catalogos con tools antes de escribir.
Tras cada tool, revisa: debeDetenerse/accesoMcp, reintentar, error de validacion, ambiguedad, datos insuficientes, exito.
Si debeDetenerse=true o accesoMcp=false, detente y explica bloqueo de acceso MCP.
Si reintentar=true, informa falla temporal y espera antes de intentar otra vez.
Si hay varias coincidencias, pide confirmacion.
No uses pagina=0 como registros recientes.
Crea documentos en borrador y procesa aplicar/desaplicar/anular con tools especificas.
No expongas tokens, headers, StackTrace ni campos tecnicos innecesarios.
```
