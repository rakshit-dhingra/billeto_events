namespace :billetto do
  desc "Fetch and ingest events from Billetto API"
  task ingest: :environment do
    results = Events::IngestService.new.call
    puts "Done — created: #{results[:created]}, updated: #{results[:updated]}, failed: #{results[:failed]}"
  end
end