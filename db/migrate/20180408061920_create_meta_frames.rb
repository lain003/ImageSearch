class CreateMetaFrames < ActiveRecord::Migration[5.1]
  def change
    create_table :meta_frames do |t|
      t.references :movie, foreign_key: true
      t.float :start_sec, null: false
      t.float :end_sec, null: false
      t.string :text, null: false
      t.integer :image_num, null: false

      t.timestamps
    end

    add_index :meta_frames, :start_sec
  end
end
