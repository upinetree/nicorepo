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
