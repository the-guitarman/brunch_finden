class SearchSuggestion < ActiveRecord::Base
  #include Mixins::HasDeltaGuard
  #switch_delta_only_for(:phrase)
  
  has_one :destination, :as => :suggestible
  
  validates_presence_of :destination_id, :destination_type, :phrase, :weight
  validates_inclusion_of :state, :in => [:new, :active]
  
#  define_index do
#    indexes phrase
#    
#    has weight
#
#    set_property :min_infix_len => 3
#    set_property :min_prefix_len => 3
#    set_property :enable_star => true
#    set_property :delta => true
#  end
end