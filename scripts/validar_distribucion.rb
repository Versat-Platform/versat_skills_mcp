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

puts "Distribución de skills válida."
