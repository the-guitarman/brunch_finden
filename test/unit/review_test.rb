#encoding: utf-8
require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  fixtures :locations
  fixtures :frontend_users
  fixtures :reviews
  
  should belong_to :destination
  should belong_to :frontend_user
  should have_one(:review_locking).dependent(:destroy)
  should have_many(:ratings).dependent(:destroy)
  
  should validate_presence_of(:destination).with_message(/is required/)
  context "valid frontend_user object needed on create" do
    subject {Review.new}
    should validate_presence_of(:frontend_user).with_message(/Please login or enter your email and name\./)
  end
  context "frontend_user_id needed on update" do
    subject {Review.last}
    should validate_presence_of(:frontend_user_id).with_message(/Please login or enter your email and name/)
  end
  should validate_presence_of(:text).with_message(/Please enter your opinion\./)
  should validate_presence_of(:value).with_message(/The rating is required\./)
  should validate_acceptance_of(:general_terms_and_conditions).with_message(/Please confirm, that you read the general terms and conditions\./)
  
  # process before each test method
  def setup
    @l1 = Location.first
    @l2 = Location.last
    @fu1 = FrontendUser.find(1)
    @fu2 = FrontendUser.find(2)
    @fu3 = FrontendUser.find(3)
  end
  
  # process before each test method
  def teardown
    
  end

  def test_creation
    Review.delete_all
    AggregatedReview.delete_all

    test_r_1 = Review.create
    assert (not test_r_1.valid?)
    assert test_r_1.errors[:destination].any?
    assert test_r_1.errors[:frontend_user].any?
    assert test_r_1.errors[:value].any?
    assert test_r_1.errors[:text].any?

    assert_equal 0, AggregatedReview.count
    
    # create a review (for location 1 by user 1)
    r1 = Factory(:review, {:destination => @l1, :frontend_user => @fu1, :value => 0.2})
    assert r1.valid?
    assert (not r1.errors[:destination].any?)
    assert_kind_of Location, r1.destination
    assert_equal @l1, r1.destination
    assert (not r1.errors[:frontend_user].any?)
    assert_kind_of FrontendUser, r1.frontend_user
    assert (not r1.errors[:value].any?)
    assert_equal 0.2, r1.value
    assert (not r1.errors[:text].any?)

    assert r1.save

    assert_equal 1, AggregatedReview.count
    ar = AggregatedReview.last
    assert_equal @l1, ar.destination
    assert_equal 0.2, ar.value
    assert_equal 1, ar.user_count
    assert ar.users_per_value.include?(0.2)
    assert_equal 1, ar.users_per_value[0.2]

    # can not create a second review (for location 1 by user 1)
    test_r_2 = Review.create(valid_attributes({:value => 0.4}))
    assert (not test_r_2.valid?)
    assert (not test_r_2.errors[:destination].any?)
    assert test_r_2.errors[:frontend_user_id].any?
    assert (not test_r_2.errors[:value].any?)

    assert_equal 1, Review.count
    assert_equal 1, AggregatedReview.count

    # create a review (for location 1 from user 2)
    r2 = Factory(:review, {:frontend_user => @fu2, :value => 1.0, :destination => @l1, :state => Review::STATES[:published]})
    assert r2.valid?
    assert_equal @l1, r2.destination
    assert_equal 2, Review.count
    
    assert_equal 1, AggregatedReview.count
    ar = AggregatedReview.destination(@l1).last
    assert_equal @l1, ar.destination
    assert_equal 2, ar.user_count
    assert_equal 0.6, ar.value
    assert ar.users_per_value.include?(0.2)
    assert_equal 1, ar.users_per_value[0.2]
    assert ar.users_per_value.include?(1.0)
    assert_equal 1, ar.users_per_value[1.0]

    # create a review (for location 1 by user 3)
    r3 = Factory(:review, {:frontend_user => @fu3, :value => 0.2, :state => Review::STATES[:published], :destination => @l1})
    assert r3.valid?
    assert_equal @l1, r3.destination
    assert_equal 3, Review.count

    assert_equal 1, AggregatedReview.count
    ar = AggregatedReview.first
    assert_equal @l1, ar.destination
    assert_equal (Rails.version >= '3.0.0' ? 0.47 : 0.46), ar.value
    assert_equal 3, ar.user_count
    assert ar.users_per_value.include?(0.2)
    assert_equal 2, ar.users_per_value[0.2]
    assert ar.users_per_value.include?(1.0)
    assert_equal 1, ar.users_per_value[1.0]

    # create a review (for location 2 by user 2)
    r4 = Factory(:review, {
      :destination => @l2, :frontend_user => @fu2, 
      :value => 0.8, :state => Review::STATES[:published],
      :text => 'Nun sind Gummibärchen weder wabbelig noch zäh; 
                sie stehen genau an der Grenze. Auch das macht sie spannend. 
                Gummibärchen sind auf eine aufreizende Art weich. 
                Und da sie weich sind, kann man sie auch ziehen. 
                Ich mache das sehr gerne. Ich sitze im dunklen Kino und ziehe 
                meine Gummibärchen in die Länge, ganz ganz langsam.'
    })
    assert r4.valid?
    assert_equal 4, Review.count
    
    assert_equal 2, AggregatedReview.count

    ar = AggregatedReview.first
    assert_equal @l1, ar.destination
    assert_equal (Rails.version >= '3.0.0' ? 0.47 : 0.46), ar.value
    assert_equal 3, ar.user_count
    assert ar.users_per_value.include?(0.2)
    assert_equal 2, ar.users_per_value[0.2]
    assert ar.users_per_value.include?(1.0)
    assert_equal 1, ar.users_per_value[1.0]

    ar = AggregatedReview.last
    assert_equal @l2, ar.destination
    assert_equal 0.8, ar.value
    assert_equal 1, ar.user_count
    assert ar.users_per_value.include?(0.8)
    assert_equal 1, ar.users_per_value[0.8]
  end
  
  def test_confirmation_code
    r = Review.new(valid_attributes)
    
    assert r.confirmation_code.blank?
    r.save
    assert (not r.confirmation_code.blank?)
  end

  def test_model_associations
    review = Review.first
    
    assert_respond_to review, :destination
    assert_respond_to review, :frontend_user
    assert_respond_to review, :ratings
    assert_respond_to review, :review_locking
  end
  
  def test_review_constants
    if Rails.version >= '3.0.0'
      assert Review.constants.include?(:VALUES)
    else
      assert Review.constants.include?('VALUES')
    end
    assert Review::VALUES.is_a?(Hash)
    assert_equal 0, Review::VALUES[0.0]
    assert_equal 0.5, Review::VALUES[0.1]
    assert_equal 1, Review::VALUES[0.2]
    assert_equal 1.5, Review::VALUES[0.3]
    assert_equal 2, Review::VALUES[0.4]
    assert_equal 2.5, Review::VALUES[0.5]
    assert_equal 3, Review::VALUES[0.6]
    assert_equal 3.5, Review::VALUES[0.7]
    assert_equal 4, Review::VALUES[0.8]
    assert_equal 4.5, Review::VALUES[0.9]
    assert_equal 5, Review::VALUES[1.0]
    
    if Rails.version >= '3.0.0'
      assert Review.constants.include?(:MIN_WORDS_FOR_REVIEW)
    else
      assert Review.constants.include?('MIN_WORDS_FOR_REVIEW')
    end
    assert_equal 20, Review::MIN_WORDS_FOR_REVIEW
    
    if Rails.version >= '3.0.0'
      assert Review.constants.include?(:TOKENIZER)
    else
      assert Review.constants.include?('TOKENIZER')
    end
    assert Review::TOKENIZER.is_a?(Proc)
    
    if Rails.version >= '3.0.0'
      assert Review.constants.include?(:STATES)
    else
      assert Review.constants.include?('STATES')
    end
    assert Review::STATES.is_a?(Hash)
    assert_equal 3, Review::STATES.keys.length
    assert_equal 0, Review::STATES[:unpublished]
    assert_equal 1, Review::STATES[:published]
    assert_equal 2, Review::STATES[:locked]
    
    if Rails.version >= '3.0.0'
      assert Review.constants.include?(:DELETION_LOG_FILE)
    else
      assert Review.constants.include?('DELETION_LOG_FILE')
    end
    assert Review::DELETION_LOG_FILE.is_a?(String)
    assert_equal "#{Rails.root}/log/review_deletions.log", Review::DELETION_LOG_FILE
  end
  
  def test_included_modules
    assert Review.included_modules.include?(Mixins::UserGeneratedContent)
    
    assert Review.included_modules.include?(Mixins::PolymorphicFinder)
    assert Review.scopes.keys.include?(:destination)
    
    assert Review.included_modules.include?(Mixins::CentInteger)
    if Rails.version >= '3.0.0'
      assert Review.instance_methods.include?(:aggregated_rating)
    else
      assert Review.instance_methods.include?('aggregated_rating')
    end
    
    assert Review.included_modules.include?(Mixins::SecureCode)
    if Rails.version >= '3.0.0'
      assert Review.instance_methods.include?(:secure_code_for_confirmation_code)
      assert Review.instance_methods.include?(:secure_code_for_confirmation_code!)
    else
      assert Review.instance_methods.include?('secure_code_for_confirmation_code')
      assert Review.instance_methods.include?('secure_code_for_confirmation_code!')
    end
    
    assert Review.included_modules.include?(Mixins::ReviewCompleteness)
    if Rails.version >= '3.0.0'
      assert Review.instance_methods.include?(:completeness_notes)
      assert Review.instance_methods.include?(:words_to_write)
    else
      assert Review.instance_methods.include?('completeness_notes')
      assert Review.instance_methods.include?('words_to_write')
    end
  end
  
  def test_scopes
    assert Review.scopes.keys.include?(:showable)
    assert Review.scopes.keys.include?(:unpublished)
  end

  def test_update
    # recalculate, if a user changes its review
    review = Review.find(2)
    aggregated_review = AggregatedReview.find(1)
    assert_equal 2, aggregated_review.user_count
    assert_equal 0.9, aggregated_review.value
    
    review.value = 1.0
    assert review.save
    
    aggregated_review = AggregatedReview.find(1)
    assert_equal 2, aggregated_review.user_count
    assert_equal 1.0, aggregated_review.value
  end

  def test_destroy
    review = Review.find(1)
    aggregated_review = AggregatedReview.find(1)
    assert_equal 2, aggregated_review.user_count
    assert_equal 0.9, aggregated_review.value
    
    review.destroy
    assert review.frozen?
    
    aggregated_review = AggregatedReview.find(1)
    assert_equal 1, aggregated_review.user_count
    assert_equal 0.8, aggregated_review.value
  end

  def test_remember_the_author_to_confirm_the_unpublished_review
    Review.record_timestamps = false
    
    # prepare the test
    Review.delete_all
    AggregatedReview.delete_all
    ActionMailer::Base.deliveries = []
    now = DateTime.now
    mc = BackgroundConfigHandler.instance.model_config
    confirmation_reminders_to_send = mc['FRONTEND_USER']['GENERATED_CONTENT']['FORWARD_CONFIRMATION_REMINDER_EMAIL'].length
    confirmation_reminders_sent = 0
    # create a review
    
    review = Review.create(
      valid_attributes({:state => Review::STATES[:unpublished], :created_at => now, :updated_at => now})
    )
    assert review.valid?
    assert_equal 1, confirmation_reminders_to_send
    # no email forwarded on creation ...
    assert_equal confirmation_reminders_to_send, review.confirmation_reminders_to_send
    assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
    # ..., don't send an email now
    Mixins::UserGeneratedContent.remember_to_confirm({:show_messages => false})
    review.reload
    assert_equal confirmation_reminders_to_send, review.confirmation_reminders_to_send
    assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
    # remember not confirmed users to confirm their accounts
    bgc = BackgroundConfigHandler.instance.model_config
    reminder_days = bgc['FRONTEND_USER']['GENERATED_CONTENT']['FORWARD_CONFIRMATION_REMINDER_EMAIL'].sort
    reminder_days.each do |day|
      # prepare object to send reminder email after x days
      review.created_at = (now - (day.days))
      assert review.save
      # send reminder email
      Mixins::UserGeneratedContent.remember_to_confirm({:show_messages => false})
      confirmation_reminders_to_send -= 1
      confirmation_reminders_sent += 1

      review.reload
      assert_equal confirmation_reminders_to_send, review.confirmation_reminders_to_send
      assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
      check_sending_a_reminder_email(review.frontend_user, review.destination.name, confirmation_reminders_sent)

      # don't send reminder email again
      Mixins::UserGeneratedContent.remember_to_confirm({:show_messages => false})

      review.reload
      assert_equal confirmation_reminders_to_send, review.confirmation_reminders_to_send
      assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
    end

    # prepare object to delete it after x days
    delete_after_days = reminder_days.last + bgc['FRONTEND_USER']['GENERATED_CONTENT']['DELETE_UNCONFIRMED_X_DAYS_AFTER_LAST_REMINDER_EMAIL'].to_i
    review.created_at = (now - (delete_after_days.days))
    assert review.save
    
    # delete not confirmed users after some days without to send an email
    Mixins::UserGeneratedContent.remember_to_confirm({:show_messages => false})
    review = Review.find_by_id(review.id)
    assert review.nil?
    
    assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
    assert_equal 0, confirmation_reminders_to_send
  ensure
    Review.record_timestamps = true
  end

  def test_text_cleaner_in_review
    Review.delete_all
    
    review = Factory.build(:review, {
      :text => "<h1>Hallo Welt!</h1>\n --------\n Dies <b>ist</b> <br /><i>Text</i>! <a href='http://www.my-domain.de' target='_blank'>weiter</a> <h3>Ueberschrift</h3> <h4>Ueberschrift</h4> <span>bla</span> <ol><li>1</li></ol> <ul><li>a</li></ul> <p>blubb</p> +------+\n"
    })
    review.valid?
    assert !review.valid?
    assert review.errors[:text].any?
    if Rails.version >= '3.0.0'
      assert_equal 'Please write at least 250 words.', review.errors[:text].first
    else
      assert review.errors[:text].include?('Please write at least 20 words.')
    end
    
    review.text = "Hallo Welt!\n --------\n <h2>Ueberschrift 1</h2> Dies ist der <strong>eigentliche</strong> <br /><em>Text</em>! \n #{'bla '*241}und weiter <h3>Ueberschrift 2</h3> <h4>Ueberschrift 3</h4> <span>bla</span> <ol><li>1</li></ol> <ul><li>a</li></ul> <p>blubb</p> +------+\n"
    assert review.valid?
    
    
    
    review.state = Review::STATES[:published]
    assert review.save
    # without ActionFormatter (gem ActionText)
