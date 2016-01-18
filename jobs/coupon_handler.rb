require 'uri_fetcher'
require 'nokogiri'
require 'jobs/job_config_handler'
require 'jobs/sitemap'
require 'jobs/robots_txt_generator'

class CouponHandler
  include Singleton
  include JobConfigHandler
  
  def initialize
    @config_handler = BackgroundConfigHandler.instance
    @config_handler_method = :coupon_handler_config
    
    @uri = 'http://www.abcdefg.de/xmlrpc/get1.06.php?uid=brunch'
    @dest_xml_file = "#{Rails.root}/tmp/feeds/coupon/detailed_coupons4u_de.xml"
    @tmp_xml_file = "#{Rails.root}/tmp/feeds/coupon/detailed_coupons4u_de_tmp.xml"
    @detailed_xml_format = :coupons4u_de_xml_format_detailed
  end

  def run
    ret = false
    if ret = CouponFetcher.new(@dest_xml_file, @tmp_xml_file, @uri).run
      if ret = CouponParser.new(@dest_xml_file, @detailed_xml_format).run
        CouponHandlerTriggeredSweeper.instance.run
        ProjectSitemap.new.run
        RobotsTxtGenerator.new.run
      end
      File.delete(@dest_xml_file) if File.exist?(@dest_xml_file)
      File.delete(@tmp_xml_file) if File.exist?(@tmp_xml_file)
    end
    reset_config
    return ret
  rescue Exception => e
    exception_thrown(e)
    return false
  end
end

class CouponFetcher < URIFetcher
  include JobConfigHandler
  
  def initialize(dest_file, tmp_file, uri)
    @config_handler = BackgroundConfigHandler.instance
    @config_handler_method = :coupon_fetcher_config
    
    @uri = URI.parse(uri.strip)
    @dest_file_name = dest_file
    @temp_file_name = tmp_file
  end
  
  def run
    download
    unzip
    reset_config
    return true
  rescue Exception => e
    exception_thrown(e)
    return false
  end
end

class CouponParser
  include JobConfigHandler
  
  def initialize(xml_file_name, xml_format)
    @config_handler = BackgroundConfigHandler.instance
    @config_handler_method = :coupon_parser_config
    
    if xml_format.is_a?(String)
      if File.exist?(xml_format)
        begin
          @xml_format = YAML::load(File.open(xml_format))
        rescue
          raise FormatError, "Wrong XML coupon format given."
        end
      else
        raise ArgumentError, "XML coupon format file (#{xml_format}) not found."
      end
    elsif xml_format.is_a?(Symbol)
      begin
        @xml_format = eval("@config_handler.#{xml_format}(true)")
      rescue
        raise ArgumentError, "Background config handler method (#{xml_format}) not found, so I have no XML format."
      end
    else
      @xml_format = xml_format
    end
    @xml_file_name = xml_file_name
    @status = 'COUPON PARSER\n'
    @found_object_ids = {}
    if Rails::VERSION::MAJOR >= 3
      @batch_size = 1000
    else
      @batch_size = GLOBAL_CONFIG[:find_each_batch_size] || 10
    end
    @last_object = ''
  end
  
  def run
    doc = Nokogiri::XML(File.open(@xml_file_name))
    
    # read meta data
    meta = (@xml_format['meta'] || {}).deep_symbolize_keys
    if meta.empty?
      raise FormatError, "Wrong XML coupon format given. Meta format not found."
    end
    read_meta_node(doc, meta, :type)
