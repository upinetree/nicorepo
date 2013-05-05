class Nicorepo
  class Cli

    def initialize
      @repo = Nicorepo.new
    end

    def run(argv)
      cmd, num, nest = parse(argv)
      help if cmd == 'help'

      acc  = account

      begin
        @repo.login(acc[:mail], acc[:pass])
      rescue
        warn "invalid mail or pass: mail = #{acc[:mail]}"
        exit 1
      end

      logs = exec_command(cmd, num, nest)
      if logs
        disp logs
      else
        case cmd
        when 'i' then interactive_run
        else help
        end
      end
    end

    # run interactively with given Nicorepo
    # returns true when exit
    def interactive_run
      loop do
        print 'nicorepo > '
        argv = gets.chomp.split
        cmd, num, nest = parse(argv)

        logs = exec_command(cmd, num, nest)
        if logs
          disp logs
        else
          case cmd
          when 'exit' then return true
          else help_interactive; next
          end
        end
      end
    end

   def account
      root = File.expand_path('../../../', __FILE__)
      begin
        f = open(File.join(root, 'config.txt'))
        mail = f.gets.chomp!
        pass = f.gets.chomp!
      rescue
        warn "config read error: please enter mail and pass to config.txt"
        exit 1
      else
        f.close
      end
     
      return {mail: mail, pass: pass}
    end


    private

    def parse(argv)
      cmd  = argv.shift  || 'help'
      num  = (argv.shift || 10).to_i
      nest = (argv.shift ||  3).to_i

      return cmd, num, nest
    end

    # it returns
    #   - logs  if succeed to exec exepcted command
    #   - nil   if unexpected command given
    def exec_command(cmd, num, nest)
      logs = nil

      case cmd
      when 'all'    then logs = @repo.all    num
      when 'videos' then logs = @repo.videos num, nest
      when 'lives'  then logs = @repo.lives  num, nest
      else return nil
      end

      return logs
    end

    def help
      puts '    usage: nicorepo command [params]'
      puts '    command:'
      puts '        i - begin interactive mode'
      help_commands
      exit 1
    end

    def help_interactive
      puts '    usage: command [params]'
      puts '    command:'
      help_commands
    end

    def help_commands
      puts <<-"EOS"
        all    [disp_num]
        videos [disp_num] [nest]
        lives  [disp_num] [nest]
          *disp_num - number of logs to display at once (default = 10)
          *nest     - max nesting level of pages to search (default = 3)
        exit
      EOS
    end

    def disp(logs)
      logs.each.with_index(1) do |log, i|
        puts "[#{i}] #{log.body} on #{log.date.to_s}"
        puts "    '#{log.target}' (#{log.url})"
      end
    end

  end
end

