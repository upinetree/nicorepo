class Nicorepo
  module Filter
    module_function def generate(type_or_topic, params = {})
      case type_or_topic
      when :all
        Nicorepo::Filter::All.new(params)
      when :videos
        Nicorepo::Filter::Equal.new('nicovideo.user.video.upload', params)
      when :lives
        Nicorepo::Filter::Match.new(/^live/, params)
      when String
        Nicorepo::Filter::Equal.new(type_or_topic, params)
      when Regex
        Nicorepo::Filter::Match.new(type_or_topic, params)
      else
        fail "Given type or topic #{type_or_topic} is not supported"
      end
    end

    class All
      def initialize(params)
      end

      def accepts?(_topic)
        true
      end
    end

    class Equal
      def initialize(topic, params)
        @topic = topic
      end

      def accepts?(topic)
        topic == @topic
      end
    end

    class Match
      def initialize(topic_regexp, params)
        @topic_regexp = topic_regexp
      end

      def accepts?(topic)
        topic =~ @topic_regexp
      end
    end
  end
end
