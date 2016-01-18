CREATE TABLE `account_cheaters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `frontend_user_id` int(11) DEFAULT NULL,
  `other_users` varchar(255) DEFAULT '',
  `client_ip` varchar(255) DEFAULT '',
  `client_agent` varchar(255) DEFAULT '',
  `switches` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `cheating_values` varchar(255) DEFAULT '',
  `ignored` tinyint(1) DEFAULT '0',
  `killed` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_account_cheaters_on_frontend_user_id` (`frontend_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `aggregated_ratings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `review_question_id` int(11) DEFAULT NULL,
  `destination_id` int(11) DEFAULT NULL,
  `destination_type` varchar(255) DEFAULT NULL,
  `value` decimal(3,2) DEFAULT NULL,
  `user_count` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_aggregated_ratings_on_review_question_id` (`review_question_id`),
  KEY `index_aggregated_ratings_on_destination_id_and_destination_type` (`destination_id`,`destination_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `aggregated_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `destination_id` int(11) DEFAULT NULL,
  `destination_type` varchar(255) DEFAULT NULL,
  `value` int(11) DEFAULT '0',
  `user_count` int(11) DEFAULT NULL,
  `users_per_value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_aggregated_reviews_on_destination_id_and_destination_type` (`destination_id`,`destination_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `backend_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `crypted_password` varchar(255) NOT NULL,
  `password_salt` varchar(255) NOT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `current_login_at` datetime DEFAULT NULL,
  `current_login_ip` varchar(255) DEFAULT NULL,
  `last_request_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `persistence_token` varchar(255) NOT NULL,
  `single_access_token` varchar(255) NOT NULL,
  `perishable_token` varchar(255) NOT NULL,
  `salutation` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `internal_information` text,
  `active` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_roles` varchar(255) DEFAULT NULL,
  `user_group` int(11) DEFAULT NULL,
  `salary_type` int(11) DEFAULT NULL,
  `gender` varchar(6) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `phone_mobile` varchar(255) DEFAULT NULL,
  `icq` varchar(255) DEFAULT NULL,
  `skype` varchar(255) DEFAULT NULL,
  `address` text,
  PRIMARY KEY (`id`),
  KEY `index_backend_users_on_login` (`login`),
  KEY `index_backend_users_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

CREATE TABLE `cities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state_id` int(11) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number_of_locations` int(11) DEFAULT '0',
  `delta` int(11) NOT NULL DEFAULT '1',
  `rewrite` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `city_char_id` int(11) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cities_on_state_id` (`state_id`),
  KEY `index_cities_on_name` (`name`),
  KEY `index_cities_on_rewrite` (`rewrite`)
) ENGINE=InnoDB AUTO_INCREMENT=54344 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `city_chars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `state_id` int(11) DEFAULT NULL,
  `start_char` varchar(1) DEFAULT NULL,
  `number_of_locations` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=365 DEFAULT CHARSET=utf8;

CREATE TABLE `clickouts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `remote_ip` varchar(255) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `destination_id` int(11) DEFAULT NULL,
  `destination_type` varchar(255) DEFAULT NULL,
  `template` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_clickouts_on_remote_ip` (`remote_ip`),
  KEY `index_clickouts_on_user_agent` (`user_agent`),
  KEY `index_clickouts_on_destination_id` (`destination_id`),
  KEY `index_clickouts_on_destination_type` (`destination_type`),
  KEY `index_clickouts_on_template` (`template`),
  KEY `index_clickouts_on_position` (`position`),
  KEY `index_clickouts_on_platform` (`platform`),
  KEY `index_clickouts_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=4961 DEFAULT CHARSET=utf8;

