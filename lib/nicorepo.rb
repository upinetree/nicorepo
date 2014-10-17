require 'mechanize'
require 'nicorepo/reports'
require 'nicorepo/parser'

class Nicorepo
  class LoginError < StandardError; end

  PER_PAGE = 20
  LOGIN_URL = 'https://secure.nicovideo.jp/secure/login?site=niconico'

  attr_reader :agent

  def initialize
    @agent = Mechanize.new
    @agent.ssl_version = 'TLSv1'
    @agent.request_headers = { 'accept-language' => 'ja-JP', 'content-language' => 'ja-JP' }
    @parser = Parser.new(@agent)
    @logined = false
  end

  def login(mail, pass)
    page = @agent.post(LOGIN_URL, mail: mail, password: pass)
    if page.header["x-niconico-authflag"] == '0'
      raise LoginError, "Failed to login"
    else
      @logined = true
    end
  end

  def logined?
    # TODO: page.header["x-niconico-auth-flag"] をチェックする？
    #       現状一度ログインしたらfalseにならない
    @logined
  end

  def all(request_num = PER_PAGE, since: nil)
    limit_page = request_num / PER_PAGE + 1
    Reports.new(@parser).fetch(request_num, limit_page, since: since)
  end

  def videos(request_num = 3, limit_page = 5, since: nil)
    VideoReports.new(@parser).fetch(request_num, limit_page, since: since)
  end

  def lives(request_num = 3, limit_page = 5, since: nil)
    LiveReports.new(@parser).fetch(request_num, limit_page, since: since)
  end
end

require 'nicorepo/cli/cli'
require "nicorepo/version"

