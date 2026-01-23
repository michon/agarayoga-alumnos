# app/controllers/stats_controller.rb
class StatsController < ApplicationController
  before_action :set_common_variables, only: [:dashboard, :monthly_comparison, :evolucion_ingresos, :asistencia_mensual, :asistencia_instructor]

  # Dashboard general principal
  def dashboard
    @key_metrics = build_key_metrics
    @alumnos_faltas = top_alumnos_faltas_mes
    @alumnos_llamar = alumnos_para_llamar

    # Métricas de alumnos estables
    stable_data = stable_students
    @new_stable_count = stable_data[:new_stable].size
    @lost_stable_count = stable_data[:lost_stable].size

    @segmentacion = segment_active_students
    @activity_comparison = compare_activity_metrics
  end

  # Gráfico de asistencia mensual
  def asistencia_mensual
    mes = params[:mes] ? Date.parse(params[:mes] + "-01") : Date.today.beginning_of_month
    @attendance_data = monthly_attendance_data(mes)
    @mes_nombre = I18n.l(mes, format: "%B %Y")
  end

  # Gráfico de asistencia por instructor
  def asistencia_instructor
    @instructor = Instructor.find_by(id: params[:instructor_id])
    mes = params[:mes] ? Date.parse(params[:mes] + "-01") : Date.today.beginning_of_month

    if @instructor
      @attendance_data = instructor_attendance_data(@instructor, mes)
      @mes_nombre = I18n.l(mes, format: "%B %Y")
    end
  end

  # Comparación mensual através de los años
  def monthly_comparison
    @comparison_data = IncomeComparisonBuilder.yearly_comparison_data
    @years = @comparison_data.keys.sort
    @months = (1..12).map { |m| "%02d" % m }
    @datos_alumnos_mes = datos_alumnos_por_mes
  end

  # Gráfico de evolución de los ingresos bruto
  def evolucion_ingresos
    combined_data = IncomeCombiner.combined_data
    @paraver = combined_data

    @chart_data = {
      labels: combined_data.map { |d| I18n.l(d[:date], format: "%b %Y") },
      values: combined_data.map { |d| d[:amount] },
      is_historical: combined_data.map { |d| d[:date] < Date.new(2025, 5, 1) }
    }
  end

  private

  def set_common_variables
    # Solo mantener si se usan en otras vistas, sino eliminar
    @key_metrics ||= build_key_metrics if action_name == 'dashboard'
  end

  def build_key_metrics
    comparacion = compare_activity_metrics

    {
      active_students: comparacion[:reales],
      active_students_teoricos: comparacion[:teoricos],
      monthly_attendance_rate: calculate_monthly_attendance_rate,
      avg_student_tenure: calculate_avg_student_tenure_months,
      stable_students_pct: calculate_stable_students_percentage,
      avg_classes_per_student: calculate_avg_classes_per_student,
      popular_instructor: most_popular_instructor,
      data_health_issue: comparacion[:hay_problema],
      data_discrepancia: comparacion[:discrepancia]
    }
  end

  # MÉTODOS MANTENIDOS (se usan en el dashboard)
  def calculate_stable_students_percentage
    segmentacion = segment_active_students
    active_total = Usuario.activo.count
    return 0.0 if active_total == 0
    ((segmentacion[:estables].to_f / active_total) * 100).round(1)
  end

  def calculate_monthly_attendance_rate
    month_start = Date.today.beginning_of_month
    today = Date.today
    current_period = month_start..today

    clases_pactadas = ClaseAlumno.where(diaHora: current_period).count
    clases_asistidas = ClaseAlumno.where(diaHora: current_period)
                                 .where(claseAlumnoEstado_id: 2)
                                 .count

    clases_pactadas > 0 ? (clases_asistidas.to_f / clases_pactadas * 100).round(1) : 0
  end

  def calculate_avg_classes_per_student
    total_classes = ClaseAlumno.where(usuario_id: Usuario.activo.pluck(:id)).count
    active_count = Usuario.activo.count
    active_count > 0 ? (total_classes.to_f / active_count).round(1) : 0
  end

  def most_popular_instructor
    instructor_id = ClaseAlumno.joins(:clase)
      .where(clases: { diaHora: 1.month.ago..Date.today })
      .group('clases.instructor_id')
      .order('COUNT(clase_alumnos.id) DESC')
      .limit(1)
      .pluck('clases.instructor_id')
      .first

    Instructor.find_by(id: instructor_id)&.nombre || "No data"
  end

  def calculate_avg_student_tenure_months
    cutoff_date = 60.days.ago
    student_ranges = ClaseAlumno
      .group(:usuario_id)
      .having("MAX(diaHora) < ?", cutoff_date)
      .pluck(:usuario_id, "MIN(diaHora)", "MAX(diaHora)")

    valid_durations = student_ranges.map do |user_id, first_class, last_class|
      duration_seconds = (last_class - first_class).to_f
      next if duration_seconds < (15.days)
      duration_days = duration_seconds / 1.day
      duration_days / 30.44
    end.compact

    return 0.0 if valid_durations.empty?
    avg_months = (valid_durations.sum / valid_durations.size).round(1)
    [avg_months, 0.0].max
  end

  # MÉTODOS PARA VISTAS ESPECÍFICAS (asistencia_mensual, asistencia_instructor)
  def monthly_attendance_data(mes)
    month_start = mes.beginning_of_month
    month_end = mes.end_of_month
    datos_semanales = []
    current_week = month_start

    while current_week <= month_end
      week_end = [current_week.end_of_week, month_end].min
      total = ClaseAlumno.joins(:clase).where(clases: { diaHora: current_week..week_end }).count
      attended = ClaseAlumno.joins(:clase).where(clases: { diaHora: current_week..week_end }, claseAlumnoEstado_id: [1, 2]).count

      datos_semanales << {
        semana: "Semana #{(current_week - month_start).to_i / 7 + 1}",
        total: total,
        attended: attended,
        rate: total > 0 ? (attended.to_f / total * 100).round(1) : 0
      }
      current_week = week_end + 1.day
    end
    datos_semanales
  end

  def instructor_attendance_data(instructor, mes)
    month_start = mes.beginning_of_month
    month_end = mes.end_of_month
    attendance_by_day = []
    current_day = month_start

    while current_day <= month_end
      total = ClaseAlumno.joins(:clase)
        .where(clases: { diaHora: current_day.all_day, instructor_id: instructor.id })
        .count
      attended = ClaseAlumno.joins(:clase)
        .where(clases: { diaHora: current_day.all_day, instructor_id: instructor.id })
        .where(claseAlumnoEstado_id: [1, 2])
        .count

      attendance_by_day << {
        dia: I18n.l(current_day, format: "%a %d"),
        total: total,
        attended: attended,
        rate: total > 0 ? (attended.to_f / total * 100).round(1) : 0
      }
      current_day += 1.day
    end
    attendance_by_day
  end

  # MÉTODOS PARA SEGMENTACIÓN Y ESTABILIDAD
  def stable_students
    current_year = Date.today.year
    course_start = Date.new(current_year - 1, 9, 1)

    qualifying_years_sql = <<-SQL
      SELECT usuario_id, YEAR(diaHora) AS activity_year
      FROM clase_alumnos
      WHERE diaHora >= '2020-01-01' AND claseAlumnoEstado_id IN (2, 3, 5)
      GROUP BY usuario_id, YEAR(diaHora)
      HAVING COUNT(DISTINCT MONTH(diaHora)) >= 3
    SQL

    results = ActiveRecord::Base.connection.execute(qualifying_years_sql)
    years_by_user = Hash.new { |h, k| h[k] = [] }
    results.each { |row| years_by_user[row[0].to_i] << row[1].to_i }

    stable_ids = []; new_stable_ids = []; lost_stable_ids = []

    years_by_user.each do |user_id, years|
      qualifying_years = years.sort.uniq
      next unless qualifying_years.size >= 2

      has_current_activity = ClaseAlumno.where(
        usuario_id: user_id,
        diaHora: course_start..Date.today,
        claseAlumnoEstado_id: [2, 3, 5]
      ).exists?

      if has_current_activity
        stable_ids << user_id
        new_stable_ids << user_id if qualifying_years.include?(current_year - 1) && qualifying_years.include?(current_year)
      elsif qualifying_years.include?(current_year - 1)
        lost_stable_ids << user_id
      end
    end

    { stable: stable_ids, new_stable: new_stable_ids, lost_stable: lost_stable_ids }
  end

  def segment_active_students
    current_year = Date.today.year
    course_start = Date.new(current_year - 1, 9, 1)
    active_user_ids = Usuario.activo.pluck(:id).to_set

    all_activity = ClaseAlumno
      .where(usuario_id: active_user_ids, claseAlumnoEstado_id: [2, 3, 5])
      .where.not(diaHora: nil)
      .pluck(:usuario_id, :diaHora)

    activity_by_user = all_activity.group_by { |uid, _| uid }
    nuevos = 0; nuevos_estables = 0; estables = 0

    activity_by_user.each do |user_id, records|
      current_activity = records.select { |_, dh| dh >= course_start }
      next if current_activity.empty?

      current_months = current_activity.map { |_, dh| dh.month }.uniq.size
      past_activity = records.select { |_, dh| dh < course_start }

      if past_activity.empty?
        current_months >= 3 ? nuevos_estables += 1 : nuevos += 1
      else
        months_by_year = {}
        past_activity.each do |_, dh|
          year = dh.year
          months_by_year[year] ||= Set.new
          months_by_year[year] << dh.month
        end
        qualifying_past_years = months_by_year.count { |_, months| months.size >= 3 }

        if qualifying_past_years >= 2
          estables += 1
        else
          current_months >= 3 ? nuevos_estables += 1 : nuevos += 1
        end
      end
    end

    { nuevos: nuevos, nuevos_estables: nuevos_estables, estables: estables }
  end

  # MÉTODOS PARA SEGUIMIENTO DE ALUMNOS
