require 'rails_helper'

RSpec.describe 'VoteCounter' do
  let(:handler) { ReadModels::VoteCounter.new }
  let(:billetto_event) { create(:billetto_event) }

  def upvote_event
    Voting::Events::EventUpvoted.new(data: {
      billetto_event_id: billetto_event.id,
      user_id: "user_123",
      voted_at: Time.current
    })
  end

  def downvote_event
    Voting::Events::EventDownvoted.new(data: {
      billetto_event_id: billetto_event.id,
      user_id: "user_456",
      voted_at: Time.current
    })
  end

  it 'increments upvotes on EventUpvoted' do
    handler.call(upvote_event)

    count = EventVoteCount.find_by!(event_id: billetto_event.id)
    expect(count.upvotes).to eq(1)
    expect(count.downvotes).to eq(0)
  end

  it 'increments downvotes on EventDownvoted' do
    handler.call(downvote_event)

    count = EventVoteCount.find_by!(event_id: billetto_event.id)
    expect(count.downvotes).to eq(1)
  end

  it 'accumulates multiple votes correctly' do
    3.times { handler.call(upvote_event) }
    2.times { handler.call(downvote_event) }

    count = EventVoteCount.find_by!(event_id: billetto_event.id)
    expect(count.upvotes).to eq(3)
    expect(count.downvotes).to eq(2)
  end

  it 'handles concurrent votes without corruption' do
    threads = 10.times.map do
      Thread.new { handler.call(upvote_event) }
    end
    threads.each(&:join)

    expect(EventVoteCount.find_by!(event_id: billetto_event.id).upvotes).to eq(10)
  end
end