# lib/factura_pdf.rb
class FacturaPdf < Prawn::Document
  require "prawn/measurement_extensions"

  def initialize(factura)
    super(size: 'A4', top_margin: cm2pt(0.5), bottom_margin: cm2pt(0.5))
    @factura = factura
    @recibo = factura.recibo
    generar_pdf
  end

  def generar_pdf
    ficha_cabecera
    ficha_detalle
    ficha_totales
    ficha_pie
  end

  def ficha_cabecera
    # Logo
    image Rails.root.join("app/assets/images/logo-agara-5cm.png"), at: [cm2pt(14), cm2pt(27)], width: 5*72/2.54

    # Fuentes
    font_families.update(
      'cocomat' => {
        normal: Rails.root.join("app/assets/fonts/cocomat.ttf"),
        italic: Rails.root.join("app/assets/fonts/cocomat.ttf"),
        bold: Rails.root.join("app/assets/fonts/cocomat.ttf"),
        bold_italic: Rails.root.join("app/assets/fonts/cocomat.ttf")
      },
      'sawasdee' => {
        normal: Rails.root.join("app/assets/fonts/Sawasdee.ttf"),
        italic: Rails.root.join("app/assets/fonts/Sawasdee-Oblique.ttf"),
        bold: Rails.root.join("app/assets/fonts/Sawasdee-Bold.ttf"),
        bold_italic: Rails.root.join("app/assets/fonts/Sawasdee-BoldOblique.ttf")
      },
      'Handlee-Regular' => {
        normal: Rails.root.join("app/assets/fonts/Handlee-Regular.ttf"),
      },
      'Roboto' => {
        normal: Rails.root.join("app/assets/fonts/Roboto-Regular.ttf"),
        italic: Rails.root.join("app/assets/fonts/Roboto-Italic.ttf"),
        bold: Rails.root.join("app/assets/fonts/Roboto-Bold.ttf"),
        bold_italic: Rails.root.join("app/assets/fonts/Roboto-Italic.ttf")
      }
    )

    move_down 10
    font('cocomat') do
      text @factura.abono? ? "FACTURA DE ABONO" : "FACTURA", styles: [:bold], size: 20, color: 'e64b2a'
    end

    move_down 30
    font('cocomat') do
      text "AGÂRA YOGA", styles: [:bold], color: 'e64b2a', size: 14
    end

    move_down 6
    font('Roboto') do
      font_size(14)
      text "Miguel Rodríguez López"
      move_down 3
      text "33.322.144-C"
      move_down 3
      text "Carril das hortas, 25 bajo"
      move_down 3
      text "27002 - Lugo"
      move_down 5
      font_size(10)
      text "contacto@agarayoga.es"
      move_down 3
      text "www.agarayoga.es"
      move_down 3
      text "677524729-982815476"
    end

    # Datos cliente desde snapshot (histórico)
    move_down 20
    font('cocomat') do
      font_size(16)
      text "FACTURAR A:", styles: [:bold], color: 'e64b2a'
    end

    move_down 6
    font('Roboto') do
      font_size(14)
      datos = JSON.parse(@factura.datos_cliente_snapshot || '{}')
      text datos['nombre'] || @recibo&.usuario&.nombre || 'N/A'
      move_down 3
      text datos['dni'] || @recibo&.usuario&.dni || 'N/A'
      move_down 3
      text datos['direccion'] || @recibo&.usuario&.direccion || 'N/A'
      move_down 3
      text "#{datos['cp'] || @recibo&.usuario&.cp} #{datos['localidad'] || @recibo&.usuario&.localidad}"
    end

    # Número y fecha de factura
    bounding_box([cm2pt(10), cursor + cm2pt(2.2)], width: cm2pt(7), height: cm2pt(2)) do
      bounding_box([0, bounds.top], width: cm2pt(5.5), height: cm2pt(1)) do
        font('cocomat') do
          font_size(16)
          text "Nº DE FACTURA:", styles: [:bold], color: 'e64b2a'
        end
      end

      bounding_box([cm2pt(5.2), bounds.top], width: cm2pt(3.5), height: cm2pt(1)) do
        font('Roboto') do
          font_size(14)
          text @factura.numero, align: :right
        end
      end

      bounding_box([0, bounds.top - cm2pt(1)], width: cm2pt(3.5), height: cm2pt(1)) do
        font('cocomat') do
          font_size(16)
          text "FECHA:", styles: [:bold], color: 'e64b2a'
        end
      end

      bounding_box([cm2pt(5.2), bounds.top - cm2pt(1)], width: cm2pt(3.5), height: cm2pt(1)) do
        font('Roboto') do
          font_size(14)
          text @factura.fecha_emision.strftime("%d.%m.%Y"), align: :right
        end
      end
    end

    # Líneas decorativas
    stroke_color 'e64b2a'
    move_down 30
    stroke { horizontal_rule }
    move_down 2
    stroke { horizontal_rule }
  end

  def ficha_detalle
    # Cabecera tabla
    bounding_box([0, cursor], width: cm2pt(19), height: cm2pt(0.7)) do
      bounding_box([cm2pt(0.3), bounds.top - 5], width: cm2pt(13), height: cm2pt(0.7)) do
        font('sawasdee') do
          font_size(14)
          text "DESCRIPCIÓN", styles: [:bold], color: 'e64b2a'
        end
      end
      bounding_box([cm2pt(14), bounds.top - 5], width: cm2pt(4.8), height: cm2pt(0.7)) do
        font('Roboto') do
          font_size(14)
          text "IMPORTE", styles: [:bold], align: :right, color: 'e64b2a'
        end
      end
    end

    stroke_color 'e64b2a'
    stroke { horizontal_rule }
    move_down 2
    stroke { horizontal_rule }
    move_down 7

    # Concepto
    # Concepto
    bounding_box([0, cursor], width: cm2pt(19), height: cm2pt(1.5)) do
      bounding_box([cm2pt(0.3), bounds.top], width: cm2pt(13.5), height: cm2pt(1.5)) do
        font('Roboto') do
          font_size(@factura.abono? ? 11 : 14)  # Más pequeño si es abono
          concepto = @recibo&.concepto || "Cuota mensual de AgâraYoga"
          if @factura.abono? && @factura.motivo_abono.present?
            text "#{concepto}:", size: 11
            text @factura.motivo_abono, size: 10, style: :italic
          else
            text concepto
          end
        end
      end
      bounding_box([cm2pt(14.4), bounds.top], width: cm2pt(4.3), height: cm2pt(0.7)) do
        font('Roboto') do
          font_size(14)
          text number_to_currency(@factura.base_imponible, unit: "€"), align: :right
        end
      end
    end
  end

  def ficha_totales
    move_down 30

    # Subtotal
    bounding_box([0, cursor], width: cm2pt(19), height: cm2pt(1.3)) do
      bounding_box([cm2pt(0.3), bounds.top], width: cm2pt(14), height: cm2pt(1.2)) do
        font('sawasdee') do
          font_size(16)
          text "Subtotal", align: :right
        end
      end
      bounding_box([cm2pt(14.4), bounds.top], width: cm2pt(4.3), height: cm2pt(1.2)) do
        font('sawasdee') do
          font_size(16)
          text number_to_currency(@factura.base_imponible, unit: "€"), align: :right
        end
      end
    end

    # IVA
    bounding_box([0, cursor], width: cm2pt(19), height: cm2pt(1.3)) do
      bounding_box([cm2pt(0.3), bounds.top], width: cm2pt(14), height: cm2pt(1.2)) do
        font('sawasdee') do
          font_size(16)
          text "I.V.A. 21%", align: :right
        end
      end
      bounding_box([cm2pt(14.4), bounds.top], width: cm2pt(4.3), height: cm2pt(1.2)) do
        font('sawasdee') do
          font_size(16)
          text number_to_currency(@factura.iva, unit: "€"), align: :right
        end
      end
    end

    # Total
    bounding_box([0, cursor], width: cm2pt(19), height: cm2pt(1.5)) do
      bounding_box([cm2pt(0.3), bounds.top], width: cm2pt(14), height: cm2pt(1.2)) do
        font('sawasdee') do
          font_size(22)
          text "Total", styles: [:bold], align: :right
        end
      end
      bounding_box([cm2pt(14.4), bounds.top], width: cm2pt(4.3), height: cm2pt(1.2)) do
        font('sawasdee') do
          font_size(22)
          text number_to_currency(@factura.total, unit: "€"), styles: [:bold], align: :right
        end
      end
    end
  end

  def ficha_pie
    frases = [
      "Gracias por permitirnos ser parte de tu viaje hacia el bienestar y la armonía.",
      "Apreciamos profundamente tu energía y presencia en cada sesión.",
      "Namasté. Tu luz y tu práctica iluminan nuestro espacio.",
      "Con gratitud por compartir tu práctica de yoga con nosotros. ¡Esperamos verte pronto!",
      "Cada asana que realizas nos inspira. Gracias por elegirnos."
    ]

    bounding_box([0, 100], width: cm2pt(19), height: cm2pt(3)) do
      font('Handlee-Regular') do
        font_size(16)
        text frases.sample, styles: [:italic], align: :center
      end
    end
  end

  private

  def cm2pt(cuantos)
    (cuantos * 72 / 2.54)
  end

  def number_to_currency(number, options = {})
    ActiveSupport::NumberHelper.number_to_currency(number, options)
  end
end
