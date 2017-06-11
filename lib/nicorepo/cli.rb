require 'nicorepo'
require 'nicorepo/cli/config'

require 'thor'
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
        # replaces by a blank for help because Interactor dosen't require the basename
        def basename
          ''
        end

        def repo
          @repo ||= Nicorepo.new
        end

        def conf
          @conf ||= Nicorepo::Cli::Configuration.new
        end

        def cache
          @cache ||= {}
        end
      end

      desc "reset_session", "reset current session and try re-login at the next access. It is useful if your session is expired"
      def reset_session
        @repo.reset_session
      end

      desc "all", "fetch all reports"
      option :"request-num", type: :numeric, aliases: :n
      option :"latest", type: :boolean, aliases: :l
      option :"days", type: :numeric, aliases: :d
      option :"hours", type: :numeric, aliases: :h
      def all
        request_num = options[:"request-num"] || conf.request_num("all")
        request_options = { since: parse_since_options(options) }
        cache(repo.all(request_num, request_options))
        show
      end

      desc "videos", "fetch only video reports"
      option :"request-num", type: :numeric, aliases: :n
      option :"limit-page", type: :numeric, aliases: :p
      option :"latest", type: :boolean, aliases: :l
      option :"days", type: :numeric, aliases: :d
      option :"hours", type: :numeric, aliases: :h
      def videos
        request_num = options[:"request-num"] || conf.request_num("videos")
        limit_page  = options[:"limit-page"]  || conf.limit_page("videos")
        request_options = { limit_page: limit_page, since: parse_since_options(options) }
        cache(repo.videos(request_num, request_options))
        show
      end

      desc "lives", "fetch only live reports"
      option :"request-num", type: :numeric, aliases: :n
      option :"limit-page", type: :numeric, aliases: :p
      option :"latest", type: :boolean, aliases: :l
      option :"days", type: :numeric, aliases: :d
      option :"hours", type: :numeric, aliases: :h
      def lives
        request_num = options[:"request-num"] || conf.request_num("lives")
        limit_page  = options[:"limit-page"]  || conf.limit_page("lives")
        request_options = { limit_page: limit_page, since: parse_since_options(options) }
        cache(repo.lives(request_num, request_options))
        show
      end

      desc "show", "show current reports"
      option :more, type: :boolean, aliases: :m
      def show
        if cached_reports.size == 0
          say "* No reports", :red
          return
        end

        reports = options[:more] ? cached_reports : cached_reports[0, recent_tail]
        reports.each.with_index(1) do |report, i|
          say "--- MORE ---", :blue if i == recent_tail + 1
          say "[#{i}] #{report[:topic]} from: #{report[:sender]} at: #{report[:created_at]}"
          say "    #{report[:title]} (#{report[:url]})", :green
        end
        say "* last fetch time: #{cached_at}", :blue
      end

      desc "open REPORT-NUMBER", "open the url in your browser. REPORT-NUMBER is shown in left of each report"
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
        self.class.cache[:report] ||= []
      end

      def recent_tail
        self.class.cache[:recent_tail]
      end

      def cached_at
        self.class.cache[:cached_at]
      end

      def cache(new_report)
        cached_reports.unshift(*new_report.format)
        self.class.cache[:recent_tail] = new_report.size
        self.class.cache[:cached_at] = Time.now
      end

      def parse_since_options(options)
        case
        when options[:latest]
          cached_at
        when options[:days]
          Time.now - options[:days] * 24 * 60 * 60
        when options[:hours]
          Time.now - options[:hours] * 60 * 60
        else
          nil
        end
      end

      def open_numbered_link(num)
        if num > cached_reports.size || num < 1
          say "Unavailable report number", :red
          return
        end

        url = cached_reports[num - 1][:url]

        Launchy.open(url, options) do |exception|
          puts "Attempted to open #{url} but failed because of #{exception}"
          raise exception
        end
      end
    end
  end
end

