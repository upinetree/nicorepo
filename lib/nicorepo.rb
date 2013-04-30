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
    timeline = page.search('div.timeline')

    titles = parse_titles(timeline)
    urls   = parse_urls(timeline)

    logs = Array.new(max_logs, nil).map!{ Log.new }
    logs.each_index do |i|
      logs[i].title = titles[i]
      logs[i].url   = urls[i]
    end

    return logs
  end


  private

  def parse_titles(timeline)
    nodes = timeline.search('div.log-target-info/a')
    nodes.map{ |n| n.inner_text }
  end

  def parse_urls(timeline)
    nodes = timeline.search('div.log-target-info/a')
    nodes.map{ |n| n['href'] }
  end

end