CREATE TABLE `coupon_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `number_of_coupons` int(11) NOT NULL DEFAULT '0',
  `rewrite` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_coupon_categories_on_rewrite` (`rewrite`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8;

CREATE TABLE `coupon_matches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coupon_id` int(11) DEFAULT NULL,
  `destination_id` int(11) DEFAULT NULL,
  `destination_type` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_coupon_matches_on_destination_type` (`destination_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `coupon_merchants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `merchant_id` int(11) DEFAULT NULL,
  `number_of_coupons` int(11) DEFAULT '0',
  `name` varchar(255) DEFAULT NULL,
  `logo_url` longtext,
  PRIMARY KEY (`id`),
  KEY `index_coupon_merchants_on_merchant_id` (`merchant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `coupons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `customer_id` int(11) DEFAULT NULL,
  `coupon_id` int(11) DEFAULT NULL,
  `merchant_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `valid_from` datetime DEFAULT NULL,
  `valid_to` datetime DEFAULT NULL,
  `image_url` longtext,
  `merchant_name` varchar(255) DEFAULT NULL,
  `merchant_logo_url` longtext,
  `url` longtext,
  `kind` int(11) DEFAULT NULL,
  `hint` text,
  `favourite` tinyint(1) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `value` decimal(10,2) DEFAULT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `minimum_order_value` decimal(10,2) DEFAULT NULL,
  `only_new_customer` tinyint(1) DEFAULT NULL,
  `delta` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_coupons_on_coupon_id` (`coupon_id`),
  KEY `index_coupons_on_merchant_id` (`merchant_id`),
  KEY `index_coupons_on_customer_id` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6278 DEFAULT CHARSET=utf8;

CREATE TABLE `coupons_in_categories` (
  `coupon_id` int(11) DEFAULT NULL,
  `coupon_category_id` int(11) DEFAULT NULL,
  KEY `index_coupons_in_categories_on_coupon_id_and_coupon_category_id` (`coupon_id`,`coupon_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `customer_type` varchar(255) DEFAULT NULL,
  `url` text,
  `internal_information` text NOT NULL,
  `state` tinyint(4) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_customers_on_name` (`name`),
  KEY `index_customers_on_state` (`state`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

CREATE TABLE `data_sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `errors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` varchar(255) DEFAULT NULL,
  `backtrace` text,
  `status` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `fullpath` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1141 DEFAULT CHARSET=utf8;

CREATE TABLE `forwardings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `source_url` varchar(2048) COLLATE utf8_unicode_ci NOT NULL,
  `destination_url` varchar(2048) COLLATE utf8_unicode_ci NOT NULL,
  `last_use_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_forwardings_on_source_url` (`source_url`(255)),
  KEY `index_forwardings_on_destination_url` (`destination_url`(255))
) ENGINE=InnoDB AUTO_INCREMENT=5227 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `frontend_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `active` int(11) NOT NULL DEFAULT '0',
  `score` int(11) NOT NULL DEFAULT '0',
  `confirmation_reminders_to_send` int(11) DEFAULT NULL,
  `general_terms_and_conditions` tinyint(1) DEFAULT NULL,
  `login_count` int(11) NOT NULL DEFAULT '0',
  `failed_login_count` int(11) NOT NULL DEFAULT '0',
  `login` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `new_email` varchar(255) NOT NULL DEFAULT '',
  `single_access_token` varchar(255) DEFAULT NULL,
  `persistence_token` varchar(255) DEFAULT NULL,
  `perishable_token` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `state` varchar(255) NOT NULL DEFAULT 'pending',
  `crypted_password` varchar(255) DEFAULT NULL,
  `password_salt` varchar(255) DEFAULT NULL,
  `current_login_at` datetime DEFAULT NULL,
  `current_login_ip` varchar(255) DEFAULT NULL,
  `last_request_at` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(255) DEFAULT NULL,
  `salutation` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `gender` varchar(255) NOT NULL DEFAULT 'undefined',
  `about_user_short` varchar(255) DEFAULT NULL,
  `about_user_long` text,
  `internal_information` text,
  PRIMARY KEY (`id`),
  KEY `index_frontend_users_on_email` (`email`),
  KEY `index_frontend_users_on_login` (`login`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8;

CREATE TABLE `geo_locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `geo_code_id` int(11) DEFAULT NULL,
  `geo_code_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lat` float DEFAULT NULL,
  `lng` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_geo_locations_on_geo_code_id_and_geo_code_type` (`geo_code_id`,`geo_code_type`),
  KEY `index_geo_locations_on_lat_and_lng` (`lat`,`lng`),
  KEY `index_geo_locations_on_geo_code_type` (`geo_code_type`)
) ENGINE=InnoDB AUTO_INCREMENT=37572 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `location_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `location_id` int(11) DEFAULT NULL,
  `frontend_user_id` int(11) DEFAULT '0',
  `review_id` int(11) DEFAULT '0',
  `data_source_id` int(11) DEFAULT NULL,
  `image_width` int(11) DEFAULT NULL,
  `image_height` int(11) DEFAULT NULL,
  `image_size` int(11) DEFAULT NULL,
  `set_watermark` int(11) NOT NULL DEFAULT '0',
  `is_hidden` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `is_main_image` tinyint(1) NOT NULL DEFAULT '0',
  `uploader_denied_main_image` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `image_format` varchar(255) DEFAULT '--- :png\n',
  `presentation_type` varchar(255) DEFAULT NULL,
  `status` varchar(10) DEFAULT '--- :new\n',
  `tags` varchar(255) DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `index_location_images_on_location_id` (`location_id`),
  KEY `index_location_images_on_frontend_user_id` (`frontend_user_id`),
  KEY `index_location_images_on_review_id` (`review_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `location_suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `information` text,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8;

CREATE TABLE `locations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zip_code_id` int(11) DEFAULT NULL,
  `frontend_user_id` int(11) DEFAULT NULL,
  `general_terms_and_conditions_confirmed` tinyint(1) DEFAULT NULL,
  `published` tinyint(1) DEFAULT NULL,
  `delta` int(11) NOT NULL DEFAULT '1',
  `rewrite` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmation_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `street` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `brunch_time` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `opening_hours` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `service` text COLLATE utf8_unicode_ci,
  `price` decimal(6,2) DEFAULT NULL,
  `price_information` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fax` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_locations_on_zip_code_id` (`zip_code_id`),
  KEY `index_locations_on_frontend_user_id` (`frontend_user_id`),
  KEY `index_locations_on_rewrite` (`rewrite`),
  KEY `index_locations_on_confirmation_code` (`confirmation_code`)
) ENGINE=InnoDB AUTO_INCREMENT=654 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `question_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `question_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `score` decimal(3,2) DEFAULT '0.00',
  `text` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ratings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `review_question_id` int(11) DEFAULT NULL,
  `review_id` int(11) NOT NULL DEFAULT '0',
  `value` decimal(3,2) DEFAULT NULL,
  `text` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `review_answers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `review_question_id` int(11) DEFAULT NULL,
  `text` varchar(255) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `score` decimal(3,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_review_answers_on_review_question_id` (`review_question_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1;

CREATE TABLE `review_lockings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `review_id` int(11) DEFAULT NULL,
  `state` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `reason` text,
  PRIMARY KEY (`id`),
  KEY `index_review_lockings_on_review_id` (`review_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `review_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `text` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `answer_type` varchar(255) NOT NULL DEFAULT '--- :list\n',
  `analyzable` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE `review_template_questions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `review_template_id` int(11) DEFAULT NULL,
  `review_question_id` int(11) DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `obligation` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_review_template_questions_on_review_question_id` (`review_question_id`),
  KEY `index_review_template_questions_on_review_template_id` (`review_template_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

CREATE TABLE `review_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `destination_type` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

CREATE TABLE `reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `destination_id` int(11) DEFAULT NULL,
  `destination_type` varchar(255) DEFAULT NULL,
  `frontend_user_id` int(11) DEFAULT NULL,
  `state` int(11) DEFAULT '0',
  `value` int(11) DEFAULT NULL,
  `aggregated_rating` int(11) DEFAULT NULL,
  `helpful_yes` int(11) DEFAULT NULL,
  `helpful_no` int(11) DEFAULT NULL,
  `general_terms_and_conditions` tinyint(1) DEFAULT NULL,
  `confirmation_reminders_to_send` int(11) DEFAULT NULL,
  `published_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `confirmation_code` varchar(255) DEFAULT NULL,
  `text` text,
  PRIMARY KEY (`id`),
  KEY `index_reviews_on_frontend_user_id` (`frontend_user_id`),
  KEY `index_reviews_on_confirmation_code` (`confirmation_code`),
  KEY `index_reviews_on_destination_id_and_destination_type` (`destination_id`,`destination_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `search_suggestions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `destination_id` int(11) DEFAULT NULL,
  `destination_type` varchar(255) DEFAULT NULL,
  `phrase` varchar(255) DEFAULT NULL,
  `weight` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_search_suggestions_on_destination_type` (`destination_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `states` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number_of_locations` int(11) DEFAULT '0',
  `delta` int(11) NOT NULL DEFAULT '1',
  `rewrite` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_states_on_rewrite` (`rewrite`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `zip_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `city_id` int(11) DEFAULT NULL,
  `code` varchar(10) COLLATE utf8_unicode_ci DEFAULT NULL,
  `number_of_locations` int(11) DEFAULT '0',
  `delta` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_zip_codes_on_city_id` (`city_id`),
  KEY `index_zip_codes_on_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=63534 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20101210124952');

INSERT INTO schema_migrations (version) VALUES ('20101210125742');

INSERT INTO schema_migrations (version) VALUES ('20101211105501');

INSERT INTO schema_migrations (version) VALUES ('20101211215109');

INSERT INTO schema_migrations (version) VALUES ('20101213193642');

INSERT INTO schema_migrations (version) VALUES ('20101214130132');

INSERT INTO schema_migrations (version) VALUES ('20101223112516');

INSERT INTO schema_migrations (version) VALUES ('20110102195242');

INSERT INTO schema_migrations (version) VALUES ('20110109123947');

INSERT INTO schema_migrations (version) VALUES ('20110120194527');

INSERT INTO schema_migrations (version) VALUES ('20110121211920');

INSERT INTO schema_migrations (version) VALUES ('20110122213115');

INSERT INTO schema_migrations (version) VALUES ('20110210201949');

INSERT INTO schema_migrations (version) VALUES ('20110211192204');

INSERT INTO schema_migrations (version) VALUES ('20110211193441');

INSERT INTO schema_migrations (version) VALUES ('20110211233922');

INSERT INTO schema_migrations (version) VALUES ('20110302215108');

INSERT INTO schema_migrations (version) VALUES ('20110302224555');

INSERT INTO schema_migrations (version) VALUES ('20110402154612');

INSERT INTO schema_migrations (version) VALUES ('20110403125812');

INSERT INTO schema_migrations (version) VALUES ('20110528211328');

INSERT INTO schema_migrations (version) VALUES ('20110602124207');

INSERT INTO schema_migrations (version) VALUES ('20110721192629');

INSERT INTO schema_migrations (version) VALUES ('20110803194801');

INSERT INTO schema_migrations (version) VALUES ('20110804195917');

INSERT INTO schema_migrations (version) VALUES ('20111107224059');

INSERT INTO schema_migrations (version) VALUES ('20111108090942');

INSERT INTO schema_migrations (version) VALUES ('20120126103810');

INSERT INTO schema_migrations (version) VALUES ('20120129213036');

INSERT INTO schema_migrations (version) VALUES ('20120211233002');

INSERT INTO schema_migrations (version) VALUES ('20120224190549');

INSERT INTO schema_migrations (version) VALUES ('20120224194849');

INSERT INTO schema_migrations (version) VALUES ('20120316212516');

INSERT INTO schema_migrations (version) VALUES ('20120514111358');

INSERT INTO schema_migrations (version) VALUES ('20120514112622');

INSERT INTO schema_migrations (version) VALUES ('20120514120417');

INSERT INTO schema_migrations (version) VALUES ('20120514121329');

INSERT INTO schema_migrations (version) VALUES ('20120514121345');

INSERT INTO schema_migrations (version) VALUES ('20120515205306');

INSERT INTO schema_migrations (version) VALUES ('20120518192627');

INSERT INTO schema_migrations (version) VALUES ('20120520110813');

INSERT INTO schema_migrations (version) VALUES ('20120526094945');

INSERT INTO schema_migrations (version) VALUES ('20120526200720');

INSERT INTO schema_migrations (version) VALUES ('20120602210507');

INSERT INTO schema_migrations (version) VALUES ('20120603175159');

INSERT INTO schema_migrations (version) VALUES ('20120604090049');

INSERT INTO schema_migrations (version) VALUES ('20120604190026');

INSERT INTO schema_migrations (version) VALUES ('20120607212100');

INSERT INTO schema_migrations (version) VALUES ('20120711213906');

INSERT INTO schema_migrations (version) VALUES ('20120817214239');

INSERT INTO schema_migrations (version) VALUES ('20120912210425');

INSERT INTO schema_migrations (version) VALUES ('20120917065850');

INSERT INTO schema_migrations (version) VALUES ('20120917192736');

INSERT INTO schema_migrations (version) VALUES ('20120926194720');

INSERT INTO schema_migrations (version) VALUES ('20120927193810');

INSERT INTO schema_migrations (version) VALUES ('20121117225502');

INSERT INTO schema_migrations (version) VALUES ('20121117230527');

INSERT INTO schema_migrations (version) VALUES ('20121117231132');

INSERT INTO schema_migrations (version) VALUES ('20121118205624');

INSERT INTO schema_migrations (version) VALUES ('20121119200729');

INSERT INTO schema_migrations (version) VALUES ('20121119202344');

INSERT INTO schema_migrations (version) VALUES ('20121229112321');

INSERT INTO schema_migrations (version) VALUES ('20130101184217');

INSERT INTO schema_migrations (version) VALUES ('20130102121937');

INSERT INTO schema_migrations (version) VALUES ('20130102142827');

INSERT INTO schema_migrations (version) VALUES ('20130102201818');

INSERT INTO schema_migrations (version) VALUES ('20130121124510');

INSERT INTO schema_migrations (version) VALUES ('20130121155122');

INSERT INTO schema_migrations (version) VALUES ('20130123125122');

INSERT INTO schema_migrations (version) VALUES ('20130217111152');

INSERT INTO schema_migrations (version) VALUES ('20130407102435');

INSERT INTO schema_migrations (version) VALUES ('20130407103358');