#    assert_equal "Hallo Welt!\n \n Dies ist der eingentliche Text!\n #{'bla bla '*21}und weiter \n", review.text
    # with ActionFormatter (gem ActionText)
    assert_equal "Hallo Welt!\n Ueberschrift 1 Dies ist der eigentliche \n Text ! \n bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla und weiter Ueberschrift 2 Ueberschrift 3 bla 1 a blubb", review.text
  end

  def test_review_state_switch
		review = Factory(:review, {:destination => @l1})
		assert review.valid?
    assert_equal Review::STATES[:published], review.state
    
    review.state = Review::STATES[:unpublished]
		assert (not review.save)
		assert review.errors[:state].any?
    
    assert (not review.lock)
    assert review.errors[:review_locking].any?
    if Rails.version >= '3.0.0'
      assert_equal "You can't lock without a reason.", review.errors[:review_locking].first
    else
      assert review.errors[:review_locking].include?("You can't lock without a reason.")
    end
    
    assert (not review.lock!)
    assert review.errors[:review_locking].any?
    if Rails.version >= '3.0.0'
      assert_equal "You can't lock without a reason.", review.errors[:review_locking].first
    else
      assert review.errors[:review_locking].include?("You can't lock without a reason.")
    end
    
    assert review.lock!('for that reason')
    assert (not review.errors[:review_locking].any?)
    
    review.state = Review::STATES[:unpublished]
		assert (not review.save)
		assert review.errors[:state].any?
    
    review.state = Review::STATES[:published]
    assert review.save
  end
  
	def test_review_locking
    ActionMailer::Base.deliveries = []
      
		review = Factory(:review, {:destination => @l1})
		assert review.valid?
    
    current_state = review.state
		review.state = Review::STATES[:locked]
		assert (not review.valid?)
		assert review.errors[:review_locking].any?
    
    review.review_locking = ReviewLocking.new({:state => current_state, :reason => 'for that reason'})
		assert review.save
		assert_kind_of ReviewLocking, review.review_locking
		assert_equal 'for that reason', review.review_locking.reason
    
		review.state = Review::STATES[:published]
		assert review.save
    
		review.reload
		assert_equal nil, review.review_locking
    
    tmail = ActionMailer::Base.deliveries.last
    assert_nil tmail
		#review_type = I18n.translate("mailers.frontend.review_mailer.review_type.review")
    #assert_equal I18n.translate('mailers.frontend.review_mailer.review_locked.subject',{
		#	:review_type => review_type}), tmail.subject
    #assert_equal review.frontend_user.email, tmail.to[0]    
	end
  
