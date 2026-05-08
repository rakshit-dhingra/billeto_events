require 'rails_helper'

RSpec.describe Voting::Service do
  subject(:service) { described_class.new }

  let(:billetto_event) { create(:billetto_event) }
  let(:user_id)        { "user_clerk_abc123" }
  let(:event_store)    { Rails.configuration.event_store }

  describe '#upvote' do
    let(:cmd) { Voting::Upvote.new(billetto_event_id: billetto_event.id, user_id: user_id) }

    it 'publishes an EventUpvoted fact to the correct stream' do
      service.upvote(cmd)

      events = event_store.read.stream(billetto_event.stream_name).to_a
      expect(events.size).to eq(1)
      expect(events.last).to be_a(Voting::Events::EventUpvoted)
    end

    it 'stores user_id in the event data for traceability' do
      service.upvote(cmd)

      fact = event_store.read.stream(billetto_event.stream_name).last
      expect(fact.data[:user_id]).to eq(user_id)
    end

    it 'raises ArgumentError when command is invalid' do
      bad_cmd = Voting::Upvote.new(billetto_event_id: nil, user_id: nil)
      expect { service.upvote(bad_cmd) }.to raise_error(ArgumentError)
    end

    it 'raises ActiveRecord::RecordNotFound for non-existent event' do
      bad_cmd = Voting::Upvote.new(billetto_event_id: 99999, user_id: user_id)
      expect { service.upvote(bad_cmd) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe '#downvote' do
    let(:cmd) { Voting::Downvote.new(billetto_event_id: billetto_event.id, user_id: user_id) }

    it 'publishes an EventDownvoted fact' do
      service.downvote(cmd)

      fact = event_store.read.stream(billetto_event.stream_name).last
      expect(fact).to be_a(Voting::Events::EventDownvoted)
    end
  end
end