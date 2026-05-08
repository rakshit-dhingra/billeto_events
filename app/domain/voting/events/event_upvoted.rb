module Voting
  module Events
    class EventUpvoted < Fact
      SCHEMA = {
        billetto_event_id: Integer,
        user_id: String,
        voted_at: Time
      }.freeze

      def stream_names
        [
          "BillettoEvent$#{data.fetch(:billetto_event_id)}",
          "User$#{data.fetch(:user_id)}"
        ]
      end
    end
  end
end