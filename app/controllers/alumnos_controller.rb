class AlumnosController < ApplicationController
  require 'ficha_alumno.rb'

  def index
      unless AlumnosPolicy.new(current_usuario).verIndex?
        render :file => "public/401.html", :status => :unauthorized
      end
      @alumnos = Usuario.where(debaja: [false,  nil]).all
  end

  def clientes
      unless AlumnosPolicy.new(current_usuario).verClientes?
        render :file => "public/401.html", :status => :unauthorized
      end
      @alumnos = Cliente.all
  end

  #---------------------------------------------------------------------------
  #Actualiza los datos en la tabla de usuario que provienen de la facturación
  #---------------------------------------------------------------------------
  def actualizar
      unless AlumnosPolicy.new(current_usuario).verActualizar?
        render :file => "public/401.html", :status => :unauthorized
      end

      #Buscamos el cliente que queremos actualizar
      @cliente = Cliente.find(params[:id])
      cli = @cliente

      if Usuario.exists?(["codigofacturacion = ?", cli.codcliente])
        usr = Usuario.where("codigofacturacion = ?", cli.codcliente).first
        usr.email = cli.email
        usr.nombre = cli.nombre
        usr.dni = cli.cifnif
        usr.telefono = cli.telefono2
        usr.movil = cli.telefono1
        usr.debaja = cli.debaja
        usr.codigofacturacion = cli.codcliente
        usr.pais = 'ES'
        usr.serie = cli.codserie

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
            bcoCli = Cuentabcocli.where("codcliente = ?", cli.codcliente).first
            usr.iban =  bcoCli.iban
            usr.lugarfirma = "LUGO"
            usr.fechafirma = Date.today
            usr.bic =  bcoCli.bic
        end
        usr.save
      else   # --- Creamos el usuario ALTA
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
        usr.serie = cli.codserie

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
            usr.errors.full_messages.each do |msg|
                puts msg
                puts "\n"
            end

        else
            puts "sin error"
            usr.errors.full_messages
        end
      end # if usuario.exists?
  end

  def procesos
      unless AlumnosPolicy.new(current_usuario).verProcesos?
        render :file => "public/401.html", :status => :unauthorized
      end
      if params[:proceso].blank?
          proceso = 2
      else
          proceso = params[:proceso]
      end
      @proceso = proceso
      @procesos = Proceso.all
      if proceso then
          @procesoEstados = ProcesoEstado.where(proceso_id: proceso).all
          @procesoLista = Array.new(Usuario.activo.count)
          Usuario.activo.order(:nombre).each_with_index do |usr, idx|
              @procesoLista[idx] = Array.new
              @procesoLista[idx][2] = usr
              @procesoLista[idx][1] = Array.new
              @procesoLista[idx][0] = ProcesoEstadoAlumno.where(usuario_id: usr.id, procesoEstado_id: ProcesoEstado.where(proceso_id: proceso)).count.to_s + usr.nombre
              ProcesoEstado.where(proceso_id: proceso).each_with_index do |prcs, i|
                  @procesoLista[idx][1][i] = Array.new
                  @procesoLista[idx][1][i][0] = prcs
                  @procesoLista[idx][1][i][1] = ProcesoEstadoAlumno.where(usuario_id: usr.id, procesoEstado_id: prcs.id).first
              end
          end
      else
          @procesoEstados = ProcesoEstado.all
      end
  end

  def procesosAlta
      proceso =  params[:proceso]
      alumno  =  params[:alumno]
      if ProcesoEstadoAlumno.exists?(Usuario_id: alumno, procesoEstado_id: proceso) then
          ProcesoEstadoAlumno.find_by(Usuario_id: alumno, procesoEstado_id: proceso).delete
      else
          ProcesoEstadoAlumno.new(Usuario_id: alumno, procesoEstado_id: proceso).save
      end

      redirect_to alumnos_procesos_get_path(ProcesoEstado.where(id: proceso).first.proceso_id)
  end

  def business
      unless AlumnosPolicy.new(current_usuario).verBusiness?
        render :file => "public/401.html", :status => :unauthorized
      end
      @fecha = params[:fecha].to_datetime
      @fechaFin = DateTime.now
      @alumnos = Usuario.where(debaja: [false,  nil]).where(created_at: @fecha.beginning_of_month..@fechaFin.end_of_month).all
  end

  def show
      unless AlumnosPolicy.new(current_usuario).verShow?
        render :file => "public/401.html", :status => :unauthorized
      end
      @id = params[:id]
      @almn = Usuario.find(params[:id])
      @claseAlumno = ClaseAlumno.where(usuario_id: @id)
      @estados = ClaseAlumnoEstado.order(:id).all

      @clases = []
      @claseAlumno.each do |cl|
        unless cl.clase.blank?
          clase = Hash.new {}
          clase["fechaClase"] =  cl.clase.diaHora unless cl.clase.blank?
          clase["clase"] = cl.clase
          clase["claseAlumno"] = cl
          @clases << [ cl.clase.diaHora, clase]
        end
      end
      respond_to do |format|
          format.html

          format.pdf do
            ficha = FichaAlumno.new(@almn)
            ficNombre = "ficha_" + @almn.nombre.sub(" ", "-")
            send_data ficha.render, filename: ficNombre, type: 'application/pdf', diposition: 'inline'
          end
      end
  end

  def ficha
      unless AlumnosPolicy.new(current_usuario).verFicha?
        render :file => "public/401.html", :status => :unauthorized
      end
      @id = params[:id]
      @almn = Usuario.find(params[:id])
  end

  def sepa
      unless AlumnosPolicy.new(current_usuario).verSepa?
        render :file => "public/401.html", :status => :unauthorized
      end
      @id = params[:id]
      @almn = Usuario.find(params[:id])
  end

  def regalo
      unless AlumnosPolicy.new(current_usuario).verRegalo?
        render :file => "public/401.html", :status => :unauthorized
      end
      usr= Usuario.find(params[:id])
      usr.regalo = (not usr.regalo)
      usr.save
      redirect_to alumnos_index_path
  end


  private

end
