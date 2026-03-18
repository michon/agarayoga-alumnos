# app/models/remesa.rb
class Remesa < ApplicationRecord
  has_many :recibos
  has_many :remesa_recibos

  validates :bloqueada, inclusion: { in: [true, false] }

  scope :bloqueadas, -> { where(bloqueada: true) }
  scope :activas, -> { where(bloqueada: false) }

  def bloquear!
    return if bloqueada?

    update!(
      bloqueada: true,
      fecha_emision: Time.current
    )
  end

  def desbloquear!
    return unless bloqueada?

    update!(
      bloqueada: false,
      fecha_emision: nil
    )
  end

  def puede_modificar_recibos?
    !bloqueada?
  end
end
