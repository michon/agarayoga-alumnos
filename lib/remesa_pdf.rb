class RemesaPdf  < Prawn::Document
  require "prawn/measurement_extensions"

  def initialize(rms)
      super(size: 'A4', top_margin: cm2pt(0.5), bottom_margin: cm2pt(0.5))
      @pagina = 1
      @rms = rms
      fichaCabecera
      cabeceraRemesa(cm2pt(24))
      cabeceraLineas(cm2pt(24))
      detalleLineas(cm2pt(23))
      piePagina

      # fichaSepa(cm2pt(14.5))
      # start_new_page()
      # fichaAutorizacionImagen(cm2pt(24))
  end


  def piePagina
        stroke_color 'd3d3d3'
        stroke do
          # just lower the current y position
          horizontal_line cm2pt(19.5), 0, at: 30
        end
        font 'sawasdee'
        draw_text "Pagina: #{@pagina}", at: [cm2pt(17.5),20], size: 9, styles: [:bold, :italic]
  end

  def cabeceraRemesa(y)
    bounding_box([0,y], width: (19*72/2.54), height: (10*72/2.54)) do 
        # Título
        bounding_box([cm2pt(0.3), cm2pt(10-0.3)], width: cm2pt(18.5), height: cm2pt(0.5)) do
            font 'cocomat'
            text "Remesa  #{@rms.id.to_s}", color: '393939'
        end
        #
        # Descripción
        bounding_box([cm2pt(0.3), cm2pt(10-0.8)], width: cm2pt(12.5), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Descripción", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@rms.nombre}", size: 12
            end
        end 
        #
        # FECHA
        bounding_box([cm2pt(13.2), cm2pt(10-0.8)], width: cm2pt(5.7), height: cm2pt(1.3)) do
            transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Fecha", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@rms.created_at.strftime("%d de %B de %Y")}", size: 12
            end
        end 
        
        # Dirección
        bounding_box([cm2pt(0.3), cm2pt(10-0.8-1.3-0.3)], width: cm2pt(12.5), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "IBAN", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@rms.iban}", size: 12
            end
        end 
        
        bounding_box([cm2pt(13.2), cm2pt(10-0.8-1.3-0.3)], width: cm2pt(5.7), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "BIC", size: 9, color: '393939' 
                move_down cm2pt(0.2) 
                font 'sawasdee'
                text "#{@rms.bic}", size: 12
            end
        end 
    end
  end

  def cabeceraLineas(y)
    bounding_box([0,y], width: (19*72/2.54), height: (10*72/2.54)) do 
        # Índice
      bounding_box([cm2pt(0.3), cm2pt(10-0.8-1.3-0.3-1.3-0.3)], width: cm2pt(2.5), height: cm2pt(0.7)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Codigo", size: 9, color: '393939' 
            end
        end 
        
        # Alumno 
      bounding_box([cm2pt(3), cm2pt(10-0.8-1.3-0.3-1.3-0.3)], width: cm2pt(12.5), height: cm2pt(0.7)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Alumno", size: 9, color: '393939' 
            end
        end 
        # Alumno 
      bounding_box([cm2pt(15.7), cm2pt(10-0.8-1.3-0.3-1.3-0.3)], width: cm2pt(3.2), height: cm2pt(0.7)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Importe", size: 9, color: '393939' 
            end
        end 
    end
  end

  def detalleLineas(y)

    inicio = 23
    @rms.recibos.order(:importe).each_with_index do |rcb, idx|
      
      if (inicio-idx) < 7 then
        piePagina
        inicio = inicio + 23 - 6
        start_new_page()
        @pagina = @pagina + 1
        fichaCabecera
        cabeceraRemesa(cm2pt(24))
        cabeceraLineas(cm2pt(24))
      end

      bounding_box([0, cm2pt(inicio-idx)], width: (19*72/2.54), height: (10*72/2.54)) do 
        # Código
        bounding_box([cm2pt(0.3), cm2pt(10-0.8-1.3-0.3-1.3-0.3)], width: cm2pt(2.5), height: cm2pt(0.7)) do
          stroke_color 'd3d3d3'
          transparent(0.5) { stroke_bounds }
              move_down cm2pt(0.2)
              indent(cm2pt(0.3)) do 
                  font 'sawasdee'
                  text rcb.usuario.codigofacturacion.to_s, size: 9, color: '393939' 
              end
          end 
        # Alumno 
        bounding_box([cm2pt(3), cm2pt(10-0.8-1.3-0.3-1.3-0.3)], width: cm2pt(12.5), height: cm2pt(0.7)) do
          stroke_color 'd3d3d3'
          transparent(0.5) { stroke_bounds }
              move_down cm2pt(0.2)
              indent(cm2pt(0.3)) do 
                  font 'sawasdee'
                  text rcb.usuario.nombre, size: 9, color: '393939' 
              end
          end 
        # Importe 
        bounding_box([cm2pt(15.7), cm2pt(10-0.8-1.3-0.3-1.3-0.3)], width: cm2pt(3.2), height: cm2pt(0.7)) do
          stroke_color 'd3d3d3'
          transparent(0.5) { stroke_bounds }
              move_down cm2pt(0.2)
              indent(cm2pt(0.3)) do 
                  font 'sawasdee'
                  text rcb.importe.to_s + ' €  ', size: 9, color: '393939', align: :right 
              end
          end 
      end
    end
  end

 def fichaCabecera()
    self.image Rails.root.join("app/assets/images/logo-agara-5cm.png"), at: [cm2pt(14),  cm2pt(27)], width: 5*72/2.54

    self.font_families.update(
      'cocomat' => { 
          normal: Rails.root.join("app/assets/fonts/cocomat.ttf"),
          italic: Rails.root.join("app/assets/fonts/cocomat.ttf"),
          bold: Rails.root.join("app/assets/fonts/cocomat.ttf"),
          bold_italic: Rails.root.join("app/assets/fonts/cocomat.ttf")

      },
      'c059' => {
          normal: Rails.root.join("app/assets/fonts/C059-Roman.ttf"),
          italic: Rails.root.join("app/assets/fonts/C059-Roman.ttf"),
          bold: Rails.root.join("app/assets/fonts/C059-Roman.ttf"),
          bold_italic: Rails.root.join("app/assets/fonts/C059-Roman.ttf")
      },
      'sawasdee' => {
          normal: Rails.root.join("app/assets/fonts/Sawasdee.ttf"),
          italic: Rails.root.join("app/assets/fonts/Sawasdee-Oblique.ttf"),
          bold: Rails.root.join("app/assets/fonts/Sawasdee-Bold.ttf"),
          bold_italic: Rails.root.join("app/assets/fonts/Sawasdee-BoldOblique.ttf")
      }

    )

    self.font('cocomat') do
        self.font_size(9)
        self.text "AGÂRA YOGA"
    end

    self.move_down 6 
    self.font('c059') do
        self.font_size(7)
        self.text "MIGUEL RODRÍGUEZ LóPEZ", color: '393939'
        self.text "N.I.F.: 33.322.144-C", color: '393939'
        self.text "CARRIL DAS HORTAS, 25 BAJO", color: '393939'
        self.text "27002 - LUGO ", color: '393939'
        self.move_down 6
        self.font_size(6)
        self.text "contacto@agarayoga.es", color: '393939'
        self.text "www.agarayoga.es", color: '393939'
        self.text "677524729-982815476", color: '393939'
    end

    self.stroke_color 'd3d3d3'
    self.move_down 5
    self.stroke do
        self.horizontal_rule
    end

  end

  private 
    def cm2pt(cuantos)
        return (cuantos*72/2.54)
    end
end
