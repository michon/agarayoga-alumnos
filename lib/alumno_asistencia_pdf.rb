require 'prawn'
require 'prawn-svg'
require 'prawn/icon'

class AlumnoAsistenciaPdf < Prawn::Document
  COLORS = {
    viene: '4CAF50',
    asistio: '2196F3',
    aviso: 'FF9800',
    falto: 'F44336',
    background: 'F5F5F5',
    text: '212121',
    grid: 'E0E0E0',
    gray: 'CCCCCC'
  }

  def initialize(params = {})
    super(
      page_size: 'A4',
      margin: [40, 40, 40, 40],
      page_layout: :portrait
    )
    setup_fonts
    setup_icon_fonts
    @usuario = params[:usuario]
    @fecha_inicio = params[:fecha_inicio] || 1.month.ago.to_date
    @fecha_fin = params[:fecha_fin] || Date.today
    @distribucion_estados = params[:distribucion_estados] || {}
    @horarios_frecuentes = params[:horarios_frecuentes] || []
    @porcentaje_instructores = params[:instructores_data] || []
    @racha_actual = params[:racha_actual] || 0
    @clases_alumno = params[:clases_alumno] || []
    calcular_totales
    generate_pdf
  end


  private

  #  Añadimos los fonts que necesitamos.
  def setup_icon_fonts
    solid_font_path = Rails.root.join('app', 'assets', 'fonts', 'fa-solid-900.ttf').to_s
    regular_font_path = Rails.root.join('app', 'assets', 'fonts', 'fa-regular-400.ttf').to_s

    if File.exist?(solid_font_path) && File.exist?(regular_font_path)
      Prawn::Icon.font_families.update(
        "FontAwesome" => {
          normal: regular_font_path,
          bold: solid_font_path
        }
      )
      Prawn::Icon.default_font "FontAwesome"
    else
      puts "Font files not found at #{solid_font_path} or #{regular_font_path}"
    end
  rescue => e
    puts "Error loading icon font: #{e.message}"
  end

  def setup_fonts
    font_dir = Rails.root.join('app', 'assets', 'fonts').to_s
    font_system = '/usr/share/fonts/truetype/dejavu/'

    # Intenta cargar DejaVu
    begin
      font_families.update(
        "DejaVu" => {
          normal: "#{font_system}/DejaVuSans.ttf",
          bold: "#{font_system}/DejaVuSans-Bold.ttf",
          italic: "#{font_system}/DejaVuSans-Oblique.ttf"
        }
      )
      font "DejaVu"
    rescue => e
      puts "Error loading DejaVu font: #{e.message}"

      # Intenta cargar Roboto
      begin
        font_families.update(
          "Roboto" => {
            normal: "#{font_dir}/Roboto-Regular.ttf",
            bold: "#{font_dir}/Roboto-Bold.ttf",
            italic: "#{font_dir}/Roboto-Italic.ttf"
          }
        )
        font "Roboto"
      rescue => e
        puts "Error loading Roboto font: #{e.message}"

        # Usar la fuente por defecto de Prawn
        font "Helvetica"
      end
    end
  end


  def calcular_totales
    # (Mantén tu código actual de calcular_totales)
  end

  #Base para el pdf
  def generate_pdf
    header
    move_down 20
    resumen_asistencia
    move_down 20
    if datos_suficientes?
      graficos_pagina_1
      start_new_page
      calendarios_mensuales
    else
      text "No hay suficientes datos para generar gráficos y calendarios", align: :center
    end
  end

  def datos_suficientes?
    @clases_alumno.any?
  end

  def header
    # (Mantén tu código actual de header)
  end

  def resumen_asistencia
    # (Mantén tu código actual de resumen_asistencia)
  end

  # Genera los mensajes para el gráfico de anillo de asistencias
  def generate_messages(distribucion_datos)
    asistio = distribucion_datos["Asistió"]
    aviso = distribucion_datos["No viene (avisó)"]
    falto = distribucion_datos["Faltó"]

    total_clases = asistio + aviso + falto
    return { asistio: "", aviso: "", falto: "" } if total_clases == 0

    # Porcentajes
    porcentaje_asistio = (asistio.to_f / total_clases) * 100
    porcentaje_aviso = (aviso.to_f / total_clases) * 100
    porcentaje_falto = (falto.to_f / total_clases) * 100

    # Mensaje para asistencia
    if porcentaje_asistio > 80
      asistio_message = "¡Excelente constancia! Tu asistencia regular a clase demuestra tu compromiso con tu práctica de yoga. ¡Sigue así!"
    elsif porcentaje_asistio >= 50
      asistio_message = "Buen trabajo manteniendo una asistencia regular. Cada clase a la que asistes te acerca más a tus metas. ¡Continúa con este ritmo!"
    else
      asistio_message = "Hemos notado que tu asistencia ha sido baja últimamente. Recuerda que la práctica constante es clave para progresar en yoga. ¡Te esperamos en clase!"
    end

    # Mensaje para avisos
    if aviso > 0 && (aviso.to_f / (aviso + falto)) * 100 > 50
      aviso_message = "Apreciamos mucho que siempre avises cuando no puedes asistir. Demuestra consideración por tus compañeros y profesores. ¡Gracias por tu responsabilidad!"
    elsif aviso > 0 && (aviso.to_f / (aviso + falto)) * 100 >= 20
      aviso_message = "Avisar cuando no puedes asistir es una gran práctica. Aunque entendemos que a veces no es posible, tu consideración es muy valorada."
    else
      aviso_message = "Hemos notado que últimamente no has avisado cuando no asistes a clase. Recordar avisar ayuda a tus compañeros y profesores a organizar mejor las clases. ¡Gracias por tu cooperación!"
    end

    # Mensaje para faltas
    if porcentaje_falto > 30
      falto_message = "Hemos notado que últimamente has faltado a varias clases sin aviso. En yoga, la práctica constante es fundamental para avanzar. ¡Te animamos a retomar tu compromiso y avisar si no puedes asistir!"
    elsif porcentaje_falto >= 10
      falto_message = "Entendemos que a veces es difícil asistir a todas las clases, pero recuerda que cada clase a la que asistes es un paso más en tu camino de yoga. Si no puedes asistir, por favor avísanos. ¡Esperamos verte pronto!"
    else
      falto_message = "Tu asistencia ha sido muy buena, y cuando no puedes asistir, generalmente avisas. ¡Gracias por ser parte de nuestra comunidad de yoga y por tu responsabilidad!"
    end

    { asistio: asistio_message, aviso: aviso_message, falto: falto_message }
  end


  # Formatea los mensajes para incluirlos todos en con su color en el mismo texto.
  def generar_textos_formateados
    textos_formateados = []
    messages = generate_messages(@distribucion_estados)

    @distribucion_estados.each do |estado, count|
      case estado.to_s.downcase
      when 'asistió', 'asistio'
        textos_formateados << {
          text: "Asistió: #{messages[:asistio]}\n\n",
          size: 7,
          color: estado_color(estado)
        }
      when 'no viene (avisó)', 'aviso'
        textos_formateados << {
          text: "Avisos: #{messages[:aviso]}\n\n", 
          size: 7,
          color: estado_color(estado)
        }
      when 'faltó', 'falto'
        textos_formateados << {
          text: "Faltas: #{messages[:falto]}\n\n",
          size: 7,
          color: estado_color(estado)
        }
      else
        textos_formateados << {
          text: "#{estado}: #{count}\n",
          size: 7,
          color: estado_color(estado),
        }
      end
    end

    textos_formateados
  end

  def graficos_pagina_1
    # Gráfico de distribución de estados (Torta)
    radio_esquinas = 10
    bounding_box([0, cursor], width: (bounds.width/3)*2, height: 250) do
      # Título con fondo amarillo
      fill_color 'F5B027'  # Amarillo
      stroke_color 'f5b027'  # Color del borde

    # Dibujar rectángulo redondeado para el título
      fill_rounded_rectangle [0, cursor], bounds.width, 20, radio_esquinas
      stroke_rounded_rectangle [0, cursor], bounds.width, 20, radio_esquinas


      # Asegúrate de que la fuente actual soporte UTF-8
      font "DejaVu" rescue font("Roboto") rescue font("Helvetica")

      # Usar prawn-icon para añadir un icono
      fill_color '000000'
      text_box " Distribución de Estados", at: [10, cursor - 6], size: 8, style: :italic
      move_down 20


    # Área de contenido con borde redondeado (todas las esquinas)
    stroke_color 'f5b027'  # Color del borde
    fill_color 'FFFFFF'    # Fondo blanco
    
    # Dibujar rectángulo redondeado para el área de contenido
    fill_rounded_rectangle [0, cursor], bounds.width, 250, radio_esquinas
    stroke_rounded_rectangle [0, cursor], bounds.width, 250, radio_esquinas

      text " ", size: 1  # Espacio para asegurar que el fondo blanco se aplique
      move_down 1
      svg generate_pie_chart_svg(@distribucion_estados), position: :center, width: 180
    end


  
    bounding_box([(bounds.width/3)*2 + 2 , cursor+250], width: (bounds.width/3) - 25, height: 250) do
      # Título con fondo amarillo
      fill_color 'F5B027'  # Amarillo
      stroke_color 'f5b027'  # Color del borde

      fill_color 'FFFFFF'    # Fondo blanco
    stroke_color 'f5b027'  # Color del borde
      move_down 20 
      fill_rounded_rectangle [0, cursor], bounds.width, 250, radio_esquinas
      stroke_rounded_rectangle [0, cursor], bounds.width, 250, radio_esquinas

      move_down 5
      indent(5,5) do
          generar_textos_formateados.each do |texto|
            fill_color texto[:color]
            text texto[:text], size: texto[:size], align: :justify, leadding: 8
          end
      end
    end

    move_down 260
    # Gráfico de horarios frecuentes (Barras)
    bounding_box([bounds.width/2, cursor ], width: bounds.width/2, height: 200) do
      stroke_bounds
      text "HORARIOS FRECUENTES", size: 12, style: :bold, align: :center
      move_down 10
      svg generate_bar_chart_svg(@horarios_frecuentes), position: :center, width: 150
    end

    # Gráfico de instructores (Barras horizontales)
    bounding_box([0, cursor - 200], width: bounds.width, height: 200) do
      stroke_bounds
      text "ASISTENCIA POR INSTRUCTOR", size: 12, style: :bold, align: :center
      move_down 10
      svg generate_instructor_chart_svg(@porcentaje_instructores), position: :center, width: 300
    end
  end

  def generate_bar_chart_svg(data)
    return "<text>No hay datos</text>" if data.empty?
    max_value = data.map { |_, count| count }.max.to_f
    svg = []
    svg << '<svg viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg">'
    bar_width = 20
    spacing = 10
    data.first(5).each_with_index do |(horario, count), index|
      x = index * (bar_width + spacing) + 20
      bar_height = (count / max_value) * 60
      y = 80 - bar_height
      svg << "<rect x=\"#{x}\" y=\"#{y}\" width=\"#{bar_width}\" height=\"#{bar_height}\" fill=\"##{COLORS[:asistio]}\" />"
      svg << "<text x=\"#{x + bar_width / 2}\" y=\"#{y - 5}\" font-size=\"8\" text-anchor=\"middle\">#{count}</text>"
      horario_short = horario.split(' - ').last[0..8] + "..."
      svg << "<text x=\"#{x + bar_width / 2}\" y=\"95\" font-size=\"6\" text-anchor=\"middle\">#{horario_short}</text>"
    end
    svg << '</svg>'
    svg.join
  end

  def generate_instructor_chart_svg(data)
    return "<text>No hay datos</text>" if data.empty?
    max_clases = data.map { |d| d[:total_clases] }.max.to_f
    svg = []
    svg << '<svg viewBox="0 0 300 200" xmlns="http://www.w3.org/2000/svg">'
    bar_height = 12
    spacing = 5
    data.first(8).each_with_index do |instructor, index|
      y = 20 + (index * (bar_height + spacing))
      bar_width = (instructor[:total_clases] / max_clases) * 250
      svg << "<rect x=\"20\" y=\"#{y}\" width=\"#{bar_width}\" height=\"#{bar_height}\" fill=\"##{instructor_color(instructor[:name])}\" />"
      svg << "<text x=\"25\" y=\"#{y + bar_height - 2}\" font-size=\"8\">#{instructor[:name]} (#{instructor[:total_clases]})</text>"
    end
    svg << '</svg>'
    svg.join
  end

