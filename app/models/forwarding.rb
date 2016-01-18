class Forwarding < ActiveRecord::Base

  @@update_last_use_at_on_find_enabled = true

  # VALIDATIONS ----------------------------------------------------------------

  validates_presence_of :source_url, :destination_url
  validates_uniqueness_of :source_url

  # CALLBACKS ------------------------------------------------------------------

  def before_create
    self.last_use_at = Time.now
  end

  def before_save
    # Update source_url to destination_url example:
    # Computer category/product/... forwards to Hardware.
    # - Computer => Hardware
    # Hardware will be deleted und forwarded to Electronics.
    # - Hardware => Electronics
    # Former forwardings to Hardware have to be updated to Electronics too.
    # - so update: Comuter => Electronics
    self.class.update_all(
      "destination_url = '#{self.destination_url}'",  # update
      "destination_url = '#{self.source_url}'"        # conditions
    )
  end

  # PUBLIC METHODS -------------------------------------------------------------

  def validate
    if self.source_url == self.destination_url
      self.errors.add(:source_url, "can't be equal to the destination url. ")
      self.errors.add(:destination_url, "can't be equal to the source url. ")
    end
  end

  # CLASS METHODS --------------------------------------------------------------

  # Extends Forwarding.find, so that all Forwardings found by
  # a given source_url (this should be one in each case only), will be
  # updated with last_use_at = Time.now.
  def self.find(*args)
    result = super

    if @@update_last_use_at_on_find_enabled
      unless result.blank?
        # url forwarding(s) found
        options = args.extract_options!
        # Are there find conditions given ...
        unless options[:conditions].blank?
          # ... and the field 'source_url' is in the conditions?
          sql = self.sanitize_sql(options[:conditions])
          unless sql.index('source_url').blank?

            # update last_use_at to Time.now
            # for all url forwarding(s), they are contained in the result
            case result.class.name
            when "Array"
              result.each do |url_forwarding|
                url_forwarding.update_attributes({:last_use_at => Time.now})
              end
            when name
              result.update_attributes({:last_use_at => Time.now})
            end
          end
        end
      end
    end

    return result
  end

  # Returns @@update_last_use_at_on_find_enabled
  def self.update_last_use_at_on_find_enabled
    @@update_last_use_at_on_find_enabled
  end

  # Note: If you set this to false, a url forwarding will not update its
  # attribute last_use_at, if it's found by Forwarding.find.
  def self.update_last_use_at_on_find_enabled=(true_or_false)
    @@update_last_use_at_on_find_enabled = true_or_false
  end

  # Cleans up not used url forwardings (default is older than one year).
  def self.cleaner(options={})
    show_messages = options[:show_messages].nil? ? true : options[:show_messages]
    last_use_before = options[:last_use_before].nil? ? (Time.now - 1.year) : options[:last_use_before]
    if show_messages
      puts; print "Clean up forwardings before #{last_use_before.strftime('%d.%m.%Y')} ..."
      count = 0
    end
    count = self.delete_all(["last_use_at < ?", last_use_before])
    if show_messages
      puts "done! (deleted #{count})"
      nil
    end
  end

  # PRIVATE METHODS ------------------------------------------------------------

  private

  
end