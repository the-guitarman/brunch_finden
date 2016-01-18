module ActionView
  class Base
    alias_method :original_render, :render
    def render(options = {}, local_assigns = {}, &block) #:nodoc:
      remember_partial_name(options)
      original_render(options, local_assigns, &block)
    end

    private

    # Remembers the rendered partial path by instance variables,
    # they are named like the partial, that is to render now.
    # This results in a string: action_name-partial_name_1-partial_name_2
    # To prevent saving a partial name to the string chain
    # add the locals key value pair :remember_partial_name => false
    # to the locals hash. In each partial, you can call
    # <b>template_partial_path</b> to get the rendered path to it.
    def remember_partial_name(options)
      ret = ''
      if respond_to?(:controller) and controller.kind_of?(Frontend::FrontendController)
        if options.is_a?(Hash)
          unless options[:partial].blank?
            remember_partial_name = true
            unless options[:locals].blank?
              remember_partial_name = options[:locals].delete(:remember_partial_name) === false ? false : true
            end
            layout = controller.class.inheritable_attributes[:layout]
            layout = layout.split('/').last unless layout.blank?
            name = options[:partial].split('/').last.split('.').first
            current_name = @_current_render.instance_variable_get(:@name).to_s.gsub(/^_/, '')
            values = []
            if instance_variable_defined?("@tpn_#{current_name}")
              values << instance_variable_get("@tpn_#{current_name}")
              values << name if remember_partial_name
              values
            else
              values << (respond_to?(:controller_name) ? controller_name : '')
              first_name = @_first_render.instance_variable_get(:@name).to_s
              values << first_name
              if not (first_name == current_name or layout == current_name)
                values << current_name
              end
              values << name if remember_partial_name
              values
            end
            values.delete_if{|el| el.blank?}
            value = values.join('-')
            instance_variable_set("@tpn_#{name}", value)
            ret = value
          else
            values = []
            values << @_current_render.instance_variable_get(:@name).to_s.gsub(/^_/, '')
            values << (respond_to?(:controller_name) ? controller_name : '')
            values << (respond_to?(:action_name) ? action_name : '')
            values.delete_if{|el| el.blank?}
            ret = value = values.join('-')
          end
          options[:locals] ||= {}
          options[:locals].merge!({:template_partial_path => value})
        end
      end
      return ret
    rescue => e
      Rails.logger.error(e.message + "\n" + e.backtrace.join("\n") + "\n")
    end
  end

  module Helpers
    module FormHelper
      # Extends the text field helper method to include the
      # maxlength option to each text field, that belongs
      # to a string column in the underlying table.
      alias_method :text_field_original, :text_field
      def text_field(object_name, method, options = {})
        options = options.symbolize_keys
        if not options.has_key?(:maxlength) and
           not options[:object].blank?
          # There's no special maxlength given by the developer. So set it
          # from database field length, if its type is string.
          maxlength = get_text_field_maxlength(options[:object], method)
          if maxlength and maxlength > 0
            options.merge!({:maxlength => maxlength})
            unless options.key?(:size)
              # There's no special size given by the developer. So set the
              # default size, otherwise it would be set to the maxlength. 
              options[:size] = InstanceTag::DEFAULT_FIELD_OPTIONS['size']
            end
          end
        end
        text_field_original(object_name, method, options)
      end

      private

      # Returns the column limit (length), of an object attribute.
      def get_text_field_maxlength(object, attribute_name)
        ret = nil
        unless object.blank?
          klass = object.class
          if ActiveRecord::Base.check_for_model_class?(klass) and klass.table_exists?
            connection = ActiveRecord::Base.connection
            column = connection.columns(klass.table_name.to_sym).find do |c|
              c.name == "#{attribute_name}"
            end
            if column  and column.type == :string and
               column.limit.to_s.is_numeric?({:decimals => false})
              ret = column.limit.to_i
            end
          end
        end
        return ret
      end
    end

    module TranslationHelper
      # raw all translations
      alias :original_translate :translate
      def translate(key, options = {})
        raw(original_translate(key, options))
      end

      # raw all translations
      alias :original_t :t
      def t(key, options = {})
        raw(original_t(key, options))
      end
    end
  end
end