def top_alumnos_faltas_mes
  current_month = Date.today.beginning_of_month..Date.today.end_of_month
  start_date = current_month.begin
  end_date = current_month.end

  # 1. Obtener faltas REALES por alumno (estado 3 "aviso" y 4 "falto")
  faltas_reales = ClaseAlumno
    .where(diaHora: current_month, claseAlumnoEstado_id: [3, 4])
    .group(:usuario_id)
    .count

  # 2. Obtener alumnos con horario activo que tengan faltas
  alumnos_con_faltas = faltas_reales.map do |usuario_id, num_faltas|
    usuario = Usuario.find_by(id: usuario_id)
    next unless usuario && HorarioAlumno.where(usuario_id: usuario_id).exists?

    clases_pactadas = calculate_clases_pactadas_alumno(usuario_id, start_date, end_date)
    
    # Calcular total de clases REALES del mes
    total_clases = ClaseAlumno.joins(:clase)
      .where(usuario_id: usuario_id)
      .where(clases: { diaHora: current_month })
      .count

    {
      id: usuario_id,
      nombre: usuario.nombre,
      faltas: num_faltas,
      clases_pactadas: clases_pactadas.to_i,
      total_clases: total_clases, # ← Este campo ya no será nil
      tasa_faltas: clases_pactadas > 0 ? (num_faltas.to_f / clases_pactadas * 100).round(1) : 0
    }
  end.compact

  # 3. Ordenar y limitar
  alumnos_con_faltas.sort_by { |a| -a[:faltas] }.take(10)
