class AlumnosController < ApplicationController
  require 'ficha_alumno.rb'
    before_action :authenticate_usuario!, except: [:clasesJulio, :clasesAgendadas]
    before_action :verificar_administrador, only: [:nueva_alta, :crear_alta, :editar, :actualizar]
    before_action :set_usuario, only: [:editar, :actualizar]

  # requires authentication only for "update" and "destroy"

  def index
      unless AlumnosPolicy.new(current_usuario).verIndex?
        render :file => "public/401.html", :status => :unauthorized
      end

      @q = Usuario.alumno.ransack(params[:q])
      @highlight_alumno_id = params[:highlight_alumno]
      @alumnos = @q.result(distinct: true)
      #
      # FILTRO ADICIONAL: SI QUIERES MANTENER SOLO ACTIVOS POR DEFECTO:
      # Si NO se ha seleccionado ningún filtro de estado, mostrar solo activos por defecto
      #if params[:q].nil? || params[:q][:debaja_eq].blank?
      #  @alumnos = @alumnos.where(debaja: false)
      #end

  
      @clases = ClaseAlumno.futuras
      @fechaInicio = Date.today.beginning_of_month
      @fechaHoy = Date.today.next_month

      alumnos_con_relaciones = @alumnos.includes(
        horarioAlumno: { horario: :aula },
        recibos: []
      )

      # Prepara el texto de WhatsApp para cada alumno
      @whatsapp_texts = {}
      alumnos_con_relaciones.each do |alumno|
        @whatsapp_texts[alumno.id] = generate_whatsapp_text(alumno)
      end

      # Pre-cargar los horarios de los alumnos para evitar el problema N+1
      @horarios_por_alumno = {}
      @alumnos.includes(horarioAlumno: :horario).each do |alumno|
            @horarios_por_alumno[alumno.id] = alumno.horarioAlumno.map do |ha|
          {
            horario: ha.horario,
            dia_semana: ha.horario.diaSemana,
            hora: ha.horario.hora,
            minuto: ha.horario.minuto,
            aula: ha.horario.aula
          }
        end
      end

      # Pre-cargar los últimos 12 recibos de los alumnos ordenados por fecha (más reciente primero)
      @recibos_por_alumno = {}
      alumnos_con_relaciones.each do |alumno|
        @recibos_por_alumno[alumno.id] = alumno.recibos
                                  .where.not(vencimiento: nil)  # ← Excluye nulos
                                  .order(vencimiento: :desc)    # ← Mejor que sort_by
                                  .limit(12)
      end
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


