class AlumnosController < ApplicationController
  require 'ficha_alumno.rb'
    before_action :authenticate_usuario!, except: [:clasesJulio, :clasesAgendadas]
  # requires authentication only for "update" and "destroy"

  def index

      unless AlumnosPolicy.new(current_usuario).verIndex?
        render :file => "public/401.html", :status => :unauthorized
      end
#      @alumnos = Usuario.where(debaja: [false,  nil]).all

      @q = Usuario.where(debaja: [false, nil]).ransack(params[:q])
      @alumnos = @q.result(distinct: true)
      @clases = ClaseAlumno.where(diaHora: Date.today.beginning_of_day..)
      @estados = ClaseAlumnoEstado.all

      @fechaInicio = Date.today.beginning_of_month
      @fechaHoy = Date.today.next_month
  end

  def clientes
      unless AlumnosPolicy.new(current_usuario).verClientes?
        render :file => "public/401.html", :status => :unauthorized
      end
      @alumnos = Cliente.all
  end

  def enhorario
      unless AlumnosPolicy.new(current_usuario).verClientes?
        render :file => "public/401.html", :status => :unauthorized
      end
      @alumnos = Usuario.where(id: HorarioAlumno.select(:usuario_id).distinct.pluck(:usuario_id))
  end


  def pdfAlumnos
    unless ComunPolicy.new(current_usuario).verFacturacion?
      render :file => "public/401.html", :status => :unauthorized
    end


    #alumnos = Usuario.where(debaja: [false,  nil]).all

    alumnos = Usuario.where(id: HorarioAlumno.select(:usuario_id).distinct.pluck(:usuario_id))
    headers=['Nombre', 'Teléfono']
    datos = []

    alumnos.each do |alm|
      linea = []
      linea << alm.nombre
      linea << alm.telefono
      datos << linea
    end

    file_data = SpreadsheetArchitect.to_ods(headers: headers, data: datos)
    ficNombre = 'Alumnos_' + I18n.l(DateTime.now, format: "%Y%m%d").to_s + '.ods'
    send_data file_data, filename: ficNombre, type: 'application/ods', diposition: 'inline'
  end

  def actualizar
      #---------------------------------------------------------------------------
      #Actualiza los datos en la tabla de usuario que provienen de la facturación
      #---------------------------------------------------------------------------
      unless AlumnosPolicy.new(current_usuario).verActualizar?
        render :file => "public/401.html", :status => :unauthorized
      end

      #Buscamos el cliente que queremos actualizar
      @cliente = Cliente.find(params[:id])
      cli = @cliente
      alerta = ""

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
                alerta = alerta.to_s + msg.to_s
            end
        else
            puts "sin error"
            alerta = "Alumno actualizado correctamente"
            usr.errors.full_messages
        end
      end # if usuario.exists?
      redirect_to alumnos_clientes_path, alert: alerta + "Alumno actualizado "
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

  def clasesAgendadas
      @fechaInicio = params[:fechaInicio].to_datetime
      @fechaFin = params[:fechaFin].to_datetime
      @id = params[:id].to_i

      @clsDelAlumno = ClaseAlumno.where(usuario_id: @id).where(diaHora: @fechaInicio.at_beginning_of_month..@fechaFin.at_end_of_month).order(:diaHora)
      @estados = ClaseAlumnoEstado.all

      # Conseguimos un array con un elemento por cada mes que vamos a presentar.
      # cada elemento del arrayMeses contiene un array con las semanas de ese mes.
      # cada elemento arraySemana es un día del mes.

      @fechaInicioCalendario = @clsDelAlumno.first.diaHora.beginning_of_month.to_date
      @fechaFinCalendario = @clsDelAlumno.last.diaHora.end_of_month.to_date

      # Calculamos los meses que tenemos que presentar.
      @arrayMeses = (@fechaInicioCalendario...@fechaFinCalendario).map{|d| d.beginning_of_month }.uniq

      # Recalculamos la fecha de inicio para que sea el mes entero
      @fechaInicioCalendario = @fechaInicioCalendario.beginning_of_month.beginning_of_week
      @fechaFinCalendario =  @fechaFinCalendario.end_of_week

      # Cargamos un array con las semanas de cada meses
      @arrayMeses.each do |mm|


      end
      arraySemana = []
  end

  def clasesJulioURL
      @clsDelAlumno = ClaseAlumno.where(diaHora: DateTime.now.at_beginning_of_month..DateTime.now.next_year.at_end_of_month).pluck(:usuario_id)
      @usuariosEnJulio = Usuario.where(id: @clsDelAlumno).order(:nombre)
      @usrSerieA = Usuario.where(serie: 'A')
      @usrSerieB = Usuario.where(serie: 'B')
  end

  def clasesJulio
      @id = params[:id]
      @clsDelAlumno = ClaseAlumno.where(usuario_id: @id).where(diaHora: DateTime.now.at_beginning_of_month..DateTime.now.next_year.at_end_of_month)
      @estados = ClaseAlumnoEstado.all
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

      @clsDelAlumno = ClaseAlumno.where(usuario_id: @id).where(diaHora: DateTime.now.next_month.at_beginning_of_month..DateTime.now.next_month. at_end_of_month).order(:diaHora)

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
      redirect_to alumnos_enhorario_path
  end

  def navidad
      unless AlumnosPolicy.new(current_usuario).verRegalo?
        render :file => "public/401.html", :status => :unauthorized
      end
      usr= Usuario.find(params[:id])
      usr.navidad = (not usr.navidad)
      usr.save
      redirect_to alumnos_enhorario_path
  end

  protected

  def configure_permitted_parameters
    params.permit(fechaFin, fechaInicio, id, q)
  end

  private

end