#  def test_review_locking_mails		
#    review = Factory(:review, {:destination => @l1})
#    assert review.valid?
#    assert_equal Review::STATES[:published], review.state
#    
#    ActionMailer::Base.deliveries = []
#    emails_sent = ActionMailer::Base.deliveries.length
#    
#    # NO MAILS:
#    no_mail_user_states = [:blocked, :anonymized, :not_deletable]
#    no_mail_user_states.each do |state|
#      review.state = Review::STATES[:published]
#      assert review.save
#      
#      FrontendUser.update_all({:state => state.to_s}, {:id => review.frontend_user.id})
#      assert_equal state, review.frontend_user(true).state.to_sym
#      
#      review.reload
#      
#      review.lock('for that reason')
#      assert review.save
#    end
#    
#    assert_equal 0, ActionMailer::Base.deliveries.length
#    
#    # MAILS:
#    mail_user_states = [:pending, :waiting, :confirmed, :changing_email, :unknown]
#    mail_user_states.each do |state|
#      review.state = Review::STATES[:published]
#      assert review.save
#      
#      FrontendUser.update_all({:state => state.to_s}, {:id => review.frontend_user.id})
#      assert_equal state, review.frontend_user(true).state.to_sym
#      
#      review.reload
#      
#      review.lock('for that reason')
#      assert review.save
#      
#      emails_sent += 1
#    end
#    
#    assert_equal emails_sent, ActionMailer::Base.deliveries.length
#  end
	
	def test_review_locking_changes_aggregated_review_data
		review = Review.find(2)
		assert_not_equal Review::STATES[:locked], review.state
    
		ar = review.destination.aggregated_review
    assert_equal 2, ar.user_count
    assert_equal 0.9, ar.value
		assert review.lock!('for that reason')
    
    review.reload
    assert review.locked?
    
		ar.reload
    assert_equal 1, ar.user_count
    assert_equal 1.0, ar.value
    
		review.state = Review::STATES[:published]
		assert review.save
    
		ar.reload
    assert_equal 2, ar.user_count
    assert_equal 0.9, ar.value		
  end
  
  def test_review_publish_method
    review    = Review.unpublished.last
    token     = review.confirmation_code
    old_score = review.frontend_user.score
    
    assert review.unpublished?
    assert review.publish!
    assert review.published?
    assert_equal old_score + 100, review.frontend_user(true).score
    assert_not_equal token, review.confirmation_code
  end
  
  def test_review_published_method_with_question_mark
    review = Review.unpublished.last
    assert_equal Review::STATES[:unpublished], review.state
    assert (not review.published?)
    
    review.state = Review::STATES[:published]
    assert review.save
    assert_equal Review::STATES[:published], review.state
    assert review.published?
    
    review.lock!('for that reason')
    assert_equal Review::STATES[:locked], review.state
    assert (not review.published?)
  end
  
  def test_review_locked_method_with_question_mark
    review = Review.unpublished.last
    assert_equal Review::STATES[:unpublished], review.state
    assert (not review.locked?)
    
    review.state = Review::STATES[:published]
    assert review.save
    assert_equal Review::STATES[:published], review.state
    assert (not review.locked?)
    
    review.lock!('for that reason')
    assert_equal Review::STATES[:locked], review.state
    assert review.locked?
  end
  
  def test_human_readable_state
    assert review = Review.unpublished.last
    assert_equal 'unpublished', review.human_readable_state
    
    review.state = Review::STATES[:published]
    assert review.save
    assert_equal 'published', review.human_readable_state
    
    review.lock!('for that reason')
    assert_equal 'locked', review.human_readable_state
  end
  
  def test_review_rating
    review = Review.find(1)
    
    review.aggregated_rating = 2
    assert_equal 1.0, review.review_rating
    
    review.aggregated_rating = 1.1
    assert_equal 1.0, review.review_rating
    
    review.aggregated_rating = 0.9
    assert_equal 1.0, review.review_rating
    
    review.aggregated_rating = 0.89
    assert_equal 0.8, review.review_rating
    
    review.aggregated_rating = 0.7
    assert_equal 0.8, review.review_rating
    
    review.aggregated_rating = 0.69
    assert_equal 0.6, review.review_rating
    
    review.aggregated_rating = 0.5
    assert_equal 0.6, review.review_rating
    
    review.aggregated_rating = 0.49
    assert_equal 0.4, review.review_rating
    
    review.aggregated_rating = 0.3
    assert_equal 0.4, review.review_rating
    
    review.aggregated_rating = 0.29
    assert_equal 0.2, review.review_rating
    
    review.aggregated_rating = 0.1
    assert_equal 0.2, review.review_rating
    
    review.aggregated_rating = 0.09
    assert_equal 0.0, review.review_rating
    
    review.aggregated_rating = -0.01
    assert_equal 0.0, review.review_rating
    
    review.aggregated_rating = -2
    assert_equal 0.0, review.review_rating
  end
  
  def test_log_deleted_reviews
    number_at_beginning = 0
    number_of_deleted_reviews = 0
    if File.exist?(Review::DELETION_LOG_FILE)
      File.open(Review::DELETION_LOG_FILE, 'r') do |f|
        number_at_beginning = f.readlines.count
        number_of_deleted_reviews = f.readlines.count
      end
    end
    
    r = Review.first
    r.destroy
    assert r.frozen?
    
    assert File.exist?(Review::DELETION_LOG_FILE)
    
    File.open(Review::DELETION_LOG_FILE, 'r') do |f|
      number_of_deleted_reviews = f.readlines.count
    end
    assert_equal number_at_beginning + 1, number_of_deleted_reviews 
  end
  
  def test_action_formatter_params
    assert Review.included_modules.include?(Mixins::TextCleaner)
    
    fields_1 = [:text]
    fields_2 = []
    
    (fields_1 + fields_2).each do |f|
      assert Review.respond_to?("action_formatter_params_for_#{f}".to_sym)
    end
    
    r = Review.new
    
    assert (not r.valid?)
    
    fields_1.each do |f|
      afp = r.send(:init_action_formatter_params_handler, Review.send("action_formatter_params_for_#{f}".to_sym))
      assert_equal "\n", afp[:replace_newlines]
      assert_equal 'remove', afp[:format_headlines]
      assert_equal 'remove', afp[:ascii_art]
      assert_equal 'all', afp[:html_optimize]
      assert_equal 'all', afp[:html_filter]      
    end
    fields_2.each do |f|
      afp = r.send(:init_action_formatter_params_handler, Review.send("action_formatter_params_for_#{f}".to_sym))
      assert_equal "\n", afp[:replace_newlines]
      assert_equal 'remove', afp[:format_headlines]
      assert_equal 'remove', afp[:ascii_art]
      assert_equal 'all', afp[:html_optimize]
      assert_equal 'all', afp[:html_filter]      
    end
  end
  
  def test_increase_and_decrease_user_score
    r = Review.first
    assert_equal 0, r.helpful_yes 
    score = r.frontend_user.score
    
    # review becomes a helpful_yes rating (+10)
    assert r.update_attributes({:helpful_yes => r.helpful_yes  + 1})
    assert_equal (score + 10), r.frontend_user(true).score
    
    # review looses the deluxe flag (-10)
    assert r.update_attributes({:helpful_no => r.helpful_no  + 1})
    assert_equal score, r.frontend_user(true).score
    
    # review becomes the deluxe flag (+10)
    assert r.update_attributes({:helpful_yes => r.helpful_yes  + 1})
    assert_equal (score + 10), r.frontend_user(true).score
    
    # review destroy (-10)
    r.destroy
    assert_equal (score + 10 - 100), r.frontend_user(true).score
  end
  
