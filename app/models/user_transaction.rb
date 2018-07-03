class UserTransaction < ApplicationRecord
  belongs_to :promocode
  belongs_to :user_balance

  after_create :change_balance

  private

  def change_balance
    balance = user_balance.amount + amount
    user_balance.update_attributes(amount: balance)
    self.finished = true
    save
  end
end
