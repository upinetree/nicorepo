require 'launchy'
require 'readline'
require 'netrc'

class Nicorepo
  class Cli

    class LogExistenceError < StandardError; end
    class LoginAccountError < StandardError; end

    def initialize
      @repo = Nicorepo.new
      @logs = nil
      @conf = Nicorepo::Cli::Config.new
    end

    def run(argv)
      cmd, request_num, limit_page = parse(argv)
      help if cmd == 'help'

      login

      logs = exec_command(cmd, request_num, limit_page)
      if logs
        disp logs
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

        logs = exec_command(cmd, request_num, limit_page)
        if logs
          @logs = logs
          disp @logs
        else
          case cmd
          when 'open'   then open_url(@logs, request_num)
          when 'login'  then login
          when 'exit'   then return true
          else help_interactive; next
          end
        end
      end
    end

    # options is now just for testing
    def open_url(logs, request_num, options = {})
      url = logs[request_num - 1].url
      if url.nil?
        puts "log existence error: please fetch logs"
        raise LogExistenceError
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
    #   - logs  if succeed to exec exepcted command
    #   - nil   if unexpected command given
    def exec_command(cmd, request_num, limit_page)
      logs = nil

      case cmd
      when 'all'    then logs = @repo.all    request_num
      when 'videos' then logs = @repo.videos request_num, limit_page
      when 'lives'  then logs = @repo.lives  request_num, limit_page
      else return nil
      end

      return logs
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
      puts '        open, o [log_num] - open url of given log number'
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

    def disp(logs)
      logs.each.with_index(1) do |log, i|
        puts "[#{i}] #{log.body} on #{log.date.to_s}"
        puts "    '#{log.title}' (#{log.url})"
      end
    end
  end
end

