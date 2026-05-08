module Voting
  # Voting domain module
  # Aggregates all voting-related commands, events, and handlers
  
  def self.subscriptions
    [
      {
        handler: -> { VoteCounter },
        events: [
          Voting::Events::EventUpvoted,
          Voting::Events::EventDownvoted
        ]
      }
    ]
  end
end