# app/controllers/alumnos_controller.rb

  def pdfAlumnos
    unless ComunPolicy.new(current_usuario).verFacturacion?
      render file: "public/401.html", status: :unauthorized
      return
    end

    # Obtener parámetros o usar valores por defecto
    alumno_id = params[:id] || current_usuario.id
    fecha_inicio = params[:fechaInicio] ? params[:fechaInicio].to_datetime : 1.month.ago
    fecha_fin = params[:fechaFin] ? params[:fechaFin].to_datetime : DateTime.now

    @alumno = Usuario.find(alumno_id)

    # Obtener datos para el informe
    @clases_alumno = ClaseAlumno
      .includes(:clase, :claseAlumnoEstado, clase: [:instructor])
      .where(usuario_id: @alumno.id)
      .where(diaHora: fecha_inicio..fecha_fin)
      .order(:diaHora)

    # Calcular estadísticas usando los métodos existentes
    @distribucion_estados = calcular_distribucion_estados(@clases_alumno)
    @horarios_frecuentes = calcular_horarios_frecuentes(@clases_alumno)
    @porcentaje_instructores = calcular_porcentaje_asistencia_por_instructor
    @racha_actual = calcular_racha_actual(@alumno.id)
    @total_asistencias = @clases_alumno.where(claseAlumnoEstado_id: [1, 2]).count
    @total_avisos = @clases_alumno.where(claseAlumnoEstado_id: 3).count
    @total_faltas = @clases_alumno.where(claseAlumnoEstado_id: 4).count

    # Generar PDF con Prawn
    pdf = AlumnoAsistenciaPdf.new(
      @alumno, 
      fecha_inicio, 
      fecha_fin, 
      @distribucion_estados, 
      @horarios_frecuentes, 
      @porcentaje_instructores,
      @racha_actual,
      @total_asistencias,
      @total_avisos,
      @total_faltas,
      @clases_alumno
    )

    ficNombre = "Informe_Asistencia_#{@alumno.nombre.parameterize}_#{Date.today.strftime('%Y%m%d')}.pdf"
    
    send_data pdf.render, filename: ficNombre, type: 'application/pdf', disposition: 'inline'
  end


  def sincronizar_facturacion
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
      redirect_to clientes_alumnos_path, alert: alerta + "Alumno actualizado "
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


  def clases_agendadas_pdf
  # Duplicamos la lógica de clasesAgendadas para asegurar que todas las variables estén disponibles
  @fechaInicio = params[:fechaInicio].to_datetime
  @fechaFin = params[:fechaFin].to_datetime
  @id = params[:id].to_i

  @clsDelAlumno = ClaseAlumno
    .includes(:clase, :claseAlumnoEstado, clase: [:instructor, :aula])
    .where(usuario_id: @id)
    .where(diaHora: @fechaInicio..@fechaFin)
    .order(:diaHora)

  @estados = ClaseAlumnoEstado.all
  @instructores_data = calcular_porcentaje_asistencia_por_instructor
  @evolucion_tendencia = calcular_evolucion_tendencia_semanal(@clsDelAlumno, @fechaInicio, @fechaFin)
  @distribucion_estados = calcular_distribucion_estados(@clsDelAlumno)
  @horarios_frecuentes = calcular_horarios_frecuentes(@clsDelAlumno)
  @racha_actual = calcular_racha_actual(@id)
  @evolucion_mensual = calcular_evolucion_mensual(@id, @fechaInicio, @fechaFin)
  @start_month = @fechaInicio.beginning_of_month
  @end_month = @fechaFin.end_of_month

  @meses = []
  current_month = @start_month
  while current_month <= @end_month
    @meses << current_month
    current_month = current_month.next_month
  end

  @clases_por_dia = {}
  @clsDelAlumno.each do |clase_alumno|
    fecha = clase_alumno.diaHora.to_date
    @clases_por_dia[fecha] ||= []
    @clases_por_dia[fecha] << clase_alumno.claseAlumnoEstado
  end

  # Obtener el usuario correctamente
  usuario = Usuario.find(@id)

  respond_to do |format|
    format.pdf do
      pdf = AlumnoAsistenciaPdf.new(
        usuario: usuario,  # Pasar el usuario encontrado, no desde @clsDelAlumno
        fecha_inicio: @fechaInicio,
        fecha_fin: @fechaFin,
        distribucion_estados: @distribucion_estados,
        horarios_frecuentes: @horarios_frecuentes,
        instructores_data: @instructores_data,
        racha_actual: @racha_actual,
        clases_alumno: @clsDelAlumno
      )

      filename = "reporte_asistencia_#{usuario.nombre.parameterize}_#{Time.now.strftime('%Y%m%d')}.pdf"

      send_data pdf.render,
                filename: filename,
                type: 'application/pdf',
                disposition: 'inline'
    end
  end
