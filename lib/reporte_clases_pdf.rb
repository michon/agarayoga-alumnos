# app/pdfs/alumno_asistencia_pdf.rb

class AlumnoAsistenciaPdf < Prawn::Document
  COLORS = {
    viene: '4CAF50',      # Verde
    asistio: '2196F3',    # Azul
    aviso: 'FF9800',      # Naranja
    falto: 'F44336',      # Rojo
    background: 'F5F5F5', # Gris claro
    text: '212121',       # Negro
    grid: 'E0E0E0'        # Gris para grid
  }

  def initialize(alumno, fecha_inicio, fecha_fin, distribucion_estados, horarios_frecuentes, 
                 porcentaje_instructores, racha_actual, total_asistencias, total_avisos, 
                 total_faltas, clases_alumno)
    super(page_size: 'A4', margin: [40, 40, 40, 40])
    
    @alumno = alumno
    @fecha_inicio = fecha_inicio
    @fecha_fin = fecha_fin
    @distribucion_estados = distribucion_estados
    @horarios_frecuentes = horarios_frecuentes
    @porcentaje_instructores = porcentaje_instructores
    @racha_actual = racha_actual
    @total_asistencias = total_asistencias
    @total_avisos = total_avisos
    @total_faltas = total_faltas
    @clases_alumno = clases_alumno
    
    generate_pdf
  end

  private

  def generate_pdf
    header
    move_down 20
    resumen_asistencia
    move_down 20
    graficos_pagina_1
    start_new_page
    calendarios_mensuales
  end

  def header
    # Logo (si tienes uno)
    # image "#{Rails.root}/app/assets/images/logo.png", width: 100, position: :left
    
    text "INFORME DE ASISTENCIA", size: 18, style: :bold, align: :center, color: COLORS[:text]
    move_down 10
    stroke_horizontal_rule
    move_down 10
    
    text "Alumno: #{@alumno.nombre}", size: 14
    text "Período: #{@fecha_inicio.strftime('%d/%m/%Y')} - #{@fecha_fin.strftime('%d/%m/%Y')}", size: 12
    text "Generado: #{Time.now.strftime('%d/%m/%Y %H:%M')}", size: 10
  end

  def resumen_asistencia
    # Cuadro de resumen con bordes
    bounding_box([0, cursor], width: bounds.width, height: 100) do
      stroke_bounds
      stroke_color COLORS[:grid]
      stroke_horizontal_line 0, bounds.width, at: 80
      stroke_vertical_line 0, 100, at: bounds.width / 3
      stroke_vertical_line 0, 100, at: (bounds.width / 3) * 2
      stroke_color '000000'
      
      # Racha actual (centrado superior)
      text_box "RACHA ACTUAL", at: [10, 90], size: 10, style: :bold
      text_box "#{@racha_actual} días", at: [10, 75], size: 16, style: :bold
      text_box "sin faltar", at: [10, 55], size: 10
      
      # Estadísticas (columna central)
      center_x = bounds.width / 3 + 10
      text_box "ASISTENCIAS", at: [center_x, 90], size: 10, style: :bold, align: :center
      text_box @total_asistencias.to_s, at: [center_x, 75], size: 16, style: :bold, align: :center
      
      text_box "AVISOS", at: [center_x, 55], size: 10, style: :bold, align: :center
      text_box @total_avisos.to_s, at: [center_x, 40], size: 12, align: :center
      
      text_box "FALTAS", at: [center_x, 25], size: 10, style: :bold, align: :center
      text_box @total_faltas.to_s, at: [center_x, 10], size: 12, align: :center
      
      # Porcentaje de asistencia (columna derecha)
      right_x = (bounds.width / 3) * 2 + 10
      total_clases = @total_asistencias + @total_avisos + @total_faltas
      porcentaje = total_clases > 0 ? (@total_asistencias.to_f / total_clases * 100).round(1) : 0
      
      text_box "PORCENTAJE", at: [right_x, 90], size: 10, style: :bold, align: :center
      text_box "#{porcentaje}%", at: [right_x, 70], size: 20, style: :bold, align: :center
      text_box "de asistencia", at: [right_x, 45], size: 10, align: :center
      text_box "#{total_clases} clases totales", at: [right_x, 25], size: 8, align: :center
    end
  end

  def graficos_pagina_1
    # Gráfico de anillo - Distribución de estados (izquierda)
    bounding_box([0, cursor], width: bounds.width/2, height: 200) do
      stroke_bounds
      text "DISTRIBUCIÓN DE ESTADOS", size: 12, style: :bold, align: :center
      move_down 10
      draw_donut_chart(@distribucion_estados)
    end
    
    # Gráfico de barras - Horarios frecuentes (derecha)
    bounding_box([bounds.width/2, cursor + 200], width: bounds.width/2, height: 200) do
      stroke_bounds
      text "HORARIOS MÁS FRECUENTADOS", size: 12, style: :bold, align: :center
      move_down 10
      draw_bar_chart(@horarios_frecuentes)
    end
    
    # Gráfico de torta - Porcentaje por instructor (abajo completo)
    bounding_box([0, cursor - 200], width: bounds.width, height: 200) do
      stroke_bounds
      text "ASISTENCIA POR INSTRUCTOR", size: 12, style: :bold, align: :center
      move_down 10
      draw_pie_chart(@porcentaje_instructores)
    end
  end

  def draw_donut_chart(data)
    total = data.values.sum.to_f
    return text "No hay datos disponibles", align: :center if total == 0
    
    center_x = bounds.width/4
    center_y = 80
    radius = 50
    hole_radius = 20
    
    start_angle = 0
    
    data.each do |estado, count|
      percentage = (count / total) * 360
      color = estado_color(estado)
      
      fill_color color
      fill_arc([center_x, center_y], radius, start_angle, start_angle + percentage)
      fill_color '000000'
      
      start_angle += percentage
    end
    
    # Agujero central
    fill_color 'FFFFFF'
    fill_circle([center_x, center_y], hole_radius)
    fill_color '000000'
    
    # Leyenda
    draw_legend(data, total, 20)
  end

  def draw_bar_chart(data)
    return text "No hay datos disponibles", align: :center if data.empty?
    
    max_value = data.map { |_, count| count }.max
    bar_width = 30
    spacing = 15
    chart_height = 80
    base_y = 70
    
    data.first(5).each_with_index do |(horario, count), index|
      x = index * (bar_width + spacing) + 20
      bar_height = (count.to_f / max_value) * chart_height
      
      fill_color COLORS[:asistio]
      fill_rectangle([x, base_y + bar_height], bar_width, bar_height)
      stroke_rectangle([x, base_y + bar_height], bar_width, bar_height)
      fill_color '000000'
      
      # Valor
      draw_text count.to_s, at: [x + 5, base_y + bar_height + 5], size: 8
      
      # Horario (abreviado)
      horario_short = horario.split(' - ').last[0..10] # Limitar longitud
      text_box horario_short, 
               at: [x, base_y - 15], 
               width: bar_width, 
               height: 20, 
               size: 6, 
               align: :center,
               valign: :top
    end
  end

  def draw_pie_chart(data)
    total = data.sum { |d| d[:total_clases] }.to_f
    return text "No hay datos disponibles", align: :center if total == 0
    
    center_x = bounds.width/2
    center_y = 80
    radius = 50
    
    start_angle = 0
    
    data.each do |instructor_data|
      percentage = (instructor_data[:total_clases] / total) * 360
      color = instructor_color(instructor_data[:name])
      
      fill_color color
      fill_arc([center_x, center_y], radius, start_angle, start_angle + percentage)
      fill_color '000000'
      
      start_angle += percentage
    end
    
    # Leyenda
    draw_instructor_legend(data, total, 20)
  end

  def draw_legend(data, total, start_y)
    y_position = start_y
    data.each do |estado, count|
      percentage = (count / total * 100).round(1)
      color = estado_color(estado)
      
      fill_color color
      fill_rectangle([10, y_position], 10, 10)
      fill_color '000000'
      
      text_box "#{estado}: #{percentage}% (#{count})", 
               at: [25, y_position + 8], 
               size: 8,
               width: 150
      
      y_position -= 15
    end
  end

  def draw_instructor_legend(data, total, start_y)
    y_position = start_y
    data.each do |instructor_data|
      percentage = (instructor_data[:total_clases] / total * 100).round(1)
      color = instructor_color(instructor_data[:name])
      
      fill_color color
      fill_rectangle([10, y_position], 10, 10)
      fill_color '000000'
      
      text_box "#{instructor_data[:name]}: #{percentage}%", 
               at: [25, y_position + 8], 
               size: 8,
               width: 150
      
      y_position -= 15
    end
  end

  def estado_color(estado)
    case estado
    when 'Asistió', 'asistio' then COLORS[:asistio]
    when 'Viene', 'viene' then COLORS[:viene]
    when 'Aviso', 'aviso' then COLORS[:aviso]
    when 'Falto', 'falto' then COLORS[:falto]
    else '#CCCCCC'
    end
  end

  def instructor_color(instructor_name)
    # Color consistente basado en hash del nombre
    hash = instructor_name.each_byte.reduce(0) { |a, b| (a << 5) - a + b }
    "##{(hash & 0xFFFFFF).to_s(16).rjust(6, '0')}"
  end

  def calendarios_mensuales
    text "CALENDARIO MENSUAL DE ASISTENCIAS", size: 14, style: :bold, align: :center
    move_down 20
    
    # Agrupar por mes
    meses = (@fecha_inicio.to_date..@fecha_fin.to_date).map { |d| d.beginning_of_month }.uniq
    
    # Crear 3 columnas
    column_width = bounds.width / 3
    column_count = 0
    current_y = cursor
    
    meses.each do |mes|
      if column_count == 3
        start_new_page
        current_y = bounds.top - 40
        column_count = 0
      end
      
      x_position = column_count * column_width
      
      bounding_box([x_position, current_y], width: column_width - 10, height: 150) do
        draw_month_calendar(mes)
      end
      
      column_count += 1
    end
  end

  def draw_month_calendar(mes)
    stroke_bounds
    
    # Encabezado del mes
    fill_color 'F0F0F0'
    fill_rectangle([0, bounds.top], bounds.width, 20)
    fill_color '000000'
    
    text_box mes.strftime('%B %Y').upcase, 
              at: [0, bounds.top - 5], 
              width: bounds.width, 
              height: 15, 
              size: 9, 
              style: :bold, 
              align: :center
    
    # Días de la semana
    days = %w[L M X J V S D]
    day_width = (bounds.width - 10) / 7
    
    days.each_with_index do |day, i|
      text_box day, 
               at: [5 + i * day_width, bounds.top - 25], 
               width: day_width, 
               size: 6, 
               align: :center
    end
    
    # Grid de días
    first_day = mes.beginning_of_month
    last_day = mes.end_of_month
    start_wday = first_day.wday == 0 ? 6 : first_day.wday - 1 # Ajuste para Lunes=0
    days_in_month = last_day.day
    
    current_day = 1
    (0..5).each do |week| # 6 semanas máximo
      break if current_day > days_in_month
      
      (0..6).each do |wday|
        break if current_day > days_in_month
        
        if week == 0 && wday < start_wday
          # Día vacío antes del primer día
          next
        end
        
        x = 5 + wday * day_width
        y = bounds.top - 35 - (week * 15)
        
        day_date = Date.new(mes.year, mes.month, current_day)
        clase_dia = @clases_alumno.find { |ca| ca.diaHora.to_date == day_date }
        
        # Color según estado
        bg_color = 'FFFFFF'
        if clase_dia
          estado = clase_dia.claseAlumnoEstado.nombre
          bg_color = case estado
                    when 'Asistió', 'Viene' then COLORS[:asistio]
                    when 'Aviso' then COLORS[:aviso]
                    when 'Falto' then COLORS[:falto]
                    else 'FFFFFF'
                    end
        end
        
        # Cuadro del día
        fill_color bg_color
        fill_rectangle([x, y], day_width - 2, 13)
        stroke_rectangle([x, y], day_width - 2, 13)
        fill_color '000000'
        
        # Número del día
        text_box current_day.to_s, 
                 at: [x + 2, y - 2], 
                 size: 6, 
                 width: day_width - 4
        
        current_day += 1
      end
    end
    
    # Leyenda de colores abajo
    fill_color COLORS[:asistio]
    fill_rectangle([5, 10], 8, 8)
    text_box "Asistió", at: [15, 12], size: 6
    
    fill_color COLORS[:aviso]
    fill_rectangle([45, 10], 8, 8)
    text_box "Aviso", at: [55, 12], size: 6
    
    fill_color COLORS[:falto]
    fill_rectangle([85, 10], 8, 8)
    text_box "Falto", at: [95, 12], size: 6
  end
end
