require 'mechanize'
require 'nicorepo/reports'

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

  def all(reqest_num = PER_PAGE)
    limit_page = reqest_num / PER_PAGE + 1
    Reports.new(@parser).fetch(reqest_num, limit_page)
  end

  def videos(reqest_num = 3, limit_page = 5)
    VideoReports.new(@parser).fetch(reqest_num, limit_page)
  end

  def lives(reqest_num = 3, limit_page = 5)
    LiveReports.new(@parser).fetch(reqest_num, limit_page)
  end
end

require "nicorepo/version"
require 'nicorepo/cli/cli'
require 'nicorepo/cli/config'

