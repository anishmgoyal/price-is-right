class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :nickname
      t.integer :last_tick
      t.timestamps null: false
    end
  end
end