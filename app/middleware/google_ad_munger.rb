#
# Google Ads inserts the following three lines of code into the HTML to display
# a banner.
#
#   <script async="async" src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
#   <ins class="adsbygoogle" style="display:inline-block;width:300px;height:75px" data-ad-client="ca-pub-5300497816765420" data-ad-slot="3493070199"></ins>
#   <script> (adsbygoogle = window.adsbygoogle || []).push({}); </script>
#
# Altruistically by removing them in the development environment we protect
# against click fraud, but the reality is that they are simply annoying and
# unecessary.
#
# But we need something to indicate their presence, location, size, and
# accuracy on the page.  This middleware accomplishes that for us by removing
# the the two 'script' lines and replacing the 'ins' with a div of the same
# size, moving the 'data-???' attributes into the content so that the ads can
# be validated by inspection.
# 
# This middleware is invoked by adding the following to
# config/environments/deploy.rb:
#
#   config.middleware.use 'GoogleAdMunger'
#
class GoogleAdMunger

  def initialize(app)
    @app = app

    # Define the regexp for the items we wich to remove.  Note the last one
    # contains matches.  This regexp isn't very robust, but we control the HTML
    # so don't have to worry about multiple line issues and spacing.
    @regexp = Regexp.new(
      Regexp.escape(%q!<script async="async" src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>!) + 
      '|' +
      Regexp.escape(%q!<script> (adsbygoogle = window.adsbygoogle || []).push({}); </script>!) +
      '|' +
      %q!<ins class="adsbygoogle" style="(.*?)" (.*)?></ins>!
    )

    # Define what we want to happen to the matched lines.  If it's the `ins`
    # tag replace it with our custom div.  Otherwise replace it with an empty
    # string.
    @regexp_block = ->(m, style, data) do
      m =~ /<ins / ? %Q!<div style="#{style}; background-color: #cccccc; border: 1px solid #333333; font-size: 9px; line-height: 1em;">Google Ad: #{data}</div>! : ''
    end

  end
  
  def call(env)
    status, headers, response = @app.call(env)

    # Technically the development check is redundant, but someone may try to
    # include the middleware elsewhere.  Also, only do it for html requests.
    if Rails.env.development? && headers['Content-Type'] =~ %r!text/html!

      # Get the current body.  Rack is a little weird, hence the .each block.
      body = '' 
      response.each {|e| body << e}

      # Run our replacements.  If the grouped matches change above
      # change them here as well.  Not ideal, but it works.
      body.gsub!(@regexp) {|m| @regexp_block.call(m, $1, $2) }

      # Return the response satisfying Rack's need for .each.
      response = [body]
    end

    [status, headers, response]
  end

end
