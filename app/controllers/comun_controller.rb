class ComunController < ApplicationController

    skip_before_action :authenticate_usuario!, :only => [:inicio]

  def indice
      if current_usuario && current_usuario.admin
          redirect_to michon_path
      elsif current_usuario
          redirect_to alumnos_path(current_usuario.id)
      else
        CarteroMailer.bienvenido_email("hola").deliver!
      end
  end

  def michon
      @fechaHoy = Date.today
      @alumnosTotal = Horario.first.alumnosTotal
  end

  def facturacion
      @fechaHoy = Date.today
      @alumnosTotal = HorarioAlumno.select("distinct usuario_id")
      @clientes = Cliente.where(debaja: :false)
      @alumnosSinCodigoFacturacion = Usuario.where(debaja: :false).where(codigofacturacion: [nil]).where(admin: false)

      usrAlta = Usuario.where(debaja: false).where(admin: false)

      #usuarios que estan como alta en la web y no estan en el horario
      @usuariosSinHorario = Array.new
      usrAlta.each do |usr|
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

      @importeTotal = 0
      HorarioAlumno.group(:usuario_id).count.each_with_index do |alm, idx|
        @aFacturar[idx] = Array.new
        @aFacturar[idx] << Usuario.find(alm[0]) << alm[1]
        @aFacturar[idx] << Cliente.find_by(codcliente: @aFacturar[idx][0].codigofacturacion)
        grupo = @aFacturar[idx][2].codgrupo
        importe = 0
        case grupo
        when  "dos"
          importe = 50
        when "uno"
          importe = 35
        when "YN"
          importe = 35
        when "zoom"
          importe = 40
        when "tres"
          importe = 60
        else
          importe = 0
        end
        @aFacturar[idx] << importe
        @importeTotal += importe
      end
  end


  def inicio
  end
end
