require 'launchy'
require 'readline'

class Nicorepo

  class Cli

    class LogExistenceError < StandardError; end

    def initialize
      @repo = Nicorepo.new
      @logs = nil
    end

    def run(argv)
      cmd, num, nest = parse(argv)
      help if cmd == 'help'

      login

      logs = exec_command(cmd, num, nest)
      if logs
        disp logs
      else
        case cmd
        when 'interactive', 'i' then interactive_run
        else help
        end
      end
    end

    # returns true when exit
    def interactive_run
      loop do
        argv = Readline::readline("nicorepo > ", true).split
        cmd, num, nest = parse(argv)

        logs = exec_command(cmd, num, nest)
        if logs
          @logs = logs
          disp @logs
        else
          case cmd
          when 'open', 'o' then open_url(@logs, num)
          when 'login'     then login
          when 'exit'      then return true
          else help_interactive; next
          end
        end
      end
    end

   def account
      root = File.expand_path('../../../', __FILE__)
      begin
        confs = open(File.join(root, 'config.yaml')) { |f| YAML.load(f.read) }
      rescue
        warn "config read error: please enter mail and pass to config.txt"
        exit 1
      end
     
      return {mail: confs["mail"], pass: confs["pass"]}
    end

    # options is now just for testing
    def open_url(logs, num, options = {})
      url = logs[num - 1].url
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
      cmd  = argv.shift  || 'help'
      num  = (argv.shift || 10).to_i
      nest = (argv.shift ||  3).to_i

      return cmd, num, nest
    end

    def login
      acc  = account

      begin
        @repo.login(acc[:mail], acc[:pass])
      rescue
        warn "invalid mail or pass: mail = #{acc[:mail]}"
        exit 1
      end
    end

    # it returns
    #   - logs  if succeed to exec exepcted command
    #   - nil   if unexpected command given
    def exec_command(cmd, num, nest)
      logs = nil

      case cmd
      when 'all',    'a' then logs = @repo.all    num
      when 'videos', 'v' then logs = @repo.videos num, nest
      when 'lives',  'l' then logs = @repo.lives  num, nest
      else return nil
      end

      return logs
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
        all, a    [disp_num]
        videos, v [disp_num] [nest]
        lives, l  [disp_num] [nest]
          *disp_num - number of logs to display at once (default = 10)
          *nest     - max nesting level of pages to search (default = 3)
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

