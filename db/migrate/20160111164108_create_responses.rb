class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
   	  t.references :user
      t.references :question
      t.integer :response
      t.timestamps null: false
    end
  end
end