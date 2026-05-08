module Events
  # Events domain module
  # Aggregates all event-related commands, events, and handlers
  
  def self.subscriptions
     [].reduce(&:merge)
  end
end
