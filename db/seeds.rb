require 'jobs/sitemap'
require 'jobs/robots_txt_generator'

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Backend User
#BackendUser.reset_column_information

unless bu = BackendUser.find_by_login('Sebastian')
  ActiveRecord::Migration.execute(
    'INSERT INTO backend_users (' +
      'name, last_request_at, single_access_token, created_at, ' +
      'crypted_password, perishable_token, internal_information, ' +
      'updated_at, salutation, failed_login_count, current_login_ip, ' +
      'password_salt, current_login_at, login_count, persistence_token, ' +
      'birthday, last_login_ip, login, last_login_at, email, first_name, active' +
    ') VALUES(' +
      "'H.', NULL, 'SRECrPqxCu6bjfIQeiIh', '2011-07-21 20:03:17', " +
      "'eed8b6fa6405cac0311cb7ed9642800339f2bc06a856ca525a953af7d5119428e04e2bdd17b85809303b4d98c7bd759c165cac0f81ad5259961f1334f06f024a', 'fgOidjWxRZrdamoP520', NULL, " +
      "'2011-07-21 20:03:17', NULL, 0, NULL, " +
      "'a9uqpzjFcf8L0dANJt4L', NULL, 0, '2303c3271ce7c3a861d14e9768ede5d1376b44a386c990f29a4df203a65f0663f4bc27b7adb1dfcfbd93f5a0e66851082ee3fc0e2396e6a87d7a821f5d007499', " +
      "NULL, NULL, 'Sebastian', NULL, 'sebastianhendygk@gmx.de', 'Sebastian', 1" +
    ')'
  ) #pw:f...g
end

unless bu = BackendUser.find_by_login('Gerd')
  ActiveRecord::Migration.execute(
    'INSERT INTO backend_users (' +
      'name, last_request_at, single_access_token, created_at, ' +
      'crypted_password, perishable_token, internal_information, ' +
      'updated_at, salutation, failed_login_count, current_login_ip, ' +
      'password_salt, current_login_at, login_count, persistence_token, ' +
      'birthday, last_login_ip, login, last_login_at, email, first_name, active' +
    ') VALUES(' +
      "'K.', NULL, 'ex2GNdGYznqfsXxH6Pn', '2011-07-21 20:03:17', " +
      "'863ee24b1ee8a1495e56555a3f8d27a53c28099d38a925c139447ca18c3b2bcfc019b1e157aafd0b09db347646766468aa8c5a2b9bf9a53ec60d05fa35dce1fb', 'ZbGC8k9t8I4XpzRqEsc', NULL, " +
      "'2011-07-21 20:03:17', NULL, 0, NULL, " +
      "'EkGSEdkVjrMnnP6TNzyB', NULL, 0, 'f679b61cebcd136d49c4ef8a93891437a33fb3b50d01f4799e06fb8920d0e126348a7581aebc4dbc37c0453c2d5e3e36a047ee91efbff4b7d011790a40173fdf', " +
      "NULL, NULL, 'Gerd', NULL, 'filmkasten@web.de', 'Gerd', 1" +
    ')'
  ) #pw: t..l
end
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# ------------------------------------------------------------------------------
# URL Forwardings
if Rails.version < '3.0.0'
  include ActionController::UrlWriter
else
  include Rails.application.routes.url_helpers
end

# http ://www .lvh.me:3000/frontend/locations/new
#map.new_location 'neue-brunch-location-eintragen.html', 
#  :controller => 'frontend/locations', :action => :new
Forwarding.create(:source_url => '/locations/new', :destination_url => new_location_path)

# http ://www .lvh.me:3000/frontend/location_suggestions/new
#map.new_location_suggestion 'neue-brunch-location-vorschlagen.html', 
#  :controller => 'frontend/location_suggestions', :action => :new
Forwarding.create(:source_url => '/location_suggestions/new', :destination_url => new_location_suggestion_path)

# http ://www .brunch-finden.de/search
#map.search 'search', 
#  :controller => 'frontend/searches', :action => :search
Forwarding.create(:source_url => '/search', :destination_url => search_path)

# http ://www .brunch-finden.de/index/general_terms_and_conditions
#map.general_terms_and_conditions 'agb.html', 
#  :controller => 'frontend/index', :action => :general_terms_and_conditions
Forwarding.create(:source_url => '/index/general_terms_and_conditions', :destination_url => general_terms_and_conditions_path)

# http ://www .brunch-finden.de/index/privacy_notice
#map.privacy_notice 'datenschutz.html', 
#  :controller => 'frontend/index', :action => :privacy_notice
Forwarding.create(:source_url => '/index/privacy_notice', :destination_url => privacy_notice_path)

# http ://www .brunch-finden.de/index/registration_information
#map.registration_information 'impressum.html', 
#  :controller => 'frontend/index', :action => :registration_information
Forwarding.create(:source_url => '/index/registration_information', :destination_url => registration_information_path)

# http ://www .brunch-finden.de/index/about_us
#map.about_us 'ueber-uns.html', 
#  :controller => 'frontend/index', :action => :about_us
Forwarding.create(:source_url => '/index/about_us', :destination_url => about_us_path)
# ------------------------------------------------------------------------------


# ******************************************************************************
ProjectSitemap.new.run
# ******************************************************************************

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
RobotsTxtGenerator.new.run
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# ------------------------------------------------------------------------------
DataSource.create({:name => DataSource::DEFAULT})
# ------------------------------------------------------------------------------
