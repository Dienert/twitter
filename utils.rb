require 'mechanize'
require 'openssl'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
I_KNOW_THAT_OPENSSL_VERIFY_PEER_EQUALS_VERIFY_NONE_IS_WRONG = 1

class Utils
  @@appUrl = 'https://www.twitter.com/'
  @@followingNumber = 0

  @@agent = Mechanize.new { |a|
    a.user_agent_alias = 'Mac Safari'
    a.idle_timeout = 1
    a.read_timeout = 300
  }

  @@test_result_page = File.open("test_page.html", "w")

  def self.name
    @@name
  end

  def self.profile
    @@profile
  end

  def self.agent
    @@agent
  end

  def self.appUrl
    @@appUrl
  end

  def self.save_result_page(page)
    @@test_result_page.write(page.to_s)
  end

  def self.arquivo_saida
    @@arquivo_saida
  end

  def self.followingNumber
    @@followingNumber
  end

  def self.setFollowingNumber followingNumber
    @@followingNumber = followingNumber
  end

  def self.login
    #email = `read -p "Login: " uid; echo $uid`.chomp
    #pass = `read -s -p "Senha: " password; echo $password`.chomp

    # Efetuando Login
    pass = File.open('pass', 'r').gets.split(';')

    login_page = @@agent.get(@@appUrl)
    form = login_page.forms[1]
    form["session[username_or_email]"] = pass[0]
    form["session[password]"] = pass[1]
    login_result = form.submit
    login_page_doc = Nokogiri::HTML(login_result.content)
    botao_logout = login_page_doc.xpath('.//li[@id="signout-button"]').to_s

    if botao_logout != ''
      puts 'Login Efetuado com Sucesso'
    else
      puts 'Falha de Login'
      exit
    end

    div = login_page_doc.xpath('//div[@class="DashboardProfileCard  module"]')

    link = div.xpath('.//a[@class="u-textInheritColor"]')

    @@name = link.text
    @@profile = link.attr("href").to_s
    @@profile = @@profile[1..@@profile.length]

    puts "#{@@name} => @#{@@profile}"

    @@arquivo_saida = File.open("#{@@profile}.csv", 'w')
    column_separator = "|"
    @@arquivo_saida.puts "name" + column_separator +
                     "user_id" + column_separator +
                     "profile" + column_separator +
                     "user_bio" + column_separator +
                     "url_picture"
  end

  def self.duration_from_seconds(seconds)
      secs = "0"
      min = "0"
      hours = "0"
      seconds = seconds.to_i
      minInt = (seconds / 60).to_i
      secsInt = seconds % 60
      secs = secsInt.to_s
      hoursInt = (minInt / 60).to_i
      minInt = minInt % 60
      min = minInt.to_s
      dias = (hoursInt / 24).to_i.to_s
      hoursInt = hoursInt % 24
      hours = hoursInt.to_s
      return dias + ":" + hours + ":" + min + ":" + secs
  end

end
