class FichaAlumno  < Prawn::Document
  require "prawn/measurement_extensions"

  def initialize(almn)
      super(size: 'A4', top_margin: cm2pt(0.5), bottom_margin: cm2pt(0.5))
      @almn = almn
      fichaCabecera
      fichaAlumno(cm2pt(24))
      fichaSepa(cm2pt(14.5))
      start_new_page()
      fichaCabecera
      fichaAutorizacionImagen(cm2pt(24))


  end

  def fichaAutorizacionImagen(y)
    bounding_box([0,y], width: (cm2pt(19)), height: cm2pt(25)) do
        # Título
        move_down cm2pt(0.5)
        font 'cocomat'
        text "AUTORIZACIÓN CESIÓN DE IMÁGEN", color: '393939'

        move_down cm2pt(0.5)

        font 'sawasdee'
        text "Con la inclusión de las nuevas tecnologías dentro de las comunicaciones, publicaciones y acciones comerciales que puede realizar Miguel A. Rodríguez López y la posibilidad de que, en éstas, puedan aparecer los datos personales y/o imágenes que ha proporcionado a nuestra entidad dentro del vínculo contractual o laboral existente; y, dado  que  el  derecho  a  la  propia  imagen  está  reconocido  al  artículo  18  de  la  Constitución  y  regulado  por  la Ley 1/1982, de 5 de mayo, sobre el derecho al honor, a la intimidad personal y familiar y a la propia imagen, en el Reglamento General de Protección de Datos (RGPD) (UE) 2016/679 y en la Ley Orgánica 3/2018, de 5 de diciembre, de Protección de Datos de Carácter Personal y Garantía de los Derechos Digitales (LOPD y GDD): ", size: 12, align: :justify, leading: 3, indent_paragraphs: 10
        move_down cm2pt(0.2)
        text " Miguel A. Rodríguez López pide su consentimiento expreso, mediante la firma de este documento, para poder publicar imágenes en las que usted aparezca, individualmente o en grupo, realizadas por el Responsable (o por un tercero designado a tal efecto), en los siguientes medios: ", size: 12, align: :justify, leading: 3, indent_paragraphs: 10
        move_down cm2pt(0.2)

        indent(cm2pt(0.3)) do 
            text " -Intranets o sistemas de comunicación instantánea.  ", size: 12, align: :justify, leading: 3
            text " -La página web y perfiles en redes sociales de la entidad.  ", size: 12, align: :justify, leading: 3
            text " -Filmaciones destinadas a difusión comercial.  ", size: 12, align: :justify, leading: 3
            text " -Fotografías para revistas o publicaciones de ámbito relacionado con nuestro sector.  ", size: 12, align: :justify, leading: 3
        end
 
        move_down cm2pt(0.2)
        text " Asimismo, le informamos de la posibilidad de ejercer los siguientes derechos sobre sus datos personales: derecho de acceso, rectificación, supresión u olvido, limitación, oposición, portabilidad y a retirar el consentimiento prestado. Para ello, podrá enviar un email a contacto@agarayoga.es, o bien dirigir un escrito a Miguel A. Rodríguez López, 33322144C, C/ Huertas, 25, Bajo - 27002 - Lugo - LUGO, adjuntando copia de su DNI. Además, el interesado puede dirigirse a la Autoridad de Control en materia de Protección de Datos competente (AEPD, en España) para obtener información adicional o presentar una reclamación.  ", size: 12, align: :justify, leading: 3, indent_paragraphs: 10
 
        move_down cm2pt(1)

        indent(cm2pt(9.5)) do 
            I18n.locale = :es
            text "  En Lugo, #{I18n.l Date.today, format: ('%A %d de %B de %Y')} ", size: 12, align: :justify, leading: 3

            move_down cm2pt(5)
     
            text " Fdo. #{@almn.nombre} ", size: 12, align: :justify, leading: 3
     
            text " D.N.I. #{@almn.dni}", size: 12, align: :justify, leading: 3
        end
    end

  end

  def fichaSepa(y)
    bounding_box([0,y], width: (cm2pt(19)), height: cm2pt(14.5)) do
        # Título
        bounding_box([cm2pt(0.3), cm2pt(14.5-0.3)], width: cm2pt(17.5), height: cm2pt(0.5)) do
            font 'cocomat'
            text "ORDEN DE DOMICILIACIÓN DE ADEUDO SEPA", color: '393939'
        end

        # acreedor
        bounding_box([cm2pt(0.3), cm2pt(14.5-0.8)], width: cm2pt(1), height: cm2pt(4.5)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            font 'cocomat'
            text_box "ACREEDOR", color: '393939', rotate: 90, rotate_around: :lower_left, width: cm2pt(4.5), height: cm2pt(1), at: [cm2pt(1.3), cm2pt(1)], align: :center
        end

        # Referencia
        bounding_box([cm2pt(1.3), cm2pt(14-0.3)], width: cm2pt(17.5), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "REFERENCIA DE LA ORDEN DE DOMICILIACIÓN", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "Cuota AgâraYoga", size: 12 if !@almn.iban.blank?
            end
        end 

        # Identificador
        bounding_box([cm2pt(1.3), cm2pt(14-1.9)], width: cm2pt(17.5), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "IDENTIFICADOR DEL ACREEDOR", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "AgâraYoga (Miguel Rodríguez López)", size: 12 if !@almn.iban.blank?
            end
        end 

        # dirección
        bounding_box([cm2pt(1.3), cm2pt(14-1.9-1.6)], width: cm2pt(17.5), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Dirección", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "Carril das Hortas 25 Bajo, 27002 de Lugo provincia de Lugo", size: 12 if !@almn.iban.blank?
            end
        end 
    
        # Deudor
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
        bounding_box([cm2pt(0.3), cm2pt(14.5-0.8-4.9)], width: cm2pt(1), height: cm2pt(6.1)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            font 'cocomat'
            text_box "DEUDOR", color: '393939', rotate: 90, rotate_around: :lower_left, width: cm2pt(4.5), height: cm2pt(1), at: [cm2pt(1.3), cm2pt(1.8)], align: :center
        end

        # Nombre deudor
        bounding_box([cm2pt(1.3), cm2pt(14-0.3-4.9)], width: cm2pt(17.5), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "NOMBRE DEL DEUDOR / TITULAR DE LA CUENTA", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@almn.nombre}", size: 12 if !@almn.iban.blank?
            end
        end 
        
        # Dirección deudor
        bounding_box([cm2pt(1.3), cm2pt(14-0.3-4.9-1.6)], width: cm2pt(17.5), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "DIRECCIÓN DEL DEUDOR ", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@almn.direccion} #{@almn.cp} de #{@almn.localidad} provincia de #{@almn.provincia}", size: 12 if !@almn.iban.blank?
            end
        end 

        # Numero de cuenta
        bounding_box([cm2pt(1.3), cm2pt(14-0.3-4.9-1.6-1.6)], width: cm2pt(12.5), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "NÚMERO DE CUENTA / IBAN", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "IBAN #{@almn.ibanImpreso}", size: 12 if !@almn.iban.blank?
            end
        end 
        
        # Firma
        bounding_box([cm2pt(14.2), cm2pt(14-0.3-4.9-1.6-1.6)], width: cm2pt(4.6), height: cm2pt(2.9)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "FIRMA", size: 9, color: '393939' 
                move_down cm2pt(0.2)
            end
        end 
        
        # Lugara y fecha
        bounding_box([cm2pt(1.3), cm2pt(14-0.3-4.9-1.6-1.6-1.6)], width: cm2pt(12.5-4.9), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "LUGAR Y FECHA", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "En Lugo a #{I18n.l Date.today, format: ('%d de %b de %Y')}", size: 12 if !@almn.iban.blank?
            end
        end 
        
        # Tipo de pago 
        bounding_box([cm2pt(14.2-5), cm2pt(14-0.3-4.9-1.6-1.6-1.6)], width: cm2pt(4.6), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "TIPO DE PAGO", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "Pago recurrente", size: 12 if !@almn.iban.blank?
            end
        end 
        

        #información bancaria
        bounding_box([cm2pt(1.3), cm2pt(14-0.3-4.9-1.6-1.6-1.6-1.6)], width: cm2pt(17), height: cm2pt(3.5)) do

            move_down cm2pt(0.2)
            text "Mediante la firma de esta orden de domiciliación, el/la deudor/a autoriza al acreedor a enviar instrucciones a la entidad del deudor/a en su cuenta y a la entidad para efectuar los adeudos en su cuenta siguiendo las instrucciones del acreedor. Como parte de sus derechos, el/la deudor/a está legitimado al reembolso por su entidad en los términos y condiciones del contrato suscrito con la misma. La solicitud de reembolso deberá efectuarse dentro de las ocho semanas que siguen a la fecha del adeudo en cuenta. Puede obtener información adicional sobre sus derechos en su entidad financiera.", size: 7, color: '393939', align: :justify
        end 

    end
  end

  def fichaAlumno(y)
    bounding_box([0,y], width: (19*72/2.54), height: (10*72/2.54)) do 
        
        # Título
        bounding_box([cm2pt(0.3), cm2pt(10-0.3)], width: cm2pt(18.5), height: cm2pt(0.5)) do
            font 'cocomat'
            text "FICHA ALUMNO", color: '393939'
        end
        
        # Nombre
        bounding_box([cm2pt(0.3), cm2pt(10-0.8)], width: cm2pt(12.5), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Nombre", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@almn.nombre}", size: 12
            end
        end 
        
        # DNI
        bounding_box([cm2pt(13.2), cm2pt(10-0.8)], width: cm2pt(5.7), height: cm2pt(1.3)) do
            transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "D.N.I.", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@almn.dni}", size: 12
            end
        end 
        
        # Dirección
        bounding_box([cm2pt(0.3), cm2pt(10-0.8-1.3-0.3)], width: cm2pt(18.6), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Dirección", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@almn.direccion} #{@almn.cp} de #{@almn.localidad} provincia de #{@almn.provincia}", size: 12
            end
        end 
        
        # Teléfono
        bounding_box([cm2pt(0.3), cm2pt(10-0.8-1.3-0.3-1.3-0.3)], width: cm2pt(5.7), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Teléfono", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@almn.telefono}", size: 12
            end
        end 
        
        # Correo Electrónico
        bounding_box([cm2pt(6.3), cm2pt(10-0.8-1.3-0.3-1.3-0.3)], width: cm2pt(12.6), height: cm2pt(1.3)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Correo electrónico", size: 9, color: '393939' 
                move_down cm2pt(0.2)
                font 'sawasdee'
                text "#{@almn.email}", size: 12
            end
        end 

        # Fecha y firma
        bounding_box([cm2pt(13.2), cm2pt(10-0.8-1.3-0.3-1.3-0.3-1.6)], width: cm2pt(5.7), height: cm2pt(3.5)) do
        stroke_color 'd3d3d3'
        transparent(0.5) { stroke_bounds }
            move_down cm2pt(0.2)
            indent(cm2pt(0.3)) do 
                font 'cocomat'
                text "Fecha y Firma", size: 9, color: '393939' 
                move_down cm2pt(0.2)
            end
        end 

        # Protección de datos 
        bounding_box([cm2pt(0.3), cm2pt(10-0.8-1.3-0.3-1.3-0.3-1.6)], width: cm2pt(12.5), height: cm2pt(3.5)) do

            move_down cm2pt(0.2)
                font 'sawasdee'
                text "Este mensaje y sus archivos adjuntos van dirigidos exclusivamente a su destinatario, pudiendo contener información confidencial sometida a secreto profesional. No está permitida su reproducción o distribución sin la autorización expresa de Miguel A. Rodríguez López. Si usted no es el destinatario final por favor elimínelo e infórmenos por esta vía.", size: 7, color: '000000', align: :justify
                
                text "Le informamos que Miguel A. Rodríguez López trata sus datos personales con la finalidad de responder a su solicitud de información, realizar la gestión administrativa derivada de la prestación del servicio, así como enviarle comunicaciones comerciales sobre nuestros servicios,", size: 7, color: '000000', align: :justify
                
                text "Asimismo, le informamos de la posibilidad de ejercer los siguientes derechos sobre sus datos personales: derecho de acceso, rectificación, supresión u olvido, limitación, oposición, portabilidad y a retirar el consentimiento prestado. Para ello podrá enviar un email a: contacto@agarayoga.es, adjuntando copia de su DNI.", size: 7, color: '000000', align: :justify
                
                text "Para más información sobre el tratamiento de sus datos, puede consultar nuestra política de privacidad.", size: 7, color: '000000', align: :justify
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