end

    def clasesAgendadas
      @fechaInicio = params[:fechaInicio] ? params[:fechaInicio].to_datetime : Date.today.beginning_of_month.to_datetime
      @fechaFin = params[:fechaFin] ? params[:fechaFin].to_datetime : Date.today.end_of_month.to_datetime

      @id = params[:id].to_i

      # Optimizamos las consultas
      @clsDelAlumno = ClaseAlumno
        .includes(:clase, :claseAlumnoEstado, clase: [:instructor, :aula])
        .where(usuario_id: @id)
        .where(diaHora: @fechaInicio..@fechaFin)
        .order(:diaHora)

      @estados = ClaseAlumnoEstado.all

      # Corregimos el método para el gráfico
      @instructores_data = calcular_porcentaje_asistencia_por_instructor

        # 1. Datos para el gráfico de Compromiso Semanal (Asistencia vs Expectativa)
  @evolucion_tendencia = calcular_evolucion_tendencia_semanal(@clsDelAlumno, @fechaInicio, @fechaFin)

  # 2. Datos para el gráfico de Distribución de Estados
  @distribucion_estados = calcular_distribucion_estados(@clsDelAlumno)

  # 3. Datos para el gráfico de Horarios Más Frecuentados
  @horarios_frecuentes = calcular_horarios_frecuentes(@clsDelAlumno)

  # 4. Datos para la Racha Actual
  @racha_actual = calcular_racha_actual(@id)

  # 5. Datos para la Evolución Mensual (si el rango de fechas abarca varios meses)
  @evolucion_mensual = calcular_evolucion_mensual(@id, @fechaInicio, @fechaFin)


      # Preparar los meses a mostrar (desde inicio de mes de fechaInicio hasta fin de mes de fechaFin)
      @start_month = @fechaInicio.beginning_of_month
      @end_month = @fechaFin.end_of_month
      
      # Generar array con todos los meses en el rango
      @meses = []
      current_month = @start_month
      while current_month <= @end_month
        @meses << current_month
        current_month = current_month.next_month
      end

      # Preparar datos para cada mes: { fecha => [estados] }
      @clases_por_dia = {}
      @clsDelAlumno.each do |clase_alumno|
        fecha = clase_alumno.diaHora.to_date
        @clases_por_dia[fecha] ||= []
        @clases_por_dia[fecha] << clase_alumno.claseAlumnoEstado
      end
    end


  def clasesAgendadasAntiguo 
      @fechaInicio = params[:fechaInicio].to_datetime - 1.month
      @fechaFin = params[:fechaFin].to_datetime
      @id = params[:id].to_i

      @clsDelAlumno = ClaseAlumno.where(usuario_id: @id).where(diaHora: @fechaInicio.at_beginning_of_month..@fechaFin.at_end_of_month).order(:diaHora)
      @estados = ClaseAlumnoEstado.all

      # Preparar datos para el gráfico de torta
      @instructores_data = preparar_datos_torta
    
      # 1. Datos para el gráfico de Compromiso Semanal (Asistencia vs Expectativa)
  @compromiso_semanal = calcular_compromiso_semanal(@clsDelAlumno, @fechaInicio, @fechaFin)

  # 2. Datos para el gráfico de Distribución de Estados
  @distribucion_estados = calcular_distribucion_estados(@clsDelAlumno)

  # 3. Datos para el gráfico de Horarios Más Frecuentados
  @horarios_frecuentes = calcular_horarios_frecuentes(@clsDelAlumno)

  # 4. Datos para la Racha Actual
  @racha_actual = calcular_racha_actual(@id)

  # 5. Datos para la Evolución Mensual (si el rango de fechas abarca varios meses)
  @evolucion_mensual = calcular_evolucion_mensual(@id, @fechaInicio, @fechaFin)


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
      #@clsDelAlumno = ClaseAlumno.where(diaHora: DateTime.now.at_beginning_of_month..DateTime.now.next_year.at_end_of_month).pluck(:usuario_id)
    @clsDelAlumno = ClaseAlumno.where(diaHora: '01-07-2024'.to_datetime.at_beginning_of_month..DateTime.now.next_year.at_end_of_month).pluck(:usuario_id)
      @usuariosEnJulio = Usuario.where(id: @clsDelAlumno).order(:nombre)
      @usrSerieA = Usuario.where(serie: 'A')
      @usrSerieB = Usuario.where(serie: 'B')
  end

  def clasesJulio
      @id = params[:id]
      #@clsDelAlumno = ClaseAlumno.where(usuario_id: @id).where(diaHora: DateTime.now.at_beginning_of_month..DateTime.now.next_year.at_end_of_month)
      @clsDelAlumno = ClaseAlumno.where(usuario_id: @id).where(diaHora: DateTime.current.to_date.at_beginning_of_month..DateTime.now.next_year.at_end_of_month)
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

  usr = Usuario.find(params[:id])
  usr.regalo = !usr.regalo
  usr.save

  respond_to do |format|
    format.html do
      # Para requests normales (sin AJAX)
      redirect_to alumnos_path, notice: "Regalo #{usr.regalo ? 'marcado como enviado' : 'marcado como pendiente'}"
    end
    format.json do
      # Para requests AJAX
      render json: {
        success: true,
        regalo: usr.regalo,
        message: "Regalo #{usr.regalo ? 'marcado como enviado' : 'marcado como pendiente'}"
      }
    end
  end
