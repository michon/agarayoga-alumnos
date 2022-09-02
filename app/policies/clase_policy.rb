class ClasePolicy
  attr_reader :usuario

  def initialize(usuario)
    @usuario = usuario
  end

  def verSemana?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verDia?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verActual?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end
end
