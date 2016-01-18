{
  :en => {
    :page_header_tags => {
      :defaults => {
        :frontend => {
          :logged_in => {
            :title       => 'Community',
            :description => '%{domain_name} helps you to compare prices on the most popular products. Read unbiased product reviews from consumers just like you.',
            :keywords    => 'comparison shopping, online shopping, consumer reviews, product ratings, store ratings, product reviews, online shopping'
          },
          :logged_out => {
            :title       => '%{domain_name} - The Shopping Community, Product and Store Reviews, Online Shopping Guide, Comparison Shopping',
            :description => '%{domain_name} helps you to compare prices on the most popular products. Read unbiased product reviews from consumers just like you.',
            :keywords    => 'comparison shopping, online shopping, consumer reviews, product ratings, store ratings, product reviews, online shopping'
          }
        },
        :mobile => {
          :logged_in => {
            :title       => 'Community',
            :description => '%{domain_name} helps you to compare prices on the most popular products. Read unbiased product reviews from consumers just like you.',
            :keywords    => 'comparison shopping, online shopping, consumer reviews, product ratings, store ratings, product reviews, online shopping'
          },
          :logged_out => {
            :title       => '%{domain_name} - The Shopping Community, Product and Store Reviews, Online Shopping Guide, Comparison Shopping',
            :description => '%{domain_name} helps you to compare prices on the most popular products. Read unbiased product reviews from consumers just like you.',
            :keywords    => 'comparison shopping, online shopping, consumer reviews, product ratings, store ratings, product reviews, online shopping'
          }
        }
      },
      :states => {
        :title_addition => 'Cities beginning with %{start_char}'
      }
    },
    :layouts => {
      :mobile => {
        :standard => {
          :general_terms_and_conditions => 'Terms &amp; Conditions',
          :new_location_suggestion => "Suggest A Location",
          :privacy_notice => 'Privacy Notice',
          :registration_information => 'Registration Information'
        }
      }
    },
    # custom common translations
    :shared => {
      :advertisement => 'Ad',
      :all => 'All',
      :asterisk_note => 'Required fields are marked with an asterisk %{image}',
      :breadcrumb => {
        :controller => {
          :cities => {
            :show => 'Brunch-Locations',
            :compare_prices => 'Compare Brunch-Locations'
          },
          :index => {
            :about_us => 'About Us',
            :advertising_opportunities => 'Advertising Opportunities',
            :general_terms_and_conditions => 'General Terms And Conditions',
            :privacy_notice => 'Privacy Notice',
            :registration_information => 'Registration Information'
          },
          :locations => {
            :confirm => 'Location Confirmation',
            :create => 'Save A New Location',
            :new => 'Save A New Location'
          },
          :location_images => {
            :confirm => 'Image Upload Confirmation',
            :create => 'Image Upload',
            :new => 'Image Upload'
          },
          :location_suggestions => {
            :new => 'Suggest A New Brunch Location'
          },
          :reviews => {
            :new => 'New Rating'
          },
          :searches => {
            :search => 'Search'
          },
          :states => {
            :show => 'Cities'
          }
        },
        :controllers => {
          :errors => 'Error'
        }
      },
      :captcha => {
        :description => 'Please type in the code from the image.',
        :error  => 'Sorry, the code was wrong.',
        :label  => 'Security Code',
        :reload => 'Get a new code'
      },
      :coupons => {
        :kind => {
          :discount    => 'Discount',
          :competition => 'Competition',
          :gratis      => 'Gratis Or Product Test',
          :offer       => 'Offer'
        },
        :by => 'at',
        :coupon_not_found => 'The requested certificate is no longer available.',
        :remaining_days => {
          :zero => "today",
          :one => "1 day",
          :other => "%{count} days"
        },
        :only_valid_for => 'only valid for %{remaining_days}!',
        :valid_for => 'valid for %{remaining_days}!'
      },
      :close => {
        :text_message => 'Close'
      },
      :for => 'for',
      :frontend_user => {
        :small_notes => {
          :name  => '(public)',
          :email => '(not public)'
        },
        :image => {
          :exemplary => 'image exemplary'
        }
      },
      :general_terms_and_conditions_confirmation => 'Yes, I read the %{link}.',
      :location => {
        :report_changes => {
          :changes_received => 'We received your changes request.<br /><br />Thank You!<br />The service team of %{domain_name}'
        }
      },
      :location_image => {
        :confirmed => {
          :message => 'Your image has been confirmed now.<br /><br />However, if an image does not agree with our terms and conditions, we will lock or remove it.<br /><br />Thank You!<br />The service team of %{domain_name}'
        },
        :created => {
          :message => 'We saved your image successfully.<br /><br />We sent you an email with an link to confirm your image. Without confirmation, we will remove the image after about %{unpublished_valid_for} hours.<br /><br />The %{domain_name} team will check all images. If an image does not agree with our terms and conditions, we will lock or remove it. You can now upload another image.'
        },
        :deleted => {
          :message => 'We deleted the image successfully.<br /><br />Thank You!<br />The service team of %{domain_name}'
        },
        :submit => {
          :publish => 'Upload Now'
        }
      },
      :na => '&nbsp;',
      :new_review => {
        :created => {
          :message    => 'We saved your rating.',
          :logged_out => 'We sent you an email with an link to confirm your rating.<br /><br />Thank you.'
        },
        :please_select => 'please select',
        :value => 'Total Rating',
        :submit => {
          :publish => 'Publish Now'
        }
      },
      :search => {
        :headline => 'Search',
        :locations  => 'Found Brunch-Locations (%{number})',
        :cities     => 'Found Cities (%{number})',
        :did_you_mean => 'Did you mean',
        :button_text => 'Search',
        :field_default_value => 'Name, City, Zip Code',
        :no_search_string => 'Oh no, without a keyword we can not find anything.',
        :no_search_string_options => 'Search within our database for',
        :no_search_string_try_again => 'Please try it again.',
        :no_search_phrase_error => 'Please enter a search phrase.',
        :no_result  => 'Your search for <span class="search-string">"%{search_string}"</span> has no result.',
        :result_for => 'Your search for <span class="search-string">"%{search_string}"</span> has %{number} results.',
        :reporter => {
          :no_searches => 'There are no search queries to report.'
        }
      },
      :page => 'Page',
      :routes => {
        :compare_prices_in_city          => 'compare-prices',
        :coupon_category                 => 'coupon-category',
        :coupon_categories               => 'all-coupon-categories',
        :coupon                          => 'coupon',
        :coupons                         => 'coupons',
        :rewrite_prefix_city             => 'brunch',
        :new_location                    => 'enter-a-new-brunch-location',
        :new_location_suggestion         => 'suggest-a-new-brunch-location',
        :new_captcha                     => 'new-captcha',
        :privacy_notice                  => 'privacy-notice',
        :registration_information        => 'registration-information',
        :about_us                        => 'about-us',
        :general_terms_and_conditions    => 'general-terms-and-conditions',
        :advertising_opportunities       => 'advertising-opportunities',
      },
      :geokit => {
        :default_units => 'miles',
        :current_unit  => 'miles'
      },
      :price => {
        :changes_possible => 'Prices may have changed. All statements made ​​without guarantee.'
      },
      :yes => 'Yes',
      :no  => 'No',
      :salutations => ['Ms', 'Mr'],
      :pagination  => {
        :previous_label => 'Previous',
        :next_label     => 'Next',
        :entries => {
          :zero  => 'No entries found',
          :one   => '1 entry',
          :other => 'all %{count} entries'
        }
      },
      :login_required    => 'Please login to access this page!',
      :logout_required   => 'Please logout to access this page!',
      :password_strength => {
        :bad       => 'low',
        :medium    => 'middle',
        :good      => 'good',
        :very_good => 'very good',
        :passwort_and_confirmation_not_equal => 'Password confirmation is not equal to password.'
      },
      :where_i_am => "Where I am?",
      :wizardly => {
        :button_next   => 'Next',
        :button_back   => 'Back',
        :button_cancel => 'Cancel',
        :button_finish => 'Finish'
      },
      :countries => {
        :germany        => 'Germany',
        :austria        => 'Austria',
        :switzerland    => 'Switzerland',
        :france         => 'France',
        :spain          => 'Spain',
        :portugal       => 'Portugal',
        :liechtenstein  => 'Liechtenstein',
        :norway         => 'Norway',
        :belgium        => 'Belgium',
        :netherlands    => 'Netherlands',
        :united_kingdom => 'United Kingdom',
        :ireland        => 'Ireland',
        :hong_kong      => 'Hong Kong',
        :poland         => 'Poland',
        :denmark        => 'Denmark'
      },
      :saved_successfully => 'Saved successfully.',      
      :stars => {
        :no => 'There is no rating for %{destination_name} available',
        :out_of_stars_1 => '%{count} of %{total} Stars',
        :out_of_stars_2 => '%{count} of %{total} Stars'
      },
      :read_more_text => 'more',
      :read_less_text => 'less',      
      :the_team_of => 'The team of %{domain_name}',
      :the_service_team_of => 'The service team of %{domain_name}'
    },
    
    :config => {
      :background => {
        :coupon_handler => {
          :answer_types => {
            :data         => 'Date has detailed format',
            :list         => 'Data has list format',
            :detailed     => 'Data has detailed format',
            :empty        => 'Data is empty',
            :forbidden    => 'User-ID (uid) invalid for the given ip address',
            :format_error => 'Wrong format requested',
            :error        => 'Another error occured'
          }
        }
      }
    },
    
    :frontend => {
      :cities => {
        :show => {
          :brunch_h1 => 'Brunch Locations %{city_name}',
          :brunch_h2 => '%{number_of_locations} Brunch Locations in %{city_name}',
          :brunch_h3 => 'Brunch Locations in %{city_name}',
          :all_locations => 'Compare Brunch Locations %{city_name}',
          :no_locations => "Für %{city_name} haben wir leider noch keine Brunch-Locations.",
          :new_location => "New Location"
        }
      },
      :common => {
        :responsive_navbar => {
          :general_terms_and_conditions => 'Terms &amp; Conditions',
          :registration_information => 'Registration Information',
          :about_us => 'About Us',
          :new_location => 'New Location',
          :new_location_suggestion => "Suggest A Location",
          :privacy_notice => 'Privacy Notice'
        },
        :responsive_footer => {
          :general_terms_and_conditions => 'Terms &amp; Conditions',
          :privacy_notice => 'Privacy Notice',
          :registration_information => 'Registration Information',
          :advertising_opportunities => 'Advertising Opportunities'
        }
      },
      :coupon_categories => {
        :index => {
          :coupon_categories => 'All Coupon Categories',
          :new_coupons       => 'New Coupons From All Categories'
        },
        :show => {
          :all_category_coupons => 'All Coupons In %{category} - Page %{page}',
          :no_coupons_available => 'At the moment there are no coupons within this category available.'
        }
      },
      :coupons => {
        :index => {
          :show_more_coupons => "All Coupon Categories",
          :coupon_merchants  => 'All Coupon Suppliers'
        },
        :all_coupon_merchants => {
          :headline_h1 => 'All Coupon Merchants from 0-9 and A-Z',
          :headline_h2 => 'All Coupon Merchants from 0-9 and A-Z',
          :headline_h3 => 'All Coupon Merchants from 0-9 and A-Z'
        },
        :all_merchant_coupons => {
          :headline_h1 => 'All %{merchant_name} Coupons - Page %{page}',
          :headline_h2 => 'All %{merchant_name} Coupons - Page %{page}',
          :headline_h3 => 'All %{merchant_name} Coupons - Page %{page}',
          :no_merchant_coupons_available => 'At the moment there are no coupons for %{merchant_name} available.'
        }
      },
      :errors => {
        :show => {
          :error_404 => 'Sorry, page not found.',
          :error_500 => 'Sorry, an error occured.',
          :error_unknown => 'Sorry, an error occured.'
        }
      },
      :location_images => {
        :new => {
          :button_image_upload => 'Upload'
        }
      },
      :locations => {
        :new => {
          :headline          => 'Register a new location',
          :note              => 'Note',
          :chapter_where     => 'Where is it?',
          :chapter_where_note_text => 'Enter zip code - select city - enter street<br />(this data we will use the geo code the new brunch location)',
          :chapter_what      => "What's there?",
          :chapter_what_note_text => 'What other users should know about the brunch location. How much is it? Opening hours and brunch times? Additional services?',
          :chapter_about_you => 'Something about you.',
          :chapter_about_you_note_text => 'Please give us some information about you. We need to know who you are, in order to protect these sites from spam and illegal content. This data will not be passed to any other person. We use it exclusively for the launch of the new brunch location. Therefor you will receive one e-mail, not more.',
          :chapter_ready => "Ok, that's it.",
          :button_preview => 'Preview',
          :button_save => 'Save'
        },
        :show => {
          :address => 'Address',
          :at_the_map => '%{name} At The Map',
          :more_locations => 'More Brunch Locations'
        },
        :confirm => {
          :text => "The new brunch location '%{name}' has successfully confirmed.<br /><br />Thank you for your help.<br /><br />See the new entry: %{link}",
          :error => 'Sorry, an error occured.<br />We found no brunch-location to confirm.<br /><br />The Service Team of %{domain_name} has been notified.'
        },
        :create => {
          :text => 'Location created. We sent you an email to confirm it.<br /><br />Thank you.'
        }
      },    
      :location_suggestions => {
        :new => {
          :headline => 'Suggest A New Brunch-Location',
          :note => 'Note',
          :chapter_what_note_text => "Really, your are missing a brunch location site?<br /><br />Tell us name and select a city and we try to bring it online soon.",
          :button_preview => 'Preview',
          :button_save => 'Save'
        },
        :create => {
          :text => 'We received your brunch location suggestion successfully.<br /><br />Thank you.'
        }
      },
      :index => {
        :ct_city_with_most_locations => {
          :cities_with_most_locations => 'Cities With Most Locations'
        },
        :ct_facebook_like_box => {
          :facebook_like_box => '%{domain_name} At Facebook'
        },
        :about_us => {
          :headline => 'About Us'
        },
        :advertising_opportunities => {
          :headline => 'Advertising Opportunities At %{domain_name}'
        },
        :general_terms_and_conditions => {
          :headline => 'General Terms And Conditions'
        }, 
        :index => {
          :headline_latest_locations => 'Latest Brunch Locations',
          :headline_latest_reviews => 'Latest Reviews',
          :lastest_coupons   => 'Latest Coupons',
          :show_more_coupons => 'Show More Coupons'
        },
        :registration_information => {
          :headline => 'Registration Information',
          :privacy_notice => 'Privacy Notice'
        },
        :privacy_notice => {
          :headline => 'Privacy Notice'
        }
      },
      :password_reset_requests => {
        :new => {
          :headline => 'Forgot your password?'
        },
        :create => {
          :headline => 'Forgot your password?'
        },
        :edit => {
          :headline => 'Your new password'
        },
        :update => {
          :headline => 'New password saved!'
        }
      },
      :reviews => {
        :confirm => {
          :text => "The new rating for '%{name}' has successfully confirmed.<br /><br />Thank you for your help.<br /><br />See the new entry: %{link}",
          :error => 'Sorry, an error occured.<br />We found no rating to confirm.<br /><br />The Service Team of %{domain_name} has been notified.'
        },
        :new => {
          :headline => 'Write a review'
        }
      },
      :searches => {
        :search => {
          :new_location => "Add a new location now ...",
        }
      },
      :states => {
        :show => {
          :brunch_h1 => 'Brunch %{state_name} - Cities with %{start_char}',
          :brunch_h2 => 'Brunch in %{state_name} in %{number_of_locations} Locations - %{current_number_of_locations} %{location} in cities with %{start_char}',
          :brunch_h3 => 'Brunch %{state_name} - Cities with %{start_char}',
          :number_of_locations_for_char => "%{number_of_locations} Brunch-Locations"
        }
      }
    },
    
    :mobile => {
      :index => {
        :general_terms_and_conditions => {
          :headline => 'General Terms And Conditions'
        }, 
        :registration_information => {
          :headline => 'Registration Information',
          :privacy_notice => 'Privacy Notice'
        },
        :privacy_notice => {
          :headline => 'Privacy Notice'
        }
      },
      :locations => {
        :show => {
          :address => 'Address'
        }
      }
    },

    :mailers => {
      :admin_mailer => {
        :report_error => {
          :subject => 'Error at %{domain_name}'
        },
        :report_search_queries => {
          :subject => 'Searched words and phrases at %{domain_name}'
        }
      },
      :frontend => {
        :frontend_user_mailer => {
          :confirmation_code => {
            :subject => 'Please confirm your registration'
          },
          :email_confirmation_code => {
            :subject => 'Change account email'
          },
          :password_reset_instructions => {
            :subject => 'Your new password at %{domain_name}'
          },
          :confirmation_reminder => {
            :subject => '%{number}. reminder to confirm your registration'
          }
        },
        :location_mailer => {
          :confirm_location => {
            :subject => 'Your Brunch-Location-Entry at %{domain_name}'
          },
          :confirm_location_image => {
            :subject => 'Your Image Upload at %{domain_name}'
          },
          :report_changes => {
            :subject => "Brunch-Location-Changes reported"
          }
        },
        :location_suggestion_mailer => {
          :location_suggestion => {
            :subject => 'Brunch-Location-Suggestion'
          }
        },
        :review_mailer => {
          :confirmation_code => {
            :subject => "Confirm Your Review for %{item_name}"
          },
          :confirmation_reminder => {
            :subject => "Reminder To Confirm Your Review for %{item_name}"
          }
        }
      }
    },

    # extend but don't delete anything
    :date => {
      :formats => {
        :default => "%d/%m/%Y",
        :short => "%e %b",
        :long => "%e %B, %Y",
        :long_ordinal => lambda { |date| "#{date.day.ordinalize} %B, %Y" },
        :only_day => "%e"
      },
      :day_names => Date::DAYNAMES,
      :abbr_day_names => Date::ABBR_DAYNAMES,
      :month_names => Date::MONTHNAMES,
      :abbr_month_names => Date::ABBR_MONTHNAMES,
      :order => [:year, :month, :day]
    },
    :time => {
      :formats => {
        :date => "%d/%m/%Y",
        :default => "%a %b %d %H:%M:%S %Z %Y",
        :time => "%H:%M",
        :short => "%d %b %H:%M",
        :latest_reviews => "%d/%m/%Y %H:%M",
        :long => "%d %B, %Y %H:%M",
        :long_ordinal => lambda { |time| "#{time.day.ordinalize} %B, %Y %H:%M" },
        :only_second => "%S",
        :log_file => "%d.%m.%Y, %H:%M:%S Uhr"
      },
      :datetime => {
        :formats => {
          :default => "%Y-%m-%dT%H:%M:%S%Z"
        }
      },
      :time_with_zone => {
        :formats => {
          :default => lambda { |time| "%Y-%m-%d %H:%M:%S #{time.formatted_offset(false, 'UTC')}" }
        }
      },
      :am => 'am',
      :pm => 'pm'
    },
    :datetime => {
      :distance_in_words => {
        :half_a_minute => 'half a minute',
        :less_than_x_seconds => {:zero => 'less than a second', :one => 'less than a second', :other => 'less than %{count} seconds'},
        :x_seconds => {:one => '1 second', :other => '%{count} seconds'},
        :less_than_x_minutes => {:zero => 'less than a minute', :one => 'less than a minute', :other => 'less than %{count} minutes'},
        :x_minutes => {:one => "1 minute", :other => "%{count} minutes"},
        :about_x_hours => {:one => 'about 1 hour', :other => 'about %{count} hours'},
        :x_days => {:one => '1 day', :other => '%{count} days'},
        :about_x_months => {:one => 'about 1 month', :other => 'about %{count} months'},
        :x_months => {:one => '1 month', :other => '%{count} months'},
        :about_x_years => {:one => 'about 1 year', :other => 'about %{count} years'},
        :over_x_years => {:one => 'over 1 year', :other => 'over %{count} years'}
      }
    },
    :number => {
      :format => {
        :precision => 2,
        :separator => ',',
        :delimiter => '.'
      },
      :currency => {
        :format => {
          :unit => '£',
          :iso_code => 'GBP',
          :precision => 2,
          :format => '%u%n'
        }
      }
    },

    # Active Record
    :activerecord => {
      :models => {
        # User.human_name returns 'User'
        :aggregated_review => {
          :one => 'Total Review',
          :other => 'Total Reviews'
        },
        :city => {
          :one => 'City',
          :other => 'Cities'
        },
        :coupon => {
          :one => 'Coupon',
          :other => 'Coupons'
        },
        :coupon_category => {
          :one => 'Coupon-Category',
          :other => 'Coupon-Categories'
        },
        :frontend_user => {
          :one => 'User',
          :other => 'Users'
        },
        :geo_location => {
          :one => 'Geo Location',
          :other => 'Geo Locations'
        },
        :location_image => {
          :one => 'Image',
          :other => 'Images'
        },
        :location => {
          :one => 'Brunch-Location',
          :other => 'Brunch-Locations'
        },
        :review => {
          :one => 'Review',
          :other => 'Reviews'
        },
        :state => {
          :one => 'State',
          :other => 'States'
        },
        :zip_code => {
          :one => 'Zip Code',
          :other => 'Zip Codes'
        }
      },
      :attributes => {
        # User.human_attribute_name(:login) returns 'Benutzername'
        :coupon => {
          :code  => 'Coupon-Code',
          :minimum_order_value => 'Minimum order value',
          :only_new_customer => 'Available for new customers only',
          :valid => 'Validity Period'
        },
        :frontend_user => {
          :_general_terms_and_conditions => 'Yes, I read the %{general_terms_and_conditions} and I accept it.',
          :_name => 'Name',
          :about_user_long => 'About me',
          :about_user_short => 'Motto',
          :author  => 'Name',
          :birthday => 'Birthday',
          :confirmation_code => 'Bestätigungscode',
          :email => 'Email',
          :first_name => 'Vorname',
          :general_terms_and_conditions  => 'General Terms And Conditions',
          :login_or_email => 'Login or Email',
          :login => 'Login',
          :name => 'Name',
          :password => 'Passwort',
          :password_confirmation => "Passwort confirmation",
          :remember_me => "Next time log me in automatically."
        },
        :location_image => {
          :general_terms_and_conditions => 'Terms &amp; Conditions',
          :image_file => 'Image'
        },
        :location => {
          :name              => 'Name',
          :zip_code          => 'Zip Code',
          :zip_code_id       => 'Zip',
          :street            => 'Street and Number',
          :description       => 'Description',
          :opening_hours     => 'Opening Hours',
          :brunch_time       => 'Times To Brunch',
          :service           => 'Service',
          :price             => 'Price Per Person',
          :price_information => 'Additional Price Info',
          :phone             => 'Phone',
          :email             => 'Email',
          :general_terms_and_conditions_confirmed => 'Terms &amp; Conditions',
          :website           => 'Website'
        },
        :location_suggestion => {
          :name => 'Name',
          :city => 'City',
          :information => 'More Information'
        },
        :review => {
          :general_terms_and_conditions => 'General Terms And Conditions'
        }
      },
      :errors => {
        :template => {
          :header => {
            :one => "Couldn't save this %{model}: 1 error",
            :other => "Couldn't save this %{model}: %{count} errors."
          },
          :body => "Please check the following fields, dude:"
        },
        :models => {
          :frontend_user => {
            :attributes => {
              :birthday => {
                :invalid => 'Your birthday is invalid.'
              },
              :email => {
                :bad_word  => 'Your email includes a blacklisted word (%{word}).',
                :blank     => 'Please type the your email.',
                :too_long  => "Deine E-Mail ist zu lang (nicht mehr als %{count} Zeichen).",
                :too_short => "Deine E-Mail ist zu kurz (nicht weniger als %{count} Zeichen).",
                :taken => 'A member with this email exists.'
              },
              :first_name => {
                :blank => 'Please enter your first name.',
                :bad_word => 'Your first name includes a blacklisted word (%{word}).'
              },
              :general_terms_and_conditions => {
                :accepted => 'Please confirm, that you read the general terms and conditions.'
              },
              :login => {
                :bad_word => 'Your login includes a blacklisted word (%{word}).',
                :blank => 'Please enter a login name.',
                :taken => 'A member with this login exists.'
              },
              :name => {
                :bad_word  => 'Your name includes a blacklisted word (%{word}).',
                :blank     => "What's your name?",
                :too_long  => "Dein Name ist zu lang (nicht mehr als %{count} Zeichen).",
                :too_short => "Dein Name ist zu kurz (nicht weniger als %{count} Zeichen)."
              },
              :new_email => {
                :bad_word => 'Your new email includes a blacklisted word (%{word}).',
                :blank => 'Please enter your new email.',
                :taken => 'A member with this email exists.'
              }, 
              :password => {
                :bad_word => 'Your password includes a blacklisted word (%{word}).',
                :confirmation => "Password and confirmation are not the same.",
                :too_short => "The password needs at least %{count} characters."
              },
              :password_confirmation => {
                :too_short => "The password needs at least %{count} characters."
              }
            }
          },
          :location_image => {
            :attributes => {
              :general_terms_and_conditions => {
                :accepted => "Please confirm, that you accept our terms and conditions."
              },
              :image_file => {
                :blank => 'Please select an location image (jpg, png or gif).',
                :invalid => 'Please select a valid location image (jpg, png or gif).'
              }
            }
          },
          :location => {
            :attributes => {
              :zip_code => {
                :blank => 'What is the zip code?',
                :invalid => 'The zip code is invalid.'
              },
              :zip_code_id => {
                :blank => 'What is the zip code?',
                :invalid => 'The zip code is invalid.'
              },
              :_changes => {
                :blank => 'Which changes do you have to report?'
              },
              :city => {
                :blank => 'Please select the city.'
              },
              :name => {
                :taken => 'The name is already taken.',
                :blank => 'What is the name of the brunch location?'
              },
              :street => {
                :blank => 'What is the street?'
              },
              :price => {
                :invalid_amount_format => 'The price %{value} has an invalid format (%{format_example}).',
                :blank => 'What is the price?'
              },
              :phone => {
                :blank => 'What is the phone number?'
              },
              :email => {
                :blank => 'What is the email?',
                :taken => 'The email is already taken.',
                :too_long => "The email is too long (not more than %{count} chars).",
                :too_short => "The email is too short (not lesser than %{count} chars)."
              },              
              :general_terms_and_conditions_confirmed => {
                :accepted => "Please confirm, that you accept our terms and conditions."
              }
            }
          },
          :location_changes => {
            :attributes => {
              :changes => {
                :blank => "Please enter the changes."
              }
            }
          },
          :location_suggestion => {
            :attributes => {
              :name => {
                :blank => "Please type the name."
              },
              :city => {
                :blank => "Please type the city.",
                :invalid => "Sorry, we do not have this city in the database."
              }
            }
          },
          :rating => {
            :attributes => {
              :value => {
                :blank        => 'The rating is required.',
                :not_a_number => 'The rating is required.'
              }
            }
          },
          :review => {
            :attributes => {
              :base => {
                :destroy => "You can't destroy without a reason."
              },
              :general_terms_and_conditions => {
                :accepted => 'Please confirm, that you read the general terms and conditions.'
              },
              :frontend_user => {
                :blank => 'Please login or enter your email and name.',
                :invalid => 'Please login or enter your email and name.',
                :taken => 'A further rating is not possible.'
              },
              :frontend_user_id => {
                :blank => 'Please login or enter your email and name.',
                :invalid => 'Please login or enter your email and name.',
                :taken => 'A further rating is not possible.'
              },
              :review_locking => {
                :reason_required => "You can't lock without a reason."
              },
              :state => {
                :no_revert => "The review state can't be reset to unpublished."
              },
              :text => {
                :blank => 'Please enter your opinion.',
                :too_short => 'Please write at least %{count} words.',
                :too_short_note => {
                  :one   => 'Please write even one word.',
                  :other => 'Please write another <span class="text-words-to-write">%{count}</span> words.'
                },
                :too_similar => "The text has too many similarities with a previously written report from you."
              },
              :value => {
                :blank        => 'The rating is required.',
                :not_a_number => 'The rating is required.'
              }
            }
          }
        },
        :messages => {
          :missing_image => 'Please select an location image (jpg, png or gif).',
          :invalid_image => 'Please select a valid location image (jpg, png or gif).',
          :inclusion => "ain't included in the list",
          :exclusion => "ain't available",
          :email_domain_exclusion => "The email address including '%{domain}' ain't available.",
          :invalid => "ain't valid",
          :confirmation => "don't match its confirmation",
          :accepted => "gotta be accepted",
          :empty => "is required",
          :blank => "is required",
          :too_long => "is too long-ish (no more than %{count} characters)",
          :too_short => "is too short-ish (no less than %{count} characters)",
          :wrong_length => "ain't got the right length (gotta be %{count} characters)",
          :taken => "ain't available",
          :not_a_number => "ain't a number",
          :greater_than => "gotta be greater than %{count}",
          :greater_than_or_equal_to => "gotta be greater than or equal to %{count}",
          :equal_to => "gotta be equal to %{count}",
          :less_than => "gotta be less than %{count}",
          :less_than_or_equal_to => "gotta be less than or equal to %{count}",
          :odd => "gotta be odd",
          :even => "gotta be even"
        }
      }
    },

    # Authlogic
    :authlogic => {
      :error_messages => {
        :login_blank      => 'can not be blank',
        :login_not_found  => 'is not valid',
        :login_invalid    => 'should use only letters, numbers, spaces, and .-_@ please.',
        :consecutive_failed_logins_limit_exceeded => 'Consecutive failed logins limit exceeded, account is disabled.',
        :email_invalid    => 'should look like an email address.',
        :password_blank   => 'can not be blank',
        :password_invalid => 'is not valid',
        :not_active       => 'Your account is not active',
        :not_confirmed    => 'Your account is not confirmed',
        :blocked => 'Your account is blocked at the moment',
        :not_approved     => 'Your account is not approved',
        :no_authentication_details => 'You did not provide any details for authentication.'
      },
      :models => {
        :frontend_user_session => 'User Session',
        :backend_user_session => 'User Session'
      },
      :attributes => {
        :frontend_user_session => {
          :login          => 'Login',
          :login_or_email => 'Login or Email',
          :email          => 'Email',
          :password       => 'Password',
          :remember_me    => 'Next time log me in automatically.'
        }
      }
    }
  }
}