end

  def navidad
      unless AlumnosPolicy.new(current_usuario).verRegalo?
        render :file => "public/401.html", :status => :unauthorized
      end
      @usuario = Usuario.find(params[:id])
      
      # Cambiar el estado de navidad
        @usuario = Usuario.find(params[:id])
      @usuario.update(navidad: !@usuario.navidad)

      fecha = params[:fecha] || Date.today.to_s

      # Si es una petición AJAX (remote: true)
      respond_to do |format|
        format.html do
          # Redirigir manteniendo el anchor
          anchor = params[:anchor] || ""
          redirect_to clase_dia_path(fecha: fecha, anchor: anchor),
                      notice: "Navidad #{@usuario.navidad ? 'activada' : 'desactivada'} para #{@usuario.nombre}"
        end

        format.js do
          # Para peticiones AJAX
          @clase_id = params[:anchor].to_s.gsub('clase-', '').to_i if params[:anchor]
          @fecha = fecha
          @usuario_id = @usuario.id
        end
      end
  end


  def generar_clave
    @alumno = Usuario.find(params[:id])

    unless AlumnosPolicy.new(current_usuario).puede_editar?(@alumno)
      render json: { error: "No autorizado" }, status: :unauthorized
      return
    end

    nueva_clave = @alumno.establecer_clave_temporal

    if @alumno.save
      # Prepara el mensaje de WhatsApp
      mensaje_whatsapp = generar_mensaje_bienvenida(@alumno, nueva_clave)

      render json: {
        success: true,
        clave: nueva_clave,
        mensaje_whatsapp: mensaje_whatsapp,
        telefono: @alumno.movil
      }
    else
      render json: { error: "Error al generar la clave" }, status: :unprocessable_entity
    end
  end
  def nueva_alta
    @usuario = Usuario.new
    cargar_datos_formulario
  end

  def crear_alta
    @usuario = Usuario.new(usuario_alta_params)
    configurar_usuario_nuevo(@usuario)

    if @usuario.save
      enviar_bienvenida(@usuario)
      redirect_to alumnos_path, notice: "Alumno #{@usuario.nombre} creado exitosamente. Se ha enviado un email de bienvenida."
    else
      # En lugar de render, redirigir con flash alert
      flash[:alert] = "Errores al crear el alumno: #{@usuario.errors.full_messages.join(', ')}"
      cargar_datos_formulario
      redirect_to nueva_alta_alumnos_path, alert: "Errores: #{@usuario.errors.full_messages.join(', ')}"
      # O si prefieres redirigir:
      # redirect_to nueva_alta_alumnos_path, alert: "Errores al crear el alumno: #{@usuario.errors.full_messages.join(', ')}"
    end
  end

  def editar
    cargar_datos_formulario
  end

  def actualizar
  if @usuario.update(usuario_edicion_params)
    # Redirigir al index con filtro Ransack por nombre
    redirect_to alumnos_path(q: { nombre_cont: @usuario.nombre }),
                notice: "Alumno #{@usuario.nombre} actualizado correctamente"
  else
    flash[:alert] = "Errores al actualizar: #{@usuario.errors.full_messages.join(', ')}"
    cargar_datos_formulario
    render :editar
  end
end

def calcular_bic
  iban = params[:iban]
  
  # Validación básica
  unless iban.present? && iban.start_with?('ES') && iban.gsub(/\s+/, '').length == 24
    render json: { error: 'IBAN español no válido' }, status: :unprocessable_entity
    return
  end
  
  # Solo podemos calcular BIC manualmente
  bic_calculado = calcular_bic_manual(iban)
  
  if bic_calculado
    render json: { bic: bic_calculado }
  else
    render json: { error: 'No se pudo calcular el BIC para este banco' }, status: :unprocessable_entity
  end
