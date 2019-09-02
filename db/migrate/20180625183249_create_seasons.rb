class CreateSeasons < ActiveRecord::Migration[5.1]
  def change
    create_table :seasons do |t|
      t.references :siry, foreign_key: true
      t.integer :serial

      t.timestamps
    end

    add_index :seasons, [:serial]
  end
end
