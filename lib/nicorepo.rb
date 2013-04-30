require 'mechanize'

class Nicorepo

  module URL
    LOGIN = 'https://secure.nicovideo.jp/secure/login?site=niconico'
    REPO_ALL = 'http://rd.nicovideo.jp/cc/my/zerotopall'
  end

  class Log
    attr_accessor :title, :url, :author, :kind

    def initialize
      @title  = nil
      @url    = nil
      @author = nil
      @kind   = nil
    end
  end

  class LoginError < StandardError; end

  attr_reader :agent

  def initialize
    @agent = Mechanize.new
    @agent.ssl_version = 'SSLv3'
  end

  def login(mail, pass)
    page = @agent.post(URL::LOGIN, mail: mail, password: pass)
    raise LoginError, "Failed to login" if page.header["x-niconico-authflag"] == '0'
  end

  def all(req_num = 20)
    log_nodes = get_log_nodes(req_num)

    logs = log_nodes.map do |node|
      log = Log.new
      log.title  = parse_title  node
      log.url    = parse_url    node
      log.author = parse_author node
      log.kind   = parse_kind   node
      log
    end

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

  def parse_title(node)
    node.search('div.log-target-info/a').first.inner_text
  end

  def parse_url(node)
    node.search('div.log-target-info/a').first['href']
  end

  def parse_author(node)
    node.search('div.log-body/a').first.inner_text
  end

  def parse_kind(node)
    case node['class']
    when /video-upload/       then 'video'
    when /live-broadcast/     then 'live'
    when /seiga-image-upload/ then 'seiga'
    when /mylist-add/         then 'mylisted'
    when /clip/               then 'clip'
    when /register-chblog/    then 'blog'
    else 'other'
    end
  end

end
