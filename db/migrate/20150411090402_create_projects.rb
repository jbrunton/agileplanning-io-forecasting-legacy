class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :domain
      t.integer :board_id
      t.string :name

      t.timestamps null: false
    end
  end
end
