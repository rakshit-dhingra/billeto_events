require 'rails_helper'

RSpec.describe "Events", type: :request do
  describe "GET /billetto_events" do
    it "returns http success" do
      get "/billetto_events"
      expect(response).to have_http_status(:success)
    end
  end

end
