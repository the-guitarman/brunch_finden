class ExtJsonSerializer < ActiveRecord::Serialization::Serializer
  #serialize an ActiveRecord Model to an JSON stream with
  #specialized keys in form of: classname__objId__fieldname or
  #classname__fieldname, if :format=>:simple as option is given,
  #instead of only field name.
  #If you want the old behavior you can give 
  #:format=>:plain to the option set for the initializer.
  def serialize 
    extify_record={}
    #p "O:#{options.inspect}"
    #get attributes:
    serializable_names.each do |name|       
      extify_record[ExtJson::ext_name(@record,name,@options[:format])]=@record.send(name)      
    end
    #get included associations:
    if options[:include] 
      @options[:format]==:plain ? assoc_format=:plain : assoc_format=:simple
      options[:include].each do |incl|
        extify_record[ExtJson::ext_name(@record,incl,assoc_format)]={}
      end if options[:include].is_a?(Enumerable)
      add_includes do |association, records, opts|
        if records.is_a?(Enumerable)
          #another hack for ExtJS, because Ext don't like arrays in json:
          records_hash={}
          records.each_with_index do |r,index|
            records_hash["i"+index.to_s]=self.class.new(r, opts).serialize
          end
          extify_record[ExtJson::ext_name(@record,association,assoc_format)] =
            records_hash
        else
          extify_record[ExtJson::ext_name(@record,association,assoc_format)] =
            self.class.new(records, opts).serialize
        end
      end
    end
    
    #added for shiny accepts_nested_attributes_for posibilities
    if options[:nested_include]
      name_prefix=""
      @options[:format]==:plain ? assoc_format=:plain : assoc_format=:simple
      options[:nested_include].to_a.each do |nested|
        name_prefix=ExtJson::ext_name(@record,nested,assoc_format)+"_attributes"
        options[:include]=nested
        #p "O:#{options.inspect}"
        @options[:format]=:plain
        add_includes do |association, records, opts|
          if records.is_a?(Enumerable)
            records_hash={}
            records.each_with_index do |r,index|
              records_hash["i"+index.to_s]=self.class.new(r, opts).serialize
            end
            records_hash.each_with_index do |nested_attr,nested_idx|
              extify_record[name_prefix+"__"+nested_idx]=  nested_attr
            end
          else
            records.attributes.each do |attr|
              extify_record[name_prefix+'__'+attr[0]] = attr[1]
            end
          end
        end
      end
    end
    extify_record
  end
end

module ExtJson
  
  def self.ext_name(record,name,format=nil)
    # for error messages in accepts_nested_attributes_for
    name=name.gsub(".","_attributes__") if name.respond_to?(:gsub)
    case format
    when :plain
      "#{name}"
    when :simple
      "#{useable_class_name(record).sub('/','___')}__#{name}"
    when :simple_without_moduls
      "#{useable_class_name(record).split('/').last}__#{name}"
    else #unique
      "#{useable_class_name(record).sub('/','___')}__#{record.id||0}__#{name}"
    end
  end

  def self.useable_class_name(record)
    klass=record.class
    until klass.descends_from_active_record? do
      klass=klass.superclass
    end
    return klass.to_s.underscore
  end
  
  module Model
    
    attr_writer :ext_format

    def to_ext_json_old(options = {})
      to_ext_json(options.merge({:in_array=>true}))
    end
    
    # returns an extified json string
    # see ExtJsonSerializer::serialize
    def to_ext_json(options = {})
      success = options.delete(:success)
      if errors.empty?#if success || (success.nil? && valid?)
        { :success => true,
          :data => if options.delete(:in_array)
            [ExtJsonSerializer.new(self,options).serialize]
          else
            ExtJsonSerializer.new(self,options).serialize
          end
        }.to_json(options)
      else
        error_hash = {}
        #        attributes.each do |field, value|
        #          if errors = self.errors.on(field)
        #            error_hash[ExtJson::ext_name(self,field,options[:format]||@ext_format)] =
        #              "#{errors.is_a?(Array) ? errors.first : errors}"
        #          end
        #        end
        errors.each do |attr,msg|
          error_hash[ExtJson::ext_name(self,attr,options[:format]||@ext_format)] = msg
          logger.debug "ERROR: #{attr}: #{msg}"
        end
        json={ :success => false, :errors => error_hash }.to_json(options)
        logger.debug "JSON:#{json}"
        return json
      end
    end
  end

  
  module Controller
    #Decodes params[] Hash with extified class__something keys
    #to useful object Hashes for Rails.
    #Sets ext_format (:simple|:unique) in Hash, as well.
    #ex.
    # - module___object__id__field
    # - product__name=test => "product"=>{"name"=>"test"}
    # - product__10__name=test => "product"=>{"10"=>{"name"=>"test"}
    def decode_ext
      streaming_hash={}
      params.each_pair do |key,value|
        unless key.split("__").last == '_destroy'
          key=key.sub('___','/')
        end
        keys=key.split("__")
        #        if not keys[1].blank? and keys[1].is_numeric? #unique format with id?
        #          streaming_hash[keys[0]]={} unless streaming_hash[keys[0]]
        #          streaming_hash[keys[0]][keys[1]]={} unless streaming_hash[keys[0]][keys[1]]
        #          streaming_hash[keys[0]][keys[1]][:ext_format]=:unique
        #          streaming_hash[keys[0]][keys[1]][keys[2]]=value
        #        else #simple format
        #          streaming_hash[keys[0]]={} unless streaming_hash[keys[0]]
        last_elem=streaming_hash
        keys.each do |k|
          last_elem[k]={} unless last_elem[k]
          last_elem[k][:ext_format]=:simple
          if k==keys[-1]
            last_elem[keys[-1]]=value
          else
            last_elem=last_elem[k]
          end
        end
        last_elem[keys[-1]]=value
      end
      logger.debug "HASH: #{streaming_hash.inspect}"
      streaming_hash
    end
  end
      
  module Array

    # returns an extified json string
    # see ExtJsonSerializer::serialize
    def to_ext_json(options = {})
      element_count = options.delete(:count) || self.length
      success = options.key?(:success) ? options.delete(:success) : true
      { :count => element_count, :success => success, :data =>
          self.collect { |elem| ExtJsonSerializer.new(elem,options).serialize }
      }.to_json(options)
    end
    alias to_ext_json_old to_ext_json
  end
  
  module Hash
    def to_ext_json(options = {})
      to_json(options)
    end
    alias to_ext_json_old to_ext_json
  end
end

#INITIALIZE#

# Extend Classes
ActiveRecord::Base.class_eval {include ExtJson::Model}
ActionController::Base.class_eval {include ExtJson::Controller}
Array.class_eval{include ExtJson::Array}
Hash.class_eval{include ExtJson::Hash}

# Register MIME type
Mime::Type.register_alias "text/javascript", :ext_json
