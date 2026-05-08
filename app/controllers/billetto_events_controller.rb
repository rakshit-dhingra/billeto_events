class BillettoEventsController < ApplicationController
  def index
    @events = BillettoEvent.upcoming.with_vote_counts
  end

  def show
    @event = BillettoEvent.find(params[:id])
  end
end