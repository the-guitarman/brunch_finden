#encoding: utf-8
#FactoryGirl documentation: https://github.com/thoughtbot/factory_girl/tree/1.3.x

#FactoryGirl.define do
#  sequence :host_name do |n|
#    "www.host#{n}.net"
#  end
#
#  sequence :uniq_name do |n|
#    "unique name nr#{n}"
#  end
#
#  sequence :uniq_rewrite do |n|
#    "rewrite-#{n}"
#  end
#
#  sequence :login do |n|
#    "hans_#{n}"
#  end
#
#  sequence :email do |n|
#    "hans#{n}@example#{n}.xxx"
#  end
#
#  sequence :uniq_id do |n| n end
#  
#  
#  
#
#  factory :frontend_user do |fu|
#    fu.first_name "Bob"
#    fu.name "Dylan"
#    fu.salutation "Mr"
#    fu.login {|u| "#{u.first_name.gsub(/\s/,'-')}-#{u.name.gsub(/\s/,'-')}"}
#    fu.email {|u| "#{u.first_name.gsub(/\s/,'-')}@#{u.name.gsub(/\s/,'-')}.name"}
#    fu.password "zimmerman"
#    fu.password_confirmation "zimmerman"
#    fu.general_terms_and_conditions true
#    fu.message_settings "receive_newsletter"=>"false", "receive_user_messages_from"=>"all"
#    fu.state "confirmed"
#    fu.active true
#  end
#
#  factory :new_frontend_user, :class => FrontendUser do |fu|
#    fu.first_name {generate :uniq_name}
#    fu.name {generate :uniq_name}
#    fu.salutation "Mr"
#    fu.login {generate :login}
#    fu.email {generate :email}
#    fu.password "zimmerman"
#    fu.password_confirmation "zimmerman"
#    fu.general_terms_and_conditions true
#    fu.message_settings "receive_newsletter"=>"false", "receive_user_messages_from"=>"all"
#    fu.state "confirmed"
#    fu.active true
#  end
#
#  factory :backend_user do |bu|
#    bu.first_name "Bob"
#    bu.name "der Baumeister"
#    bu.user_roles "administrator"
#    bu.gender 'male'
#    bu.country 'germany'
#    bu.user_group 1
#    bu.salary_type 0
#    bu.login {|u| "#{u.first_name.gsub(/\s/,'-')}-#{u.name.gsub(/\s/,'-')}"}
#    bu.email {|u| "#{u.first_name.gsub(/\s/,'-')}@#{u.name.gsub(/\s/,'-')}.name"}
#    bu.password "zimmerman"
#    bu.password_confirmation "zimmerman"
#  end
#
#  factory :review do |r|
#    r.destination_type 'Location'
#    r.destination_id 1
#    r.frontend_user_id 1
#    r.value 0.8
#    r.text "Man wühlt in den Gummibärchen, man fühlt sie. Gummibärchen haben eine Konsistenz wie weichgekochter Radiergummi. "*2
#    r.published_at "2011-05-30 15:52:50"
#    r.created_at "2011-05-30 15:52:50"
#    r.updated_at "2011-05-30 15:52:50"
#    r.state 1
#    r.general_terms_and_conditions true
#  end
#
#  factory :complete_review, :class=>Review do |r|
#    r.destination_type 'Location'
#    r.destination_id 1
#    r.frontend_user_id 2
#    r.value 0.8
#    r.title "toller Testbericht fürs testen"
#    r.text "ein wirklich ganz toller Test "*500
#    r.summary "alles wird gut "*10
#    r.pros "toll"
#    r.cons "not so good"
#    r.published_at "2011-05-30 15:52:50"
#    r.created_at "2011-05-30 15:52:50"
#    r.updated_at "2011-05-30 15:52:50"
#    r.state 1
#    r.general_terms_and_conditions true
#    r.recommendation true
#  end
#
#  factory :rating do |rr|
#    rr.review {|a| a.association :review}
#    rr.review_question_id 1
#    rr.value 0.8
#  end
#
#  factory :negative_review_rating, :class=>ReviewRating do |rr|
#    #rr.review {|a| a.association :review}
#    #rr.frontend_user {|a| a.association :frontend_user}
#    rr.value 0.2
#  end
#
#  factory :positive_review_rating, :class=>ReviewRating do |rr|
#    #rr.review {|a| a.association :review}
#    #rr.frontend_user {|a| a.association :frontend_user}
#    rr.value 0.8
#  end
#
#  factory :review_rating, :class=>ReviewRating do |rr|
#    rr.value 0.6
#  end
#
#  factory(:review_comment, {:class => ReviewComment}) do |rc|
#    rc.review {|a| a.association :review}
#    rc.frontend_user {|a| a.association :frontend_user}
#    rc.text "Review comment. This is a comment. "*4
#    rc.general_terms_and_conditions true
#  end
#
#  factory :image do |img|
#    img.title 'Test'
#    img.presentation_type 'location'
#    img.status 'checked'
#    img.data_source_id 1
#    img.image_file File.open("#{Rails.root}/test/data/images/alex_chemnitz.jpg")
#  end
#end




  Factory.define :frontend_user do |fu|
    fu.first_name "Bob"
    fu.name "Dylan"
    fu.salutation "Mr"
    fu.login {|u| "#{u.first_name.gsub(/\s/,'-')}-#{u.name.gsub(/\s/,'-')}"}
    fu.email {|u| "#{u.first_name.gsub(/\s/,'-')}@#{u.name.gsub(/\s/,'-')}.name"}
    fu.password "zimmerman"
    fu.password_confirmation "zimmerman"
    fu.general_terms_and_conditions true
    fu.message_settings "receive_newsletter"=>"false", "receive_user_messages_from"=>"all"
    fu.state "confirmed"
    fu.active true
  end

  Factory.define :new_frontend_user, :class => FrontendUser do |fu|
    fu.first_name {generate :uniq_name}
    fu.name {generate :uniq_name}
    fu.salutation "Mr"
    fu.login {generate :login}
    fu.email {generate :email}
    fu.password "zimmerman"
    fu.password_confirmation "zimmerman"
    fu.general_terms_and_conditions true
    fu.message_settings "receive_newsletter"=>"false", "receive_user_messages_from"=>"all"
    fu.state "confirmed"
    fu.active true
  end

  Factory.define :backend_user do |bu|
    bu.first_name "Bob"
    bu.name "der Baumeister"
    bu.user_roles "administrator"
    bu.gender 'male'
    bu.country 'germany'
    bu.user_group 1
    bu.salary_type 0
    bu.login {|u| "#{u.first_name.gsub(/\s/,'-')}-#{u.name.gsub(/\s/,'-')}"}
    bu.email {|u| "#{u.first_name.gsub(/\s/,'-')}@#{u.name.gsub(/\s/,'-')}.name"}
    bu.password "zimmerman"
    bu.password_confirmation "zimmerman"
  end

  Factory.define :review do |r|
    r.destination_type 'Location'
    r.destination_id 1
    r.frontend_user_id 1
    r.value 0.8
    r.text "Man wühlt in den Gummibärchen, man fühlt sie. Gummibärchen haben eine Konsistenz wie weichgekochter Radiergummi. "*2
    r.published_at "2011-05-30 15:52:50"
    r.created_at "2011-05-30 15:52:50"
    r.updated_at "2011-05-30 15:52:50"
    r.state 1
    r.general_terms_and_conditions true
  end

  Factory.define :complete_review, :class=>Review do |r|
    r.destination_type 'Location'
    r.destination_id 1
    r.frontend_user_id 2
    r.value 0.8
    r.title "toller Testbericht fürs testen"
    r.text "ein wirklich ganz toller Test "*500
    r.summary "alles wird gut "*10
    r.pros "toll"
    r.cons "not so good"
    r.published_at "2011-05-30 15:52:50"
    r.created_at "2011-05-30 15:52:50"
    r.updated_at "2011-05-30 15:52:50"
    r.state 1
    r.general_terms_and_conditions true
    r.recommendation true
  end

  Factory.define :rating do |rr|
    rr.review {|a| a.association :review}
    rr.review_question_id 1
    rr.value 0.8
  end

  Factory.define :image do |img|
    img.title 'Test'
    img.presentation_type 'location'
    img.status 'checked'
    img.data_source_id 1
    img.image_file File.open("#{Rails.root}/test/data/images/alex_chemnitz.jpg")
  end




#Factory.define :rating do |rr|
#  rr.review {|a| a.association :review}
#  rr.review_question_id 1
#  rr.value 0.8
#end
#
#Factory.define :review do |r|
#  r.destination_id 1
#  r.destination_type 'Location'
#  r.frontend_user_id 1
#  r.value 0.8
#  r.text "Man wühlt in den Gummibärchen, man fühlt sie. Gummibärchen haben eine Konsistenz wie weichgekochter Radiergummi. "*2
#  r.published_at "2011-05-30 15:52:50"
#  r.created_at "2011-05-30 15:52:50"
#  r.updated_at "2011-05-30 15:52:50"
#	r.state 1
#  r.general_terms_and_conditions true
#end