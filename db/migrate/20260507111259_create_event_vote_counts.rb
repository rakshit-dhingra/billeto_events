class CreateEventVoteCounts < ActiveRecord::Migration[7.1]
  def change
    create_table :event_vote_counts do |t|
      t.integer :event_id,   null: false
      t.integer :upvotes,    default: 0, null: false
      t.integer :downvotes,  default: 0, null: false
      t.timestamps
    end
    add_index :event_vote_counts, :event_id, unique: true
  end
end
