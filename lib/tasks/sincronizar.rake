namespace :sincronizar do

    desc "recorre los usuarios y actualiza la referencia del mandato"
    task referencia: :environment do
      Usuario.all.each do |usr|
       unless usr.codigofacturacion.blank?
         usr.referencia = usr.codigofacturacion + "0"*12 + "1"
         usr.save
       end
      end
    end

    desc "Recorre los recibos y actualiza el concepto "
    task rcbConcepto: :environment do
      Recibo.all.each do |rcb|
       if rcb.concepto.blank?
         rcb.concepto = "Cuota mensual de AgâraYoga " + I18n.translate(:"date.month_names", :locale => :es)[rcb.created_at.mon] + " " + rcb.created_at.year.to_s
         rcb.save
       end
      end
    end

    desc "recorre los usuarios y actualiza la serie "
    task serie: :environment do
        Usuario.all.each do |usr|
           if Cliente.exists?(["codcliente = ?", usr.codigofacturacion])
               cli = Cliente.where("codcliente = ?", usr.codigofacturacion).first
               unless cli.blank?
                 usr.serie = cli.codserie
                 usr.remesa = cli.codserie == "A"
                 usr.save
               end
           end
        end
    end

    desc "recorre los usuarios y actualiza el bic y el iban"
    task banco: :environment do
        Usuario.all.each do |usr|
           if Cliente.exists?(["codcliente = ?", usr.codigofacturacion])
               cli = Cliente.where("codcliente = ?", usr.codigofacturacion).first
               cta = Cuentasbcocli.find_by(codcliente: cli.codcliente)
               unless cta.blank?
                 usr.iban = cta.iban
                 usr.bic = cta.bic
                 usr.save
               end
           end
        end
    end

    desc "recorre los usuarios y actualiza el grupo al que pertenecen"
    task grupo: :environment do
        Usuario.all.each do |usr|
           if Cliente.exists?(["codcliente = ?", usr.codigofacturacion])
               cli = Cliente.where("codcliente = ?", usr.codigofacturacion).first
               usr.grupoAlumno = GrupoAlumno.find_by(codigoFacturacion: cli.codgrupo)
               usr.save
           end
        end
    end

    desc "accede a la base de datos de facturación y sincroniza los datos"
    task actualizar: :environment do
        Cliente.all.each do |cli|
            puts "Nombre: #{cli.nombre}"
            if Usuario.exists?(["codigofacturacion = ?", cli.codcliente])
                puts "... Actualizando ... "
                usr = Usuario.where("codigofacturacion = ?", cli.codcliente).first
                usr.email = cli.email
                usr.nombre = cli.nombre
                usr.dni = cli.cifnif
                usr.telefono = cli.telefono2
                usr.movil = cli.telefono1
                usr.debaja = cli.debaja
                usr.codigofacturacion = cli.codcliente
                usr.pais = 'ES'
                if GrupoAlumno.find_by(codigoFacturacion: cli.codgrupo).blank?
                    usr.grupoAlumno = GrupoAlumno.all.first
                else
                    usr.grupoAlumno = GrupoAlumno.find_by(codigoFacturacion: cli.codgrupo)
                end
                if Dircliente.exists?(["codcliente = ?", cli.codcliente])
                    puts "Actualizando direccion ... "
                    dir =  Dircliente.where("codcliente = ?", cli.codcliente).first
                    usr.direccion = dir.direccion
                    usr.localidad = dir.ciudad
                    usr.provincia = dir.provincia
                    usr.cp = dir.codpostal
                end
                if Cuentabcocli.exists?(["codcliente = ?", cli.codcliente])
                    puts "Actualizando dantos bancarios ... "
                    usr.iban =  Cuentabcocli.where("codcliente = ?", cli.codcliente).first.iban
                    usr.lugarfirma = "LUGO"
                    usr.fechafirma = Date.today
                end
                puts "\n"
                usr.save
            else
                puts "... Alta ... "
                usr = Usuario.new
                usr.email = cli.email
                usr.nombre = cli.nombre
                usr.dni = cli.cifnif
                usr.telefono = cli.telefono2
                usr.movil = cli.telefono1
                usr.debaja = cli.debaja
                usr.codigofacturacion = cli.codcliente
                usr.password = cli.nombre.gsub(' ','_')
                usr.password_confirmation = cli.nombre.gsub(' ','_')
                usr.pais = 'ES'
                if GrupoAlumno.find_by(codigoFacturacion: cli.codgrupo).blank?
                    usr.grupoAlumno = GrupoAlumno.all.first
                else
                    usr.grupoAlumno = GrupoAlumno.find_by(codigoFacturacion: cli.codgrupo)
                end
                if Dircliente.exists?(["codcliente = ?", cli.codcliente])
                    puts "Actualizando direccion ... "
                    dir =  Dircliente.where("codcliente = ?", cli.codcliente).first
                    usr.direccion = dir.direccion
                    usr.localidad = dir.ciudad
                    usr.provincia = dir.provincia
                    usr.cp = dir.codpostal
                end
                if Cuentabcocli.exists?(["codcliente = ?", cli.codcliente])
                    puts "Actualizando dantos bancarios ... "
                    usr.iban =  Cuentabcocli.where("codcliente = ?", cli.codcliente).first.iban
                    usr.lugarfirma = "LUGO"
                    usr.fechafirma = Date.today
                end
                puts "\n"
                unless usr.save then
                    puts "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                    puts "error al grabar"
                    usr.errors.full_messages.each do |msg|
                        puts msg
                        puts "\n"
                    end

                else
                    puts "sin error"
                    usr.errors.full_messages
                end
            end # if usuario.exists?
        end # each cliente
    end # task
end # name space
