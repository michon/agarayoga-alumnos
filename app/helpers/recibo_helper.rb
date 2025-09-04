module ReciboHelper
  def filtro_params
    controller.send(:filtro_params)
  end
end
