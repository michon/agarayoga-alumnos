# lib/tasks/reporte_clases_agosto.rake
require 'csv'

namespace :reports do
  desc "Genera reporte CSV de alumnos con clases en agosto"
  task clases_agosto: :environment do
    current_year = Date.today.year
    august_start = Date.new(current_year, 8, 1)
    august_end = august_start.end_of_month
    output_file = "reporte_clases_agosto_#{current_year}.csv"

    # Obtener usuarios con clases en agosto (excluyendo admins)
    usuarios = Usuario.joins(:claseAlumno)
                     .joins("INNER JOIN clases ON clase_alumnos.clase_id = clases.id")
                     .where(admin: false)
                     .where("clases.diaHora >= ? AND clases.diaHora <= ?", august_start, august_end)
                     .distinct
                     .order(:nombre)

    CSV.open(output_file, 'w', col_sep: ';') do |csv|
      # Encabezados
      csv << [
        'Nombre', 
        'Semanas con clase', 
        'Clases semana 1', 
        'Clases semana 2', 
        'Clases semana 3', 
        'Clases semana 4', 
        'Clases semana 5', 
        'Promedio clases/semana',
        'Total clases'
      ]

      usuarios.each do |usuario|
        clases = ClaseAlumno.joins(:clase)
                           .where(usuario_id: usuario.id)
                           .where("clases.diaHora >= ? AND clases.diaHora <= ?", august_start, august_end)

        # Calcular semanas
        semanas = Hash.new(0)
        clases.each do |clase|
          semana = ((clase.clase.diaHora.to_date - august_start).to_i / 7 + 1)
          semanas[semana] += 1 if semana.between?(1, 5)
        end

        next if semanas.empty?

        total_clases = semanas.values.sum
        semanas_activas = semanas.keys.size
        promedio = semanas_activas > 0 ? total_clases.to_f / semanas_activas : 0

        # Fila con datos
        csv << [
          usuario.nombre,
          semanas_activas,
          semanas[1], semanas[2], semanas[3], semanas[4], semanas[5],
          promedio.round(2),
          total_clases
        ]
      end
    end

    puts "Reporte generado en: #{output_file}"
    puts "Total alumnos con clases: #{usuarios.count}"
  end
end
