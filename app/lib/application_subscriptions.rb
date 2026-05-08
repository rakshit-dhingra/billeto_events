class ApplicationSubscriptions
  def call
    event_store = Rails.configuration.event_store

    # Wire subscriptions from domain modules
    # Use begin/rescue to handle cases where constants might not be fully loaded
    begin
      [Voting, Events].each do |domain_module|
        domain_module.subscriptions.each do |subscription|
          handler = subscription[:handler]
          # Resolve handler if it's a lambda (deferred resolution)
          handler = handler.call if handler.is_a?(Proc)
          
          event_store.subscribe(
            handler,
            to: subscription[:events]
          )
        end
      end
    rescue NameError => e
      # If constants aren't loaded yet, log and silently continue
      Rails.logger.debug("ApplicationSubscriptions: Deferred loading - #{e.message}")
    end
  end

  private

  def event_store
    Rails.configuration.event_store
  end
end