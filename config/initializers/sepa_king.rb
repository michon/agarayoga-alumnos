require 'sepa_king'

module SEPA
  class Document
    def to_xml(schema_name)
      # Generar XML con encoding explícito
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        # ... (código original)
      end
      
      # Limpieza final del XML
      builder.to_xml(indent: 2)
        .force_encoding('UTF-8')
        .scrub('') # Elimina caracteres inválidos
    end
  end
end
