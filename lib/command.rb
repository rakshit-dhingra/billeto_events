# Command base pattern for domain-driven design
# Commands represent explicit requests to change state in the system.
# They encapsulate all necessary data and validation for an action.

module Command
  module Executable
    # Mixin for command classes that can be executed via the command bus
    # 
    # Usage:
    #   class MyCommand
    #     include Command::Executable
    #     attribute :user_id, String
    #     validates :user_id, presence: true
    #   end
    #
    # The command bus will call #call on the command instance
    
    def self.included(base)
      base.include ActiveModel::Model
      base.include ActiveModel::Attributes
    end

    def call
      raise NotImplementedError, "#{self.class} must implement #call method"
    end
  end
end
