module ReciboHelper

  def filtro_params
    controller.send(:filtro_params)
  end

  def estado_badge_color(estado_id)
    case estado_id
    when 1 then 'warning' # EMITIDO
    when 2 then 'success' # PAGADO
    when 3 then 'danger'  # DEVUELTO
    else 'secondary'
    end
  end
end
