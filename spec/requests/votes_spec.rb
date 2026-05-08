require 'rails_helper'

RSpec.describe "Votes", type: :request do
  let(:billetto_event) { create(:billetto_event) }
  let(:clerk_user_id) { "user_abc123" }

  describe "POST /billetto_events/:id/upvote" do
    context 'when unauthenticated' do
      it 'redirects to sign in' do
        post upvote_billetto_event_path(billetto_event)
        expect(response).to redirect_to(sign_in_path)
      end
    end

    context 'when authenticated' do
      before do
        sign_in_as_clerk_user(clerk_user_id)
      end

      it 'records an upvote event and redirects' do
        expect {
          post upvote_billetto_event_path(billetto_event), 
               headers: { "Authorization" => "Bearer test_token" }
        }.to change {
          Rails.configuration.event_store
            .read.stream(billetto_event.stream_name).count
        }.by(1)

        expect(response).to redirect_to(billetto_events_path)
      end
    end
  end
end