end 

def calculate_clases_pactadas_alumno(usuario_id, start_date, end_date)
  dias_pactados = HorarioAlumno.where(usuario_id: usuario_id)
                              .joins(:horario)
                              .select('horarios.diaSemana')
                              .distinct
                              .pluck('horarios.diaSemana')

  # Si no hay días pactados, retornar 0
  return 0 if dias_pactados.empty?

  count = (start_date..end_date).count do |date|
    dias_pactados.include?(date.wday)
  end

  count
end

  def alumnos_para_llamar
    current_month = Date.today.beginning_of_month..Date.today.end_of_month
    alumnos_activos = Usuario.activo

    alumnos_con_faltas = alumnos_activos.map do |alumno|
      clases_mes = ClaseAlumno.joins(:clase)
        .where(usuario_id: alumno.id)
        .where(clases: { diaHora: current_month })

      total_clases = clases_mes.count
      total_faltas = clases_mes.where(claseAlumnoEstado_id: [3, 4]).count
      total_asistencias = clases_mes.where(claseAlumnoEstado_id: [1, 2]).count

      criterio_1 = total_faltas >= 3
      criterio_2 = total_clases > 0 && (total_faltas.to_f / total_clases) >= 0.7
      criterio_3 = total_asistencias == 0 && total_clases > 0
      necesita_llamada = criterio_1 || criterio_2 || criterio_3

      {
        id: alumno.id,
        nombre: alumno.nombre,
        telefono: alumno.telefono || alumno.movil,
        email: alumno.email,
        total_clases: total_clases,
        total_asistencias: total_asistencias,
        total_faltas: total_faltas,
        tasa_faltas: total_clases > 0 ? (total_faltas.to_f / total_clases * 100).round(1) : 0,
        necesita_llamada: necesita_llamada,
        urgencia: calcular_urgencia(total_faltas, total_clases, total_asistencias)
      }
    end

    alumnos_con_faltas.select { |a| a[:necesita_llamada] }.sort_by { |a| -a[:urgencia] }
  end

  def calcular_urgencia(faltas, total_clases, asistencias)
    urgencia = 0
    if total_clases > 0
      urgencia += (faltas.to_f / total_clases * 70).round
    end
    urgencia += [faltas * 2, 20].min
    urgencia += 10 if asistencias == 0 && total_clases > 0
    [urgencia, 100].min
  end

  # MÉTODO PARA COMPARACIÓN DE ACTIVIDAD
  def compare_activity_metrics
    activos_teoricos = Usuario.activo.count
    activos_reales = HorarioAlumno.select("DISTINCT usuario_id").count
    discrepancia = activos_teoricos - activos_reales
    porcentaje_discrepancia = activos_teoricos > 0 ? ((discrepancia.to_f / activos_teoricos) * 100).round(1) : 0

    {
      teoricos: activos_teoricos,
      reales: activos_reales,
      discrepancia: discrepancia.abs,
      porcentaje_discrepancia: porcentaje_discrepancia,
      hay_problema: discrepancia > 0
    }
  end


  def datos_alumnos_por_mes
    datos_alumnos = {}
    usuarios_excluidos = Usuario.where(grupoAlumno_id: [7, 8]).pluck(:id)

    @years.each do |year|
      datos_alumnos[year] = {}
      @months.each do |mes|
        inicio_mes = Date.new(year.to_i, mes.to_i, 1)
        fin_mes = inicio_mes.end_of_month

        datos_alumnos[year][mes] = ClaseAlumno
          .where(diaHora: inicio_mes..fin_mes, claseAlumnoEstado_id: [1, 2])
          .where.not(usuario_id: usuarios_excluidos)
          .distinct
          .count(:usuario_id)
      end
    end

    datos_alumnos
  end

end