end




  private

  def generar_mensaje_bienvenida(alumno, clave)
    nombre = alumno.alias.presence || alumno.nombre.split.first
    usuario = alumno.email # o el campo que uses como usuario

    <<~MENSAJE
      ¡Hola #{nombre}! 👋

      ¡Bienvenido a AgâraYoga! 🌸 Nos alegra mucho que te unas a nuestra familia.

      Aquí tienes tus claves para acceder a la web y gestionar tus clases:

      🔗 Web: https://familia.agarayoga.eu
      👤 Usuario: #{usuario}
      🔒 Clave: #{clave}

      Si tienes algún problema, avísanos. ¡Estamos aquí para ayudarte!
    MENSAJE
  end


  def verificar_administrador
    unless current_usuario.admin? || current_usuario.michon?
      render file: "public/401.html", status: :unauthorized
    end
  end

  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  def cargar_datos_formulario
    @grupos_alumno = GrupoAlumno.all
    @instructores = Instructor.all
  end

  def configurar_usuario_nuevo(usuario)
    usuario.rol = :yogui
    usuario.debaja = false
    usuario.regalo = false
    usuario.navidad = false
    usuario.admin = false
    
    # Generar contraseña temporal
    clave_temporal = usuario.generar_clave_facil
    usuario.password = clave_temporal
    usuario.password_confirmation = clave_temporal
  end

  def enviar_bienvenida(usuario)
    # Usar tu mailer existente o crear uno nuevo
    if defined?(UsuarioMailer)
      clave_temporal = usuario.generar_clave_facil
      UsuarioMailer.bienvenida(usuario, clave_temporal).deliver_later
    end
  end

  # Params para altas (todos los campos)
  def usuario_alta_params
    params.require(:usuario).permit(
      :nombre, :email, :dni, :telefono, :movil, :direccion, 
      :pais, :localidad, :provincia, :iban, :lugarfirma, 
      :fechafirma, :codigofacturacion, :cp, :grupoAlumno_id, 
      :instructor_id, :bic, :serie, :remesa, :fechaCaducidad, 
      :referencia, :tipo, :alias, :debaja
    )
  end

  # Params para edición (excluir campos sensibles como rol, debaja, etc.)
  def usuario_edicion_params
    params.require(:usuario).permit(
      :nombre, :email, :dni, :telefono, :movil, :direccion, 
      :pais, :localidad, :provincia, :iban, :lugarfirma, 
      :fechafirma, :codigofacturacion, :cp, :grupoAlumno_id, 
      :instructor_id, :bic, :serie, :remesa, :fechaCaducidad, 
      :referencia, :tipo, :alias, :debaja
    )
  end


  protected

  def configure_permitted_parameters
    params.permit(fechaFin, fechaInicio, id, q)
  end



  def calcular_evolucion_tendencia_semanal(clases_alumno, fecha_inicio, fecha_fin)
  return [] if clases_alumno.blank?

  # 1. Obtener asistencias por semana
  asistencias_por_semana = Hash.new(0)

  clases_alumno.joins(:claseAlumnoEstado)
               .where(clase_alumno_estados: {nombre: 'Asistió'})
               .each do |ca|
    semana_num = ca.diaHora.to_date.cweek
    año = ca.diaHora.to_date.cwyear
    clave_semana = "#{año}-#{semana_num}" # Para evitar conflictos entre años
    asistencias_por_semana[clave_semana] += 1
  end

  # 2. Crear array ordenado con todas las semanas en el rango
  semanas_con_datos = []
  fecha_actual = fecha_inicio.to_date
  fecha_fin_date = fecha_fin.to_date

  while fecha_actual <= fecha_fin_date
    semana_num = fecha_actual.cweek
    año = fecha_actual.cwyear
    clave_semana = "#{año}-#{semana_num}"

    semanas_con_datos << {
      semana_key: clave_semana,
      semana_num: semana_num,
      año: año,
      fecha_inicio: fecha_actual.beginning_of_week,
      asistencias: asistencias_por_semana[clave_semana] || 0,
      # La semana se muestra como "Sem 23 (2 Jun)"
      label: "Sem #{semana_num} (#{fecha_actual.beginning_of_week.strftime('%d %b')})"
    }

    fecha_actual += 7.days # Avanzar a la siguiente semana
  end

  # 3. Calcular media móvil (tendencia)
  calcular_media_movil(semanas_con_datos)
