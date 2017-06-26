class Nicorepo
  module Filter
    module_function def generate(type_or_topic, options = {})
      case type_or_topic
      when :all
        Nicorepo::Filter::All.new(options)
      when :videos
        Nicorepo::Filter::Equal.new('nicovideo.user.video.upload', options)
      when :lives
        Nicorepo::Filter::Match.new(/^live/, options)
      when String
        Nicorepo::Filter::Equal.new(type_or_topic, options)
      when Regex
        Nicorepo::Filter::Match.new(type_or_topic, options)
      else
        fail "Given type or topic #{type_or_topic} is not supported"
      end
    end

    class All
      def initialize(options)
      end

      def accepts?(_topic)
        true
      end
    end

    class Equal
      def initialize(topic, options)
        @topic = topic
      end

      def accepts?(topic)
        topic == @topic
      end
    end

    class Match
      def initialize(topic_regexp, options)
        @topic_regexp = topic_regexp
      end

      def accepts?(topic)
        topic =~ @topic_regexp
      end
    end
  end
end
