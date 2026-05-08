require 'rails_helper'

RSpec.describe Billetto::Client do
  subject(:client) { described_class.new(api_key: "test_key") }

  describe '#list_events' do
    context 'with a successful response' do
      before do
        stub_request(:get, %r{https://api.billetto.com(/v3)?/events/public})
          .to_return(
            status: 200,
            body: { data: [{ id: 1, title: "Jazz Night", starts_at: 1.week.from_now.iso8601 }] }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns parsed event data' do
        result = client.list_events
        expect(result[:data]).to be_an(Array)
        expect(result[:data].first[:title]).to eq("Jazz Night")
      end
    end

    context 'with a 401 response' do
      before do
        stub_request(:get, %r{https://api.billetto.com}).to_return(status: 401)
      end

      it 'raises AuthenticationError' do
        expect { client.list_events }.to raise_error(Billetto::Client::AuthenticationError)
      end
    end

    context 'with a 429 rate limit response' do
      before do
        stub_request(:get, %r{https://api.billetto.com}).to_return(status: 429)
      end

      it 'raises RateLimitError' do
        expect { client.list_events }.to raise_error(Billetto::Client::RateLimitError)
      end
    end
  end
end