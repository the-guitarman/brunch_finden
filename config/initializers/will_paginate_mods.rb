require 'will_paginate'
require 'will_paginate/array'

module WillPaginate
  class LinkRenderer
    protected

    def page_link(page, text, attributes = {})
      if page == 1
        page = nil
        params = {:controller => @template.controller_name, :action => @template.action_name}
        params.merge!(@template.params)
        params.symbolize_keys!
        params.merge!(@template.params.symbolize_keys)
        params[param_name.to_sym] = nil
        @template.link_to text, @template.url_for(params), attributes
      else
        @template.link_to text, url_for(page), attributes
      end
    end
  end
  
  module ViewHelpers    
    @@pagination_options = {
      :class          => 'pagination',
      :previous_label => I18n.t('shared.pagination.previous_label'),
      :next_label     => I18n.t('shared.pagination.next_label'),
      :inner_window   => 4, # links around the current page
      :outer_window   => 1, # links around beginning and end
      :separator      => ' ', # single space is friendly to spiders and non-graphic browsers
      :param_name     => :page,
      :params         => nil,
      :renderer       => 'WillPaginate::LinkRenderer',
      :page_links     => true,
      :container      => true
    }

#    def page_entries_info(collection)
#      out='<div class="page_entry_info">'
#      if collection.total_pages < 2
#        out << I18n.t('shared.pagination.entries', :count => collection.size)
##        case collection.size
##        when 0; out << I18n.t('shared.pagination.no_entries_found')
##        when 1; out << '<b>1</b> entry'
##        else;   out << "<b>all #{collection.size}</b> entries"
##        end
#      else
#        out<<%{<b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b>} % [
#          collection.offset + 1,
#          collection.offset + collection.length,
#          collection.total_entries
#        ]
#      end
#      out<<"</div>"
#    end
  end
end

# Array extension to use an array with the will_paginate view helper method.
# * Usage:
# ** in the controller action:
#    my_array.paginate!({:page => 2, :per_page => 10, :total_entries => 20})
#    NOTE: This example requires that 'my_array' holds the objects of page 2 ONLY, 
#          because you used offset and limit methods to ask your database and 
#          receive your results. May be you have the results of more than one page, 
#          than you have to use Array#paginate instead. This method adds the methods
#          which are used within the will_paginate view helper to the array only.
# ** in the view:
#    <%= will_paginate(my_array) -%>
class Array
  def paginate!(options = {})
    current_page  = options[:page] || 1
    per_page      = options[:per_page] || WillPaginate.per_page
    total_entries = options[:total_entries] || self.length
    
    total_pages = (total_entries / per_page.to_f).ceil
    previous_page = current_page > 1 ? (current_page - 1) : nil
    next_page = current_page < total_pages ? (current_page + 1) : nil
    offset = (current_page - 1) * per_page
    
    eval(
      "def self.current_page; #{current_page}; end; " +
      "def self.per_page; #{per_page}; end; " +
      "def self.total_entries; #{total_entries}; end; " +
      "def self.total_pages; #{total_pages}; end; " +
      "def self.previous_page; #{previous_page}; end; " +
      "def self.next_page; #{next_page}; end; " +
      "def self.offset; #{offset}; end"
    )
  end
end