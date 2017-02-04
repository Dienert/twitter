class TwitterUser

  attr_reader :user_id
  attr_reader :screen_name
  attr_reader :profile
  attr_reader :user_bio
  attr_reader :url_profile_picture


  def initialize (user_id, screen_name, profile, user_bio, url_profile_picture)
    @user_id = user_id
    @screen_name = screen_name
    @profile = profile
    @user_bio = user_bio
    @url_profile_picture = url_profile_picture
  end

  def to_s
    return "Usuário: " + @screen_name +
           "\nId: " + @user_id +
           "\nPerfil: @" + @profile +
           "\nBio: " + @user_bio +
           "\nFoto: " + @url_profile_picture
  end

  def to_cvs_line
    column_separator = "|"
    return @screen_name + column_separator +
         @user_id + column_separator +
         @profile + column_separator +
         @user_bio + column_separator +
         @url_profile_picture
  end

end
