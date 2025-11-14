class Usuario < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  belongs_to :grupoAlumno
  has_many :horarioAlumno
  has_many :claseAlumno
  has_many :recibos
  has_many :cajas
  has_many :horarios, through: :horarioAlumno
  has_one :instructor
  has_one_attached :image, :dependent => :destroy
  has_many :preinscripciones, class_name: 'Preinscripcion'

  # Validaciones personalizadas para IBAN/BIC
  validate :iban_valido, if: -> { iban.present? }
  validate :bic_valido, if: -> { bic.present? }

  scope :alumno, -> {where(instructor_id: [nil, 0])}
  scope :activo, -> {
    alumno.where(debaja: false)
  }
  scope :inactivos, -> {alumno.where(debaja: true)}
  scope :esInstructor, -> {where(debaja: false).where.not(instructor_id: [nil, 0])}
  default_scope { order(nombre: :asc) }


  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum rol: [:yogui, :instructor, :admin, :michon]

  after_initialize :set_default_rol, :if => :new_record?


  def generar_clave_facil
    # Genera una clave del tipo "Palabra123" (fácil de recordar)
    adjetivos = %w[Alegre Brillante Calido Dulce Especial Feliz Grande Hermoso Importante Joven Karma Lindo Magico Natural Optimista Puro Quieto Radiante Sereno Tranquilo Unico Valiente]
    sustantivos = %w[Sol Luna Estrella Mar Rio Monte Flor Arbol Cielo Nube Viento Ola Paz Luz Alma Corazon Yoga Meditacion Zen Energia]
    numero = rand(100..999)

    "#{adjetivos.sample}#{sustantivos.sample}#{numero}"
  end

  def establecer_clave_temporal
    nueva_clave = generar_clave_facil
    self.password = nueva_clave
    self.password_confirmation = nueva_clave
    save
    nueva_clave
  end



  def set_default_rol
    sef_rol ||= :usuario
  end


  def self.ransackable_attributes(auth_object = nil)
    [ "nombre" ]
  end  

  def ibanImpreso
      ibanImp = ""
      (self.iban.length/4).times do |i|
        ibanImp <<  self.iban[(i*4)..(i*4)+3] + " "
      end
      ibanImp
  end

  # app/models/usuario.rb
  # app/models/usuario.rb
def iban_valido
  return if iban.blank?

  iban_limpio = iban.gsub(/\s+/, "").upcase

  # Validación con IBANTools
  iban_obj = IBANTools::IBAN.new(iban_limpio)

  # Verificar dígitos de control
  unless iban_obj.valid_check_digits?
    errors.add(:iban, "tiene dígitos de control incorrectos")
    return
  end

  # Validación con SepaKing - FORMA CORRECTA
  if defined?(SEPA::IBANValidator)
    begin
      # SEPA::IBANValidator se usa como mixin, no como clase
      # Probamos creando una clase temporal con la validación
      temp_class = Class.new do
        include SEPA::IBANValidator
        attr_accessor :iban
      end
      temp_instance = temp_class.new
      temp_instance.iban = iban_limpio

      # Verificar si hay errores de validación
      unless temp_instance.valid_sepa_iban?
        errors.add(:iban, "no es un IBAN válido según SEPA")
      end
    rescue => e
      Rails.logger.warn "SEPA IBAN validation failed: #{e.message}"
      # Si falla, continuamos con la validación básica
    end
  end

  # Validación específica para España
  if iban_limpio.start_with?('ES') && iban_limpio.length != 24
    errors.add(:iban, "debe tener 24 caracteres para IBANs españoles")
  end
end

def bic_valido
  return if bic.blank?

  bic_limpio = bic.gsub(/\s+/, "").upcase

  # Validación con SepaKing - FORMA CORRECTA
  if defined?(SEPA::BICValidator)
    begin
      temp_class = Class.new do
        include SEPA::BICValidator
        attr_accessor :bic
      end
      temp_instance = temp_class.new
      temp_instance.bic = bic_limpio

      unless temp_instance.valid_sepa_bic?
        errors.add(:bic, "no es un código BIC válido según SEPA")
      end
    rescue => e
      Rails.logger.warn "SEPA BIC validation failed: #{e.message}"
      # Si falla, continuamos con la validación básica
    end
  end

  # Validación básica de formato
  unless bic_limpio =~ /^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$/
    errors.add(:bic, "no tiene un formato BIC válido")
  end
end

end
