class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name
      t.string :domain
      t.datetime :last_synced

      t.timestamps null: false
    end
  end
end
