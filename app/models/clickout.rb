class Clickout < ActiveRecord::Base

  # URL_PARAMETERS hash includes the translation of all field names, 
  # they could be tracked, to url parameter names.
  # IMPORTANT: Reserved parameter names are (don't use it in this hash):
  # - :m  # => model class name of the exit link object
  # - :id # => exit link object id
  # - :c  # => object attribute or method name to call for the exit link
  # - :el  # => exit link for customer clicks f.e. ebay api
  # At first, this hash is used with the get_byebye_url helper method to translate
  # the given field names in their url parameter names.
  # At least, the hash is used to translate given url parameters back in their
  # field names to track the received data in the exit controller.
  URL_PARAMETERS = {
    :template => :a,
    :position => :b,
    # (see text above) => :c,
    :platform => :d
    # (see text above) => :id,
    # (see text above) => :m,
    # (see text above) => :el
  }

  DEFAULT_VALUES = {
    :platform => CustomConfigHandler.instance.frontend_config['DOMAIN']['FULL_NAME']
  }

  DO_NOT_TRACK = {
    :user_agents => BackgroundConfigHandler.instance.model_config['CLICKOUT']['DO_NOT_TRACK']['USER_AGENTS'].join('|'),
    :ips         => BackgroundConfigHandler.instance.model_config['CLICKOUT']['DO_NOT_TRACK']['IPS']
  }

  belongs_to :destination, :polymorphic => true

  validates_presence_of :destination_type
  validates_presence_of :destination_id

  #disable update and destroy, should make some exceptions...
  before_update :not_update_not_destroy
  before_destroy :not_update_not_destroy

  def date
    self.created_at.strftime('%d.%m.%y')
  end
  
  private
  
  def not_update_not_destroy
    false
  end
end
