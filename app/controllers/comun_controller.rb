class ComunController < ApplicationController

    skip_before_action :authenticate_usuario!, :only => [:inicio]

  def indice
      if current_usuario && current_usuario.michon?
          redirect_to michon_path
      elsif current_usuario && current_usuario.instructor?
          redirect_to instructor_index_path
      elsif current_usuario && current_usuario.yogui?
          redirect_to alumnos_path(current_usuario.id)
      else
          redirect_to inicio_path()
      end
  end

  def michon
      if ComunPolicy.new(current_usuario).verMichon?
        @fechaHoy = Date.today
        @alumnosTotal = Horario.first.alumnosTotal
      else
        render :file => "public/401.html", :status => :unauthorized
      end
  end

  def facturacion
      unless ComunPolicy.new(current_usuario).verFacturacion?
        render :file => "public/401.html", :status => :unauthorized
      end

      @fechaHoy = Date.today
      @clientes = Cliente.where(debaja: :false)
      @alumnosTotal = HorarioAlumno.select("distinct usuario_id")
      @alumnosVeces = HorarioAlumno.group(:usuario_id).count.pluck(1).tally  #array que contiene las veces que vienen y cuantos vienen
      @alumnosSinCodigoFacturacion = Usuario.where(debaja: :false).where(codigofacturacion: [nil]).where("admin = false and (instructor_id = 0 or instructor_id is null)")


      @usrAlta = Usuario.where( "debaja = false and admin = false and (instructor_id = 0 or instructor_id is null)")

      #usuarios que estan como alta en la web y no estan en el horario
      @usuariosSinHorario = Array.new
      @usrAlta.each do |usr|
          if @alumnosTotal.find_by(usuario_id: usr.id).blank? then
              @usuariosSinHorario  << usr
          end
      end

      # Zona de clientes
      # Buscamos clientes que estan como alta en factuación y no estan dados de
      # alta como usuarios
      # Y
      # Buscamos clientes que estan como alta en facturación y ya no estan en el
      # horario.
      #
      @clientesSinHorario = Array.new
      @clientesSinUsuario = Array.new
      cliAlta = Cliente.where(debaja: false)
      cliAlta.each do |cl|
          usr = Usuario.find_by(codigofacturacion: cl.codcliente)
          if usr.blank? then
              @clientesSinUsuario << cl
          else
             if @alumnosTotal.find_by(usuario_id: usr.id).blank? then
                 @clientesSinHorario << usr
             end
          end
      end

      # Alumnos a facturar según el horario general actual
      @aFacturar = Array.new

      #Listado de usuarios que están actualmente en horario
      @usuariosEnHorario = Usuario.where(id: HorarioAlumno.group(:usuario_id).pluck(:usuario_id))
      @importeTotal = 0
      HorarioAlumno.group(:usuario_id).count.each_with_index do |alm, idx|
        @aFacturar[idx] = Array.new
        @aFacturar[idx] << Usuario.find(alm[0]) << alm[1]
        @aFacturar[idx] << Cliente.find_by(codcliente: @aFacturar[idx][0].codigofacturacion)
        if @aFacturar[idx][2].blank?
            grupo = 'No'
        else
            grupo = @aFacturar[idx][2].codgrupo
        end
        importe = 0

        # número de veces que aparece el alumno en el horario
        case alm[1].to_i
          when 1
            importe = 40
          when 2
            importe = 55
          when 3
            importe = 65
        end

        @aFacturar[idx] << importe
        @aFacturar[idx] << Cliente.find_by(codcliente: @aFacturar[idx][0].serie)
        @importeTotal += importe
      end

      # Establecemos los colores para la salida
      if @aFacturar.count == @clientes.count then
        @colorClientes =  "success"
      else
        @colorClientes =  "danger"
      end

      if @aFacturar.count == @usrAlta.count then
        @colorUsuarios =  "success"
      else
        @colorUsuarios =  "danger"
      end


      @colorFacturar
  end


  def inicio
  end
end
