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
  end

  def login(mail, pass)
    page = @agent.post(LOGIN_URL, mail: mail, password: pass)
    raise LoginError, "Failed to login" if page.header["x-niconico-authflag"] == '0'
  end

  def all(req_num = PER_PAGE)
    page_nest_max = req_num / PER_PAGE + 1
    Reports.new(@agent).fetch(req_num, page_nest_max)
  end

  def videos(req_num = 3, page_nest_max = 5)
    VideoReports.new(@agent).fetch(req_num, page_nest_max)
  end

  def lives(req_num = 3, page_nest_max = 5)
    LiveReports.new(@agent).fetch(req_num, page_nest_max)
  end
end

require "nicorepo/version"
require 'nicorepo/cli/cli'
require 'nicorepo/cli/config'

