def account 
  begin
    f = open('spec/resource/account.txt')
    mail = f.gets.chomp!
    pass = f.gets.chomp!
  ensure
    f.close
  end

  {mail: mail, pass: pass}
end
