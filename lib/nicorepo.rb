require 'mechanize'

class Nicorepo

  module URL
    LOGIN = 'https://secure.nicovideo.jp/secure/login?site=niconico'
    REPO_ALL = 'http://rd.nicovideo.jp/cc/my/zerotopall'
  end

  class Log
    attr_accessor :body, :target, :url, :author, :kind, :date

    def initialize(node = nil)
      if node.nil? then return end
      @body   = parse_body   node
      @target = parse_target node
      @url    = parse_url    node
      @author = parse_author node
      @kind   = parse_kind   node
      @date   = parse_date   node
    end

    private

    def parse_body(node)
      node.search('div.log-body').first.inner_text.gsub(/(\t|\r|\n)/, "")
    end

    def parse_target(node)
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
      d = node.search('div.log-footer/a.log-footer-date/time').first['datetime']
      Time.xmlschema(d).localtime
    end
 
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
    get_logs(req_num, page_nest_max)
  end

  def videos(req_num = 3, page_nest_max = 5)
    filtered_by('video-upload', req_num, page_nest_max)
  end

  def lives(req_num = 3, page_nest_max = 5)
    filtered_by('live', req_num, page_nest_max)
  end

  def filtered_by(filter, req_num = LOGS_PER_PAGE, page_nest_max = 1)
    get_logs(req_num, page_nest_max, filter)
  end

  private

  def get_logs(req_num, page_nest_max, filter = nil, url = URL::REPO_ALL)
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
        next_logs = get_logs(req_num - logs.size, page_nest_max - 1, filter, next_url)
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
