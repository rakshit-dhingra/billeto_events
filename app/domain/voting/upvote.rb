module Voting
  # Command: Upvote an event
  # Validates preconditions and delegates to command handler
  class Upvote
    include Command::Executable

    attribute :billetto_event_id, :integer
    attribute :user_id, :string

    validates :billetto_event_id, :user_id, presence: true

    def call
      raise ArgumentError, errors.full_messages.join(", ") unless valid?

      event = BillettoEvent.find(billetto_event_id)

      event_store.publish(
        Voting::Events::EventUpvoted.strict(
          data: {
            billetto_event_id: billetto_event_id,
            user_id: user_id,
            voted_at: Time.current
          }
        ),
        stream_name: event.stream_name
      )
    end

    private

    def event_store
      Rails.configuration.event_store
    end
  end
end