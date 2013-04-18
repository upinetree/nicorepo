require 'mechanize'

class Nicorepo

	module URL
		LOGIN = 'https://secure.nicovideo.jp/secure/login?site=niconico'
		REPO_ALL = 'http://rd.nicovideo.jp/cc/my/zerotopall'
	end

	def initialize
		@logined = false
		
		@agent = Mechanize.new
		@agent.ssl_version = 'SSLv3'
	end

	def login(mail, pass)
		page = @agent.post(URL::LOGIN, mail: mail, password: pass)
		raise LoginError, "Failed to login (x-niconico-authflag is 0)" if page.header["x-niconico-authflag"] == '0'

		@logind = true
	end

	class LoginError < StandardError; end
end

