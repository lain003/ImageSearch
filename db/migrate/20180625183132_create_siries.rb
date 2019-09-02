class CreateSiries < ActiveRecord::Migration[5.1]
  def change
    create_table :siries do |t|
      t.string :name
      t.string :identifier

      t.timestamps
    end
    add_index :siries, [:name], :unique => true
    add_index :siries, [:identifier], :unique => true
  end
end
