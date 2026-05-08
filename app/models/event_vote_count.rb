class EventVoteCount < ApplicationRecord
  belongs_to :billetto_event, foreign_key: :event_id

  validates :event_id, presence: true, uniqueness: true
  validates :upvotes, :downvotes, numericality: { greater_than_or_equal_to: 0 }
end