require 'nicorepo'

module Helper
  def right_account
    begin
      f = open('spec/resource/account.txt')
      mail = f.gets.chomp!
      pass = f.gets.chomp!
    ensure
      f.close
    end

    {mail: mail, pass: pass}
  end
end

module CliHelper
  def conf_init(conf, params)
    conf.stub!(:open).and_return(params)
    conf.read
  end
end
