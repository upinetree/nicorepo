require 'mechanize'

class Nicorepo

  module URL
    LOGIN = 'https://secure.nicovideo.jp/secure/login?site=niconico'
    REPO_ALL = 'http://rd.nicovideo.jp/cc/my/zerotopall'
  end

  class Log
    attr_accessor :title, :url

    def initialize
      @title = nil
      @url   = nil
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

  def all(max_logs = 20)
    page = @agent.get(URL::REPO_ALL)
    log_nodes = page.search('div.timeline/div.log')

    log_nodes = log_nodes[0, max_logs] if log_nodes.size > max_logs

    logs = log_nodes.map do |node|
      log = Log.new
      log.title = parse_title node
      log.url   = parse_url   node
      log
    end

    return logs
  end


  private

  def parse_title(log_node)
    log_node.search('div.log-target-info/a').first.inner_text
  end

  def parse_url(log_node)
    log_node.search('div.log-target-info/a').first['href']
  end

end
