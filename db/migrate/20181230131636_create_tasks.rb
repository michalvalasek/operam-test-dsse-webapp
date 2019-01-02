class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :phone_number, null: false
      t.string :cloud_function, null: false
      t.boolean :response_processed, default: false
      t.text :response_text

      t.timestamps null: false
    end
  end
end
