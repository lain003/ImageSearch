class CreateEditedGifs < ActiveRecord::Migration[5.1]
  def change
    create_table :edited_gifs do |t|
      t.string :file_name
      t.belongs_to :meta_frame, foreign_key: true
      t.integer :start_frame
      t.integer :end_frame

      t.timestamps
    end
  end
end
