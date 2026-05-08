module Billetto
  # Maps raw API response shape to our domain attributes.
  # Isolates us from Billetto's API changing field names.

  class EventMapper
    def self.to_domain(raw)
      {
        external_id: raw.fetch(:id).to_s,
        title:       raw.fetch(:title),
        description: raw[:description]&.truncate(500),
        image_url:   raw.dig(:cover_image, :url),
        starts_at:   parse_time(raw[:starts_at]),
        ends_at:     parse_time(raw[:ends_at]),
        location:    build_location(raw[:location]),
        url:         raw[:url],
        status:      raw[:status]
      }
    end

    def self.parse_time(value)
      Time.zone.parse(value) if value.present?
    end

    def self.build_location(loc)
      return nil unless loc
      [loc[:address], loc[:city], loc[:country]].compact.join(", ")
    end
  end
end