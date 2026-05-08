# Fact base class for domain events in event sourcing
# Facts are immutable records of what happened in the system
# They follow Billetto's pattern with SCHEMA for validation and stream_names for routing

class Fact < RailsEventStore::Event
  # Base class for all domain events (Facts)
  # Provides schema validation and stream name routing
  
  # Must be defined by subclasses to enforce structure
  # Example:
  #   SCHEMA = {
  #     user_id: String,
  #     event_id: String
  #   }.freeze
  
  def self.inherited(subclass)
    super
    # Ensure subclass defines SCHEMA
    unless subclass.const_defined?(:SCHEMA, false)
      # SCHEMA can be defined by subclass - not required to be inherited
    end
  end

  def self.strict(data:)
    # Factory method to create and validate a Fact with schema enforcement
    instance = new(data: data)
    instance.validate_schema! if instance.class.const_defined?(:SCHEMA)
    instance
  end

  def validate_schema!
    schema = self.class.const_get(:SCHEMA)
    schema.each do |key, type|
      value = data.fetch(key)
      unless value.is_a?(type)
        raise TypeError, "#{self.class}##{key} must be #{type}, got #{value.class}"
      end
    end
  end

  # Must be implemented by subclasses to define which streams this fact belongs to
  # Example: def stream_names = ["Event$#{data[:event_id]}", "User$#{data[:user_id]}"]
  def stream_names
    raise NotImplementedError, "#{self.class} must implement #stream_names"
  end
end
