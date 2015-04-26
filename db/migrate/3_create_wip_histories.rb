class CreateWipHistories < ActiveRecord::Migration
  def change
    create_table :wip_histories do |t|
      t.date :date
      t.belongs_to :issue, index: true

      t.timestamps null: false
    end
  end
end