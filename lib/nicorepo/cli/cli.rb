require 'launchy'
require 'readline'
require 'netrc'

class Nicorepo
  class Cli

    class ReportExistenceError < StandardError; end
    class LoginAccountError < StandardError; end

    def initialize
      @repo = Nicorepo.new
      @reports = nil
      @conf = Nicorepo::Cli::Config.new
    end

    def run(argv)
      cmd, request_num, limit_page = parse(argv)
      help if cmd == 'help'

      login

      reports = exec_command(cmd, request_num, limit_page)
      if reports
        disp reports
      else
        case cmd
        when 'interactive'  then interactive_run
        else help
        end
      end
    end

    # returns true when exit
    def interactive_run
      loop do
        argv = Readline::readline("nicorepo > ", true).split
        cmd, request_num, limit_page = parse(argv)

        reports = exec_command(cmd, request_num, limit_page)
        if reports
          @reports = reports
          disp @reports
        else
          case cmd
          when 'open'   then open_url(@reports, request_num)
          when 'login'  then login
          when 'exit'   then return true
          else help_interactive; next
          end
        end
      end
    end

    # options is now just for testing
    def open_url(reports, request_num, options = {})
      url = reports[request_num - 1].url
      if url.nil?
        puts "report existence error: please fetch reports"
        raise ReportExistenceError
      end

      Launchy.open(url, options) do |exception|
        puts "Attempted to open #{url} and failed because #{exception}"
        raise exception
      end

      return true
    end

    private

    def parse(argv)
      cmd  = translate(argv.shift  || 'help')
      request_num  = (argv.shift || @conf.request_num(cmd)).to_i
      limit_page = (argv.shift || @conf.limit_page(cmd)).to_i

      return cmd, request_num, limit_page
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

    # it returns
    #   - reports if succeed to exec exepcted command
    #   - nil     if unexpected command given
    def exec_command(cmd, request_num, limit_page)
      reports = nil

      case cmd
      when 'all'    then reports = @repo.all    request_num
      when 'videos' then reports = @repo.videos request_num, limit_page
      when 'lives'  then reports = @repo.lives  request_num, limit_page
      else return nil
      end

      return reports
    end

    ALIAS = {"a" => "all", "v" => "videos", "l" => "lives",
             "o" => "open", "i" => "interactive"}
    def translate(cmd)
      if ALIAS.has_key?(cmd)
        ALIAS[cmd]
      else
        cmd
      end
    end

    def help
      puts '    usage: nicorepo command [params]'
      puts '    command:'
      help_commands
      puts '        interactive, i - begin interactive mode'
      exit 1
    end

    def help_interactive
      puts '    usage: command [params]'
      puts '    command:'
      help_commands
      puts '        open, o [report_num] - open url of given report number'
      puts '        login'
      puts '        exit'
    end

    def help_commands
      puts <<-"EOS"
        all, a    [request_num]
        videos, v [request_num] [limit_page]
        lives, l  [request_num] [limit_page]
          *request_num - number of reports to fetch from nicovideo (default = 10)
          *limit_page  - limit page to fetch reports(default = 3)
      EOS
    end

    def disp(reports)
      reports.each.with_index(1) do |report, i|
        puts "[#{i}] #{report.body} on #{report.date.to_s}"
        puts "    '#{report.title}' (#{report.url})"
      end
    end
  end
end

