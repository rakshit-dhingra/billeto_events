module Voting
  class Service
    # Command handler — validates, enforces business rules, publishes events
    # No direct DB mutations here — state changes happen via events

    def upvote(cmd)
      validate!(cmd)

      event = BillettoEvent.find(cmd.billetto_event_id)

      event_store.publish(
        Voting::Events::EventUpvoted.new(
          data: {
            billetto_event_id: cmd.billetto_event_id,
            user_id: cmd.user_id,
            voted_at: Time.current
          },
          metadata: { causation_id: cmd.object_id.to_s }
        ),
        stream_name: event.stream_name
      )
    end

    def downvote(cmd)
      validate!(cmd)

      event = BillettoEvent.find(cmd.billetto_event_id)

      event_store.publish(
        Voting::Events::EventDownvoted.new(
          data: {
            billetto_event_id: cmd.billetto_event_id,
            user_id: cmd.user_id,
            voted_at: Time.current
          }
        ),
        stream_name: event.stream_name
      )
    end

    private

    def validate!(cmd)
      raise ArgumentError, cmd.errors.full_messages.join(", ") unless cmd.valid?
    end

    def event_store
      Rails.configuration.event_store
    end
  end
end