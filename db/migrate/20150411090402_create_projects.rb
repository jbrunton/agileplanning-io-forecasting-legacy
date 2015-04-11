class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :domain
      t.string :board_id
      t.string :name

      t.timestamps null: false
    end
  end
end
