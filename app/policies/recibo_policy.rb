class ReciboPolicy
  attr_reader :usuario

  def initialize(usuario)
    @usuario = usuario
  end

  def descargarFacturacion?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

end
