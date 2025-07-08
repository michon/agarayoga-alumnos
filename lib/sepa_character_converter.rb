# lib/sepa_character_converter.rb
module SepaCharacterConverter
  # Mapeo de caracteres especiales a sus equivalentes SEPA
  CHAR_REPLACEMENTS = {
    # Letras con acentos y diacríticos
    'á' => 'a', 'à' => 'a', 'ä' => 'a', 'â' => 'a', 'â' => 'a', 'Á' => 'A', 'À' => 'A', 'Ä' => 'A', 'Â' => 'A',
    'é' => 'e', 'è' => 'e', 'ë' => 'e', 'ê' => 'e', 'É' => 'E', 'È' => 'E', 'Ë' => 'E', 'Ê' => 'E',
    'í' => 'i', 'ì' => 'i', 'ï' => 'i', 'î' => 'i', 'Í' => 'I', 'Ì' => 'I', 'Ï' => 'I', 'Î' => 'I',
    'ó' => 'o', 'ò' => 'o', 'ö' => 'o', 'ô' => 'o', 'Ó' => 'O', 'Ò' => 'O', 'Ö' => 'O', 'Ô' => 'O',
    'ú' => 'u', 'ù' => 'u', 'ü' => 'u', 'û' => 'u', 'Ú' => 'U', 'Ù' => 'U', 'Ü' => 'U', 'Û' => 'U',
    'ñ' => 'n', 'Ñ' => 'N',
    'ç' => 'c', 'Ç' => 'C',
    
    # Caracteres especiales
    'º' => 'o', 'ª' => 'a',
    '¿' => '', '¡' => '',
    'ß' => 'ss',
    '€' => 'E',
    
    # Otros símbolos
    '´' => '', '`' => '', '¨' => '', '^' => '', '~' => '', '¯' => ''
  }.freeze

  # Expresión regular que combina todos los caracteres a reemplazar
  PATTERN = Regexp.new(CHAR_REPLACEMENTS.keys.map { |k| Regexp.escape(k) }.join('|')).freeze

  module_function

  # Convierte una cadena UTF-8 al formato aceptado por SEPA
  def to_sepa_format(string)
    return '' if string.nil?
    
    # Primero: reemplazar caracteres especiales
    converted = string.gsub(PATTERN, CHAR_REPLACEMENTS)
    
    # Segundo: eliminar cualquier otro carácter no ASCII (opcional, según requisitos)
    converted.gsub(/[^\x00-\x7F]/, '')
  end

  # Versión que modifica el objeto original
  def to_sepa_format!(string)
    return if string.nil?
    string.replace(to_sepa_format(string))
  end
end
