class UserBalance < ApplicationRecord
  belongs_to :user
  has_many :user_transactions

  def self.generate(user_id)
    create(user_id: user_id, amount: 0)
  end
end
