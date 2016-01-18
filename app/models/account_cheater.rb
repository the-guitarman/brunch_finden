# notifications are registered from user_sessions_controller#create

class AccountCheater < ActiveRecord::Base
  belongs_to :frontend_user

  # the core method for adding stuff!
  # parameters:
  #   :user => a valid frontend-user object
  #   :request => the rails request object, which includes the remote_ip and env-hash
  #   :old_user_id => the id of the last logged_in user
  # simple as pie. everything else will be managed internal.
  def self.add_switch(user, request, old_frontend_user_id)
    # get the correct ac-objects
    if ac_old = AccountCheater.get_or_create_by_frontend_user_id(old_frontend_user_id.to_i, request)
      ac_old.add_other(user.id) unless ac_old.has_other?(user.id)
      ac_old.switches += 1
      ac_old.save
    end
  end

  def self.current_cheaters
    AccountCheater.where({:ignored => false, :killed => false})
  end

  def self.ignored_cheaters
    AccountCheater.where({:ignored => true, :killed => false})
  end

  def self.killed_cheaters
    AccountCheater.where({:killed => true})
  end

  # just a little helper method to hide the create_or_find_if_exist stuff
  def self.get_or_create_by_frontend_user_id(frontend_user_id, request)
    unless ac = AccountCheater.find_by_frontend_user_id(frontend_user_id)
      if fu = FrontendUser.find_by_id(frontend_user_id)
        ac = AccountCheater.new
        ac.frontend_user = fu
        ac.client_ip = request.remote_ip.to_s
        ac.client_agent = request.env["HTTP_USER_AGENT"].to_s
      end
    end
    ac
  end

  def has_other? fu_id 
    self.other_users.split("|").include?(fu_id.to_s)
  end

  # helper for updating the "other_users" attribute
  def add_other fu_id
    self.other_users.split("|").push(fu_id.to_s).uniq.join("|")
  end

  def find_cheating_values
    # query for the number of reviews which are written by this AccountCheater and rated by the other_users in the watchlist
    self.other_users.split("|").map(&:to_i).inject({}) do |ou_hash, ou_id|
      ou_hash[ou_id] = Review.
        where({:frontend_user_id => self.frontend_user_id}).
        joins(:review_ratings).where({:review_ratings => {:frontend_user_id => ou_id}}).
        count
      ou_hash #accumulator
    end
  end

  # if cheating_values-hash given, use it. way faster than collect the data again from database!
  def cheating_ratio_total(hsh = nil)
    vals = hsh ? hsh : self.find_cheating_values
    sum = self.frontend_user.reviews.size
    vals_sum = vals.inject(0){|acc, (user_id, cheated_reviews)| acc + cheated_reviews}
    others = self.other_users.split("|").size
    others = 1 if others < 1 # sanitize: division by zero ;)
    sum = 1 if sum < 1 # sanitize: division by zero ;)
    (vals_sum.to_f / others) / sum
  end

  def cheating_ratio_highest(hsh = nil)
    vals = hsh ? hsh : self.find_cheating_values
    sum = self.frontend_user.reviews.size
    sum = 1 if sum < 1 # sanitize: division by zero ;)
    vals.values.max.to_f / sum
  end

  # Do not cheat on us. 
  def kill
    self.update_attribute :killed, true
    self.update_attribute :ignored, false
    self.frontend_user.update_attribute :is_account_cheater, true
  end

  # Okay, seems legit. Go on. Sorry if we'd hurt you. 
  def ignore
    self.update_attribute :killed, false
    self.update_attribute :ignored, true
    self.frontend_user.update_attribute :is_account_cheater, false
  end

  # Oh, wrong target. But we'll keep watching you. 
  def revitalize
    self.update_attribute :killed, false
    self.update_attribute :ignored, false
    self.frontend_user.update_attribute :is_account_cheater, false
  end
  alias :observe :revitalize # logical better if used from ignored -> observed
end
