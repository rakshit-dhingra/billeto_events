# Injector for Rails Event Store access in domain objects
# Provides a clean way for domain objects to publish events

module EventStoreInjector
  # Mixin for domain objects that need to publish events to the event store
  # 
  # Usage:
  #   class MyAggregate
  #     include EventStoreInjector
  #     
  #     def perform_action(user_id)
  #       event_store.publish(MyEvent.strict(data: {...}))
  #     end
  #   end
  
  def event_store
    Rails.configuration.event_store
  end
end
