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

  def estado_icono(estado_id)
    case estado_id
    when 1 then 'clock-history'     # EMITIDO
    when 2 then 'check-circle-fill' # PAGADO
    when 3 then 'exclamation-triangle-fill' # DEVUELTO
    else 'question-circle'
    end
  end
end