end

def calcular_media_movil(semanas, ventana = 3)
  semanas.each_with_index do |semana, index|
    inicio = [0, index - ventana + 1].max
    fin = index
    semanas_ventana = semanas[inicio..fin]

    total = semanas_ventana.sum { |s| s[:asistencias] }
    semana[:media_movil] = (total.to_f / semanas_ventana.size).round(2)
  end

  semanas
end


def calcular_distribucion_estados(clases_alumno)
  distribucion = Hash.new(0)
  clases_alumno.each do |ca|
    unless ca.claseAlumnoEstado_id == 1 
    estado = ca.claseAlumnoEstado.nombre
    distribucion[estado] += 1
    end
  end
  distribucion
end

def calcular_horarios_frecuentes(clases_alumno)
  return [] if clases_alumno.blank?

  horarios_count = Hash.new(0)

  # CORREGIDO: Filtrar por estado "Asistió" usando joins
  clases_alumno.joins(:claseAlumnoEstado)
               .where(clase_alumno_estados: {nombre: 'Asistió'}) # ← Cambiado
               .each do |ca|
    key = "#{ca.clase.instructor.nombre} - #{ca.diaHora.strftime('%A %H:%M')}"
    horarios_count[key] += 1
  end

  horarios_count.sort_by { |_, count| -count }.first(5)
end

def calcular_racha_actual(alumno_id)
  # Encontrar la última asistencia - CORREGIDO
  ultima_asistencia = ClaseAlumno.joins(:claseAlumnoEstado)
                                .where(
                                  usuario_id: alumno_id,
                                  clase_alumno_estados: {nombre: 'Asistió'} # ← Cambiado
                                )
                                .maximum(:diaHora)

  return 0 unless ultima_asistencia

  # Calcular días desde la última asistencia
  (Date.today - ultima_asistencia.to_date).to_i
end

def calcular_evolucion_mensual(alumno_id, fecha_inicio, fecha_fin)
  # Agrupar asistencia por mes - CORREGIDO
  evolucion = {}
  
  current_month = fecha_inicio.beginning_of_month
  while current_month <= fecha_fin
    mes_key = current_month.strftime('%Y-%m')
    
    # Asistencias
    asistencia_mes = ClaseAlumno.joins(:claseAlumnoEstado)
                               .where(
                                 usuario_id: alumno_id,
                                 diaHora: current_month..current_month.end_of_month,
                                 clase_alumno_estados: {nombre: 'Asistió'} # ← Cambiado
                               ).count
    
    # Total de clases
    total_mes = ClaseAlumno.where(
      usuario_id: alumno_id,
      diaHora: current_month..current_month.end_of_month
    ).count
    
    porcentaje = total_mes > 0 ? (asistencia_mes.to_f / total_mes * 100).round(2) : 0
    
    evolucion[mes_key] = porcentaje
    current_month = current_month.next_month
  end
  
  evolucion
