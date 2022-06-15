class HorarioPolicy
  attr_reader :usuario

  def initialize(usuario)
    @usuario = usuario
  end

  def verIndex?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verLibres?
    usuario.rol == 'instructor' || usuario.rol == 'admin' || usuario.rol == 'michon'
  end


end
