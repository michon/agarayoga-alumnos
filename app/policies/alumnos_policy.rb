class AlumnosPolicy
  attr_reader :usuario

  def initialize(usuario)
    @usuario = usuario
  end

  def verIndex?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verClientes?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verActualizar?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verProcesos?
    usuario.rol == 'admin' || usuario.rol == 'michon' || usuario.rol == 'instructor'
  end

  def verShow?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verRegalo?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verSepa?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verFicha?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verBusiness?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end

  def verShow?
    usuario.rol == 'admin' || usuario.rol == 'michon'
  end
end
