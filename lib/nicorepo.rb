require 'mechanize'
require 'nicorepo/report'

class Nicorepo

  class LoginError < StandardError; end
  class ReportsAccessError < StandardError; end

  LOGIN_URL = 'https://secure.nicovideo.jp/secure/login?site=niconico'
  TOP_URL = 'http://www.nicovideo.jp/my/top'
  LOGS_PER_PAGE = 20

  attr_reader :agent

  def initialize
    @agent = Mechanize.new
    @agent.ssl_version = 'SSLv3'
    @agent.request_headers = { 'accept-language' => 'ja-JP', 'content-language' => 'ja-JP' }
  end

  def login(mail, pass)
    page = @agent.post(LOGIN_URL, mail: mail, password: pass)
    raise LoginError, "Failed to login" if page.header["x-niconico-authflag"] == '0'
  end

  def all(req_num = LOGS_PER_PAGE)
    page_nest_max = req_num / LOGS_PER_PAGE + 1
    fetch(req_num, page_nest_max)
  end

  def videos(req_num = 3, page_nest_max = 5)
    filtered_by('video-upload', req_num, page_nest_max)
  end

  def lives(req_num = 3, page_nest_max = 5)
    filtered_by('live', req_num, page_nest_max)
  end

  def filtered_by(filter, req_num = LOGS_PER_PAGE, page_nest_max = 1)
    fetch(req_num, page_nest_max, filter)
  end

  private

  # TODO: Reportsに移譲
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

    # fetch next reports
    if reports.size < req_num then
      next_url = page.search('div.next-page/a').first['href']
      begin
        next_reports = fetch(req_num - reports.size, page_nest_max - 1, filter, next_url)
      rescue
        warn '*** reports access error occurs ***'
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

require "nicorepo/version"
require 'nicorepo/cli/cli'
require 'nicorepo/cli/config'
