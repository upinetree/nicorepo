require 'nicorepo/report'
require 'forwardable'

class Nicorepo
  class Reports
    extend Forwardable

    TOP_URL = 'http://www.nicovideo.jp/my/top'

    attr_reader :reports
    def_delegators :@reports, :size

    def initialize(parser)
      @parser = parser
      @reports = []
    end

    def fetch(request_num, limit_page, since: nil)
      filter = {}
      filter[:kind] = selected_kind
      filter[:since] =
        case since
        when String
          Time.parse since
        when Time
          since
        else
          nil
        end
      @reports = fetch_recursively(request_num, limit_page, filter)
    end

    private

    def selected_kind
      nil
    end

    def fetch_recursively(request_num, limit_page, filter = {}, url = TOP_URL)
      return [] unless limit_page > 0

      # fetch current page reports
      page = @parser.parse_page(url)
      reports = page[:reports_attrs].map { |attrs| Report.new(attrs) }

      if filter[:since]
        reach_oldest_page = (reports.last.date < filter[:since])
        reports.reject! { |report| report.date < filter[:since] }
      end
      reports.select! { |report| report.kind =~ /#{filter[:kind]}|#{Report::ERROR_KIND}/ } if filter[:kind]

      return reports[0, request_num] if reports.size >= request_num
      return reports if filter[:since] && reach_oldest_page

      # recursively fetch next reports
      next_reports = fetch_recursively(request_num - reports.size, limit_page - 1, filter, page[:next_url])
      reports += next_reports unless next_reports.nil?
      reports
    end
  end

  class VideoReports < Reports
    private

    def selected_kind
      'video-upload'
    end
  end

  class LiveReports < Reports
    private

    def selected_kind
      'live'
    end
  end
end

