require 'nicorepo/report'
require 'forwardable'

class Nicorepo
  class Reports
    extend Forwardable

    class ReportsAccessError < StandardError; end

    TOP_URL = 'http://www.nicovideo.jp/my/top'

    attr_reader :reports
    def_delegators :@reports, :size

    def initialize(parser)
      @parser = parser
      @reports = []
    end

    def fetch(req_num, page_nest_max)
      @reports = fetch_recursively(req_num, page_nest_max)
    end

    def fetch_with_filtere(filter, req_num, page_nest_max)
      @reports = fetch_recursively(req_num, page_nest_max, filter)
    end

    private

    def fetch_recursively(req_num, page_nest_max, filter = nil, url = TOP_URL)
      return [] unless page_nest_max > 0

      # fetch current reports
      page = @parser.parse_page(url)
      begin
        reports = page[:nodes].map { |node| Report.new(node) }
      rescue
        raise ReportsAccessError
      end
      reports.select!{ |report| report.kind =~ /#{filter}/ } if filter

      if reports.size > req_num then
        return reports[0, req_num]
      end

      # recursively fetch next reports
      if reports.size < req_num then
        begin
          next_reports = fetch_recursively(req_num - reports.size, page_nest_max - 1, filter, page[:next_url])
        rescue
          return reports
        else
          reports += next_reports unless next_reports.nil?
        end
      end

      return reports
    end
  end

  class VideoReports < Reports
    def fetch(req_num, page_nest_max)
      fetch_with_filtere('video-upload', req_num, page_nest_max)
    end
  end

  class LiveReports < Reports
    def fetch(req_num, page_nest_max)
      fetch_with_filtere('live', req_num, page_nest_max)
    end
  end
end
