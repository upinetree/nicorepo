require 'net/http'
require 'cgi'
require 'openssl'

module Nicorepo
  module Request
    class Auth
      class LoginError < StandardError; end

      attr_reader :session

      def initialize
        @session = ''
      end

      def login(mail, pass)
        res = Net::HTTP.start(url.host, url.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |client|
          client.post(url.path, body(mail, pass))
        end

        cookies = res.get_fields('set-cookie').map { |str| CGI::Cookie.parse(str) }

        session_cookie = cookies.detect { |c|
          c['user_session']&.size > 0 && c['user_session'] != ['deleted']
        }
        fail LoginError, "invalid mail or password: mail => #{mail}" unless session_cookie

        @session = session_cookie.fetch('user_session').first
      end

      private

      def url
        URI('https://secure.nicovideo.jp/secure/login?site=niconico')
      end

      def body(mail, pass)
        "mail=#{mail}&password=#{pass}"
      end
    end

    class Timeline
      require 'json'

      def self.fetch(session, cursor: nil)
        new.fetch(session, cursor)
      end

      def fetch(session, cursor)
        url = url(cursor)
        res = Net::HTTP.start(url.host, url.port) do |client|
          client.get(url.request_uri, header(session))
        end

        fail "Request timeline failed !! #{res.inspect}: #{res.to_hash}" if res.code != '200'

        JSON.parse(res.body)
      end

      private

      def header(session)
        {
          'Cookie' => CGI::Cookie.new('user_session', session).to_s,
          'Connection' => 'keep-alive',
        }
      end

      def url(cursor)
        params = {
          client_app: 'pc_myrepo',
          cursor: cursor,
        }.compact

        URI('http://www.nicovideo.jp/api/nicorepo/timeline/my/all').tap do |url|
          url.query = params.map { |k, v| "#{CGI.escape(k.to_s)}=#{v}" }.join('&')
        end
      end
    end
  end
end
