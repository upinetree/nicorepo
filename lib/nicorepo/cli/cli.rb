require 'thor'
require 'netrc'
require 'launchy'
require 'readline'
require 'nicorepo/cli/config'

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
        attr_accessor :cache
        attr_reader   :repo, :conf

        def start(*)
          @repo ||= Nicorepo.new
          @conf ||= Nicorepo::Cli::Configuration.new
          @cache ||= {}

          login unless @repo.logined?

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
        end
      end

      desc "login", "re-login if your session is expired"
      def login
        login
      end

      desc "all", "fetch all reports"
      option :"request-num", type: :numeric, aliases: :n
      option :"latest", type: :boolean, aliases: :l
      def all
        request_num = options[:"request-num"] || conf.request_num("all")
        request_options = options[:latest] ? { since: cached_at } : { since: nil }
        cache(repo.all(request_num, request_options))
        show
      end

      desc "videos", "fetch only video reports"
      option :"request-num", type: :numeric, aliases: :n
      option :"limit-page", type: :numeric, aliases: :p
      option :"latest", type: :boolean, aliases: :l
      def videos
        request_num = options[:"request-num"] || conf.request_num("videos")
        limit_page  = options[:"limit-page"]  || conf.limit_page("videos")
        request_options = options[:latest] ? { since: cached_at } : { since: nil }
        cache(repo.videos(request_num, limit_page, request_options))
        show
      end

      desc "lives", "fetch only live reports"
      option :"request-num", type: :numeric, aliases: :n
      option :"limit-page", type: :numeric, aliases: :p
      option :"latest", type: :boolean, aliases: :l
      def lives
        request_num = options[:"request-num"] || conf.request_num("lives")
        limit_page  = options[:"limit-page"]  || conf.limit_page("lives")
        request_options = options[:latest] ? { since: cached_at } : { since: nil }
        cache(repo.lives(request_num, limit_page, request_options))
        show
      end

      desc "show", "show current reports"
      option :more, type: :boolean, aliases: :m
      def show
        showed_reports = options[:more] ? cached_reports : cached_reports[0, recent_tail]
        showed_reports.each.with_index(1) do |report, i|
          say "--- MORE ---", :blue if i == recent_tail + 1
          say "[#{i}] #{report.body} at #{report.date.to_s}"
          say "     #{report.title} (#{report.url})", :green
        end
        say "* last fetch time: #{cached_at}", :blue
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

      def cached_reports
        self.class.cache[:reports] ||= []
      end

      def recent_tail
        self.class.cache[:recent_tail]
      end

      def cached_at
        self.class.cache[:cached_at]
      end

      def cache(reports)
        cached_reports.unshift(reports).flatten!
        self.class.cache[:recent_tail] = reports.size
        self.class.cache[:cached_at] = Time.now
      end

      def open_numbered_link(request_num)
        url = cached_reports[request_num - 1].url
        raise ReportExistenceError, "report existence error: please fetch reports" if url.nil?

        Launchy.open(url, options) do |exception|
          puts "Attempted to open #{url} and failed because #{exception}"
          raise exception
        end
      end
    end
  end
end

