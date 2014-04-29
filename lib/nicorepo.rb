require 'forwardable'
require 'mechanize'
require 'nicorepo/reports'

class Nicorepo
  extend Forwardable

  class LoginError < StandardError; end

  LOGIN_URL = 'https://secure.nicovideo.jp/secure/login?site=niconico'

  attr_reader :agent

  def_delegators :@reports, :all, :videos, :lives

  def initialize
    @agent = Mechanize.new
    @agent.ssl_version = 'SSLv3'
    @agent.request_headers = { 'accept-language' => 'ja-JP', 'content-language' => 'ja-JP' }
    @reports = Reports.new(@agent)
  end

  def login(mail, pass)
    page = @agent.post(LOGIN_URL, mail: mail, password: pass)
    raise LoginError, "Failed to login" if page.header["x-niconico-authflag"] == '0'
  end
end

require "nicorepo/version"
require 'nicorepo/cli/cli'
require 'nicorepo/cli/config'

