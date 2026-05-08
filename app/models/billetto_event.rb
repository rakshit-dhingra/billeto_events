class BillettoEvent < ApplicationRecord

  self.table_name = "events"
  has_one :event_vote_count, dependent: :destroy

  validates :external_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :starts_at, presence: true

  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :with_vote_counts, -> { includes(:event_vote_count) }

  def stream_name
    "BillettoEvent$#{id}"
  end

  def upvotes
    event_vote_count&.upvotes || 0
  end

  def downvotes
    event_vote_count&.downvotes || 0
  end
end