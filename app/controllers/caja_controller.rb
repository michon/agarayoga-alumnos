class CajaController < ApplicationController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def listado
    @fechaHoy = Date.today
    @caja = Caja.order(created_at: :desc).all
  end

  def nuevo
    cj = Caja.new
    cj.fecha = params[:caja][:fecha]
    cj.concepto = params[:caja][:concepto]
    cj.importe = Money.new(params[:caja][:importe].to_i * 100, 'EUR')
    cj.usuario_id = 325
    cj.total = cj.totalCaja + cj.importe
    cj.save

    @fechaHoy = Date.today
    @caja = Caja.all

    redirect_to caja_listado_path()
  end

  def modificar
  end

  def ver
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:caja)
  end

end
