class VotesController < ApplicationController
  before_action :require_authentication!
  before_action :set_event

  def upvote
    handle_vote(Voting::Upvote)
  end

  def downvote
    handle_vote(Voting::Downvote)
  end

  def handle_vote(command_class)
    command = command_class.new(
      billetto_event_id: @event.id,
      user_id: current_user_id
    )
    command.call
    redirect_to billetto_events_path, notice: "Vote recorded!"
  rescue ArgumentError => e
    redirect_to billetto_events_path, alert: e.message
  end

  private

  def set_event
    @event = BillettoEvent.find(params[:billetto_event_id] || params[:id])
  end
end