def estado_color(estado)
  case estado.to_s.downcase
  when 'asistió', 'asistio' then '4CAF50'  # Verde
  when 'no viene (avisó)', 'aviso' then 'FF9800'  # Naranja
  when 'faltó', 'falto' then 'F44336'  # Rojo
  else 'CCCCCC'  # Gris
  end
end


  def instructor_color(name)
    # (Mantén tu código actual de instructor_color)
  end

  def calendarios_mensuales
    # (Mantén tu código actual de calendarios_mensuales)
  end

  def generate_pie_chart_svg(data)
  return "<text>No hay datos</text>" if data.empty?

  total = data.values.sum.to_f
  svg = []
  svg << '<svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">'

  center_x, center_y, radius = 100, 100, 70
  inner_radius = radius * 0.6
  gap_angle = 3

  start_angle = -90

  data.each do |estado, count|
    next if count == 0
    angle = (count / total) * 360 - gap_angle
    color = estado_color(estado)

    # Coordenadas de inicio y fin
    start_outer_x = center_x + radius * Math.cos(start_angle * Math::PI / 180)
    start_outer_y = center_y + radius * Math.sin(start_angle * Math::PI / 180)

    end_outer_x = center_x + radius * Math.cos((start_angle + angle) * Math::PI / 180)
    end_outer_y = center_y + radius * Math.sin((start_angle + angle) * Math::PI / 180)

    start_inner_x = center_x + inner_radius * Math.cos(start_angle * Math::PI / 180)
    start_inner_y = center_y + inner_radius * Math.sin(start_angle * Math::PI / 180)

    end_inner_x = center_x + inner_radius * Math.cos((start_angle + angle) * Math::PI / 180)
    end_inner_y = center_y + inner_radius * Math.sin((start_angle + angle) * Math::PI / 180)

    large_arc_flag = angle > 180 ? 1 : 0

    # Ruta de la sección
    svg << "<path d=\"M#{start_outer_x},#{start_outer_y}
                     A#{radius},#{radius} 0 #{large_arc_flag},1 #{end_outer_x},#{end_outer_y}
                     L#{end_inner_x},#{end_inner_y}
                     A#{inner_radius},#{inner_radius} 0 #{large_arc_flag},0 #{start_inner_x},#{start_inner_y}
                     Z\" fill=\"##{color}\" />"

    mid_angle = start_angle + angle / 2
    label_radius = radius + 15
    label_x = center_x + label_radius * Math.cos(mid_angle * Math::PI / 180)
    label_y = center_y + label_radius * Math.sin(mid_angle * Math::PI / 180)

    svg << "<text x=\"#{label_x}\" y=\"#{label_y}\" font-size=\"7\" text-anchor=\"middle\" fill=\"#333\">#{estado}: #{count}</text>"

    start_angle += angle + gap_angle
  end

  # Leyenda en línea
  legend_x, legend_y = 20, 180
  data.each_with_index do |(estado, _), index|
    next if estado.nil? || estado.empty?
    color = estado_color(estado)
   
    svg << "<rect x=\"#{legend_x + index * 70}\" y=\"#{legend_y+5}\" width=\"8\" height=\"8\" fill=\"##{color}\" />"
    svg << "<text x=\"#{legend_x + index * 70 + 10}\" y=\"#{legend_y + 12}\" font-size=\"7\" fill=\"#333\">#{estado}</text>"
  end

  svg << '</svg>'
  svg.join
end



end

