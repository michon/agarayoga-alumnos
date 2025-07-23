namespace :julio do
    desc "Añade los usuarios actuales en horario a la tabla julio"
    task agregarAlumnos: :environment do
      HorarioAlumno.group(:usuario_id).each do |alm|
        Julio.new(usuario_id: alm.usuario_id).save 
      end
    end

    desc "Actualiza el nombre en la tabla julio"
    task actualizarNombre: :environment do
      Julio.all.each do |alm|
        alm.nombre = alm.usuario.nombre
        alm.save 
      end
    end
end
