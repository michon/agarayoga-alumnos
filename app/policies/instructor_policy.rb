class InstructorPolicy
  attr_reader :usuario

def initialize(usuario)
  @usuario = usuario
end

def verShow?
  usuario.rol == 'admin' || usuario.rol == 'michon' || usuario.rol == 'instructor' 
end

def verDia?
  usuario.rol == 'admin' || usuario.rol == 'michon' || usuario.rol == 'instructor'
end

end
