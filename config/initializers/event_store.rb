Rails.configuration.event_store = RailsEventStore::Client.new(
  message_broker: RubyEventStore::Broker.new(
    subscriptions: RubyEventStore::Subscriptions.new,
    dispatcher: RubyEventStore::ComposedDispatcher.new(
      RailsEventStore::AfterCommitAsyncDispatcher.new(
        scheduler: RailsEventStore::ActiveJobScheduler.new(
          serializer: RubyEventStore::Serializers::YAML
        )
      ),
      RubyEventStore::Dispatcher.new
    )
  )
)