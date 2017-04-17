class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.text :question
      t.string :image_location
      t.string :content_type
      t.integer :answer
      t.string :type
      t.timestamps null: false
    end
  end
end