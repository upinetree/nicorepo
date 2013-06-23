require 'mechanize'
require_relative 'nicorepo/log.rb'

class Nicorepo

  module URL
    LOGIN = 'https://secure.nicovideo.jp/secure/login?site=niconico'
    REPO_ALL = 'http://rd.nicovideo.jp/cc/my/zerotopall'
  end

  class LoginError < StandardError; end
  class LogsAccessError < StandardError; end

  LOGS_PER_PAGE = 20

  attr_reader :agent

  def initialize
    @agent = Mechanize.new
    @agent.ssl_version = 'SSLv3'
    @agent.request_headers = { 'accept-language' => 'ja-JP', 'content-language' => 'ja-JP' }
  end

  def login(mail, pass)
    page = @agent.post(URL::LOGIN, mail: mail, password: pass)
    raise LoginError, "Failed to login" if page.header["x-niconico-authflag"] == '0'
  end

  def all(req_num = LOGS_PER_PAGE)
    page_nest_max = req_num / LOGS_PER_PAGE + 1
    fetch_logs(req_num, page_nest_max)
  end

  def videos(req_num = 3, page_nest_max = 5)
    filtered_by('video-upload', req_num, page_nest_max)
  end

  def lives(req_num = 3, page_nest_max = 5)
    filtered_by('live', req_num, page_nest_max)
  end

  def filtered_by(filter, req_num = LOGS_PER_PAGE, page_nest_max = 1)
    fetch_logs(req_num, page_nest_max, filter)
  end

  private

  def fetch_logs(req_num, page_nest_max, filter = nil, url = URL::REPO_ALL)
    return [] unless page_nest_max > 0

    # fetch current logs
    page = @agent.get(url)
    begin
      logs = log_nodes(page).map { |node| Log.new(node) }
    rescue
      raise LogsAccessError
    end
    logs.select!{ |log| log.kind =~ /#{filter}/ } if filter

    if logs.size > req_num then
      return logs[0, req_num]
    end

    # fetch next logs
    if logs.size < req_num then
      next_url = page.search('div.next-page/a').first['href']
      begin
        next_logs = fetch_logs(req_num - logs.size, page_nest_max - 1, filter, next_url)
      rescue
        warn '*** logs access error occurs ***'
        return logs
      else
        logs += next_logs unless next_logs.nil?
      end
    end

    return logs
  end

  def log_nodes(page)
    page.search('div.timeline/div.log')
  end

end

require_relative 'nicorepo/cli.rb'
