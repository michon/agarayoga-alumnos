class ComunPolicy
  attr_reader :usuario

  def initialize(usuario)
    @usuario = usuario
  end

  def verMichon?
    usuario.rol == 'michon'
  end

  def verFacturacion?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end
end
