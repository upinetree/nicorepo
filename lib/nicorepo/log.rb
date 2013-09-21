class Nicorepo

  class Log
    attr_accessor :body, :title, :url, :author, :kind, :date

    def initialize(node = nil)
      if node.nil? then return end
      @body   = parse_body   node
      @title  = parse_title  node
      @url    = parse_url    node
      @author = parse_author node
      @kind   = parse_kind   node
      @date   = parse_date   node
    end

    private

    def parse_body(node)
      node.search('div.log-body').first.inner_text.gsub(/(\t|\r|\n)/, "")
    end

    def parse_title(node)
      node.search('div.log-target-info/a').first.inner_text
    end

    def parse_url(node)
      node.search('div.log-target-info/a').first['href']
    end

    def parse_author(node)
      node.search('div.log-body/a').first.inner_text
    end

    # example: 'log.log-community-video-upload' -> 'community-video-upload'
    def parse_kind(node)
      cls = node['class']
      trim = 'log-'

      index = cls.index(/#{trim}/)
      return cls if index.nil?

      index += trim.size
      cls[index..cls.size]
    end

    def parse_date(node)
      d = node.search('div.log-footer/div.log-footer-inner/a.log-footer-date/time').first['datetime']
      Time.xmlschema(d).localtime
    end
 
  end

end