end



  def calcular_porcentaje_asistencia_por_instructor
  return [] if @clsDelAlumno.empty?

  datos_instructores = {}

  @clsDelAlumno.each do |clase_alumno|
    instructor_nombre = clase_alumno.clase.instructor.nombre
    datos_instructores[instructor_nombre] ||= { total: 0, asistencias: 0, faltas: 0, avisos: 0 }

    datos_instructores[instructor_nombre][:total] += 1

    case clase_alumno.claseAlumnoEstado_id
    when 1, 2 # viene (1), asistio (2)
      datos_instructores[instructor_nombre][:asistencias] += 1
    when 3 # aviso (3)
      datos_instructores[instructor_nombre][:avisos] += 1
    when 4 # falto (4)
      datos_instructores[instructor_nombre][:faltas] += 1
    end
  end

  # Calcular porcentajes para el gráfico
  datos_instructores.map do |instructor, datos|
    porcentaje_asistencia = datos[:total] > 0 ? (datos[:asistencias].to_f / datos[:total] * 100).round(1) : 0

    {
      name: instructor,
      value: datos[:total], # ← CAMBIO IMPORTANTE: usar total de clases, no porcentaje
      total_clases: datos[:total],
      asistencias: datos[:asistencias],
      faltas: datos[:faltas],
      avisos: datos[:avisos],
      porcentaje: porcentaje_asistencia, # ← mantener porcentaje para el tooltip
      label: "#{instructor} (#{porcentaje_asistencia}%)"
    }
  end.sort_by { |data| -data[:porcentaje] }
