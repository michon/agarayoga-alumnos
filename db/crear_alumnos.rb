require 'csv'

def seed_alumnos
    csv_file_path = './db/alumnos.csv'
    puts 'Enviando alumnos a la base de datos... '
    f = File.new(csv_file_path, 'r')
    csv = CSV.new(f)
    herader = csv.shift
    csv.each do |row|
        correo = ""
        if 1 == 1 
            correo << row[2].to_s.gsub(' ','-') + '@agarayoga.eu'
        else
            correo << row[6]
        end
        un_alumno = {
            codigofacturacion: row[0],
            debaja: row[1],
            nombre: row[2],
            dni: row[3],
            telefono: row[4],
            movil: row[5],
            email: correo, 
            direccion: row[7],
            cp: row[8],
            localidad: row[9],
            provincia: row[10],
            pais: row[11],
            iban: row[12],
            password: row[2].to_s.gsub(' ','-'),
        }
       
        inv = Usuario.create(un_alumno)
    end
    csv.close
    f.close
    puts "Los alumnos ya están en la base de datos."
end
