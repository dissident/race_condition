class Promocode < ApplicationRecord
  has_one :user_transaction

  validates :code, uniqueness: true

  scope :active, -> { where(active: true) }

  def self.generate(amount)
    code = SecureRandom.urlsafe_base64(8, false)
    create(code: code, amount: amount, active: true)
  end

  def activate(user)
    self.active = false
    self.user_transaction = UserTransaction.new(
      amount: amount,
      user_balance: user.user_balance
    )
    save
  end
end
