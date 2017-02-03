class FollowingJson

    attr_reader :min_position
    attr_reader :has_more_items
    attr_reader :items_html
    attr_reader :new_latent_count

    def initialize (min_position, has_more_items, items_html, new_latent_count)
      @min_position = min_position
      @has_more_items = has_more_items
      @items_html = items_html
      @new_latent_count = new_latent_count
    end

end
