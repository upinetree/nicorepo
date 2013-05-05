class Nicorepo
  class Cli

    def run(argv)
      option = argv.shift || help
      acc = account

      repo = Nicorepo.new

      begin
        repo.login(acc[:mail], acc[:pass])
      rescue
        warn "invalid mail or pass: mail = #{acc[:mail]}"
        exit 1
      end

      interactive_run(repo) if option == '-i' 
    end
 
    # run interactively with given Nicorepo
    # returns true when exit
    def interactive_run(repo)
      loop do
        print 'nicorepo > '
        argv = gets.chomp.split
        cmd, num, nest = parse(argv)

        logs = nil

        case cmd
        when 'all'    then logs = repo.all    num
        when 'videos' then logs = repo.videos num, nest
        when 'lives'  then logs = repo.lives  num, nest
        when 'exit'   then return true
        else help_interactive; next
        end

        disp logs if repo
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

    def help
      puts 'usage: nicorepo [-i]'
      exit 1
    end

    def help_interactive
      puts <<-"EOS"
        usage: command params'
        command:
          all    [disp_num]
          videos [disp_num] [nest]
          lives  [disp_num] [nest]'
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


