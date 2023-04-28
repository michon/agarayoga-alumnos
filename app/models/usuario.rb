class Usuario < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  belongs_to :grupoAlumno
  has_many :horarioAlumno
  has_many :recibos
  has_many :cajas
  has_one :instructor
  has_one_attached :image, :dependent => :destroy

  scope :activo, -> {where(debaja: false)}
  scope :inactivos, -> {where(debaja: true)}
  default_scope { order(nombre: :asc) }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum rol: [:yogui, :instructor, :admin, :michon]

  after_initialize :set_default_rol, :if => :new_record?

  def set_default_rol
    sef_rol ||= :usuario
  end
  def ibanImpreso
      ibanImp = ""
      (self.iban.length/4).times do |i|
        ibanImp <<  self.iban[(i*4)..(i*4)+3] + " "
      end
      ibanImp
  end
end
