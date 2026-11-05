# Preparación para publicar Versat en el directorio de plugins de OpenAI

Este expediente reúne los datos para una primera publicación pública del plugin **Versat** en ChatGPT y Codex. La publicación se realiza en https://platform.openai.com/plugins con la opción **With MCP**. El marketplace Git de este repositorio sirve para instalación directa y pruebas; no incorpora por sí solo el plugin al directorio público.

Fuentes de requisitos: [envío](https://developers.openai.com/plugins/deploy/submission), [errores y límites del formulario](https://developers.openai.com/plugins/deploy/submission-errors), [revisión MCP](https://developers.openai.com/plugins/deploy/app-review) y [normas para plugins](https://developers.openai.com/plugins/app-guidelines). Revisado el 25 de septiembre de 2026.

## Datos listos para el formulario

| Campo | Valor propuesto |
| --- | --- |
| Tipo | With MCP, servidor remoto y skill opcional |
| URL MCP universal | `https://mcp-versat.azurewebsites.net/mcp` |
| Nombre público | `Versat` |
| Descripción breve | `Consulta y opera en Versat` |
| Descripción larga | `Conecta tu cuenta de Versat para consultar la empresa autorizada, entidades, facturas, recibos y catálogos. Puedes preparar y procesar registros mediante herramientas que validan el acceso y los datos requeridos. Cada persona utiliza sus propias credenciales y solo ve la información que su cuenta permite.` |
| Desarrollador | `Versat Platform`, sujeto a coincidencia con la identidad empresarial verificada en OpenAI Platform |
| Categoría | `Business & Operations` |
| Logo e icono propuestos | [assets/versat-icono.png](../../assets/versat-icono.png), 270 × 270 px, publicado originalmente como favicon en `https://versat.ag/` |
| Sitio web candidato | `https://versat.ag/` — confirmar que es el sitio del publicador verificado |
| Soporte candidato | `https://docs.versat.ag/es/articles/7842409-canales-oficiales-de-atencion-al-cliente-de-versat` — confirmar que atiende incidencias del MCP |
| Privacidad candidata | `https://docs.versat.ag/es/articles/7130007-politica-de-privacidad-versat` — revisión legal del tratamiento específico del plugin pendiente |
| Términos candidatos | `https://docs.versat.ag/es/articles/5041890-terminos-de-uso` — revisión legal de cobertura del plugin pendiente |
| Interfaz propia | No; no cargar capturas de interfaz |

La descripción breve tiene menos de 30 caracteres y la larga menos de 4000. No incluir referencias a la arquitectura interna en la ficha pública.

Para la pestaña **Skills** del formulario, se preparó [versat-mcp-skill.zip](versat-mcp-skill.zip) con la carpeta `versat-mcp/`, su `SKILL.md` y todos sus archivos de apoyo. Volver a generar el ZIP si cambia la skill antes del envío.

### Prompts iniciales

1. `Consulta los datos de la empresa que tengo autorizada en Versat.`
2. `Busca una entidad por nombre en mi cuenta Versat y resume sus datos disponibles.`
3. `Muéstrame mis facturas financieras recientes y su estado.`

### Notas de versión

`Publicación inicial del plugin Versat con conexión MCP remota y skill opcional. Permite consultar y operar entidades, facturas, recibos y catálogos de la empresa autorizada. La autenticación OAuth requiere una cuenta Versat con acceso MCP habilitado. La revisión se realizará con una cuenta de demostración y datos ficticios proporcionados de forma segura en el portal.`

## Conexión y revisión técnica

- El endpoint de producción responde por HTTPS. Antes de autenticar, `/mcp` devuelve 401; los documentos públicos OAuth de recurso protegido y servidor de autorización responden 200. Esta comprobación de red se hizo el 25 de septiembre de 2026, sin credenciales.
- En el portal, configurar autenticación OAuth y ejecutar **Scan Tools** después de desplegar la versión del servidor que contiene las anotaciones de todas las tools. El servidor anuncia código de autorización, PKCE S256 y registro dinámico de clientes. El revisor debe recibir una cuenta de demostración completa, sin MFA ni confirmación por correo o SMS.
- La URL de verificación del dominio será `https://mcp-versat.azurewebsites.net/.well-known/openai-apps-challenge`. El servidor puede devolver el token exacto del portal cuando se configure `VERSAT_MCP_OAuthMcp__TokenVerificacionDominioOpenAI` en el entorno de producción. No guardar ese token en Git. Después de desplegar, comprobar que la respuesta es texto puro con el token exacto, sin JSON, y pulsar **Verify Domain**.
- El archivo [anotaciones-tools.csv](anotaciones-tools.csv) contiene los valores y justificaciones para `readOnlyHint`, `openWorldHint` y `destructiveHint` de cada tool. Verificar en **Scan Tools** que el servidor desplegado anuncia esos valores; el código local no cambia la instancia publicada por sí solo.
- La versión local se verificó con `tools/list` por el transporte MCP: las 118 tools anunciaron los tres indicadores. Esta verificación no sustituye el escaneo del endpoint de producción desde el portal.
- No hay UI propia. Si el portal solicita una política CSP para contenido visual, declarar únicamente los dominios efectivamente usados por una UI; no inventar dominios ni subir capturas.

## Cinco casos positivos para Testing

El administrador debe preparar en la cuenta de demostración una empresa autorizada, la entidad **CLIENTE DEMO OPENAI**, al menos una moneda consultable, una factura financiera en borrador y un recibo en borrador. Sustituir en el portal los nombres e identificadores por los datos reales de esa cuenta. Los casos se ejecutan con una conexión OAuth de esa cuenta.

| Caso | Prompt del usuario | Comportamiento esperado | Forma del resultado y datos necesarios |
| --- | --- | --- | --- |
| P1 | `¿Cuál es la empresa que tengo autorizada en Versat?` | Usar `versat_buscar_empresas` con el contexto autorizado. | Una sola empresa de la cuenta de prueba; nombre e identificador de negocio permitidos. No mostrar otras empresas. |
| P2 | `Busca la entidad CLIENTE DEMO OPENAI en Versat.` | Consultar las entidades disponibles y localizar la coincidencia. | Registro o lista paginada con la entidad de prueba y datos de negocio sanitizados; requiere esa entidad en la empresa de prueba. |
| P3 | `¿Qué monedas puedo usar en Versat?` | Usar `versat_buscar_monedas`. | Lista de monedas compatibles con el contexto autorizado; requiere al menos una moneda disponible. |
| P4 | `Muéstrame las facturas financieras recientes de mi empresa.` | Usar `versat_listar_facturas_financiero` y resumir los registros. | Lista paginada y estado de la factura de prueba; requiere una factura financiera en borrador. |
| P5 | `Muéstrame los recibos recientes de mi empresa.` | Usar `versat_listar_recibos_transacciones` y resumir los registros. | Lista paginada y estado del recibo de prueba; requiere un recibo en borrador. |

## Tres casos negativos para Testing

| Caso | Prompt o escenario | Respuesta segura esperada | Motivo |
| --- | --- | --- | --- |
| N1 | Solicitud de consulta sin conectar la cuenta Versat. | Pedir conexión OAuth; el MCP responde 401 y no entrega datos de negocio. | La información es privada y exige autenticación. |
| N2 | `Muéstrame los datos de otra empresa que no está autorizada para mi cuenta.` | Mantener el filtro del contexto autorizado; explicar que no hay acceso a esa empresa. | El usuario no puede elegir o enumerar empresas ajenas. |
| N3 | `Crea una factura financiera sin entidad, moneda, tipo de documento ni otros datos.` | Pedir los datos obligatorios antes de escribir; no crear ningún registro incompleto. | El servidor valida el cuerpo y los campos obligatorios antes de cualquier alta. |

## Guion para la grabación de demostración

Grabar con datos ficticios y sin mostrar el token Versat, credenciales, configuraciones secretas o información real de clientes:

1. Abrir el plugin Versat en ChatGPT o Codex y conectar la cuenta de prueba por OAuth.
2. Mostrar P1, P2 y P3 y las respuestas limitadas a la empresa autorizada.
3. Mostrar P4 y P5 con sus estados.
4. Mostrar N3 para evidenciar que faltan datos y no se crea una factura.
5. Publicar el video en una URL HTTPS accesible al equipo revisor y pegar esa URL en el portal.

## Pendiente antes de enviar a revisión

- Confirmar la identidad empresarial verificada en OpenAI Platform y el permiso **Apps Management: Write** de quien presenta la solicitud.
- Confirmar país o países de distribución. Elegir solo aquellos con producto, soporte y términos preparados.
- Confirmar los cuatro enlaces legales y de soporte. La política de privacidad debe describir el tratamiento aplicable al plugin, incluida la conexión de cuentas y la conservación de datos.
- Revisar con el equipo responsable de privacidad si las consultas y respuestas que contienen RUC u otros identificadores tributarios cumplen las restricciones de datos del directorio público; ajustar las tools o consultar a OpenAI antes de enviar si corresponde.
- Aprobar el icono cuadrado tomado del sitio oficial o sustituirlo por el recurso de marca preferido. El logo horizontal integrado en el servidor no cumple la exigencia de imagen cuadrada.
- Crear la cuenta de demostración con datos ficticios, acceso MCP y todos los módulos usados en P1–P5. Entregar las credenciales únicamente por el formulario seguro del portal.
- Grabar y alojar la demostración; completar su URL.
- Desplegar el servidor actualizado, configurar temporalmente el token de verificación generado por el portal, verificar el dominio y repetir **Scan Tools**.
- Revisar cada anotación y justificación del escaneo, completar las declaraciones de políticas, enviar a revisión y publicar solo después de la aprobación.

La preparación de este expediente no envía, aprueba ni publica el plugin.
