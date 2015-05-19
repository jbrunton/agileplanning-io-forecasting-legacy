class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :key
      t.string :summary
      t.string :issue_type
      t.string :size
      t.references :project, index: true, foreign_key: true
      t.string :epic_key, index: true
      t.string :epic_status

      t.timestamp :started
      t.timestamp :completed

      t.timestamps null: false
    end
  end
end
