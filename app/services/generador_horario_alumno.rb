# app/services/generador_horario_alumno.rb
class GeneradorHorarioAlumno
  def initialize(limpiar_previos = false)
    @limpiar_previos = limpiar_previos
    @conflictos = []
    @asignaciones = 0
  end

  def generar_desde_preinscripciones
    limpiar_asignaciones_previas if @limpiar_previos
    
    procesar_preinscripciones
    
    { 
      exitoso: @conflictos.empty?, 
      asignaciones: @asignaciones, 
      conflictos: @conflictos,
      total_preinscripciones: Preinscripcion.activas.count
    }
  end

  private

  def limpiar_asignaciones_previas
    puts "Eliminando asignaciones previas de HorarioAlumno..."
    count = HorarioAlumno.count
    HorarioAlumno.delete_all
    puts "Eliminadas #{count} asignaciones previas"
  end

  def procesar_preinscripciones
    puts "Procesando #{Preinscripcion.activas.count} preinscripciones activas..."
    
    # Cargar preinscripciones con usuarios y horarios
    preinscripciones = Preinscripcion.activas
                                    .joins("INNER JOIN usuarios ON usuarios.id = preinscripciones.usuario_id")
                                    .joins("INNER JOIN horarios ON horarios.id = preinscripciones.horario_id")
                                    .select("preinscripciones.*, usuarios.nombre as usuario_nombre, horarios.*")
    
    # Agrupar por usuario_id manualmente
    preinscripciones_por_usuario = {}
    preinscripciones.each do |preinscripcion|
      usuario_id = preinscripcion.usuario_id
      preinscripciones_por_usuario[usuario_id] ||= []
      preinscripciones_por_usuario[usuario_id] << preinscripcion
    end
    
    puts "Encontrados #{preinscripciones_por_usuario.size} usuarios con preinscripciones"
    
    preinscripciones_por_usuario.each do |usuario_id, preinscripciones_usuario|
      usuario = Usuario.find(usuario_id)
      asignar_horario_definitivo(usuario, preinscripciones_usuario)
    end
  end

  def asignar_horario_definitivo(usuario, preinscripciones)
    # Extraer horarios de las preinscripciones
    horarios_solicitados = preinscripciones.map do |preinscripcion|
      {
        id: preinscripcion.horario_id,
        diaSemana: preinscripcion.read_attribute(:diaSemana),
        hora: preinscripcion.read_attribute(:hora),
        minuto: preinscripcion.read_attribute(:minuto)
      }
    end
    
    if horarios_solicitados.empty?
      registrar_conflicto(usuario, nil, "No hay horarios válidos")
      return
    end

    if tiene_conflictos_entre_horarios?(horarios_solicitados)
      registrar_conflicto(usuario, nil, "Conflictos entre horarios solicitados del mismo usuario")
      return
    end

    horarios_solicitados.each do |horario_data|
      horario = Horario.find(horario_data[:id])
      if puede_asignar_horario?(usuario, horario)
        crear_horario_alumno(usuario, horario)
        @asignaciones += 1
      else
        registrar_conflicto(usuario, horario, "No se pudo asignar horario (conflicto o ya asignado)")
      end
    end
  end

  def tiene_conflictos_entre_horarios?(horarios_data)
    horarios_data.combination(2).any? do |horario1, horario2|
      se_solapan_horarios?(horario1, horario2)
    end
  end

  def se_solapan_horarios?(horario1_data, horario2_data)
    return false unless horario1_data[:diaSemana] == horario2_data[:diaSemana]
    
    tiempo1 = horario1_data[:hora] * 60 + horario1_data[:minuto]
    tiempo2 = horario2_data[:hora] * 60 + horario2_data[:minuto]
    
    (tiempo1..(tiempo1 + 60)).cover?(tiempo2) || (tiempo2..(tiempo2 + 60)).cover?(tiempo1)
  end

  def puede_asignar_horario?(usuario, horario)
    # Verificar si ya tiene este horario asignado
    return false if HorarioAlumno.exists?(usuario_id: usuario.id, horario_id: horario.id)
    
    # Verificar conflictos con otros horarios asignados
    horarios_asignados_ids = HorarioAlumno.where(usuario_id: usuario.id).pluck(:horario_id)
    horarios_asignados = Horario.where(id: horarios_asignados_ids)
    
    horarios_asignados.each do |horario_asignado|
      if se_solapan_horarios_objects?(horario_asignado, horario)
        return false
      end
    end
    
    true
  end

  def se_solapan_horarios_objects?(horario1, horario2)
    return false unless horario1.diaSemana == horario2.diaSemana
    
    tiempo1 = horario1.hora * 60 + horario1.minuto
    tiempo2 = horario2.hora * 60 + horario2.minuto
    
    (tiempo1..(tiempo1 + 60)).cover?(tiempo2) || (tiempo2..(tiempo2 + 60)).cover?(tiempo1)
  end

  def crear_horario_alumno(usuario, horario)
    HorarioAlumno.create!(
      usuario_id: usuario.id,
      horario_id: horario.id
    )
    puts "Asignado: Usuario #{usuario.nombre} -> Horario #{horario.id} (#{horario.diaSemana} #{horario.hora}:#{horario.minuto})"
  end

  def registrar_conflicto(usuario, horario, motivo)
    conflicto = {
      usuario: usuario.nombre,
      horario: horario&.id,
      motivo: motivo
    }
    @conflictos << conflicto
    puts "CONFLICTO: Usuario #{usuario.nombre} - #{motivo}"
  end
end
