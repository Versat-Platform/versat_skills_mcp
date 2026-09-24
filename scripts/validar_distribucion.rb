#!/usr/bin/env ruby

require "digest"
require "json"
require "pathname"
require "yaml"

raiz = Pathname.new(__dir__).parent
manifiesto = JSON.parse((raiz / "skills-manifest.json").read)

abort "schemaVersion no compatible" unless manifiesto["schemaVersion"] == 1
abort "No hay skills distribuidas" unless manifiesto["skills"].is_a?(Array) && !manifiesto["skills"].empty?

manifiesto["skills"].each do |skill|
  nombre = skill.fetch("name")
  ruta = raiz / skill.fetch("path")
  archivos = skill.fetch("files")
  hashes = skill.fetch("sha256")

  abort "Nombre de skill inválido: #{nombre}" unless nombre.match?(/\A[a-z0-9-]+\z/)
  abort "Directorio de skill ausente: #{ruta}" unless ruta.directory?
  abort "Lista de archivos inválida para #{nombre}" unless archivos.is_a?(Array) && archivos.uniq == archivos
  abort "Hashes incompletos para #{nombre}" unless hashes.keys.sort == archivos.sort

  version = (raiz / skill.fetch("versionFile")).read.strip
  abort "Versión divergente para #{nombre}" unless version == skill.fetch("version")
  abort "Entrypoint inválido para #{nombre}" unless (raiz / skill.fetch("entrypoint")).file?

  archivos.each do |ruta_relativa|
    abort "Ruta insegura en #{nombre}: #{ruta_relativa}" if Pathname.new(ruta_relativa).absolute? || ruta_relativa.split("/").include?("..")

    archivo = ruta / ruta_relativa
    abort "Archivo ausente en #{nombre}: #{ruta_relativa}" unless archivo.file?

    hash = Digest::SHA256.file(archivo).hexdigest
    abort "Hash divergente en #{nombre}: #{ruta_relativa}" unless hash == hashes.fetch(ruta_relativa)
  end

  skill_md = ruta / "SKILL.md"
  contenido = skill_md.read
  coincidencia = contenido.match(/\A---\n(.*?)\n---/m)
  abort "Frontmatter ausente en #{nombre}" unless coincidencia

  frontmatter = YAML.safe_load(coincidencia[1])
  abort "Frontmatter inválido en #{nombre}" unless frontmatter.is_a?(Hash)
  abort "Nombre divergente en SKILL.md: #{nombre}" unless frontmatter["name"] == nombre
  abort "Descripción ausente en #{nombre}" if frontmatter["description"].to_s.strip.empty?
  abort "Campos inesperados en SKILL.md: #{nombre}" unless (frontmatter.keys - %w[name description]).empty?

  archivos.grep(/\.md\z/).each do |ruta_relativa|
    origen = ruta / ruta_relativa
    origen.read.scan(/\]\(([^)]+)\)/).flatten.each do |destino|
      next if destino.start_with?("#", "http://", "https://")

      ruta_destino = destino.split("#", 2).first
      abort "Link local inválido en #{ruta_relativa}: #{destino}" unless (origen.dirname / ruta_destino).cleanpath.file?
    end
  end
end

nombre_plugin = "versat-mcp"
version_plugin = manifiesto.fetch("skills").find { |skill| skill["name"] == nombre_plugin }&.fetch("version")
abort "La skill del plugin no está en el manifiesto" unless version_plugin

plugin = JSON.parse((raiz / "plugin.json").read)
plugin_codex = JSON.parse((raiz / ".codex-plugin/plugin.json").read)
plugin_claude = JSON.parse((raiz / ".claude-plugin/plugin.json").read)
paquete_claude = raiz / "plugins/claude/versat-mcp"
plugin_claude_distribuido = JSON.parse((paquete_claude / ".claude-plugin/plugin.json").read)
mercado_codex = JSON.parse((raiz / ".agents/plugins/marketplace.json").read)
mercado_claude = JSON.parse((raiz / ".claude-plugin/marketplace.json").read)
mcp_portatil = JSON.parse((raiz / "mcp.json").read)
mcp_nativo = JSON.parse((raiz / ".mcp.json").read)

[plugin, plugin_codex, plugin_claude, plugin_claude_distribuido].each do |datos|
  abort "Nombre divergente en el plugin" unless datos["name"] == nombre_plugin
  abort "Versión divergente en el plugin" unless datos["version"] == version_plugin
end

abort "Ruta de skills inválida para Codex" unless plugin_codex["skills"] == "./skills/"
abort "Ruta MCP inválida para Codex" unless plugin_codex["mcpServers"] == "./.mcp.json"
abort "Skill no encontrada en el plugin" unless (raiz / "skills" / nombre_plugin / "SKILL.md").file?
abort "Versión del marketplace Claude divergente" unless mercado_claude.fetch("plugins").any? { |entrada| entrada["name"] == nombre_plugin && entrada["source"] == "./plugins/claude/versat-mcp" && entrada["version"] == version_plugin }
abort "Configuración MCP del plugin Claude divergente" unless (paquete_claude / ".mcp.json").read == (raiz / ".mcp.json").read
abort "Manifiesto del plugin Claude divergente" unless (paquete_claude / ".claude-plugin/plugin.json").read == (raiz / ".claude-plugin/plugin.json").read
manifiesto.fetch("skills").find { |skill| skill["name"] == nombre_plugin }.fetch("files").each do |archivo|
  origen = raiz / "skills" / nombre_plugin / archivo
  copia = paquete_claude / "skills" / nombre_plugin / archivo
  abort "Skill del plugin Claude divergente: #{archivo}" unless copia.file? && copia.read == origen.read
end
abort "Marketplace Codex inválido" unless mercado_codex.fetch("plugins").any? do |entrada|
  entrada["name"] == nombre_plugin && entrada.dig("source", "source") == "local" && entrada.dig("source", "path") == "./" && entrada.dig("policy", "authentication") == "ON_INSTALL"
end

url_portatil = mcp_portatil.dig("mcpServers", "versat", "url")
url_nativa = mcp_nativo.dig("mcpServers", "versat", "url")
abort "URL MCP divergente" unless url_portatil == url_nativa && url_portatil.to_s.match?(%r{\Ahttps://[^/]+/mcp\z})
abort "Transporte MCP portátil inválido" unless mcp_portatil.dig("mcpServers", "versat", "type") == "streamable-http"
abort "Transporte MCP nativo inválido" unless mcp_nativo.dig("mcpServers", "versat", "type") == "http"

[mcp_portatil, mcp_nativo].each do |configuracion|
  abort "No incluya credenciales en el plugin" unless configuracion.fetch("mcpServers").fetch("versat").keys.sort == %w[type url]
end

puts "Distribución de skills y plugin válida."
