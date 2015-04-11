class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :key
      t.string :summary
      t.references :project_id, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
