class WizardHorarioController < ApplicationController
  before_action :autorizar_admin
  before_action :cargar_alumno, except: [:iniciar]
  before_action :cargar_horario_actual, only: [:paso1_contexto, :paso2_seleccion, :paso3_confirmacion, :ejecutar]

  # Ruta de entrada desde distintos puntos
  def iniciar
    alumno_id = params[:alumno_id]
    horario_id = params[:horario_id] # Opcional: para preseleccionar

    # Guardar en sesión o redirigir directamente
    session[:wizard_horario] = {
      alumno_id: alumno_id,
      horario_preseleccionado: horario_id,
      origen: params[:origen] || 'desconocido'
    }

    redirect_to wizard_horario_paso1_path(alumno_id: alumno_id)
  end

  # Paso 1: Contexto del alumno
  def paso1_contexto
    # La vista mostrará información del alumno y su horario actual
  end

  # Paso 2: Selección de horarios
  def paso2_seleccion
    # Cargar todos los horarios activos
    todos_horarios = Horario.includes(:aula, :instructor, :horarioAlumno)
                           .order(:diaSemana, :hora, :minuto)

    # Separar por disponibilidad
    @horarios_disponibles = todos_horarios.select do |h|
      h.horarioAlumno.count < h.aula.aforo
    end

    @horarios_completos = todos_horarios.select do |h|
      h.horarioAlumno.count >= h.aula.aforo
    end

    # IDs de horarios que ya tiene el alumno
    @horarios_actual_ids = @horario_actual.map(&:id)
  end

  # Paso 3: Confirmación de cambios
  def paso3_confirmacion
    # DEBUG: Ver qué llega
    Rails.logger.info "=== DEBUG paso3_confirmacion ==="
    Rails.logger.info "params[:horarios_mantener]: #{params[:horarios_mantener].inspect}"
    Rails.logger.info "params[:horarios_nuevos]: #{params[:horarios_nuevos].inspect}"
    
    # Procesar selección del paso anterior
    # FIX: Manejar explícitamente cuando no hay checkboxes seleccionados
    @horarios_mantener_ids = []
    if params[:horarios_mantener]
      # Filtrar IDs válidos (mayores que 0 y no vacíos)
      @horarios_mantener_ids = Array(params[:horarios_mantener])
                             .map(&:to_i)
                             .select { |id| id > 0 }  # ← FILTRO CRÍTICO
    end
    
    @horarios_nuevos_ids = []
    if params[:horarios_nuevos]
      # Filtrar IDs válidos (mayores que 0 y no vacíos)
      @horarios_nuevos_ids = Array(params[:horarios_nuevos])
                            .map(&:to_i)
                            .select { |id| id > 0 }  # ← FILTRO CRÍTICO
    end

    # Calcular horarios a eliminar (los actuales que no se mantienen)
    @horarios_eliminar_ids = @horario_actual.map(&:id) - @horarios_mantener_ids
    
    Rails.logger.info "Horarios actual IDs: #{@horario_actual.map(&:id).inspect}"
    Rails.logger.info "Horarios a mantener IDs: #{@horarios_mantener_ids.inspect}"
    Rails.logger.info "Horarios a eliminar IDs: #{@horarios_eliminar_ids.inspect}"

    # Guardar en sesión para el paso de ejecución
    session[:wizard_horario] ||= {}
    session[:wizard_horario].merge!(
      alumno_id: @alumno.id,
      horarios_mantener: @horarios_mantener_ids,
      horarios_nuevos: @horarios_nuevos_ids,
      horarios_eliminar: @horarios_eliminar_ids
    )

    # Cargar objetos completos para mostrar
    @horarios_mantener = Horario.where(id: @horarios_mantener_ids).includes(:aula, :instructor)
    @horarios_nuevos = Horario.where(id: @horarios_nuevos_ids).includes(:aula, :instructor)
    @horarios_eliminar = Horario.where(id: @horarios_eliminar_ids).includes(:aula, :instructor)

    # Calcular impacto real en ClaseAlumno
    @impacto = calcular_impacto_real_clases_futuras
  end

  # Paso 4: Ejecutar cambios
  def ejecutar
    # DEBUG
    Rails.logger.info "=== DEBUG ejecutar ==="
    Rails.logger.info "Params recibidos: #{params.inspect}"
    Rails.logger.info "Session ID: #{session.id}"
    Rails.logger.info "Session completo: #{session.to_hash.inspect}"
    Rails.logger.info "Session[:wizard_horario]: #{session[:wizard_horario].inspect}"

    # Si venimos del paso 3 con parámetros en el body
    if params[:horarios_mantener].present? || params[:horarios_nuevos].present?
      Rails.logger.info "Procesando parámetros directos..."
      procesar_seleccion_params_directos
    end

    wizard_data = session[:wizard_horario]

    # DEBUG
    Rails.logger.info "Datos del wizard: #{wizard_data.inspect}"
    Rails.logger.info "Tipo de wizard_data: #{wizard_data.class}"
    Rails.logger.info "Claves de wizard_data: #{wizard_data.keys.inspect}"
    Rails.logger.info "Horario actual: #{@horario_actual.map(&:id).inspect}"

    # Validar que tenemos datos - VERIFICACIÓN CORREGIDA PARA STRINGS
    if wizard_data.nil?
      Rails.logger.error "❌ ERROR: wizard_data es NIL"
      flash[:alert] = "No hay datos de selección. Por favor, comienza de nuevo."
      redirect_to wizard_horario_paso1_path(alumno_id: @alumno.id)
      return
    end

    unless wizard_data.is_a?(Hash)
      Rails.logger.error "❌ ERROR: wizard_data no es un Hash: #{wizard_data.class}"
      flash[:alert] = "Datos de sesión inválidos. Por favor, comienza de nuevo."
      redirect_to wizard_horario_paso1_path(alumno_id: @alumno.id)
      return
    end

    # VERIFICAR TANTO CON SÍMBOLOS COMO CON STRINGS
    unless wizard_data.key?(:horarios_mantener) || wizard_data.key?("horarios_mantener")
      Rails.logger.error "❌ ERROR: Falta clave horarios_mantener en wizard_data"
      Rails.logger.error "Claves disponibles: #{wizard_data.keys.inspect}"
      flash[:alert] = "Datos de selección incompletos. Por favor, comienza de nuevo."
      redirect_to wizard_horario_paso1_path(alumno_id: @alumno.id)
      return
    end

    Rails.logger.info "✅ Validación pasada. Procediendo con los cambios..."

    # CONVERTIR LAS CLAVES A SÍMBOLOS PARA CONSISTENCIA
    if wizard_data.keys.any? { |k| k.is_a?(String) }
      Rails.logger.info "Convirtiendo claves de strings a símbolos..."
      wizard_data = wizard_data.transform_keys(&:to_sym)
      # Actualizar la sesión con las claves como símbolos
      session[:wizard_horario] = wizard_data
    end

    begin
      # Contadores para el resultado
      nuevas_creadas = 0
      existentes_eliminadas = 0
      email_enviado = false

      ActiveRecord::Base.transaction do
        # 1. Procesar cambios en HorarioAlumno
        aplicar_cambios_horario_alumno

        # 2. Propagación a ClaseAlumno (con contadores)
        nuevas_creadas, existentes_eliminadas = propagar_a_clase_alumno

        # 3. Enviar email si se solicitó
        if params[:enviar_email] == '1'
          enviar_email_notificacion
          email_enviado = true
        end
      end

      # Calcular total de clases futuras después del cambio
      total_clases_despues = calcular_total_clases_futuras

      # Guardar resultados en sesión para mostrar en el paso 4
      session[:wizard_horario_resultado] = {
        cambios_aplicados: {
          nuevas_creadas: nuevas_creadas,
          existentes_eliminadas: existentes_eliminadas,
          total_clases: total_clases_despues
        },
        email_enviado: email_enviado
      }

      # Éxito - redirigir a resultado
      redirect_to wizard_horario_resultado_path(alumno_id: @alumno.id)

    rescue => e
      flash[:alert] = "❌ Error al procesar cambios: #{e.message}"
      Rails.logger.error "Error en wizard horario: #{e.message}\n#{e.backtrace.join("\n")}"
      redirect_to wizard_horario_paso2_path(alumno_id: @alumno.id)
    end
  end
  # Paso 5: Resultado final
  def paso4_resultado
    # Recuperar datos de la sesión si existen
    if session[:wizard_horario_resultado]
      @cambios_aplicados = session[:wizard_horario_resultado][:cambios_aplicados]
      @email_enviado = session[:wizard_horario_resultado][:email_enviado]

      # Limpiar después de mostrar
      session[:wizard_horario_resultado] = nil
    end
  end

  private

  def autorizar_admin
    # Adaptar según tu sistema de autorización
    unless current_usuario && (current_usuario.admin? || current_usuario.michon?)
      redirect_to root_path, alert: "No autorizado. Se requiere rol de administrador."
    end
  end

  def obtener_fecha_limite_clases
    # Buscar la fecha de la última clase creada en el sistema
    ultima_clase = Clase.futuras.order(diaHora: :desc).first

    if ultima_clase
      ultima_clase.diaHora
    else
      # Si no hay clases futuras, usar 1 mes como fallback
      Time.current + 1.month
    end
  end

  def cargar_alumno
    @alumno = Usuario.find(params[:alumno_id])

    # Verificar que no esté de baja (a menos que sea reactivación)
    if @alumno.debaja?
      flash[:alert] = "El alumno está de baja. Reactívalo primero."
      redirect_to editar_alumno_path(@alumno)
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Alumno no encontrado"
    redirect_to alumnos_path
  end

  def cargar_horario_actual
    @horario_actual = @alumno.horarioAlumno.includes(:horario).map(&:horario)
    @horario_actual = [] if @horario_actual.nil?
  end

  def procesar_seleccion_params_directos
    # DEBUG
    Rails.logger.info "=== DEBUG procesar_seleccion_params_directos ==="
    Rails.logger.info "Params horarios_mantener: #{params[:horarios_mantener].inspect}"
    Rails.logger.info "Params horarios_nuevos: #{params[:horarios_nuevos].inspect}"

    # Asegurar que @horario_actual no sea nil
    @horario_actual ||= []

    # Para cuando venimos del formulario del paso 3
    @horarios_mantener_ids = []
    if params[:horarios_mantener].present? && params[:horarios_mantener] != ""
      # Filtrar IDs válidos
      @horarios_mantener_ids = params[:horarios_mantener].to_s.split(',')
                             .map(&:to_i)
                             .select { |id| id > 0 }
    end

    @horarios_nuevos_ids = []
    if params[:horarios_nuevos].present? && params[:horarios_nuevos] != ""
      # Filtrar IDs válidos
      @horarios_nuevos_ids = params[:horarios_nuevos].to_s.split(',')
                            .map(&:to_i)
                            .select { |id| id > 0 }
    end

    @horarios_eliminar_ids = @horario_actual.map(&:id) - @horarios_mantener_ids

    # Guardar en sesión
    session[:wizard_horario] = {
      alumno_id: @alumno.id,
      horarios_mantener: @horarios_mantener_ids,
      horarios_nuevos: @horarios_nuevos_ids,
      horarios_eliminar: @horarios_eliminar_ids
    }

    Rails.logger.info "Datos guardados en sesión: #{session[:wizard_horario].inspect}"
  end

  def calcular_impacto_real_clases_futuras
    fecha_actual = Time.current
    fecha_limite = obtener_fecha_limite_clases

    # 1. Clases que se crearán para nuevos horarios
    nuevas_crear = 0
    @horarios_nuevos.each do |horario|
      # Buscar clases futuras que coincidan en día/hora/instructor
      clases_coincidentes = Clase.futuras
        .where(instructor_id: horario.instructor_id)
        .where('diaHora BETWEEN ? AND ?', fecha_actual, fecha_limite)

      # Filtrar por día de la semana y hora manualmente
      clases_futuras = clases_coincidentes.select do |clase|
        clase.diaHora.wday == horario.diaSemana &&
        clase.diaHora.hour == horario.hora &&
        clase.diaHora.min == horario.minuto
      end.count

      nuevas_crear += clases_futuras
    end

    # 2. Clases que se eliminarán para horarios eliminados
    existentes_eliminar = 0
    @horarios_eliminar.each do |horario|
      # Buscar ClaseAlumno del usuario que coincidan
      clases_alumno = ClaseAlumno.joins(:clase)
        .where(usuario_id: @alumno.id)
        .where('clases.instructor_id = ?', horario.instructor_id)
        .where('clases.diaHora BETWEEN ? AND ?', fecha_actual, fecha_limite)

      # Filtrar por día/hora
      clases_a_eliminar = clases_alumno.select do |ca|
        ca.clase.diaHora.wday == horario.diaSemana &&
        ca.clase.diaHora.hour == horario.hora &&
        ca.clase.diaHora.min == horario.minuto
      end.count

      existentes_eliminar += clases_a_eliminar
    end

    # 3. Calcular TOTAL REAL de clases futuras después del cambio
    # Para los horarios que mantiene, contar sus clases futuras
    mantenidas_crear = 0
    @horarios_mantener.each do |horario|
      clases_coincidentes = Clase.futuras
        .where(instructor_id: horario.instructor_id)
        .where('diaHora BETWEEN ? AND ?', fecha_actual, fecha_limite)

      clases_futuras = clases_coincidentes.select do |clase|
        clase.diaHora.wday == horario.diaSemana &&
        clase.diaHora.hour == horario.hora &&
        clase.diaHora.min == horario.minuto
      end.count

      mantenidas_crear += clases_futuras
    end

    # Total REAL = clases mantenidas + clases nuevas
    total_clases_real = mantenidas_crear + nuevas_crear

    {
      nuevas_crear: nuevas_crear,
      existentes_eliminar: existentes_eliminar,
      total_clases_futuras: total_clases_real
    }
  end

  def aplicar_cambios_horario_alumno
    wizard_data = session[:wizard_horario]

    Rails.logger.info "=== DEBUG aplicar_cambios_horario_alumno ==="
    Rails.logger.info "wizard_data claves: #{wizard_data.keys.inspect}"
    
    # Asegurarnos de usar la clave correcta (símbolo o string)
    horarios_eliminar = wizard_data[:horarios_eliminar] || wizard_data["horarios_eliminar"]
    horarios_nuevos = wizard_data[:horarios_nuevos] || wizard_data["horarios_nuevos"]
    
    Rails.logger.info "Horarios a eliminar: #{horarios_eliminar.inspect}"
    Rails.logger.info "Horarios a añadir: #{horarios_nuevos.inspect}"

    # Eliminar horarios (array puede estar vacío - eso está bien)
    if horarios_eliminar.present?
      horarios_eliminar.each do |horario_id|
        Rails.logger.info "Eliminando horario_id: #{horario_id}"
        HorarioAlumno.where(usuario_id: @alumno.id, horario_id: horario_id).destroy_all
      end
    else
      Rails.logger.info "No hay horarios a eliminar"
    end

    # Añadir nuevos horarios (array puede estar vacío - eso está bien)
    if horarios_nuevos.present?
      horarios_nuevos.each do |horario_id|
        Rails.logger.info "Añadiendo horario_id: #{horario_id}"
        HorarioAlumno.create!(usuario_id: @alumno.id, horario_id: horario_id)
      end
    else
      Rails.logger.info "No hay horarios nuevos a añadir"
    end
  end

  def propagar_a_clase_alumno
    wizard_data = session[:wizard_horario]
    fecha_actual = Time.current
    fecha_limite = obtener_fecha_limite_clases

    nuevas_creadas = 0
    existentes_eliminadas = 0

    # Asegurarnos de usar la clave correcta (símbolo o string)
    horarios_eliminar = wizard_data[:horarios_eliminar] || wizard_data["horarios_eliminar"]
    horarios_nuevos = wizard_data[:horarios_nuevos] || wizard_data["horarios_nuevos"]

    # 1. Eliminar ClaseAlumno futuras para horarios eliminados
    if horarios_eliminar.present?
      horarios_eliminar.each do |horario_id|
        horario = Horario.find_by(id: horario_id)
        next unless horario # Si el horario no existe, continuar

        # Buscar clases futuras del usuario que coincidan
        clases_alumno_a_eliminar = ClaseAlumno.joins(:clase)
          .where(usuario_id: @alumno.id)
          .where('clases.instructor_id = ?', horario.instructor_id)
          .where('clases.diaHora BETWEEN ? AND ?', fecha_actual, fecha_limite)

        # Filtrar por día/hora
        clases_alumno_a_eliminar.each do |ca|
          if ca.clase.diaHora.wday == horario.diaSemana &&
             ca.clase.diaHora.hour == horario.hora &&
             ca.clase.diaHora.min == horario.minuto
            ca.destroy
            existentes_eliminadas += 1
          end
        end
      end
    end

    # 2. Crear ClaseAlumno futuras para nuevos horarios
    if horarios_nuevos.present?
      horarios_nuevos.each do |horario_id|
        horario = Horario.find_by(id: horario_id)
        next unless horario # Si el horario no existe, continuar

        # Buscar clases futuras que coincidan con este horario
        clases_futuras = Clase.futuras
          .where(instructor_id: horario.instructor_id)
          .where('diaHora BETWEEN ? AND ?', fecha_actual, fecha_limite)

        clases_futuras.each do |clase|
          # Verificar si coincide día/hora
          if clase.diaHora.wday == horario.diaSemana &&
             clase.diaHora.hour == horario.hora &&
             clase.diaHora.min == horario.minuto

            # Crear solo si no existe ya
            unless ClaseAlumno.exists?(clase_id: clase.id, usuario_id: @alumno.id)
              ClaseAlumno.create!(
                clase_id: clase.id,
                usuario_id: @alumno.id,
                instructor_id: horario.instructor_id,
                diaHora: clase.diaHora,
                claseAlumnoEstado_id: 1 # Estado por defecto (activa)
              )
              nuevas_creadas += 1
            end
          end
        end
      end
    end

    [nuevas_creadas, existentes_eliminadas]
  end

  # ... otros métodos existentes ...

  def calcular_total_clases_futuras
    fecha_actual = Time.current
    fecha_limite = obtener_fecha_limite_clases

    ClaseAlumno.joins(:clase)
      .where(usuario_id: @alumno.id)
      .where('clases.diaHora BETWEEN ? AND ?', fecha_actual, fecha_limite)
      .count
  end


  def enviar_email_notificacion
    # Crearemos el mailer después
    # HorarioMailer.nuevo_horario(@alumno).deliver_later
    Rails.logger.info "Email de nuevo horario enviado a: #{@alumno.email}"
  end
end
