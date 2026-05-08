# Handler base pattern for event handlers and process managers
# Handlers are called asynchronously to maintain read models and trigger side effects

module Handler
  # Mixin for creating async event handlers using Sidekiq
  # 
  # Usage:
  #   class VoteCounter
  #     include Handler.async(queue: "low")
  #     subscribes_to Voting::EventUpvoted
  #     
  #     def call(event)
  #       # Update read model based on event
  #     end
  #   end
  
  def self.async(queue: "default", options: {})
    Module.new do
      include Sidekiq::Worker
      sidekiq_options({ queue: queue }.merge(options))
      
      define_method(:perform) do |event_data|
        # Reconstruct the event from serialized data
        event = RailsEventStore::Serializers::YAML.load(event_data)
        call(event)
      end
    end
  end

  # Class-level method to declare which events a handler subscribes to
  def self.subscribes_to(*event_types)
    define_method(:subscribed_to?) do |event_class|
      event_types.any? { |et| event_class.is_a?(Class) && event_class <= et }
    end
  end
end

# Make subscribes_to available as a class method
module HandlerMacro
  def subscribes_to(*event_types)
    @subscribed_events = event_types
  end

  def subscribed_events
    @subscribed_events || []
  end
end
