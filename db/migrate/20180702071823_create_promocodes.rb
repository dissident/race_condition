class CreatePromocodes < ActiveRecord::Migration[5.2]
  def change
    create_table :promocodes do |t|
      t.string :code
      t.integer :amount
      t.boolean :active

      t.timestamps
    end
  end
end
