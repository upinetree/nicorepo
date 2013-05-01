require 'mechanize'

class Nicorepo

  module URL
    LOGIN = 'https://secure.nicovideo.jp/secure/login?site=niconico'
    REPO_ALL = 'http://rd.nicovideo.jp/cc/my/zerotopall'
  end

  class Log
    attr_accessor :body, :target, :url, :author, :kind

    def initialize
      @body   = nil
      @target = nil
      @url    = nil
      @author = nil
      @kind   = nil
    end
  end

  class LoginError < StandardError; end

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
    get_logs(req_num, page_nest_max, 'video-upload')
  end

  private

  def get_logs(req_num, page_nest_max, filter = nil, url = URL::REPO_ALL)
    return [] unless page_nest_max > 0

    page = @agent.get(url)
    logs = log_nodes(page).map do |node|
      log = Log.new
      log.body   = parse_body   node
      log.target = parse_target node
      log.url    = parse_url    node
      log.author = parse_author node
      log.kind   = parse_kind   node
      log
    end
    logs.select!{ |log| log.kind =~ /#{filter}/ } if filter

    if logs.size > req_num then
      return logs[0, req_num]
    end

    if logs.size < req_num then
      next_url = page.search('div.next-page/a').first['href']
      logs += get_logs(req_num - logs.size, page_nest_max - 1, filter, next_url)
    end

    return logs
  end

  def log_nodes(page)
    page.search('div.timeline/div.log')
  end

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

  # example: 'log.log-community-video-upload' -> 'video-upload'
  def parse_kind(node)
    cls = node['class']
    index = cls.index(/(user|community)\-/)
    cls[index..cls.size]
  end

end
