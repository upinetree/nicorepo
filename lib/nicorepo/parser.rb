# TODO: Romove in next version

class Nicorepo
  class Parser
    def initialize(agent)
      @agent = agent
    end

    def parse_page(url)
      page = @agent.get(url)
      {
        reports_attrs: parse_reports(page),
        next_url: next_url(page)
      }
    end

    private

    def parse_reports(page)
      nodes = report_nodes(page)
      nodes.map { |node| report_attrs(node) }
    end

    def report_attrs(node)
      {
        body:   parse_body(node),
        title:  parse_title(node),
        url:    parse_url(node),
        author: parse_author(node),
        kind:   parse_kind(node),
        date:   parse_date(node)
      }
    rescue => e
      error_report(node, e)
    end

    def report_nodes(page)
      page.search('.timeline/.log')
    end

    def next_url(page)
      page.search('.next-page-link').first['href']
    end

    def parse_body(node)
      node.search('.log-body').first.inner_text.gsub(/(\t|\r|\n)/, "")
    end

    def parse_title(node)
      node.search('.log-target-info/a').first.inner_text
    end

    def parse_url(node)
      node.search('.log-target-info/a').first['href']
    end

    def parse_author(node)
      node.search('.log-body/a').first.inner_text
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
      d = node.search('.log-footer-date/time').first['datetime']
      Time.xmlschema(d).localtime
    end

    def error_report(node, e)
      {
        body:   node.inner_html.gsub(/\r|\n|\t/, ''),
        title:  "An exception occured: #{e.message}\n#{e.backtrace}",
        url:    '',
        author: '',
        kind:   Report::ERROR_KIND,
        date:   ''
      }
    end
  end
end
