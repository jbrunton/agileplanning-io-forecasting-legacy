class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :key
      t.string :summary
      t.string :issue_type
      t.references :dashboard, index: true, foreign_key: true
      t.string :epic_key, index: true
      t.string :epic_status
      t.integer :story_points

      t.timestamp :started
      t.timestamp :completed

      t.timestamps null: false
    end
  end
end
