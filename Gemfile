source 'https://rubygems.org'
#source :gemcutter # marked as deprecated

gem 'rake', '0.9.2.2'

gem 'bundler'
gem "rails", '2.3.15' #"2.3.8"
gem "mongrel", "1.1.5"
gem "mongrel_cluster", "1.0.5"
gem 'puma'
gem 'subdomain_routes', '~> 0.3.1'
gem 'unicorn'

#gem 'rails', '3.0.4'
# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem "mysql", "2.8.1"
#gem "mysql2", "0.2.7"

# packed (:cache => true) js and css compressor
#gem 'smurf', '1.0.8'

gem 'sitemap_generator'

#gem 'cache_generator'

# Build nice looking sentences from ugly formatted strings.
# Check if other strings or even words or whole sentences are included in the text.
# Compare texts for similarity.
gem 'ActionText', '1.2.2', :git => 'git://github.com/the-guitarman/ActionText.git'

#gem 'acts_as_tree'
#gem 'acts_as_taggable_on_steroids', :git=> 'git://github.com/jviney/acts_as_taggable_on_steroids.git'
gem 'aasm', '3.0.14'
gem 'authlogic', "2.1.6"
#gem 'authlogic' ,:git=> "git://github.com/jjb/authlogic.git" #rails3 compatible
#gem 'bartt-ssl_requirement'
gem 'cancan'
# dead-simple string encryption library
gem "encrypted_strings", "~> 0.3.3"
# concurency / use fibers with event machine (rails3): -------------------------
#gem 'em-resolv-replace'
#gem 'rack-fiber_pool'
#gem 'evented-memcache-client'
#gem 'starling'
# concurency gems end ----------------------------------------------------------
#gem 'cells' #rails3 compatible
gem 'htmlentities'
#gem 'iconv'
gem 'json'
#gem 'hpricot'
gem 'rmagick', '2.13.1' # install before: sudo apt-get install imagemagick, libmagick9-dev
gem 'fleximage', '1.0.4'
#gem 'fleximage', :git=>"git://github.com/hewo/fleximage.git" #rails3 compatible
#gem 'fleximage', :git=>"https://github.com/hewo/fleximage.git" #rails3 compatible
#gem 'geokit', '1.6.5' #, '1.5.0'
#gem 'geokit-rails3'
#gem 'gmaps4rails'
gem "geocoder", :branch  => 'rails2'
#gem 'libxml-ruby'
gem 'money', '3.6.1'
gem "nokogiri", '1.4.4'
gem 'sanitize', '2.0.3'
#gem 'sanitize', :git=>"git@github.com:the-guitarman/sanitize.git"
#gem 'sanitize', :git=>"https://github.com/the-guitarman/sanitize.git"
gem 'will_paginate', '2.3.15'
gem 'ya2yaml', '0.30'
#gem 'ym4r', '0.6.1'
#gem 'ym4r_gm' ,:group=>:post_init#, :git => 'git://github.com/guilleiguaran/ym4r_gm.git' #Rails 3 repo

# DynamicForm holds a few helper methods to help you deal with your models.
# They are removed from rails 3. 
#gem 'dynamic_form'
# This gem adds support for form_remote_tag, link_to_remote, etc from Rails 2 to Rails 3.
#gem 'prototype_legacy_helper', '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git'
#gem 'will_paginate', '~> 3.0.pre2'


# bundler requires these gems in all environments
# gem "nokogiri", "1.4.2"

#gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"

#gem 'wirble'
gem 'amount_field', '1.4.2'
#gem 'amount_field', git:"git://github.com/hewo/amount_field.git"
#gem 'amount_field', "https://github.com/hewo/amount_field.git"
#gem 'wizardly'
#gem 'wizardly', git:"git://github.com/hewo/wizardly.git"
#gem 'wizardly', "https://github.com/hewo/wizardly.git"
#gem 'enumerated_attribute'
#gem 'units', :git=>'git://github.com/woahdae/units.git'
#gem "sqlite3-ruby", :lib => "sqlite3"


#ThinkingSphinx
#gem 'thinking-sphinx' #, '2.0.0', :require => 'thinking_sphinx'
#gem 'thinking-sphinx', '1.3.14' #, :require => 'thinking_sphinx'
gem 'thinking-sphinx', '1.4.10' #, :require => 'thinking_sphinx'
#gem 'thinking-sphinx',
#  :git     => 'git://github.com/freelancing-god/thinking-sphinx.git',
#  :branch  => 'rails3',
#  :require => 'thinking_sphinx'
gem 'thinking-sphinx-raspell', '1.1.1', :require => 'thinking_sphinx/raspell'

# jQuery 
# For Rails 3.1, add these lines to the top of your app/assets/javascripts/application.js file:
# //= require jquery
# //= require jquery_ujs
# For Rails 3.0, run this command (add --ui if you want jQuery UI):
# Be sure to get rid of the rails.js file if it exists, and instead use the new jquery_ujs.js file that gets copied to the public directory. Choose to overwrite jquery_ujs.js if prompted.
# $ rails generate jquery:install
#gem 'jquery-rails'


# Use unicorn as the web server
#gem 'psych'
#gem 'tmail'
#gem 'tzinfo'
#gem 'unicorn'
# Use rainbows as the web server
#gem 'rainbows'
# Use thin as the web server
#gem 'thin'
#libraries for rainbows server:
#gem 'rev'
#gem 'cool.io'


# Deploy with Capistrano
# gem 'capistrano'


# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'


# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'


group :development do
  #gem 'pry'
  #gem 'pry-doc'
  #gem 'pry-rails'
  
  # bundler requires these gems in development
  # gem "rails-footnotes"

  #gem 'webrat'
  
  #  gem 'rspec-rails', '2.3.0'
  #gem "rails-erd"
  
  #gem 'rack-mini-profiler'
end


group :test do
  ruby = `ruby -v`
  if (ruby.match(/ruby 1\.8/))
    gem 'ruby-debug'
  elsif (ruby.match(/ruby 1\.9/))
    gem 'ruby-debug19'
  end
  # bundler requires these gems while running tests
  # gem "rspec"
  # gem "faker"

  gem 'factory_girl', '1.3.3'
  #gem 'factory_girl_rails'
  gem 'shoulda'
  #gem 'rspec', '2.3.0'

  gem 'test-unit', '1.2.3'
  #gem 'test-unit', '2.3.0'
  #gem 'ruby-prof'
  #gem 'hoe', '2.8.0'
end

