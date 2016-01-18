

require "xml"

class LibXML::XML::Node

  #Return value on descriptors position.
  ##Descriptor is an String representing a Node or an Array with two String entries,
  #where the first is the Node and the second the attribute.
  def find_first_value(descriptor)
    node=find_first(descriptor.to_a[0])
    if node.blank?
      return nil
    else
      if descriptor.is_a? Array and (not descriptor[1].empty?)
        return node[descriptor[1]]
      else
        return node.content
      end
    end
  end

  #Return values matching on descriptor.
  #Descriptor is described on find_first_value()
  def find_values(descriptor)
    nodes=find(descriptor.to_a[0])
    if nodes.blank?
      return nil
    else
      found_nodes=[]
      nodes.each do |node|
        if descriptor.is_a? Array and (not descriptor[1].empty?)
          found_nodes.push node[descriptor[1]]
        else
          found_nodes.push node.content
        end
      end
      return found_nodes
    end
  end
end

class XMLParser

  # Initialize the parser with #yml_config.
  # The config describes witch data should be returned from the xml file.
  def initialize(yml_config)
    @node_count=0
    load_config(yml_config)
  end

  # See initialize / new
  def load_config(yml_config)
    if yml_config.is_a? String
      @config_file_name=yml_config
      print "CONFIG  : #{@config_file_name}\n"
      File.open(yml_config) do |f|
        @config=YAML::load(f)
      end
    elsif yml_config.is_a? Hash
      @config=yml_config
    else
      raise "No config given. I will cry and die!"
    end
    #    p "E_ID: "+@config['meta']['entity_identifier']
  end

  #Set the xml data source from the config if #xml_file is not given
  def treat_xml_source(xml_file=nil)
    xml_file=@config['meta']['uri'] if xml_file.blank?
    raise "No xml file given" if xml_file.blank?
    xml_file
  end

  # Starts the parse process on #xml_file.
  # Yields a block every parsed entity_node.
  def start(xml_file=nil)
    @input_file_name=treat_xml_source(xml_file)
    print "INPUT   : #{@input_file_name}\n"
    @xml_reader=XML::Reader.file(@input_file_name)
    while @xml_reader.read
      with_proper_xml_node do |node|
        properties_hash=Hash.new
        @config['xml'].each_pair do |key,prop|
          found_nodes = node.find(prop['read'].to_a[0])          
          properties_hash[key]=evaluate_nodes_with_conf(found_nodes, prop)
        end
#        print_results(properties_hash)
        yield properties_hash
        properties_hash=nil
        found_nodes=nil
        node=nil
        if (@node_count % 1)==0
          GC.start
        end
      end
    end
  end

  # Uses YML config to determine if a read node should be considered as a result.
  def evaluate_nodes_with_conf(nodes,conf_props)
    if conf_props['if']
      value=nil
      nodes.each do |n|
        if_path=conf_props['if']['path']
        if_value=n.find_first_value(if_path)
        if if_value==conf_props['if']['value']
          value=grep_value(n,conf_props['read']) || conf_props['if']['set']
        else
          value=conf_props['if']['set'] if conf_props['if']['set']
        end
      end
    else
      value=grep_value(nodes[0],conf_props['read'])
    end
    value
  end

  # Search #what in #from, doesn't matter if it is a attribute value or
  # content of a node.
  def grep_value(from,what)
    if value=from
      if what.is_a?(Array)
        value=value[what[1]]
      else
        value=value.content
      end
    end
  end


  # Checks whether last read xml node is a usable node.
  def with_proper_xml_node
    if @xml_reader.node and @xml_reader.node.name == @config['meta']['entity_node'] and
        @xml_reader.node_type == XML::Reader::TYPE_ELEMENT
      @node_count+=1
      node=@xml_reader.expand
      if node
#        p "FOUND E_ID : "+@xml_reader.node.name
        yield node
      end
    else
      #      p "NO E_ID: "+@xml_reader.node.name
    end
  end

  def print_results(results)
    print "RESULTS : \n"
    results.each_pair { |key,value|
      print " -- #{key} : #{value} \n" unless value.blank?
    }

  end

  def self.rearrange_parser_result_hash(parser_result_hash)
    retval={}
    parser_result_hash.each do |key, value|
      keys = key.split('__');
      last_elem=retval
      keys.each do |k|
        last_elem[k]={} unless last_elem[k]
        if k==keys[-1]
          last_elem[keys[-1]]=value
        else
          last_elem=last_elem[k]
        end
      end
      last_elem[keys[-1]]=value
    end
    retval
  end

end
