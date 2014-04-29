require 'nicorepo/report'
require 'nicorepo/parser'
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

    def fetch(req_num, limit_page)
      @reports = fetch_recursively(req_num, limit_page)
    end

    def fetch_with_filtere(filter, req_num, limit_page)
      @reports = fetch_recursively(req_num, limit_page, filter)
    end

    private

    def fetch_recursively(req_num, limit_page, filter = nil, url = TOP_URL)
      return [] unless limit_page > 0

      # fetch current reports
      page = @parser.parse_page(url)
      begin
        reports = page[:reports_attrs].map { |attrs| Report.new(attrs) }
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
          next_reports = fetch_recursively(req_num - reports.size, limit_page - 1, filter, page[:next_url])
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
    def fetch(req_num, limit_page)
      fetch_with_filtere('video-upload', req_num, limit_page)
    end
  end

  class LiveReports < Reports
    def fetch(req_num, limit_page)
      fetch_with_filtere('live', req_num, limit_page)
    end
  end
end

