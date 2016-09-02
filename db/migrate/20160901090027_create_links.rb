class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.string :title
      t.string :link
      t.string :favicon
      t.text :description
      t.string :image
      t.string :embed
      t.integer :song_id
      t.belongs_to :song, foreign_key: true

      t.timestamps
    end
  end
end
