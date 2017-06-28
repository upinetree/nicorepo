require 'nicorepo/request'

class Nicorepo
  class Page
    attr_reader :raw

    def initialize(session, filter, from = nil, to = nil)
      @session = session
      @filter = filter
      @cursor = Cursor.new(from).value
      @min_cursor = Cursor.new(to).value

      fetch
    end

    def next
      fail 'Next page not found' if last_page?

      self.class.new(@session, @filter, @next_cursor, @min_cursor)
    end

    def last_page?
      return false unless @min_cursor && @next_cursor

      @min_cursor > @next_cursor
    end

    private

    def fetch
      json = Request::Timeline.fetch(@session, cursor: @cursor)

      @next_cursor = json['meta']['minId']
      @raw = json['data'].select { |data| @filter.accepts?(data) }
    end

    class Cursor
      attr_reader :value

      def initialize(time_or_cursor)
        @value = cursor?(time_or_cursor) ? time_or_cursor : value_from_time(time_or_cursor)
      end

      def to_s
        @value
      end

      private

      def value_from_time(time)
        return unless time

        time = Time.parse(time) if time === String
        (time.to_f * 1000).floor.to_s
      end

      def cursor?(value)
        value === String && cursor.match?(/\A\d{13}\z/)
      end
    end
  end
end
