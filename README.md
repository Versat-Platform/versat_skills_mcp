# Versat MCP Skills

Instrucciones opcionales para que agentes de IA usen las tools de Versat con criterios de negocio consistentes. El servidor MCP conserva sus validaciones y puede utilizarse sin instalar skills.

Este repositorio, en la rama `main`, es la fuente oficial de distribución. [skills-manifest.json](skills-manifest.json) identifica versiones, rutas y hashes SHA-256; cada skill incluye `VERSION`. Una edición local no actualiza la versión publicada hasta incorporarse a la rama de distribución.

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

## Conectar el cliente MCP

Obtenga la URL HTTPS y una credencial de Versat con el administrador de la instalación. Configure el servidor en un cliente compatible con MCP HTTP y use una de estas formas de autenticación:

```http
Authorization: Bearer <token-versat>
```

```http
X-Versat-Mcp-Token: <token-versat>
```

Use solo una. En el encabezado personalizado, no agregue `Bearer`. Si el cliente pide una variable de entorno, indique su nombre y configure el valor secreto en el entorno del cliente. No almacene credenciales reales en este repositorio, prompts ni capturas.

El formato de configuración depende del cliente; use su mecanismo de servidores MCP y almacenamiento de credenciales. Copiar una configuración de otro cliente no garantiza compatibilidad.

Para verificar la conexión:

1. Liste las tools y solicite la guía MCP.
2. Ejecute `versat_buscar_empresas` para comprobar lectura de la empresa autorizada.
3. Si la consulta falla, consulte [Autenticación](skills/versat-mcp/references/authentication.md). El descubrimiento de tools no demuestra acceso a datos.

## Instalar o actualizar la skill

### Mediante el MCP

Pida al agente instalar o actualizar la skill oficial de Versat. El flujo usa `versat_sincronizar_skills`:

1. Informa la versión local cuando esté disponible.
2. Revisa el resultado y, si devuelve un paquete, guarda todos sus archivos respetando `rutaDestinoRelativa` y `rutaRelativa` dentro del directorio de skills admitido por el cliente.
3. Verifica los hashes y que `VERSION` coincida con `versionOficial`.
4. Recarga las skills mediante el mecanismo del cliente cuando sea necesario.

La tool prepara el paquete oficial, pero no escribe archivos en el cliente. Solo confirme la instalación después de guardar y verificar los archivos.

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
