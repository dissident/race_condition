class CreateUserTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_transactions do |t|
      t.integer :amount
      t.boolean :finished
      t.references :user_balance, foreign_key: true
      t.references :promocode, foreign_key: true

      t.timestamps
    end
  end
end
