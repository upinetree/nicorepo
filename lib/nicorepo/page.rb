require 'nicorepo/client'

class Nicorepo
  class Page
    def initialize(session, filter, cursor = nil)
      @session = session
      @filter = filter
      @cursor = cursor
    end

    def reports
      @reports ||= (
        json = Nicorepo::Client::Timeline.fetch(@session, cursor: @cursor)
        @next_cursor = json['meta']['minId']

        json['data'].select { |r| @filter.accepts?(r['topic']) }
      )
    end

    def next
      fail 'Next page not found' unless @next_cursor

      self.class.new(@session, @filter, @next_cursor)
    end
  end
end
