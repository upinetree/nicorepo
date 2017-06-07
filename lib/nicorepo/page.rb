require 'nicorepo/request'

class Nicorepo
  class Page
    attr_reader :raw

    def initialize(session, filter, cursor = nil)
      @session = session
      @filter = filter
      @cursor = cursor

      fetch
    end

    def next
      fail 'Next page not found' unless @next_cursor

      self.class.new(@session, @filter, @next_cursor)
    end

    private

    def fetch
      json = Request::Timeline.fetch(@session, cursor: @cursor)

      @next_cursor = json['meta']['minId']
      @raw = json['data'].select { |r| @filter.accepts?(r['topic']) }
    end
  end
end
