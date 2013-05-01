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
    log_nodes = get_log_nodes(req_num)

    logs = log_nodes.map do |node|
      log = Log.new
      log.body   = parse_body   node
      log.target = parse_target node
      log.url    = parse_url    node
      log.author = parse_author node
      log.kind   = parse_kind   node
      log
    end

    return logs
  end

  def videos(page_max = 3)
    logs = all(page_max * LOGS_PER_PAGE)
    logs.select!{ |log| log.kind =~ /video-upload/ }

    return logs
  end

  private

  def get_log_nodes(req_num, url = URL::REPO_ALL)
    page = @agent.get(url)
    nodes = page.search('div.timeline/div.log')

    if nodes.size > req_num then
      nodes = nodes[0, req_num]
    elsif nodes.size < req_num then
      next_url = page.search('div.next-page/a').first['href']
      nodes = nodes + get_log_nodes(req_num - nodes.size, next_url)
    end

    return nodes
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
