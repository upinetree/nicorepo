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
    @agent.ssl_version = 'SSLv3'
    @agent.request_headers = { 'accept-language' => 'ja-JP', 'content-language' => 'ja-JP' }
    @parser = Parser.new(@agent)
  end

  def login(mail, pass)
    page = @agent.post(LOGIN_URL, mail: mail, password: pass)
    raise LoginError, "Failed to login" if page.header["x-niconico-authflag"] == '0'
  end

  def all(request_num = PER_PAGE)
    limit_page = request_num / PER_PAGE + 1
    Reports.new(@parser).fetch(request_num, limit_page)
  end

  def videos(request_num = 3, limit_page = 5)
    VideoReports.new(@parser).fetch(request_num, limit_page)
  end

  def lives(request_num = 3, limit_page = 5)
    LiveReports.new(@parser).fetch(request_num, limit_page)
  end
end

require 'nicorepo/cli/cli'
require "nicorepo/version"

