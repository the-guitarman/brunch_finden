class Frontend::SocialController < Frontend::FrontendController
  def show
    id = params[:id].to_i
    @partial = nil
    ['facebook_like_box', 'facebook_like_button', 'google_plus'].each do |partial|
      if partial.to_crc32 == id
        @partial = partial
      end
    end
  end
end