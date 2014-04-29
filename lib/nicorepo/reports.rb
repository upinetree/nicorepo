require 'nicorepo/report'

class Nicorepo
  class Reports
    class ReportsAccessError < StandardError; end

    TOP_URL = 'http://www.nicovideo.jp/my/top'
    PER_PAGE = 20

    def initialize(agent)
      @agent = agent
    end

    def all(req_num = PER_PAGE)
      page_nest_max = req_num / PER_PAGE + 1
      fetch(req_num, page_nest_max)
    end

    def videos(req_num = 3, page_nest_max = 5)
      filtered_by('video-upload', req_num, page_nest_max)
    end

    def lives(req_num = 3, page_nest_max = 5)
      filtered_by('live', req_num, page_nest_max)
    end

    def filtered_by(filter, req_num = PER_PAGE, page_nest_max = 1)
      fetch(req_num, page_nest_max, filter)
    end

    private

    def fetch(req_num, page_nest_max, filter = nil, url = TOP_URL)
      return [] unless page_nest_max > 0

      # fetch current reports
      page = @agent.get(url)
      begin
        reports = report_nodes(page).map { |node| Report.new(node) }
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
          next_url = page.search('a.next-page-link').first['href']
          next_reports = fetch(req_num - reports.size, page_nest_max - 1, filter, next_url)
        rescue
          return reports
        else
          reports += next_reports unless next_reports.nil?
        end
      end

      return reports
    end

    def report_nodes(page)
      page.search('div.timeline/div.log')
    end
  end
end
