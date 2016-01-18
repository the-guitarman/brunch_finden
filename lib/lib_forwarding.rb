module LibForwarding
  def self.included(klass)
    klass.instance_eval do
      #extend ClassMethods
      include InstanceMethods
    end
  end
  
  module InstanceMethods
    def forwarding_needed?(object, attr)
      ret = false
      attr = attr.to_s
      changes = object.changes
      if not attr.blank? and not changes.empty?
        if changes.include?(attr)
          if (changes[attr][0] and changes[attr][1])
            ret = true
          end
        end
      end
      return ret
    end

    def create_forwarding(source_path, destination_path)
      destroy_forwarding(destination_path)
      Forwarding.create({:source_url => source_path, :destination_url => destination_path})
    end

    def destroy_forwarding(source_path)
      # destroy all forwardings from this rewrite without to update each before
      Forwarding.update_last_use_at_on_find_enabled = false
      Forwarding.destroy_all({:source_url => source_path})
      Forwarding.update_last_use_at_on_find_enabled = true
    end
  end
end