end

    def map_bootstrap_color(bootstrap_color)
      color_map = {
        'primary' => '#007bff',
        'secondary' => '#6c757d',
        'success' => '#28a745',
        'danger' => '#dc3545',
        'warning' => '#ffc107',
        'info' => '#17a2b8',
        'light' => '#f8f9fa',
        'dark' => '#343a40',
        'blue' => '#007bff',
        'indigo' => '#6610f2',
        'purple' => '#6f42c1',
        'pink' => '#e83e8c',
        'red' => '#dc3545',
        'orange' => '#fd7e14',
        'yellow' => '#ffc107',
        'green' => '#28a745',
        'teal' => '#20c997',
        'cyan' => '#17a2b8'
      }
      color_map[bootstrap_color] || '#cccccc'
    end

  def generate_whatsapp_text(alumno)
    clases_activas = @clases.where(usuario_id: alumno.id, claseAlumnoEstado_id: 1)
                           .where("diaHora >= ?", Date.today)
                           .order(:diaHora)

    # Usamos solo emojis básicos compatibles
    text = "¡Hola #{alumno.alias.presence || alumno.nombre.split.first}!"
    text = text + "👋 \n"
    text = text + "\n"
    text = text + "*TUS PRÓXIMAS CLASES*\n\n" 

    clases_activas.each do |cl|
      text = text + "📅 *#{I18n.l(cl.diaHora, format: '%A %d/%m')}*\n"
      text = text + "⏰ *" + "#{cl.diaHora.strftime('%H:%M')} con #{cl.clase.instructor.nombre.split.first}*\n"
      text = text + "➖➖➖➖➖➖➖➖➖➖" + "\n\n"
    end

    text = text + "Gracias por llegar puntual para mantener la armonía del grupo\n\n"

    text = text + "¡Nos vemos en clase!"

    text
  end

  def calcular_bic_manual(iban)
  codigo_banco = iban.gsub(/\s+/, '')[4..7]

  # Mapeo extendido de códigos de banco españoles a BICs
  bic_map = {
    '0001' => 'BOFAGESM',    # Banco de España
    '0030' => 'ESPBESMM',    # Banesto
    '0049' => 'BSCHESMM',    # Santander
    '0061' => 'CGGKESMM',    # Caja General Granada
    '0073' => 'OPENESMM',    # Openbank
    '0075' => 'POPLESMM',    # Banco Popular
    '0081' => 'BSABESBB',    # Banco Sabadell
    '0128' => 'BKBKESMM',    # Bankinter
    '0138' => 'BESMESMM',    # Banco Espíritu Santo
    '0149' => 'DEUTESBB',    # Deutsche Bank
    '0152' => 'GEBAESMM',    # Banco GE Money
    '0162' => 'BVALESMM',    # Banco Valencia
    '0182' => 'BBVAESMM',    # BBVA
    '0186' => 'CCOCESMM',    # Caja España
    '0198' => 'ALCLESMM',    # Banco Alcalá
    '0216' => 'BCOEESMM',    # Banco Etcheverría
    '0229' => 'EVOBESMM',    # Banco EVO
    '0232' => 'BCOEESMM',    # Banco Gallego
    '0239' => 'BCOEESMM',    # Banco Pastor
    '0240' => 'BCOEESMM',    # Banco de Crédito Balear
    '0285' => 'BCOEESMM',    # Banco Urquijo
    '1465' => 'INGDESMM',    # ING Direct
    '2038' => 'CAGRESMM',    # Caja Granada
    '2048' => 'CECAESMM',    # CECA
    '2056' => 'CCRIES2A',    # Caja Rural
    '2080' => 'CAIXESBB',    # CaixaBank
    '2085' => 'BCOEESMM',    # Banco Popular
    '2095' => 'BASKES2B',    # Kutxabank
    '2100' => 'CBCLESMM',    # CaixaBank
    '2103' => 'UCJAESM1',    # Caja Rural Jaén
    '2108' => 'BCOEESMM',    # Caja Rural Málaga
    '2110' => 'CASDESBB',    # Caja de Ahorros del Mediterráneo
    '3005' => 'CCRIES2A',    # Caja Rural Intermediterránea
    '3016' => 'CCRIES2A',    # Caja Rural Ntra. Sra. del Socorro
    '3023' => 'CDENESBB',    # Caixa d'Estalvis de Denia
    '3025' => 'CCRIES2A',    # Caja Rural Central
    '3058' => 'CCRIES2A',    # Caja Rural de Almería
    '3063' => 'BCOEESMM',    # Caja de Arquitectos
    '3070' => 'BCOEESMMXXX', # Caja de Ingenieros
    '3080' => 'CCRIES2A',    # Caja Rural de Granada
    '3085' => 'CCRIES2A',    # Caja Rural de Jaén
    '3091' => 'CCRIES2A',    # Caja Rural de Málaga
    '3095' => 'CCRIES2A',    # Caja Rural de Navarra
    '3100' => 'CCRIES2A',    # Caja Rural de Asturias
    '3108' => 'CCRIES2A',    # Caja Rural de Extremadura
    '3110' => 'CCRIES2A',    # Caja Rural de Salamanca
    '3116' => 'CCRIES2A',    # Caja Rural de Soria
    '3118' => 'CCRIES2A',    # Caja Rural de Teruel
    '3120' => 'CCRIES2A',    # Caja Rural de Toledo
    '3123' => 'CCRIES2A',    # Caja Rural de Valladolid
    '3125' => 'CCRIES2A',    # Caja Rural de Zamora
    '3127' => 'CCRIES2A',    # Caja Rural de Aragón
    '3130' => 'CCRIES2A',    # Caja Rural de Albacete
    '3135' => 'CCRIES2A',    # Caja Rural de Guadalajara
    '3138' => 'CCRIES2A',    # Caja Rural de La Rioja
    '3140' => 'CCRIES2A',    # Caja Rural de Segovia
    '3143' => 'CCRIES2A',    # Caja Rural de Cuenca
    '3146' => 'CCRIES2A',    # Caja Rural de Burgos
    '3149' => 'CCRIES2A',    # Caja Rural de Palencia
    '3150' => 'CCRIES2A',    # Caja Rural de León
    '3154' => 'CCRIES2A',    # Caja Rural del Sur
    '3159' => 'CCRIES2A',    # Caja Rural de Casas Blancas
    '3160' => 'CCRIES2A',    # Caja Rural de Canarias
    '3161' => 'CCRIES2A',    # Caja Rural de Tenerife
    '3165' => 'CCRIES2A',    # Caja Rural de Córdoba
    '3167' => 'CCRIES2A',    # Caja Rural de Huelva
    '3169' => 'CCRIES2A',    # Caja Rural de Sevilla
    '3175' => 'CCRIES2A',    # Caja Rural de Alcalá
    '3180' => 'CCRIES2A',    # Caja Rural del Maestrazgo
    '3183' => 'CCRIES2A',    # Caja Rural de Guissona
    '3187' => 'CCRIES2A',    # Caja Rural de Navarra
    '3190' => 'CCRIES2A',    # Caja Rural de Extremadura
    '3191' => 'CCRIES2A'     # Caja Rural de Galicia
  }

  bic_map[codigo_banco]
end
end
