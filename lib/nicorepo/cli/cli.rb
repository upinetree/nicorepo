require 'thor'
require 'netrc'
require 'launchy'
require 'readline'

class Nicorepo
  module Cli
    class Runner
      def self.run
        loop do
          args = Readline::readline("nicorepo > ", true).split
          ret = Interactor.start(args)
          break if ret == :exit
        end
      end
    end

    class Interactor < Thor
      class LoginAccountError < StandardError; end
      class ReportExistenceError < StandardError; end

      class << self
        attr_accessor :reports
        attr_reader   :repo, :conf

        def start(*)
          @repo ||= Nicorepo.new
          @conf ||= Nicorepo::Cli::Configuration.new
          @reports ||= []

          login unless logined?

          super
        end

        # replaces by a blank for help because Interactor dosen't require the basename
        def basename
          ''
        end

        def login
          mail, pass = Netrc.read["nicovideo.jp"]
          raise LoginAccountError, "machine nicovideo.jp is not defined in .netrc" if mail.nil? || pass.nil?
          begin
            @repo.login(mail, pass)
          rescue
            raise LoginAccountError, "invalid mail or pass: mail = #{mail}"
          end
          @logined = true
        end

        # TODO: Nicorepo側に持たせる
        def logined?
          @logined
        end
      end

      desc "login", "re-login if your session is expired"
      def login
        login
      end

      desc "all", "fetch all reports"
      option :"request-num", type: :numeric, aliases: :n
      def all
        request_num = options[:"request-num"] || conf.request_num("all")
        cache(repo.all(request_num))
        show
      end

      desc "videos", "fetch only video reports"
      option :"request-num", type: :numeric, aliases: :n
      option :"limit-page", type: :numeric, aliases: :p
      def videos
        request_num = options[:"request-num"] || conf.request_num("videos")
        limit_page  = options[:"limit-page"]  || conf.limit_page("videos")
        cache(repo.videos(request_num, limit_page))
        show
      end

      desc "lives", "fetch only live reports"
      option :"request-num", type: :numeric, aliases: :n
      option :"limit-page", type: :numeric, aliases: :p
      def lives
        request_num = options[:"request-num"] || conf.request_num("lives")
        limit_page  = options[:"limit-page"]  || conf.limit_page("lives")
        cache(repo.lives(request_num, limit_page))
        show
      end

      desc "show", "show current reports"
      def show
        current_reports.each.with_index(1) do |report, i|
          puts "[#{i}] #{report.body} on #{report.date.to_s}"
          puts "    '#{report.title}' (#{report.url})"
        end
      end

      desc "open REPORT-NUMBER", "open the report url specified by number in your browser"
      def open(report_number)
        open_numbered_link(report_number.to_i)
      end

      desc "exit", "exit interactive prompt"
      def exit
        :exit
      end

      private

      def repo
        self.class.repo
      end

      def conf
        self.class.conf
      end

      def current_reports
        self.class.reports
      end

      def cache(reports)
        self.class.reports = reports
      end

      def open_numbered_link(request_num)
        url = current_reports[request_num - 1].url
        raise ReportExistenceError, "report existence error: please fetch reports" if url.nil?

        Launchy.open(url, options) do |exception|
          puts "Attempted to open #{url} and failed because #{exception}"
          raise exception
        end
      end
    end
  end
end

