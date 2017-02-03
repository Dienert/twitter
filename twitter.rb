require 'mechanize'
require_relative 'TwitterUser'
require_relative 'FollowingJson'
require_relative 'utils'
require 'htmlentities'
require 'json'

def process_following_page(following_doc)
  following_doc.xpath('.//div[contains(@class, "ProfileCard js-actionable-user")]').each do |profile_card|
    url_profile_picture = profile_card.xpath('.//img[contains(@class, "ProfileCard-avatarImage")]/@src').to_s
    user_bio = profile_card.xpath('.//p[@class="ProfileCard-bio u-dir js-ellipsis"]/text()').to_s.gsub(%r{\r\n|\n}, "")
    user_bio = HTMLEntities.new.decode(user_bio)
    user_infos = profile_card.xpath('.//div[contains(@class, " following ") or contains(@class, " not-following ")]')
    begin
      profile = user_infos.attr('data-screen-name').to_s
      screen_name = user_infos.attr('data-name').to_s
      user_id = user_infos.attr('data-user-id').to_s
      Utils.resultado.write TwitterUser.new(user_id, screen_name, profile, user_bio, url_profile_picture).to_cvs_line
      Utils.resultado.puts @string
      Utils.setFollowingNumber(Utils.followingNumber + 1)
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
        Utils.save_result_page profile_card.to_s
#        exit
    end
  end
end

def process_json_following(following_json)
  obj = JSON.parse(following_json)
  return FollowingJson.new(obj['min_position'], obj['has_more_items'],  obj['items_html'], obj['new_latent_count'])
end

Utils.initialize

request_url = Utils.appUrl + Utils.profile + "/following"
puts request_url
following_page = Utils.agent.get(request_url).content.to_s
following_doc = Nokogiri::HTML(following_page)
next_data_min_position = following_doc.xpath('.//div[contains(@class,"GridTimeline-items")]/@data-min-position').to_s

begin
  process_following_page(following_doc)
  request_next_following_page =
  "https://twitter.com/" + Utils.profile + "/following/users?include_available_features=1&include_entities=1&max_position=" + next_data_min_position.to_s + "&reset_error_state=false"
  following_json = Utils.agent.get(request_next_following_page).content.to_s
  followinJson = process_json_following(following_json)
  following_page = followinJson.items_html
  next_data_min_position = followinJson.min_position
end while followinJson.has_more_items

following_doc = Nokogiri::HTML(following_page)
process_following_page(following_doc)
puts 'Seguindo ' + Utils.followingNumber.to_s + ' perfis'
