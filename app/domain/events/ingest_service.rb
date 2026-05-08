module Events
  class IngestService
    def initialize(client: Billetto::Client.new)
      @client = client
    end

    def call(cmd = nil)
      page = 1
      results = { created: 0, updated: 0, failed: 0, errors: [] }

      loop do
        response = client.list_events(page: page, per_page: 50)
        raw_events = response[:data] || []
        break if raw_events.empty?

        raw_events.each { |raw| upsert(raw, results) }

        break unless response.dig(:meta, :next_page)
        page += 1
      end

      Rails.logger.info("[IngestService] Done: #{results.slice(:created, :updated, :failed)}")
      results
    rescue Billetto::Client::RateLimitError => e
      Rails.logger.warn("[IngestService] Rate limited: #{e.message}")
      results.merge(error: e.message)
    rescue Billetto::Client::Error => e
      Rails.logger.error("[IngestService] API error: #{e.message}")
      raise
    end

    private

    attr_reader :client

    def upsert(raw, results)
      attrs = Billetto::EventMapper.to_domain(raw)
      record = BillettoEvent.find_or_initialize_by(external_id: attrs[:external_id])

      if record.update(attrs)
        record.previously_new_record? ? results[:created] += 1 : results[:updated] += 1
      else
        results[:failed] += 1
        results[:errors] << { id: attrs[:external_id], errors: record.errors.full_messages }
      end
    end
  end
end