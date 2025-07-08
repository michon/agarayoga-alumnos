module PdfGenerators
  class AsistenciaJulioPdf
    def initialize(alumnos)
      @alumnos = alumnos
      @pdf = Prawn::Document.new(page_size: 'A4', page_layout: :landscape)
    end

    def generate
      build_header
      build_table
      @pdf
    end

    private

    def build_header
      @pdf.image "#{Rails.root}/app/assets/images/logo-agara.png", width: 100, position: :left
      @pdf.text "Reporte de Asistencia - Julio 2025", size: 18, style: :bold, align: :center
      @pdf.text "Generado el: #{Time.now.strftime('%d/%m/%Y %H:%M')}", size: 10, align: :right
      @pdf.move_down 30
    end

    def build_table
        font_path = "#{Rails.root}/app/assets/fonts/DejaVuSans.ttf"
        @pdf.font_families.update("DejaVu" => {
          normal: font_path,
          bold: font_path,
          italic: font_path,
          bold_italic: font_path
        })
        @pdf.font("DejaVu")

      data = table_data
      
      @pdf.table(data, header: true, width: @pdf.bounds.width) do |table|
        style_table(table)
      end
    end

    def table_data
      data = []
      header = ["Nombre", "Sem 1\n(1-6 Jul)", "Sem 2\n(7-13 Jul)", "Sem 3\n(14-20 Jul)", 
               "Sem 4\n(21-27 Jul)", "Sem 5\n(28-30 Jul)", "No viene"]
      data << header

      @alumnos.each do |alumno|
        data << build_row(alumno)
      end

      data
    end

    def build_row(alumno)
      [
        alumno.nombre,
        status_icon(alumno.sem1),
        status_icon(alumno.sem2),
        status_icon(alumno.sem3),
        status_icon(alumno.sem4),
        status_icon(alumno.sem5),
        status_icon(alumno.noviene)
      ]
    end

    def style_table(table)
      # Header styling
      table.row(0).font_style = :bold
      table.row(0).size = 10
      table.row(0).background_color = '3366CC'
      table.row(0).text_color = 'FFFFFF'
      table.row(0).align = :center
      
      # Cell styling
      table.cells.borders = [:bottom]
      table.cells.border_width = 0.5
      table.cells.border_color = 'DDDDDD'
      table.cells.padding = [5, 10, 5, 10]
      
      # Column alignments
      table.columns(1..5).align = :center
      table.column(6).align = :center
      
      # Row banding for readability
      table.row_colors = ['FFFFFF', 'F5F5F5']
    end

    def status_icon(value)
      # Asumiendo que value es booleano
      value ? '✓' : '✗'
      
      # O si prefieres texto simple:
      # value ? 'Sí' : 'No'
      
      # O si necesitas mantener compatibilidad con ambos tipos:
      # value.to_s == 'true' || value.to_s == '1' ? '✓' : '✗'
    end
  end
end