#    node = doc.at_xpath("#{meta['date']['read']}")
#    node = doc.at_xpath("#{meta['time']['read']}")
#    node = doc.at_xpath("#{meta['count']['read']}")
#    node = doc.at_xpath("#{meta['your_ip']['read']}")
#    node = doc.at_xpath("#{meta['your_uid']['read']}")
    
    # read coupons
    objects = (@xml_format['objects'] || {}).deep_symbolize_keys
    if objects.empty?
      raise FormatError, "Wrong XML coupon format given. Object structure not found."
    end
    format  = (@xml_format['format'] || {}).deep_symbolize_keys
    if format.empty?
      raise FormatError, "Wrong XML coupon format given. Object formats not found."
    end
    skip    = (@xml_format['skip'] || {}).deep_symbolize_keys
    
    ThinkingSphinx.updates_enabled = false
    parse(doc, objects, format, skip)
    
    # There's a management decision to keep old (untouched) coupons.
    #delete_untouched_objects
    # In case of keeping old (untouched) coupons, 
    # their matches should be deleted.
    delete_matches_of_untouched_coupons
    
    update_coupon_category_statistics
    update_coupon_merchant_statistics
    ThinkingSphinx.updates_enabled = true
    #Coupon.reindex
    
    reset_config
    return true
  rescue Exception => e
    exception_thrown(e, @last_object)
    return false
  end
  
  private
  
  def create_or_update_object(model_name, attributes, skip_attributes, parent_object, values)
    @last_object += "----------------------------- 3 model_name: #{model_name}\n"
    ret = nil
    if skip_attributes and not skip_attributes.empty?
      # If an attribute has a value which is defined in the skip_attributes hash, 
      # then return nil and do not create or remember to this object.
      skip_attributes.each do |attribute, skip_values|
        unless skip_values.all?{|sv| sv.is_a?(Hash) and sv.key?('value')}
          raise "Skip value invalid for 'Coupon##{attribute}'. Hash expected. Example: ({'value' => 5, 'description' => 'merchant id'}"
        end
        vals = skip_values.map{|sv| sv['value']}
        if vals.include?(attributes[attribute])
          @last_object += "----------------------------- skip, because: #{vals.inspect}.include?(#{attributes[attribute].inspect})"
          return ret
        end
      end
    end
    if model_class = model_name.to_s.camelize.constantize
      found_object = nil
      conditions = {}
      if values[:find_by]
        conditions[values[:find_by]] = attributes[values[:find_by].to_sym]
        @last_object += "----------------------------- 4 conditions: #{conditions.inspect}\n"
        # Rails 3
        #found_object = model_class.where(conditions).first
        # Rails 2
        found_object = model_class.find(:first, :conditions => conditions)
        @last_object += "----------------------------- 5 found_object: #{found_object.inspect}\n"
      end
      
      @last_object += "----------------------------- 6 attributes: #{attributes.inspect}\n"
      
      # create or update the current object
      if found_object
        found_object.update_attributes(attributes)
        ret = found_object
      else
        @last_object += "----------------------------- 7 create object\n"
        ret = model_class.create(attributes)
      end
      
      if ret and not ret.new_record?
        remember_found_object_id(ret)
      end
      
      # set object relations/associations
      if parent_object and ret and not ret.new_record?
        if values[:has_and_belongs_to_many]
          eval("parent_object.#{values[:has_and_belongs_to_many]} << ret unless parent_object.#{values[:has_and_belongs_to_many]}.include?(ret)")
          @last_object += "----------------------------- 8 has_and_belongs_to_many: #{values[:has_and_belongs_to_many]}\n"
        elsif values[:has_many]
          eval("parent_object.#{values[:has_many]} << ret unless parent_object.#{values[:has_many]}.include?(ret)")
          @last_object += "----------------------------- 8 has_many: #{values[:has_many]}\n"
        elsif values[:has_one]
          eval("parent_object.#{values[:has_one]} = ret")
          @last_object += "----------------------------- 8 has_one: #{values[:has_one]}\n"
        elsif values[:belongs_to]
          raise 'Found object belongs to is not implemented at the moment.'
        end
      end
    end
    return ret
  end
  
  def delete_untouched_objects
    @found_object_ids.keys.each do |model_name|
      table_name = model_name.pluralize.underscore
      @status += "\n\nDeleting #{table_name.gsub('_', ' ')} they have been untouched ..."
      counter = 0
      unless @found_object_ids[model_name].empty?
        @found_object_ids[model_name].uniq!
        conditions = "#{table_name}.id NOT IN (#{@found_object_ids[model_name].join(',')})"
        model_class = model_name.constantize
        model_class.find_each(:conditions => conditions, :batch_size => @batch_size) do |object|
          object.destroy
          counter += 1
          @status += '.'
        end
      end
      @status += " done! (deleted: #{counter})\n"
    end
    @status += "\n\n"
  end
  
  def delete_matches_of_untouched_coupons
    @found_object_ids.keys.each do |model_name|
      model_class = model_name.constantize
      if model_class.reflect_on_association(:coupon_matches)
        table_name = model_name.pluralize.underscore
        @status += "\n\nDeleting matches for #{table_name.gsub('_', ' ')} they have been untouched ..."
        counter = 0
        @found_object_ids[model_name].uniq!
        @found_object_ids[model_name].delete_if{|id| id.blank?}
        unless @found_object_ids[model_name].empty?
          conditions = "#{table_name}.id NOT IN (#{@found_object_ids[model_name].join(',')})"
          model_class.find_each(:conditions => conditions, :batch_size => @batch_size) do |object|
            object.coupon_matches.destroy_all
            object.update_attributes({:not_to_match => false}) if object.not_to_match
            counter += 1
            @status += '.'
          end
        end
        @status += " done! (deleted: #{counter})\n"
      end
    end
    @status += "\n\n"
  end
  
  def parse(doc, objects, format, skip)
    objects.each do |model_name,values|
      read_objects(doc, model_name, values, values[:read], format, skip, nil)
    end
  end
  
  def read_objects(doc, model_name, values, read, format, skip, parent_object)
    @last_object = "----------------------------- 1 model     : #{model_name}\n"
    #nodes = doc.at_xpath(read)
    nodes = doc.xpath(read)
    if not nodes.blank? and not nodes.children.empty?
      nodes.children.each do |node|
        unless node.blank?
          attributes = read_attributes(node, format[model_name.to_sym])
          @last_object += "----------------------------- 2 attributes: #{attributes.inspect}\n"
          if object = create_or_update_object(model_name, attributes, skip[model_name], parent_object, values)
            if values[:objects]
              values[:objects].each do |sub_model_name,sub_values|              
                sub_read = sub_values[:read].split('/')
                sub_read.shift
                sub_read = sub_read.join('/')
                read_objects(node, sub_model_name, sub_values, sub_read, format, skip, object)
              end
            end
          end
        end
      end
    end
  end
  
  def read_attributes(doc, format)
    attributes = {}
    format.each do |attr, values|
      if not values[:read].blank?
        read = values[:read]
        unless read.end_with?('?')
          read = read.split('/')
          read.shift
          node = doc.at_xpath(read.join('/'))
        else
          node = doc
        end
        if not node.blank? and not node.text.blank?
          attributes[attr] = node.text.to_s.strip
        end
      elsif not values[:association].blank?
        association = values[:association].split(/#|=/)
        if model_name = association.first
          klass = model_name.camelize.constantize
          attribute = association[1]
          value = association.last
          conditions = {}
          conditions[attribute] = value
          if el = klass.find(:first, :conditions => conditions)
            attributes[attr] = el.id
          elsif el = klass.create(conditions)
            attributes[attr] = el.id
          end
        end
      end
    end
    return attributes
  end
  
  def read_meta_node(doc, meta_format, type)
    node = doc.at_xpath("#{meta_format[type][:read]}")
    text = node.text
    status("#{type}: #{text}")
    if type == :type
      unless text == 'data' #['list','detailed'].include?(text)
        raise I18n.t("config.background.coupon_handler.answer_types.#{text}") + " (#{type}: #{text})"
      end
    end
  end
  
  def remember_found_object_id(object)
    model_name = object.class.name.to_s
    @found_object_ids[model_name] = [] unless @found_object_ids.key?(model_name)
    @found_object_ids[model_name] << object.id unless object.id.blank?
  end
  
  def status(msg, space = true)
    @status += space == true ? '  ' : ''
    @status += "#{msg}\n"
  end
  
  def update_coupon_category_statistics
    @status += "\n\nUpdating coupon category statistics ..."
    CouponCategory.update_statistics
    @status += " done!\n\n\n"
  end
  
  def update_coupon_merchant_statistics
    @status += "\n\nUpdating coupon merchant statistics ..."
    CouponMerchant.update_statistics
    @status += " done!\n\n\n"
  end
end
