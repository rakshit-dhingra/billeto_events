class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string  :external_id, null: false
      t.string  :title,       null: false
      t.text    :description
      t.string  :image_url
      t.datetime :starts_at
      t.datetime :ends_at
      t.string  :location
      t.string  :url
      t.string  :status
      t.timestamps
    end
    add_index :events, :external_id, unique: true
  end
end
