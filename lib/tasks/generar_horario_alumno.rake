# lib/tasks/generar_horario_alumno.rake
namespace :horarios do
  desc "Generar HorarioAlumno desde las Preinscripciones activas"
  task generar_desde_preinscripciones: :environment do
    puts "Iniciando generación de HorarioAlumno desde Preinscripciones..."
    
    generador = GeneradorHorarioAlumno.new
    resultado = generador.generar_desde_preinscripciones
    
    puts "\n=== RESULTADO ==="
    puts "Asignaciones exitosas: #{resultado[:asignaciones]}"
    puts "Conflictos detectados: #{resultado[:conflictos].count}"
    
    if resultado[:conflictos].any?
      puts "\n=== CONFLICTOS DETECTADOS ==="
      resultado[:conflictos].each do |conflicto|
        puts "Usuario: #{conflicto[:usuario]} | Horario: #{conflicto[:horario]} | Motivo: #{conflicto[:motivo]}"
      end
    end
    
    if resultado[:exitoso]
      puts "\n✅ Generación completada exitosamente"
    else
      puts "\n⚠️  Generación completada con conflictos"
    end
  end

  desc "Generar HorarioAlumno desde Preinscripciones con opciones avanzadas"
  task :generar_avanzado, [:limpiar_previos] => :environment do |t, args|
    puts "Plural de preinscripcion: #{'preinscripcion'.pluralize}"
    puts "Table name: #{Preinscripcion.table_name}"
    puts "Iniciando generación avanzada de HorarioAlumno..."
    
    # Opción para limpiar asignaciones previas
    if args[:limpiar_previos] == "true"
      puts "Limpiando asignaciones previas de HorarioAlumno..."
      HorarioAlumno.delete_all
      puts "Asignaciones previas eliminadas"
    end
    
    generador = GeneradorHorarioAlumno.new
    resultado = generador.generar_desde_preinscripciones
    
    # Mostrar resultados
    mostrar_resultados(resultado)
  end
end

def mostrar_resultados(resultado)
  puts "\n=== RESULTADOS DETALLADOS ==="
  puts "Total de asignaciones creadas: #{resultado[:asignaciones]}"
  puts "Total de conflictos: #{resultado[:conflictos].count}"
  
  if resultado[:conflictos].any?
    puts "\n--- Detalle de Conflictos ---"
    resultado[:conflictos].each_with_index do |conflicto, index|
      puts "#{index + 1}. Usuario: #{conflicto[:usuario]}"
      puts "   Horario ID: #{conflicto[:horario] || 'N/A'}"
      puts "   Motivo: #{conflicto[:motivo]}"
      puts "   ---"
    end
  end
  
  # Estadísticas adicionales
  total_preinscripciones = Preinscripcion.activas.count
  tasa_exito = total_preinscripciones > 0 ? (resultado[:asignaciones].to_f / total_preinscripciones * 100).round(2) : 0
  
  puts "\n=== ESTADÍSTICAS ==="
  puts "Total de preinscripciones: #{total_preinscripciones}"
  puts "Asignaciones exitosas: #{resultado[:asignaciones]}"
  puts "Tasa de éxito: #{tasa_exito}%"
end
