class CreateMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :movies do |t|
      t.references :season, foreign_key: true
      t.integer :ep_num

      t.timestamps
    end

    add_index :movies, [:id,:ep_num], :unique => true
    add_index :movies, [:ep_num]
  end
end
