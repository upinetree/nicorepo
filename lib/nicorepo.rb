require 'mechanize'

class Nicorepo

  module URL
    LOGIN = 'https://secure.nicovideo.jp/secure/login?site=niconico'
    REPO_ALL = 'http://rd.nicovideo.jp/cc/my/zerotopall'
  end

  class Log
    attr_accessor :title

    def initialize
      @title = nil
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

  def all
    page = @agent.get(URL::REPO_ALL)
    timeline = page.parser.css("div[class='timeline']")

    titles = parse_titles(timeline)
    titles.map do |t|
      log = Log.new
      log.title = t
      log
    end
  end


  private

  def parse_titles(timeline)
    parsed_items = timeline.css("div[class*='log-target-info']")
    parsed_items.xpath("./a").map do |t|
      t.inner_text
    end
  end

end
