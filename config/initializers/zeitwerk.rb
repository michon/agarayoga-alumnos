Rails.autoloaders.each do |autoloader|
  # Ejemplo de inflexiones personalizadas (opcional)
  autoloader.inflector.inflect(
    "html_parser" => "HTMLParser",
    "ssl_error" => "SSLError"
  )
end