#  def test_calculate_aggregated_rating
#    Review.delete_all
#    ReviewComment.delete_all
#    ReviewRating.delete_all
#    
#    p = FactoryGirl.create(:product)
#    r = FactoryGirl.create(:complete_review, {
#      :destination => p, 
#      :frontend_user => FactoryGirl.create(:frontend_user)
#    })
#    assert r.aggregated_rating.blank?
#    
#    rating_values = [0.8, 1.0, 1.0, 0.8, 1.0, 1.0, 0.8, 0.8, 1.0, 0.8, 1.0, 0.8, 1.0, 1.0]
#    rating_values.each do |value|
#      frontend_user = FactoryGirl.create(:new_frontend_user)
#      review_comment = FactoryGirl.create(:review_comment, {
#        :review => r, 
#        :frontend_user => frontend_user
#      })
#      FactoryGirl.create(:review_rating, {
#        :review => r, 
#        :review_comment => review_comment,
#        :value => value,
#        :frontend_user => frontend_user
#      })
#      review_comment.publish!
#    end
#    
#    r.reload
#    assert_equal 1.0, r.review_rating
#    assert_equal 0.914, r.aggregated_rating
#  end
	
  private

  def valid_attributes(add_attributes={})
    {
      :destination   => @l1,
      :frontend_user => @fu1,
      :value         => 0.2,
      :text          => 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit ametbr br Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.',
      :general_terms_and_conditions => true
    }.merge(add_attributes)
  end
	
  def check_sending_a_reminder_email(user, item_name, confirmation_reminders_sent)
    assert_equal confirmation_reminders_sent, ActionMailer::Base.deliveries.length
    tmail = ActionMailer::Base.deliveries[confirmation_reminders_sent - 1]
    assert tmail.to.include?(user.email)
    #assert_equal 'text/plain; charset=UTF-8', tmail.content_type
    assert_equal 'text/plain', tmail.content_type
    assert_equal I18n.translate('mailers.frontend.review_mailer.confirmation_reminder.subject', {
        :item_name => item_name
      }), tmail.subject
  end
end
