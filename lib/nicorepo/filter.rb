module Nicorepo
  class Filter
    def initialize(type_or_topic, options = {})
      @rules = [].tap do |r|
        r << (
          case type_or_topic
          when :all
            All.new
          when :videos
            Equal.new('nicovideo.user.video.upload')
          when :lives
            Match.new(/^live/)
          when String
            Equal.new(type_or_topic)
          when Regex
            Match.new(type_or_topic)
          else
            fail "Given type or topic #{type_or_topic} is not supported"
          end
        )

        r << MinTime.new(options[:min_time]) if options[:min_time]
      end
    end

    def accepts?(data)
      @rules.all? { |r| r.accepts?(data) }
    end

    class MinTime
      def initialize(min_time)
        @min_time = min_time
      end

      def accepts?(data)
        Time.parse(data['createdAt']) > @min_time
      end
    end

    class All
      def accepts?(_)
        true
      end
    end

    class Equal
      def initialize(topic)
        @topic = topic
      end

      def accepts?(data)
        data['topic'] == @topic
      end
    end

    class Match
      def initialize(topic_regexp)
        @topic_regexp = topic_regexp
      end

      def accepts?(data)
        data['topic'] =~ @topic_regexp
      end
    end
  end
end
