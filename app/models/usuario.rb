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

  scope :activo, -> {where(debaja: false)}

  scope :inactivos, -> {where(debaja: true)}
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
end
