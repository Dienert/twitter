require 'rubygems'
require 'mechanize'
require 'logger'

cookie_path = 'twitter_client.cookie.yaml'
target = 'dienert'

agent = Mechanize.new

# お好みで Logger
logger = Logger.new STDOUT
logger.level = Logger::DEBUG
agent.log = logger

# UA 偽装
agent.user_agent_alias = 'Windows IE 7'

# cookie をファイルから読み込む
agent.cookie_jar.load cookie_path if File.exist? cookie_path

# friends の1ページ目を開く
uri = URI.parse "http://twitter.com/#{target}/friends"
top = agent.get uri

# login 画面に飛ばされたらログインする
if top.uri.path == '/login'
  username = 'dienert'
  password = 'Leao0724!'
  f = top.forms[0]
  f['session[username_or_email]'] = username
  f['session[password]'] = password
  f.checkboxes.name('remember_me').check
  top = f.submit
end

# friends の取得
friends = []
loop do
  page = agent.page

  # ページに書かれているユーザ名をすべて取得
  (page / 'a.uid[@href]').each do |uid|
    friends << uid.inner_text
  end

  # '次へ'ボタンがあれば次のページを開く
  next_button = (page / 'a[@rel*="next"]')
  break if next_button.empty?
  agent.get next_button.attr('href')
end

# 表示
puts friends.join("\n")
puts "#{target} follows #{friends.length} users."

# cookie を保存する
agent.cookie_jar.save_as cookie_path
