module ReadModels
  # Async handler — subscribed to vote events.
  # Maintains a denormalized count table for fast reads.
  # Can be rebuilt at any time by replaying events from the stream.
  
  class VoteCounter
    extend HandlerMacro
    include Handler.async(queue: "low")

    subscribes_to Voting::Events::EventUpvoted, Voting::Events::EventDownvoted

    def call(event)
      event_id = event.data.fetch(:billetto_event_id)

      # Ensure record exists first - use find_or_create_by which handles race conditions
      ::EventVoteCount.find_or_create_by(event_id: event_id) rescue ::EventVoteCount.find_by(event_id: event_id)

      # Use atomic update_counters for thread-safe increments
      case event
      when Voting::Events::EventUpvoted
        ::EventVoteCount.where(event_id: event_id).update_counters(upvotes: 1)
      when Voting::Events::EventDownvoted
        ::EventVoteCount.where(event_id: event_id).update_counters(downvotes: 1)
      end
    end
  end
end